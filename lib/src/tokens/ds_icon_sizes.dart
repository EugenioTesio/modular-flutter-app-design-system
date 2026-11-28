/// @docImport '../brand/ds_brand.dart';
/// @docImport '../theme/ds_theme_context.dart';
library;

import 'package:flutter/foundation.dart';

/// Value that holds a brand's icon sizes, in logical pixels.
///
/// Use this for every icon in a screen, through `context.dsIconSizes`, so
/// icons follow the nearest brand: `Icon(Icons.send, size:
/// context.dsIconSizes.md)`.
///
/// This is **not** a tap-target size: tappable icons still need a target of
/// at least 48 × 48 around them.
///
/// Built-in: [DsBrand.iconSizes] holds it, and [DsThemeContext.dsIconSizes]
/// reads the nearest brand's sizes.
///
/// Rules: every size is at least 0. The white label uses 18, 24, and 48.
///
/// Usage from a micro app:
/// ```dart
/// Icon(Icons.account_balance, size: context.dsIconSizes.lg)
/// ```
@immutable
final class DsIconSizes {
  /// Creates a set of icon sizes.
  ///
  /// Parameters:
  /// * [sm] - Size of small icons, such as an icon inside a button.
  /// * [md] - Size of regular icons.
  /// * [lg] - Size of large, illustrative icons, such as in an empty state.
  ///
  /// Every size must be at least 0.
  const DsIconSizes({required this.sm, required this.md, required this.lg})
    : assert(sm >= 0, 'sm must be at least 0'),
      assert(md >= 0, 'md must be at least 0'),
      assert(lg >= 0, 'lg must be at least 0');

  /// Size of small icons, such as an icon inside a button.
  final double sm;

  /// Size of regular icons.
  final double md;

  /// Size of large, illustrative icons, such as in an empty state.
  final double lg;

  @override
  bool operator ==(Object other) =>
      other is DsIconSizes &&
      other.sm == sm &&
      other.md == md &&
      other.lg == lg;

  @override
  int get hashCode => Object.hash(sm, md, lg);
}
