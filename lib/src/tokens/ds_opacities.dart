/// @docImport '../brand/ds_brand.dart';
/// @docImport '../theme/ds_theme_context.dart';
library;

import 'package:flutter/foundation.dart';

/// Value that holds a brand's state-layer opacities: how strongly a control
/// is tinted while it is hovered, focused, or pressed.
///
/// Use this when a custom tappable surface needs the same feedback as the
/// components, through `context.dsOpacities`.
///
/// This is **not** a way to fade content: it only tints the layer drawn over
/// a control to show its state.
///
/// Built-in: [DsBrand.opacities] holds it, and [DsThemeContext.dsOpacities]
/// reads the nearest brand's values.
///
/// Rules: every value is between 0 and 1. The white label uses 0.08 for
/// [hovered] and 0.12 for [focused] and [pressed].
///
/// Usage from a micro app:
/// ```dart
/// InkWell(
///   onTap: onTap,
///   splashColor: context.dsColors.textPrimary.withValues(
///     alpha: context.dsOpacities.pressed,
///   ),
///   child: child,
/// )
/// ```
@immutable
final class DsOpacities {
  /// Creates a set of state-layer opacities.
  ///
  /// Parameters:
  /// * [hovered] - Opacity of the layer while a pointer hovers the control.
  /// * [focused] - Opacity of the layer while the control has focus.
  /// * [pressed] - Opacity of the layer while the control is pressed.
  ///
  /// Every value must be between 0 and 1.
  const DsOpacities({
    required this.hovered,
    required this.focused,
    required this.pressed,
  }) : assert(hovered >= 0 && hovered <= 1, 'hovered must be within 0 and 1'),
       assert(focused >= 0 && focused <= 1, 'focused must be within 0 and 1'),
       assert(pressed >= 0 && pressed <= 1, 'pressed must be within 0 and 1');

  /// Opacity of the layer while a pointer hovers the control.
  final double hovered;

  /// Opacity of the layer while the control has focus.
  final double focused;

  /// Opacity of the layer while the control is pressed.
  final double pressed;

  @override
  bool operator ==(Object other) =>
      other is DsOpacities &&
      other.hovered == hovered &&
      other.focused == focused &&
      other.pressed == pressed;

  @override
  int get hashCode => Object.hash(hovered, focused, pressed);
}
