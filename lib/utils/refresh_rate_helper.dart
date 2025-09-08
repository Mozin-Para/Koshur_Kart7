import 'package:flutter_displaymode/flutter_displaymode.dart';

/// Reads & caches the device's highest supported refresh rate,
/// falling back to 60 Hz if anything goes wrong.
class RefreshRateHelper {
  static double deviceRefreshRate = 60.0;

  /// Call from main() before runApp().
  static Future<void> init({double defaultRate = 60.0}) async {
    deviceRefreshRate = defaultRate;
    try {
      final modes = await FlutterDisplayMode.supported;
      if (modes.isNotEmpty) {
        final best = modes.reduce(
              (a, b) => a.refreshRate > b.refreshRate ? a : b,
        );
        deviceRefreshRate = best.refreshRate;
        await FlutterDisplayMode.setPreferredMode(best);
      }
    } catch (_) {
      // fallback to defaultRate
    }
  }
}