import 'package:flutter/foundation.dart';

/// Helper that prints a debug warning once per app run.
///
/// This is internal to the design system and is not exported. Every method
/// does its work inside an `assert`, so release builds print nothing and keep
/// no state.
abstract final class DsDebugWarnings {
  // Debug-only memory of the warning keys already seen. It is read and
  // written only inside `assert` bodies, which release builds remove.
  static final Set<Object> _seen = {};

  /// Prints [message] the first time [key] is seen in this run.
  ///
  /// Parameters:
  /// * [key] - What identifies the warning: a fixed string for run-level
  ///   warnings, or a value such as a brand, compared by equality.
  /// * [message] - The text to print. It never contains personal data.
  static void warnOnce(Object key, String message) =>
      DsDebugWarnings.warnOnceIfNeeded(key, () => message);

  /// Builds and prints a warning the first time [key] is seen in this run.
  ///
  /// [message] runs only for a new key, so an expensive check, such as the
  /// contrast gate, runs once per key. When it returns null, nothing is
  /// printed, and the key is still remembered.
  ///
  /// Parameters:
  /// * [key] - What identifies the warning, compared by equality.
  /// * [message] - Returns the text to print, or null for no warning. The
  ///   text never contains personal data.
  static void warnOnceIfNeeded(Object key, String? Function() message) {
    assert(() {
      if (_seen.add(key)) {
        final text = message();
        if (text != null) debugPrint(text);
      }
      return true;
    }());
  }

  /// Forgets every warning key seen so far, so tests start clean.
  @visibleForTesting
  static void debugReset() {
    assert(() {
      _seen.clear();
      return true;
    }());
  }
}
