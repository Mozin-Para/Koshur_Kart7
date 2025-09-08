// lib/pages/profile/theme_color_settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../managers/theme_manager.dart';
import '../../managers/color_manager.dart';

class ThemeColorSettingsPage extends StatelessWidget {
  final ThemeManager themeManager;
  final ColorManager colorManager;

  const ThemeColorSettingsPage({
    super.key,
    required this.themeManager,
    required this.colorManager,
  });

  @override
  Widget build(BuildContext context) {
    final MaterialColor currentSwatch = colorManager.currentMaterialColor;
    final Color accentShade = currentSwatch.shade500;

    return Scaffold(
      appBar: AppBar(title: const Text('Theme & Color Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // App Theme selector
            Builder(builder: (tileCtx) {
              return ListTile(
                leading: Icon(Icons.brightness_6, color: accentShade),
                title: const Text('App Theme'),
                subtitle: const Text('Light / Dark / System'),
                onTap: () => _showThemeMenu(tileCtx),
                trailing: Icon(Icons.arrow_drop_down, color: accentShade),
              );
            }),

            const Divider(),

            // Accent Color selector with Custom…
            Builder(builder: (tileCtx) {
              return ListTile(
                leading: Icon(Icons.palette, color: accentShade),
                title: const Text('Accent Color'),
                subtitle: const Text('Choose your app color'),
                onTap: () => _showAccentMenu(tileCtx),
                trailing: Icon(Icons.arrow_drop_down, color: accentShade),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _showThemeMenu(BuildContext tileCtx) async {
    final box = tileCtx.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    final rect = RelativeRect.fromLTRB(
      pos.dx, pos.dy + box.size.height, pos.dx + box.size.width, 0,
    );

    final selected = await showMenu<ThemeMode>(
      context: tileCtx,
      position: rect,
      items: ThemeMode.values.map((mode) {
        return PopupMenuItem(
          value: mode,
          child: Text(
            mode.toString().split('.').last.capitalize(),
            style: TextStyle(color: Theme.of(tileCtx).colorScheme.onSurface),
          ),
        );
      }).toList(),
    );

    if (selected != null) themeManager.setTheme(selected);
  }

  Future<void> _showAccentMenu(BuildContext tileCtx) async {
    final box = tileCtx.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    final rect = RelativeRect.fromLTRB(
      pos.dx, pos.dy + box.size.height, pos.dx + box.size.width, 0,
    );

    // Build preset swatch entries
    final items = <PopupMenuEntry<int>>[
      for (var i = 0; i < colorManager.colors.length; i++)
        PopupMenuItem<int>(
          value: i,
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colorManager.colors[i].shade500,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _label(colorManager.colors[i]),
                style: TextStyle(color: Theme.of(tileCtx).colorScheme.onSurface),
              ),
            ],
          ),
        ),
      const PopupMenuDivider(),
      // Custom Color entry
      PopupMenuItem<int>(
        value: -1,
        child: Text(
          'Custom Color…',
          style: TextStyle(color: Theme.of(tileCtx).colorScheme.onSurface),
        ),
      ),
    ];

    final selected = await showMenu<int>(
      context: tileCtx,
      position: rect,
      items: items,
    );

    if (selected == null) return;
    if (selected >= 0) {
      colorManager.setColorByIndex(selected);
    } else {
      await _openCustomColorPicker(tileCtx);
    }
  }

  Future<void> _openCustomColorPicker(BuildContext ctx) async {
    Color pickerColor = colorManager.currentMaterialColor.shade500;

    await showDialog(
      context: ctx,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Pick a custom accent color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (c) => pickerColor = c,
              showLabel: true,
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                colorManager.setCustomColor(pickerColor);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  static String _label(MaterialColor c) {
    switch (c) {
      case Colors.green:  return 'Green';
      case Colors.grey:   return 'Grey';
      case Colors.blue:   return 'Blue';
      case Colors.red:    return 'Red';
      case Colors.yellow: return 'Yellow';
      case Colors.purple: return 'Purple';
      case Colors.teal:   return 'Teal';
      default:            return 'Custom';
    }
  }
}

extension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
