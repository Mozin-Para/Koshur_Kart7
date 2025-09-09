// lib/widgets/theme_mode_toggle.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../managers/theme_manager.dart';
import '../pages/profile/theme_color_settings_page.dart';

/// A pill-shaped Light/Dark toggle for your AppBar.
/// Constrained to fit within kToolbarHeight to prevent overflow.
class ThemeModeToggle extends StatelessWidget {
  final double width;
  final double height;

  const ThemeModeToggle({
    super.key,
    this.width = 100,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();

    return AnimatedBuilder(
      animation: themeManager,
      builder: (ctx, _) {
        final mode = themeManager.themeMode;
        final platformBrightness = MediaQuery.of(ctx).platformBrightness;
        final isDark = mode == ThemeMode.dark ||
            (mode == ThemeMode.system &&
                platformBrightness == Brightness.dark);

        final bgColor = isDark ? Colors.black : Colors.white;
        final thumbColor = isDark ? Colors.white : Colors.black;
        final alignment =
        isDark ? Alignment.centerRight : Alignment.centerLeft;
        final label = isDark ? 'DARK MODE' : 'LIGHT MODE';

        return SizedBox(
          height: kToolbarHeight, // lock widget height
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center, // center contents
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.0, // tighten line-height
                  fontWeight: FontWeight.bold,
                  color: thumbColor,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ThemeColorSettingsPage(),
                    ),
                  );
                },
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(height / 2),
                    border: Border.all(color: thumbColor, width: 1.2),
                  ),
                  child: AnimatedAlign(
                    alignment: alignment,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Container(
                      width: height - 4,
                      height: height - 4,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: thumbColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}