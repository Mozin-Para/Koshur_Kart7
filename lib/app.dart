// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'managers/theme_manager.dart';
import 'managers/color_manager.dart';
import 'managers/profile_manager.dart';
import 'pages/home_page.dart';
import 'pages/profile/guest_profile_page.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeMgr  = context.watch<ThemeManager>();
    final colorMgr  = context.watch<ColorManager>();
    final isLoggedIn = context.watch<ProfileManager>().isLoggedIn;

    return AnimatedBuilder(
      animation: Listenable.merge([themeMgr, colorMgr]),
      builder: (_, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeMgr.themeMode,
          theme: ThemeData(
            primarySwatch: colorMgr.currentMaterialColor,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: colorMgr.currentMaterialColor,
            useMaterial3: true,
          ),
          home: isLoggedIn
              ? HomePage(
            themeManager: themeMgr,
            colorManager: colorMgr,
          )
              : GuestProfilePage(
            themeManager: themeMgr,
            colorManager: colorMgr,
          ),
        );
      },
    );
  }
}
