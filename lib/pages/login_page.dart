import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/frosted_dialog.dart';
import 'package:spot/components/gradient_button.dart';
import 'package:spot/pages/splash_page.dart';
import 'package:spot/repositories/repository.dart';

import '../components/app_scaffold.dart';

/// Indicates which dialog is currently openeds
enum _DialogPage {
  termsOfService,
  loginOrSignup,
  login,
  signUp,
}

const _termsOfServiceAgreementKey = 'agreed';

class LoginPage extends StatefulWidget {
  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => LoginPage());
  }

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..forward();

  late final _curvedAnimation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  late final _yellowBlobAnimationController = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );

  late final _delayedCurvedAnimation = CurvedAnimation(
    parent: _yellowBlobAnimationController,
    curve: Curves.easeOutCubic,
  );

  late final _redBlobAnimationController = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );

  late final _moreDdelayedCurvedAnimation = CurvedAnimation(
    parent: _redBlobAnimationController,
    curve: Curves.easeOutCubic,
  );

  _DialogPage _currentDialogPage = _DialogPage.loginOrSignup;

  double _dialogOpacity = 1;
  static const _dialogOpacityAnimationDuration = Duration(milliseconds: 200);

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -53,
            right: -47,
            child: AnimatedBuilder(
                animation: _controller,
                child: Image.asset(
                  'assets/images/purple-fog.png',
                  height: 228,
                ),
                builder: (context, child) {
                  return Opacity(
                    opacity: _controller.value,
                    child: child,
                  );
                }),
          ),
          Positioned(
            top: 201,
            left: 0,
            child: AnimatedBuilder(
                animation: _curvedAnimation,
                child: Image.asset(
                  'assets/images/blue-ellipse.png',
                  height: 168,
                ),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(-200 + 200 * _curvedAnimation.value, 0),
                    child: child,
                  );
                }),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 37,
            child: AnimatedBuilder(
              animation: _curvedAnimation,
              child: Image.asset('assets/images/blue-blob.png'),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    200 - 200 * _curvedAnimation.value,
                    400 - 400 * _curvedAnimation.value,
                  ),
                  child: child,
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 46,
            child: AnimatedBuilder(
              animation: _delayedCurvedAnimation,
              child: Image.asset('assets/images/yellow-blob.png'),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    -300 + 300 * _delayedCurvedAnimation.value,
                    400 - 400 * _curvedAnimation.value,
                  ),
                  child: child,
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _moreDdelayedCurvedAnimation,
              child: Image.asset('assets/images/red-blob.png'),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    300 - 300 * _moreDdelayedCurvedAnimation.value,
                  ),
                  child: child,
                );
              },
            ),
          ),
          FrostedDialog(
            child: AnimatedOpacity(
              duration: _dialogOpacityAnimationDuration,
              opacity: _dialogOpacity,
              child: _isLoading
                  ? const SizedBox(
                      height: 150,
                      child: preloader,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_currentDialogPage == _DialogPage.termsOfService) ..._termsOfService(),
                        if (_currentDialogPage == _DialogPage.loginOrSignup) ..._loginOrSignup(),
                        if (_currentDialogPage == _DialogPage.login) ..._login(),
                        if (_currentDialogPage == _DialogPage.signUp) ..._signUp(),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _playDelayedAnimation();
    _checkTermsOfServiceAgreement();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _yellowBlobAnimationController.dispose();
    _redBlobAnimationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkTermsOfServiceAgreement() async {
    final agreed = await localStorage.containsKey(key: _termsOfServiceAgreementKey);
    if (!agreed) {
      setState(() {
        _currentDialogPage = _DialogPage.termsOfService;
      });
    }
  }

  List<Widget> _termsOfService() {
    return [
      SizedBox(
        height: 300,
        child: FutureBuilder(
          future: rootBundle.loadString('assets/md/terms_of_service.md'),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              final mdData = snapshot.data;
              if (mdData == null) {
                return const Center(
                  child: Text('Error loading Terms of Service'),
                );
              }
              return Markdown(data: mdData);
            }
            return preloader;
          },
        ),
      ),
      const SizedBox(height: 8),
      GradientButton(
        onPressed: () async {
          setState(() {
            _currentDialogPage = _DialogPage.loginOrSignup;
          });
          await localStorage.write(key: _termsOfServiceAgreementKey, value: 'true');
        },
        child: const Center(child: Text('Agree')),
      ),
    ];
  }

  List<Widget> _loginOrSignup() {
    return [
      const Text(
        'Would you like to...',
        style: TextStyle(fontSize: 18),
      ),
      const SizedBox(height: 24.5),
      _LoginButton(
        label: 'Sign in',
        onPressed: () {
          _fadeDialog(action: () {
            setState(() {
              _currentDialogPage = _DialogPage.login;
            });
          });
        },
      ),
      const SizedBox(height: 24.5),
      _LoginButton(
        label: 'Create an Account',
        onPressed: () {
          _fadeDialog(action: () {
            setState(() {
              _currentDialogPage = _DialogPage.signUp;
            });
          });
        },
      ),
    ];
  }

  List<Widget> _login() {
    return [
      Row(
        children: [
          IconButton(
            icon: const Icon(FeatherIcons.chevronLeft),
            onPressed: () {
              _fadeDialog(action: () {
                setState(() {
                  _currentDialogPage = _DialogPage.loginOrSignup;
                });
              });
            },
          ),
          const Text(
            'Sign in',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
      const SizedBox(height: 24.5),
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Email',
          prefixIcon: Icon(FeatherIcons.mail),
        ),
      ),
      const SizedBox(height: 24.5),
      TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Password',
          prefixIcon: Icon(FeatherIcons.lock),
        ),
      ),
      const SizedBox(height: 24.5),
      _LoginButton(
        label: 'Sign in',
        onPressed: () async {
          try {
            setState(() {
              _isLoading = true;
            });
            final res = await RepositoryProvider.of<Repository>(context)
                .supabaseClient
                .auth
                .signIn(email: _emailController.text, password: _passwordController.text);
            final data = res.data;
            final error = res.error;
            if (error != null) {
              setState(() {
                _isLoading = false;
              });
              context.showErrorSnackbar(error.message);
              return;
            }

            // Store current session
            await localStorage.write(key: persistantSessionKey, value: data!.persistSessionString);

            await Navigator.of(context).pushReplacement(SplashPage.route());
          } catch (e) {
            setState(() {
              _isLoading = false;
            });
            context.showErrorSnackbar('Error signing in');
          }
        },
      ),
    ];
  }

  List<Widget> _signUp() {
    return [
      Row(
        children: [
          IconButton(
            icon: const Icon(FeatherIcons.chevronLeft),
            onPressed: () {
              _fadeDialog(action: () {
                setState(() {
                  _currentDialogPage = _DialogPage.loginOrSignup;
                });
              });
            },
          ),
          const Text(
            'Create an Account',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
      const SizedBox(height: 24.5),
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Email',
          prefixIcon: Icon(FeatherIcons.mail),
        ),
      ),
      const SizedBox(height: 24.5),
      TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Password',
          prefixIcon: Icon(FeatherIcons.lock),
        ),
      ),
      const SizedBox(height: 24.5),
      _LoginButton(
        label: 'Sign Up',
        onPressed: () async {
          try {
            setState(() {
              _isLoading = true;
            });
            final res = await RepositoryProvider.of<Repository>(context)
                .supabaseClient
                .auth
                .signUp(_emailController.text, _passwordController.text);
            final data = res.data;
            final error = res.error;
            if (error != null) {
              setState(() {
                _isLoading = false;
              });
              context.showSnackbar(error.message);
              return;
            }

            // Store current session
            await localStorage.write(key: persistantSessionKey, value: data!.persistSessionString);

            await Navigator.of(context).pushReplacement(SplashPage.route());
          } catch (err) {
            setState(() {
              _isLoading = false;
            });
            context.showErrorSnackbar('Error signing up');
          }
        },
      ),
      const SizedBox(height: 24.5),
      const Text(
        'By signing in, you agree to the Terms of Service and Privacy Policy',
      ),
    ];
  }

  Future<void> _playDelayedAnimation() async {
    await Future.delayed(const Duration(milliseconds: 700));
    _yellowBlobAnimationController..forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _redBlobAnimationController..forward();
  }

  Future<void> _fadeDialog({required void Function() action}) async {
    setState(() {
      _dialogOpacity = 0;
    });
    await Future.delayed(_dialogOpacityAnimationDuration);
    action();
    await Future.delayed(_dialogOpacityAnimationDuration);
    setState(() {
      _dialogOpacity = 1;
    });
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({Key? key, required void Function() onPressed, required String label})
      : _onPressed = onPressed,
        _label = label,
        super(key: key);

  final void Function() _onPressed;
  final String _label;

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      onPressed: _onPressed,
      child: Text(
        _label,
        textAlign: TextAlign.center,
      ),
    );
  }
}
