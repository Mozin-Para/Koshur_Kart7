import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'managers/theme_manager.dart';
import 'managers/color_manager.dart';
import 'managers/profile_manager.dart';
import 'app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => ColorManager()),
        ChangeNotifierProvider(create: (_) => ProfileManager()),
      ],
      child: const App(), // ← App can now safely use context.watch<ThemeManager>()
    ),
  );
}
