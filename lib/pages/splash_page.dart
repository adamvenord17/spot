import 'package:flutter/material.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/pages/tab_page.dart';

import '../components/app_scaffold.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => SplashPage());
  }

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: preloader,
    );
  }

  @override
  void initState() {
    redirect();
    super.initState();
  }

  Future<void> _restoreSession() async {
    final hasSession =
        await localStorage.containsKey(key: persistantSessionKey);
    if (!hasSession) {
      return;
    }

    final jsonStr = await localStorage.read(key: persistantSessionKey);
    if (jsonStr == null) {
      await localStorage.delete(key: persistantSessionKey);
      return;
    }
    final response = await supabaseClient.auth.recoverSession(jsonStr);
    if (response.error != null) {
      await localStorage.delete(key: persistantSessionKey);
      return;
    }

    final session = response.data;
    if (session == null) {
      await localStorage.delete(key: persistantSessionKey);
      return;
    }

    await localStorage.write(
        key: persistantSessionKey, value: session.persistSessionString);
  }

  Future<void> redirect() async {
    await Future.delayed(const Duration(milliseconds: 100));
    await _restoreSession();

    /// Check Auth State
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      _redirectToLoginPage();
      return;
    }
    final snap = await supabaseClient
        .from('users')
        .select()
        .eq('id', authUser.id)
        .execute();
    final error = snap.error;
    if (error != null) {
      print(error);
      return;
    }
    final data = snap.data as List<dynamic>;
    if (data.isEmpty) {
      _redirectToEditProfilePage();
      return;
    }
    _redirectToTabsPage();
  }

  void _redirectToLoginPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LoginPage(),
      ),
    );
  }

  void _redirectToEditProfilePage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const EditProfilePage(isCreatingAccount: true),
      ),
    );
  }

  void _redirectToTabsPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TabPage(),
      ),
    );
  }
}
