import 'package:flutter/foundation.dart';

/// A singleton service exposing a ValueNotifier<bool> for global loading state.
/// Call show() before your async/blocking code and hide() after.
class LoadingService {
  LoadingService._();
  static final LoadingService _instance = LoadingService._();
  factory LoadingService() => _instance;

  // The underlying notifier: true = show spinner, false = hide it
  final ValueNotifier<bool> _loading = ValueNotifier(false);

  /// Expose the notifier so widgets can listen.
  ValueNotifier<bool> get notifier => _loading;

  /// Turn on loading spinner.
  void show() {
    if (!_loading.value) {
      _loading.value = true;
    }
  }

  /// Turn off loading spinner.
  void hide() {
    if (_loading.value) {
      _loading.value = false;
    }
  }

  /// Execute an async function with loading indicator
  Future<T> runWithLoader<T>(Future<T> Function() asyncFunction) async {
    show();
    try {
      return await asyncFunction();
    } finally {
      hide();
    }
  }
}