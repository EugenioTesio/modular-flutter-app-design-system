import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'ds_guidelines.dart';

/// Rules that decide whether the developer guidelines overlay is active.
///
/// This is internal to the design system and is not exported.
abstract final class DsGuidelinesMode {
  /// Returns whether the overlay is active.
  ///
  /// A release build never shows the overlay, whatever asked for it. Debug
  /// and profile builds show it when it is requested. The build mode is a
  /// parameter, so the release case can be unit-tested even though tests run
  /// in debug mode. [DsGuidelines.isEnabledOf] calls it with the real build
  /// mode.
  ///
  /// Parameters:
  /// * [releaseMode] - Whether this is a release build.
  /// * [requested] - Whether the build switch or the nearest [DsGuidelines]
  ///   asks for the overlay.
  static bool isActive({required bool releaseMode, required bool requested}) =>
      !releaseMode && requested;

  /// Returns whether anything at [context] can turn the overlay on: the
  /// build switch, or a [DsGuidelines] above, whatever its `enabled` value.
  ///
  /// When nothing can, outlines and tints leave the widget tree exactly as
  /// it is without the overlay. When something can, they keep their painter
  /// widget in the tree, so toggling `enabled` keeps the components' state.
  /// It always returns false in a release build.
  ///
  /// Parameters:
  /// * [context] - Where the overlay is read. It rebuilds when the nearest
  ///   [DsGuidelines] changes.
  static bool isSwitchable(BuildContext context) =>
      !kReleaseMode &&
      (DsGuidelines.buildEnabled ||
          context.dependOnInheritedWidgetOfExactType<DsGuidelines>() != null);
}
