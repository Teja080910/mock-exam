import 'package:flutter/services.dart';

/// Manages Android kiosk (lock task) mode while a quiz is active.
///
/// Pairs with the native MethodChannel in MainActivity.kt
/// (`com.mock.exam.app/kiosk`) which calls startLockTask()/stopLockTask().
class KioskHelper {
  static const MethodChannel _channel = MethodChannel('com.mock.exam.app/kiosk');
  static bool _isLocked = false;

  static Future<void> start() async {
    if (_isLocked) {
      return;
    }
    _isLocked = true;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    try {
      await _channel.invokeMethod('startKiosk');
    } catch (_) {
      // Method channel unavailable (e.g. running on web) - system UI is
      // still hidden, so the quiz flow remains protected.
    }
  }

  static Future<void> stop() async {
    if (!_isLocked) {
      return;
    }
    _isLocked = false;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    try {
      await _channel.invokeMethod('stopKiosk');
    } catch (_) {
      // Ignore - nothing to release when the channel is unavailable.
    }
  }
}
