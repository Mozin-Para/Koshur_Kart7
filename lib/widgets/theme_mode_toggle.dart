import 'package:flutter/material.dart';
import '../managers/theme_manager.dart';
import '../managers/color_manager.dart';
import '../pages/profile/theme_color_settings_page.dart';

/// A pill‐shaped Light/Dark toggle that opens your
/// Theme & Color Settings page when tapped.
/// It rebuilds automatically whenever the ThemeManager changes.
class ThemeModeToggle extends StatelessWidget {
  final ThemeManager themeManager;
  final ColorManager colorManager;
  final double width;
  final double height;

  const ThemeModeToggle({
    super.key,
    required this.themeManager,
    required this.colorManager,
    this.width = 100,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder listens to themeManager.notifyListeners()
    return AnimatedBuilder(
      animation: themeManager,
      builder: (ctx, _) {
        // Decide light vs dark
        final ThemeMode mode = themeManager.themeMode;
        final bool isDark = mode == ThemeMode.dark ||
            (mode == ThemeMode.system &&
                MediaQuery.of(ctx).platformBrightness == Brightness.dark);

        // Colors & positions
        final Color bgColor = isDark ? Colors.black : Colors.white;
        final Color thumbColor = isDark ? Colors.white : Colors.black;
        final Alignment align =
        isDark ? Alignment.centerRight : Alignment.centerLeft;
        final String label = isDark ? 'DARK MODE' : 'LIGHT MODE';
        final Color labelColor = thumbColor;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                )),
            const SizedBox(height: 1),
            GestureDetector(
              onTap: () {
                // Open your Theme & Color Settings page
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ThemeColorSettingsPage(
                      themeManager: themeManager,
                      colorManager: colorManager,
                    ),
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
                  alignment: align,
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
        );
      },
    );
  }
}