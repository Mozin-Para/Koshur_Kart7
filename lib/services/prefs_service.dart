// lib/services/prefs_service.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A concise wrapper around SharedPreferences for persisting:
///  • ThemeMode
///  • Selected preset color index
///  • Arbitrary custom color ARGB value
class PrefsService {
  // Keys for SharedPreferences
  static const String _kThemeMode     = 'theme_mode';
  static const String _kColorIndex    = 'color_index';
  static const String _kCustomColor   = 'custom_color';

  /// Persists the given [mode] as a lowercase string.
  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light  => 'light',
      ThemeMode.dark   => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_kThemeMode, value);
  }

  /// Loads the stored ThemeMode, defaulting to light if absent/invalid.
  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kThemeMode) ?? 'light';
    return switch (stored) {
      'dark'   => ThemeMode.dark,
      'system' => ThemeMode.system,
      _        => ThemeMode.light,
    };
  }

  /// Persists the selected preset‐color [index].
  Future<void> saveColorIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kColorIndex, index);
  }

  /// Loads the stored preset‐color index, or null if never set.
  Future<int?> loadColorIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kColorIndex);
  }

  /// Persists a fully custom accent color as its ARGB integer value.
  Future<void> saveCustomColorValue(int argb) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCustomColor, argb);
  }

  /// Loads the stored custom color’s ARGB integer, or null if none.
  Future<int?> loadCustomColorValue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kCustomColor);
  }
}
