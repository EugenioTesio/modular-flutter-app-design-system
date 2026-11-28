/// @docImport '../catalog/ds_component_info.dart';
/// @docImport '../layout/ds_gap.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'ds_guidelines_mode.dart';

/// Widget that turns the developer guidelines overlay on or off for the
/// components below it.
///
/// Use this to review a screen against the design system: with the overlay
/// on, every component is outlined in the color of its atomic level, and
/// the gaps that come from [DsGap] are tinted, so you can see at a glance
/// what is a component, at which level, and which spacing comes from
/// tokens. The App Shell can place it at startup, for example from a debug
/// menu, and the Widgetbook's Guidelines toggle places it around each use
/// case.
///
/// This is **not** Flutter's `debugPaintSizeEnabled`: it outlines design
/// system components only, by level, and leaves every other widget alone.
///
/// Built-in: the overlay is always off in release builds. A release build
/// ignores this widget and the `DS_GUIDELINES` build switch, so end users
/// never see it. In debug and profile builds:
/// * The overlay is on below a `DsGuidelines(enabled: true)`, or everywhere
///   when the app is built with `--dart-define=DS_GUIDELINES=true`
///   ([buildEnabled]). It is off by default.
/// * The nearest [DsGuidelines] wins, unless the build switch is on.
/// * Outlines and tints are painted over the components, so the overlay
///   never moves or resizes anything.
/// * Keep the [DsGuidelines] in place and switch [enabled], so components
///   keep their state when the overlay is toggled.
/// * With neither a [DsGuidelines] above nor the build switch, components
///   build exactly as they would without the overlay.
/// * Outlines use fixed debug colors, the same in every brand: pink for
///   atoms, blue for molecules, orange for organisms, and green for
///   templates ([DsComponentInfo.level]).
///
/// Usage from the App Shell:
/// ```dart
/// MaterialApp(
///   theme: DsTheme.light(brand: brand),
///   builder: (context, child) => DsGuidelines(
///     enabled: debugSettings.showGuidelines,
///     child: child!,
///   ),
///   home: const HomeScreen(),
/// )
/// ```
final class DsGuidelines extends InheritedWidget {
  /// Creates a guidelines switch for the components below it.
  ///
  /// Parameters:
  /// * [enabled] - Whether the overlay is on below this widget. Release
  ///   builds ignore it.
  /// * [child] - The subtree the switch applies to.
  const DsGuidelines({super.key, required this.enabled, required super.child});

  /// Whether the build switch turns the overlay on everywhere, from the
  /// compile-time `DS_GUIDELINES` define. Defaults to false, and is always
  /// false in release builds.
  static const bool buildEnabled =
      !kReleaseMode && bool.fromEnvironment('DS_GUIDELINES');

  /// Whether the overlay is on below this widget. Release builds ignore it.
  final bool enabled;

  /// Returns whether the overlay is on at [context].
  ///
  /// It is on when [buildEnabled] is true or the nearest [DsGuidelines] is
  /// enabled, and off when there is neither. It always returns false in a
  /// release build. A widget that calls it rebuilds when the nearest
  /// [DsGuidelines] changes.
  ///
  /// Parameters:
  /// * [context] - Where the overlay is read.
  static bool isEnabledOf(BuildContext context) {
    final nearest = context.dependOnInheritedWidgetOfExactType<DsGuidelines>();
    return DsGuidelinesMode.isActive(
      releaseMode: kReleaseMode,
      requested: buildEnabled || (nearest?.enabled ?? false),
    );
  }

  @override
  bool updateShouldNotify(DsGuidelines oldWidget) =>
      enabled != oldWidget.enabled;
}
