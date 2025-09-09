// lib/managers/color_manager.dart

import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

/// Provide an explicit 32-bit ARGB integer from any Color.
extension ColorToArgb on Color {
  int toArgb32() => (alpha << 24) | (red << 16) | (green << 8) | blue;
}

class ColorManager extends ChangeNotifier {
  final PrefsService _prefs = PrefsService();

  // 1) Your fixed, built-in MaterialColor swatches.
  final List<MaterialColor> colors = [
    Colors.green,
    Colors.grey,
    Colors.blue,
    Colors.red,
    Colors.yellow,
    Colors.purple,
    Colors.teal,
  ];

  // 2) The active swatch.
  late MaterialColor _currentColor = colors.first;

  // 3) If preset is chosen, its index; otherwise null.
  int? _savedIndex;

  // 4) If custom, the raw ARGB stored here.
  int? _customArgb;

  MaterialColor get currentMaterialColor => _currentColor;
  bool get isPresetColorSet  => _savedIndex != null;
  bool get isCustomColorSet  => _customArgb  != null;

  /// Load saved settings, build swatch accordingly.
  Future<void> load() async {
    final idx        = await _prefs.loadColorIndex();
    final customArgb = await _prefs.loadCustomColorValue();

    if (idx != null && idx >= 0 && idx < colors.length) {
      _savedIndex  = idx;
      _customArgb  = null;
      _currentColor = colors[idx];
    }
    else if (customArgb != null) {
      _savedIndex  = null;
      _customArgb  = customArgb;
      _buildCustomSwatch(Color(customArgb));
    }

    notifyListeners();
  }

  /// Pick one of the built-in swatches.
  void setColorByIndex(int index) {
    if (index < 0 || index >= colors.length) return;

    _savedIndex   = index;
    _customArgb   = null;
    _currentColor = colors[index];
    _prefs.saveColorIndex(index);
    notifyListeners();
  }

  /// Create + persist a one-off Color swatch.
  void setCustomColor(Color color) {
    _savedIndex  = null;
    _customArgb  = color.toArgb32();
    _prefs.saveCustomColorValue(_customArgb!);
    _buildCustomSwatch(color);
    notifyListeners();
  }

  /// Build a 10-shade MaterialColor using only withAlpha().
  void _buildCustomSwatch(Color baseColor) {
    const int maxA = 0xFF;
    final int argb = baseColor.toArgb32();

    _currentColor = MaterialColor(argb, <int, Color>{
      50:  baseColor.withAlpha((0.1 * maxA).round()),
      100: baseColor.withAlpha((0.2 * maxA).round()),
      200: baseColor.withAlpha((0.3 * maxA).round()),
      300: baseColor.withAlpha((0.4 * maxA).round()),
      400: baseColor.withAlpha((0.5 * maxA).round()),
      500: baseColor.withAlpha(maxA),              // 100% alpha
      600: baseColor.withAlpha((0.7 * maxA).round()),
      700: baseColor.withAlpha((0.8 * maxA).round()),
      800: baseColor.withAlpha((0.9 * maxA).round()),
      900: baseColor.withAlpha(maxA),              // 100% alpha
    });
  }

  /// A simple two-shade vertical gradient.
  LinearGradient currentGradient() => LinearGradient(
    colors: [_currentColor.shade400, _currentColor.shade700],
    begin : Alignment.topCenter,
    end   : Alignment.bottomCenter,
  );
}
