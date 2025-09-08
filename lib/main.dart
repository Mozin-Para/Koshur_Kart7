// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'managers/theme_manager.dart';
import 'managers/color_manager.dart';
import 'managers/profile_manager.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Instantiate and load saved theme
  final themeManager = ThemeManager();
  await themeManager.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeManager),
        ChangeNotifierProvider(create: (_) => ColorManager()),
        ChangeNotifierProvider(create: (_) => ProfileManager()),
      ],
      child: const App(),
    ),
  );
}
