// lib/managers/profile_manager.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds user profile data: avatar image and login state.
/// Notifies listeners whenever avatar or login state changes.
class ProfileManager extends ChangeNotifier {
  // Singleton boilerplate
  static final ProfileManager _instance = ProfileManager._internal();
  factory ProfileManager() => _instance;
  ProfileManager._internal() {
    _loadFromPrefs();
  }

  // Keys for SharedPreferences
  static const _avatarPrefKey  = 'profile_avatar_path';
  static const _loginPrefKey   = 'profile_is_logged_in';

  // Backing fields
  ImageProvider _avatarImage = const AssetImage('assets/avatar_dp.png');
  bool _isLoggedIn           = false;

  /// Public: current avatar (AssetImage or FileImage)
  ImageProvider get avatarImage => _avatarImage;

  /// Public: whether the user is logged in
  bool get isLoggedIn => _isLoggedIn;

  /// Loads both avatar path and login flag from prefs.
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // 1) Load login state
    _isLoggedIn = prefs.getBool(_loginPrefKey) ?? false;

    // 2) Load avatar path
    final path = prefs.getString(_avatarPrefKey);
    if (path != null && File(path).existsSync()) {
      _avatarImage = FileImage(File(path));
    }

    notifyListeners();
  }

  /// Call when user successfully logs in.
  /// Persist login flag and notify listeners.
  Future<void> logIn() async {
    _isLoggedIn = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginPrefKey, true);
  }

  /// Call to log out the user (back to guest).
  /// Clears login flag (but keeps avatar) and notifies listeners.
  Future<void> logOut() async {
    _isLoggedIn = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginPrefKey, false);
  }

  /// Updates the avatar image to [file], persists its path, and notifies.
  Future<void> updateAvatar(File file) async {
    _avatarImage = FileImage(file);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarPrefKey, file.path);
  }
}
