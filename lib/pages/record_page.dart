import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/gradient_border.dart';
import 'package:spot/cubits/record/record_cubit.dart';

import '../components/app_scaffold.dart';
import '../cubits/record/record_cubit.dart';

class RecordPage extends StatelessWidget {
  static Route<void> route() {
    return MaterialPageRoute(
      builder: (_) => BlocProvider<RecordCubit>(
        create: (_) => RecordCubit()..initialize(),
        child: RecordPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: BlocBuilder<RecordCubit, RecordState>(
        builder: (context, state) {
          if (state is RecordInitial) {
            return preloader;
          } else if (state is RecordReady) {
            return RecordPreview(
              controller: state.controller,
              isPaused: true,
            );
          } else if (state is RecordInProgress) {
            return RecordPreview(
              controller: state.controller,
              isPaused: false,
            );
          } else if (state is RecordPaused) {
            return RecordPreview(
              controller: state.controller,
              isPaused: true,
            );
          } else if (state is RecordCompleted) {
            return RecordPreview(
              controller: state.controller,
              isPaused: true,
            );
          } else if (state is RecordError) {
            return Center(child: Text(state.errorMessage));
          }
          return Container();
        },
      ),
    );
  }
}

@visibleForTesting
class RecordPreview extends StatelessWidget {
  const RecordPreview({
    Key? key,
    required CameraController controller,
    required bool isPaused,
  })   : _controller = controller,
        _isPaused = isPaused,
        super(key: key);

  final CameraController _controller;
  final bool _isPaused;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _cameraPreview(),
        _recordButton(context),
        _gauge(context),
      ],
    );
  }

  ClipRect _cameraPreview() {
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            height: 1,
            child: AspectRatio(
              aspectRatio: 1 / _controller.value.aspectRatio,
              child: CameraPreview(_controller),
            ),
          ),
        ),
      ),
    );
  }

  Positioned _recordButton(BuildContext context) {
    return Positioned.fill(
      top: null,
      bottom: MediaQuery.of(context).padding.bottom + 24,
      child: Center(
        child: SizedBox(
          width: 70,
          height: 70,
          child: GradientBorder(
            borderRadius: 100,
            strokeWidth: 3,
            gradient: blueGradient,
            child: Material(
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              child: InkWell(
                onTap: () {
                  if (_isPaused) {
                    BlocProvider.of<RecordCubit>(context).startRecording();
                  } else {
                    BlocProvider.of<RecordCubit>(context).pauseRecording();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Center(
                    child: _RecordButtonTarget(
                      isPaused: _isPaused,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Positioned _gauge(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: GradientBorder(
              borderRadius: 50,
              strokeWidth: 1,
              gradient: const LinearGradient(
                colors: [
                  appRed,
                  appOrange,
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: _RecordingGaugeIndicator(
                  isPaused: _isPaused,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingGaugeIndicator extends StatefulWidget {
  const _RecordingGaugeIndicator({
    Key? key,
    required bool isPaused,
  })   : _isPaused = isPaused,
        super(key: key);

  final bool _isPaused;

  @override
  __RecordingGaugeIndicatorState createState() =>
      __RecordingGaugeIndicatorState();
}

class __RecordingGaugeIndicatorState extends State<_RecordingGaugeIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                appBlue,
                appLightBlue,
              ],
            ),
          ),
          child: SizedBox(height: 16),
        ),
        builder: (_, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _animationController.value,
            child: child,
          );
        });
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        BlocProvider.of<RecordCubit>(context).doneRecording();
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _RecordingGaugeIndicator oldWidget) {
    final isPausedChanged = widget._isPaused != oldWidget._isPaused;
    if (isPausedChanged) {
      if (widget._isPaused) {
        _animationController.stop();
      } else {
        _animationController.forward();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class _RecordButtonTarget extends StatefulWidget {
  const _RecordButtonTarget({
    Key? key,
    required bool isPaused,
  })   : _isRecording = isPaused,
        super(key: key);

  final bool _isRecording;

  @override
  __RecordButtonTargetState createState() => __RecordButtonTargetState();
}

class __RecordButtonTargetState extends State<_RecordButtonTarget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _curve,
        builder: (_, __) {
          return SizedBox(
            width: 50 - 20 * _curve.value,
            height: 50 - 20 * _curve.value,
            child: Ink(
              decoration: BoxDecoration(
                gradient: redOrangeGradient,
                borderRadius: BorderRadius.circular(25 - 19 * _curve.value),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
    _curve =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _RecordButtonTarget oldWidget) {
    final isRecordingChanged = widget._isRecording != oldWidget._isRecording;
    if (isRecordingChanged) {
      if (widget._isRecording) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
