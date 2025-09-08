// lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'managers/theme_manager.dart';
import 'managers/color_manager.dart';
import 'managers/profile_manager.dart';
import 'pages/intro_splash.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeMgr = context.watch<ThemeManager>();
    final colorMgr = context.watch<ColorManager>();
    final isLoggedIn = context.watch<ProfileManager>().isLoggedIn;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMgr.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: colorMgr.currentMaterialColor,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        primarySwatch: colorMgr.currentMaterialColor,
        brightness: Brightness.dark,
      ),
      home: const IntroSplash(),
    );
  }
}
