// lib/pages/color_settings_page.dart
// A screen where users choose an accent color from a 7-color palette,
// plus a “Reset to Defaults” button that restores green.

import 'package:flutter/material.dart';             // Core Flutter UI widgets
import '../managers/color_manager.dart';            // Manages current color state and persistence

/// A stateful widget displaying color options and a reset button.
class ColorSettingsPage extends StatefulWidget {
  /// Reference to the shared ColorManager instance
  /// so UI widgets can read and update the current color.
  final ColorManager colorManager;

  /// Constructor requiring the ColorManager.
  /// `super.key` passes the optional Key up to StatefulWidget.
  const ColorSettingsPage({
    super.key,
    required this.colorManager,
  });

  @override
  State<ColorSettingsPage> createState() => _ColorSettingsPageState();
}

/// The mutable state for ColorSettingsPage.
class _ColorSettingsPageState extends State<ColorSettingsPage> {
  /// A fixed list of swatches matching ColorManager.colors by index.
  /// Index 0 is green (the default), then pink, blue, red, yellow, purple, teal.
  final List<MaterialColor> _swatches = const [
    Colors.green,
    Colors.pink,
    Colors.blue,
    Colors.red,
    Colors.yellow,
    Colors.purple,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic visual layout: AppBar + body.
    return Scaffold(
      // AppBar with a simple title
      appBar: AppBar(
        title: const Text('Color Settings'),
      ),

      // Body uses a ListView.builder to render swatch tiles + reset button.
      body: ListView.builder(
        // Vertical padding above first and below last item
        padding: const EdgeInsets.symmetric(vertical: 8),
        // Number of items = number of swatches + 1 reset button
        itemCount: _swatches.length + 1,
        // itemBuilder creates each row based on its index
        itemBuilder: (context, idx) {
          // If idx refers to a swatch, render a color tile
          if (idx < _swatches.length) {
            // Grab the MaterialColor at this index
            final color = _swatches[idx];
            // Compare against the manager’s current selection
            final isSelected =
                widget.colorManager.currentMaterialColor == color;

            // Return a ListTile showing the swatch
            return ListTile(
              // CircleAvatar filled with the swatch color
              leading: CircleAvatar(backgroundColor: color),
              // Title: the swatch’s human-readable name
              title: Text(_nameOf(color)),
              // If this swatch is selected, show a check icon
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.black)
                  : null,
              // Tap handler: update the manager’s color by this index
              onTap: () {
                widget.colorManager.setColorByIndex(idx);
                // Call setState to redraw the checkmark immediately
                setState(() {});
              },
            );
          }

          // Otherwise, idx == _swatches.length → render the Reset button
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              // Light grey background, black text
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
              ),
              // When pressed, call our private reset helper
              onPressed: _resetToDefaults,
              child: const Text('Reset to Defaults'),
            ),
          );
        },
      ),
    );
  }

  /// Resets the accent swatch back to the default (green at index 0).
  void _resetToDefaults() {
    // Tell the ColorManager to pick index 0 (green).
    widget.colorManager.setColorByIndex(0);

    // If this widget is still part of the tree, show confirmation.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Accent color reset to Green')),
    );

    // Redraw so the checkmark appears on the green tile.
    setState(() {});
  }

  /// Converts a MaterialColor swatch into a human-readable String.
  /// Matches the order & names used in the swatch list.
  String _nameOf(MaterialColor c) {
    if (c == Colors.green) return 'Green';
    if (c == Colors.pink) return 'Pink';
    if (c == Colors.blue) return 'Blue';
    if (c == Colors.red) return 'Red';
    if (c == Colors.yellow) return 'Yellow';
    if (c == Colors.purple) return 'Purple';
    if (c == Colors.teal) return 'Teal';
    // Fallback if ever extended with a custom swatch
    return 'Custom';
  }
}
