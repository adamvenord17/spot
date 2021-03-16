import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot/cubits/video/video_cubit.dart';
import 'package:video_player/video_player.dart';

import '../components/app_scaffold.dart';

class ViewVideoPage extends StatelessWidget {
  static Route<void> route(String videoId) {
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => VideoCubit()..initialize(videoId),
        child: ViewVideoPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: BlocBuilder<VideoCubit, VideoState>(
        builder: (context, state) {
          if (state is VideoInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VideoPlaying) {
            final controller = state.videoPlayerController;
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        height: 1,
                        child: AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: VideoPlayer(controller),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 123,
                  right: 14,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      width: 36,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipOval(
                            child: Image.network(
                              'https://www.muscleandfitness.com/wp-content/uploads/2015/08/what_makes_a_man_more_manly_main0.jpg?quality=86&strip=all',
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 36),
                          IconButton(
                            icon: const Icon(Icons.comment),
                            onPressed: () {},
                          ),
                          const SizedBox(height: 36),
                          IconButton(
                            icon: const Icon(Icons.favorite),
                            onPressed: () {},
                          ),
                          const SizedBox(height: 36),
                          IconButton(
                            icon: const Icon(Icons.more_horiz),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
