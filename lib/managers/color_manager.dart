//lib/managers/color_manager.dart
import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

class ColorManager extends ChangeNotifier {
  final PrefsService _prefs = PrefsService();

  // 1) Fixed palette of MaterialColor swatches.
  final List<MaterialColor> colors = [
    Colors.green,  // index 0 (default)
    Colors.grey,   // index 1
    Colors.blue,   // index 2
    Colors.red,    // index 3
    Colors.yellow, // index 4
    Colors.purple, // index 5
    Colors.teal,   // index 6
  ];

  // 2) Backing field for the active swatch (updates via setColorByIndex or setCustomColor).
  late MaterialColor _currentColor = colors[0];

  // 3) Holds the user’s chosen preset index, or null if using a custom color.
  int? _savedIndex;

  // 4) Holds the raw ARGB value of a custom color if the user picked one.
  int? _customColorValue;

  /// Public getter for the active swatch.
  MaterialColor get currentMaterialColor => _currentColor;

  /// True if the user selected one of the preset swatches.
  bool get isPresetColorSet => _savedIndex != null;

  /// True if the user picked a completely custom color.
  bool get isCustomColorSet => _customColorValue != null;

  /// Loads both a saved preset‐index *and* a saved custom‐color value.
  /// Priority: if preset index found, use it; otherwise if custom exists, use that.
  Future<void> load() async {
    final int? idx        = await _prefs.loadColorIndex();
    final int? customArgb = await _prefs.loadCustomColorValue();

    if (idx != null && idx >= 0 && idx < colors.length) {
      // 5a) Found a valid preset index → use that swatch
      _savedIndex = idx;
      _customColorValue = null;
      _currentColor = colors[idx];
    }
    else if (customArgb != null) {
      // 5b) No preset, but found a custom‐ARGB value → build swatch from that
      _savedIndex = null;
      _customColorValue = customArgb;
      _buildCustomSwatch(Color(customArgb));
    }
    // else: first‐launch default (colors[0])

    notifyListeners();
  }

  /// Switches to one of the fixed‐palette swatches by index.
  /// Persists the index and clears any custom‐color setting.
  void setColorByIndex(int index) {
    if (index < 0 || index >= colors.length) return;

    _savedIndex      = index;
    _customColorValue = null;
    _currentColor    = colors[index];
    notifyListeners();
    _prefs.saveColorIndex(index);
  }

  /// Builds a one-off MaterialColor from any [color], persists it,
  /// and clears any preset‐index setting.
  void setCustomColor(Color color) {
    _savedIndex      = null;
    _customColorValue = color.value;
    _buildCustomSwatch(color);
    notifyListeners();
    _prefs.saveCustomColorValue(color.value);
  }

  /// Internal helper to build the opacity‐ramp swatch for a custom Color.
  void _buildCustomSwatch(Color color) {
    _currentColor = MaterialColor(
      color.value,
      <int, Color>{
        50:  color.withOpacity(0.1),
        100: color.withOpacity(0.2),
        200: color.withOpacity(0.3),
        300: color.withOpacity(0.4),
        400: color.withOpacity(0.5),
        500: color,
        600: color.withOpacity(0.7),
        700: color.withOpacity(0.8),
        800: color.withOpacity(0.9),
        900: color.withOpacity(1.0),
      },
    );
  }

  /// Returns a vertical gradient based on the active swatch.
  LinearGradient currentGradient() => LinearGradient(
    colors: [_currentColor.shade400, _currentColor.shade700],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
