import 'package:flutter/foundation.dart';

/// Helper that prints a debug warning once per app run.
///
/// This is internal to the design system and is not exported. Every method
/// does its work inside an `assert`, so release builds print nothing and keep
/// no state.
abstract final class DsDebugWarnings {
  // Debug-only memory of the warnings already printed. It is read and written
  // only inside `assert` bodies, which release builds remove.
  static final Set<Object> _printed = {};

  /// Prints [message] the first time [key] is seen in this run.
  ///
  /// Parameters:
  /// * [key] - What identifies the warning: a fixed string for run-level
  ///   warnings, or a value such as a brand, compared by equality.
  /// * [message] - The text to print. It never contains personal data.
  static void warnOnce(Object key, String message) {
    assert(() {
      if (_printed.add(key)) debugPrint(message);
      return true;
    }());
  }

  /// Forgets every warning printed so far, so tests start clean.
  @visibleForTesting
  static void debugReset() {
    assert(() {
      _printed.clear();
      return true;
    }());
  }
}
