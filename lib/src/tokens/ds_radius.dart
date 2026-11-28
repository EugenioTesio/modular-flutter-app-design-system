/// @docImport '../brand/ds_brand.dart';
/// @docImport '../theme/ds_theme_context.dart';
library;

import 'package:flutter/foundation.dart';

/// Value that holds a brand's corner-radius scale, in logical pixels.
///
/// Use this when a custom shape needs rounded corners that match the
/// components, through `context.dsRadius`:
/// `BorderRadius.circular(context.dsRadius.lg)`.
///
/// This is **not** a set of fixed constants: each brand supplies its own
/// scale.
///
/// Built-in: [DsBrand.radius] holds it, and [DsThemeContext.dsRadius] reads
/// the nearest brand's scale. Buttons, fields, and cards use [md].
///
/// Rules: every step is at least 0. The white label's scale is 4 · 8 · 16,
/// plus 999 for [pill].
///
/// Usage from a micro app:
/// ```dart
/// ClipRRect(
///   borderRadius: BorderRadius.circular(context.dsRadius.lg),
///   child: Image.asset('assets/promo.png'),
/// )
/// ```
@immutable
final class DsRadius {
  /// Creates a corner-radius scale.
  ///
  /// Parameters:
  /// * [sm] - Small radius.
  /// * [md] - Medium radius, used by buttons, fields, and cards.
  /// * [lg] - Large radius.
  /// * [pill] - Radius large enough to round both ends of any control fully.
  ///
  /// Every step must be at least 0.
  const DsRadius({
    required this.sm,
    required this.md,
    required this.lg,
    required this.pill,
  }) : assert(sm >= 0, 'sm must be at least 0'),
       assert(md >= 0, 'md must be at least 0'),
       assert(lg >= 0, 'lg must be at least 0'),
       assert(pill >= 0, 'pill must be at least 0');

  /// Small radius.
  final double sm;

  /// Medium radius, used by buttons, fields, and cards.
  final double md;

  /// Large radius.
  final double lg;

  /// Radius large enough to round both ends of any control fully.
  final double pill;

  @override
  bool operator ==(Object other) =>
      other is DsRadius &&
      other.sm == sm &&
      other.md == md &&
      other.lg == lg &&
      other.pill == pill;

  @override
  int get hashCode => Object.hash(sm, md, lg, pill);
}
