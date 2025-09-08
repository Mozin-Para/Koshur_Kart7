// lib/widgets/custom_app_bar.dart
// A reusable AppBar widget that:
//  • Paints its background from the user’s selected swatch (shade500).
//  • Adjusts status bar color and icon brightness for contrast.
//  • Provides PopupMenuButtons to select ThemeMode and color swatch.
//  • Automatically rebuilds when ColorManager notifies of changes.

import 'package:flutter/material.dart';                    // Core Flutter widgets
import 'package:flutter/services.dart';                    // For SystemUiOverlayStyle
import '../managers/theme_manager.dart';                   // To read and set ThemeMode
import '../managers/color_manager.dart';                   // To read and set accent swatch

/// CustomAppBar implements PreferredSizeWidget to define its own height.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// ThemeManager instance to control light/dark/system theme.
  final ThemeManager themeManager;

  /// ColorManager instance to control app accent swatch.
  final ColorManager colorManager;

  /// Constructor requires both managers.
  const CustomAppBar({
    super.key,
    required this.themeManager,
    required this.colorManager,
  });

  /// Defines the AppBar’s preferred size (toolbar height).
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder listens to colorManager.notifyListeners() and rebuilds.
    return AnimatedBuilder(
      animation: colorManager,
      builder: (context, _) {
        // Obtain the current MaterialColor swatch.
        final MaterialColor swatch = colorManager.currentMaterialColor;

        // Background color uses the swatch’s 500 shade.
        final Color bgColor = swatch.shade500;

        // Determine text/icon brightness based on swatch luminance.
        final bool lightBg = swatch.computeLuminance() > 0.5;
        final Brightness iconBrightness =
        lightBg ? Brightness.dark : Brightness.light;
        final Color iconColor =
        iconBrightness == Brightness.dark ? Colors.black : Colors.white;

        // AnnotatedRegion sets status bar color and icon brightness.
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: bgColor,                 // Android status bar
            statusBarIconBrightness: iconBrightness, // Android icons
            statusBarBrightness: iconBrightness,     // iOS status text
          ),
          // Actual AppBar widget configured with custom styling.
          child: AppBar(
            elevation: 0,                            // No shadow under status bar
            backgroundColor: bgColor,               // AppBar background color
            foregroundColor: iconColor,             // Title and icon color
            title: const Text('Koshur Kart'),       // App title

            // Action buttons on the right side of the AppBar
            actions: [
              // ─── ThemeMode selector ─────────────────────────────────
              PopupMenuButton<ThemeMode>(
                icon: Icon(Icons.brightness_6, color: iconColor),
                tooltip: 'Select theme mode',
                color: bgColor,                     // Dropdown background matches AppBar
                onSelected: themeManager.setTheme,  // Update and persist new ThemeMode
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light mode', style: TextStyle(color: iconColor)),
                  ),
                  PopupMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark mode', style: TextStyle(color: iconColor)),
                  ),
                  PopupMenuItem(
                    value: ThemeMode.system,
                    child: Text('System default', style: TextStyle(color: iconColor)),
                  ),
                ],
              ),

              // ─── Color swatch selector ────────────────────────────────
              PopupMenuButton<int>(
                icon: Icon(Icons.palette, color: iconColor),
                tooltip: 'Select app color',
                color: bgColor,                      // Dropdown background matches AppBar
                onSelected: colorManager.setColorByIndex, // Update and persist new swatch
                itemBuilder: (_) => List<PopupMenuEntry<int>>.generate(
                  colorManager.colors.length,
                      (int index) {
                    final MaterialColor c = colorManager.colors[index];
                    // Contrast logic for dropdown item text
                    final bool itemLightBg = c.shade500.computeLuminance() > 0.5;
                    final Color itemTextColor =
                    itemLightBg ? Colors.black : Colors.white;

                    return PopupMenuItem<int>(
                      value: index,                   // Return this swatch’s index
                      child: Row(
                        children: [
                          // A small circle filled with the swatch color
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: c.shade500,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Swatch label with contrast-aware text color
                          Text(
                            _swatchLabel(c),
                            style: TextStyle(color: itemTextColor),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Converts a MaterialColor swatch into a human-readable label.
  static String _swatchLabel(MaterialColor c) {
    if (c == Colors.green)  return 'Green';
    if (c == Colors.pink)   return 'Pink';
    if (c == Colors.blue)   return 'Blue';
    if (c == Colors.red)    return 'Red';
    if (c == Colors.yellow) return 'Yellow';
    if (c == Colors.purple) return 'Purple';
    if (c == Colors.teal)   return 'Teal';
    return 'Custom';
  }
}
