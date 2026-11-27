/// @docImport '../brand/ds_brand.dart';
/// @docImport '../theme/ds_theme_context.dart';
library;

import 'package:flutter/foundation.dart';

/// Value that holds a brand's border widths, in logical pixels.
///
/// Use this when a custom shape draws a border that should match the
/// components, through `context.dsBorderWidths`.
///
/// This is **not** a divider thickness setting: dividers follow the Material
/// theme that the design system builds.
///
/// Built-in: [DsBrand.borderWidths] holds it, and
/// [DsThemeContext.dsBorderWidths] reads the nearest brand's widths. Fields
/// and secondary buttons draw [thin] borders, and focused controls draw
/// [thick] ones.
///
/// Rules: both widths are at least 0. The white label uses 1 and 2.
///
/// Usage from a micro app:
/// ```dart
/// DecoratedBox(
///   decoration: BoxDecoration(
///     border: Border.all(
///       color: context.dsColors.border,
///       width: context.dsBorderWidths.thin,
///     ),
///   ),
///   child: child,
/// )
/// ```
@immutable
final class DsBorderWidths {
  /// Creates a set of border widths.
  ///
  /// Parameters:
  /// * [thin] - Width of regular borders.
  /// * [thick] - Width of emphasized borders, such as a focus ring.
  ///
  /// Both widths must be at least 0.
  const DsBorderWidths({required this.thin, required this.thick})
    : assert(thin >= 0, 'thin must be at least 0'),
      assert(thick >= 0, 'thick must be at least 0');

  /// Width of regular borders.
  final double thin;

  /// Width of emphasized borders, such as a focus ring.
  final double thick;

  @override
  bool operator ==(Object other) =>
      other is DsBorderWidths && other.thin == thin && other.thick == thick;

  @override
  int get hashCode => Object.hash(thin, thick);
}
