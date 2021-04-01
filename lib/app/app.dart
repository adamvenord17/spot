// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:spot/l10n/l10n.dart';
import 'package:spot/pages/splash_page.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFFFFFFF),
        accentColor: const Color(0xFFFFFFFF),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF13B9FF),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: Color(0xFFFFFFFF)),
          ),
          isDense: true,
        ),
      ),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: SplashPage(),
    );
  }
}
