// lib/managers/theme_manager.dart
// This class controls the app’s ThemeMode (light, dark, or system)
// and persists the user’s choice via a simple PrefsService wrapper.

import 'package:flutter/material.dart';       // Provides ThemeMode and ChangeNotifier
import '../services/prefs_service.dart';      // Wraps SharedPreferences for load/save

/// A ChangeNotifier that holds and persists the current ThemeMode.
class ThemeManager extends ChangeNotifier {
  // 1) Private field: holds the active theme; defaults to light on fresh start
  ThemeMode _themeMode = ThemeMode.light;

  // 2) PrefsService instance used to read/write the saved theme from disk
  final PrefsService _prefs = PrefsService();

  /// 3) Public getter: other parts of the app read the current ThemeMode here
  ThemeMode get themeMode => _themeMode;

  /// 4) Async initializer: loads the saved ThemeMode from preferences
  Future<void> load() async {
    // a) Retrieve the stored mode (returns light if not yet saved)
    _themeMode = await _prefs.loadThemeMode();
    // b) Notify any listeners (e.g., MaterialApp) to rebuild with the loaded mode
    notifyListeners();
  }

  /// 5) Public setter: updates the theme at runtime and persists the choice
  void setTheme(ThemeMode mode) {
    // a) Update the private field with the new mode
    _themeMode = mode;
    // b) Inform all listening widgets that the theme has changed
    notifyListeners();
    // c) Persist the new mode so it’s available next time the app launches
    _prefs.saveThemeMode(mode);
  }
}
