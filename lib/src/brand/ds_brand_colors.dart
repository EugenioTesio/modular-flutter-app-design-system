/// @docImport '../tokens/ds_colors.dart';
/// @docImport 'ds_brand.dart';
library;

import 'package:flutter/foundation.dart';

import 'ds_color_scale.dart';

/// Value that holds every color scale of a brand: its primitive colors.
///
/// Use this when you build a brand in code, for example in a test. Brands
/// usually come from a brand file instead.
///
/// This is **not** a set of colors for screens or components: they read the
/// semantic roles in [DsColors], which the design system derives from these
/// scales for light and dark mode.
///
/// Built-in: [DsBrand.colors] holds it.
///
/// Usage from a test:
/// ```dart
/// final colors = DsBrand.whiteLabel.colors;
/// expect(colors.brand.shade600, const Color(0xFF1F5FD1));
/// ```
@immutable
final class DsBrandColors {
  /// Creates the color scales of a brand.
  ///
  /// Parameters:
  /// * [brand] - The brand's main scale, for actions and focus.
  /// * [neutral] - The neutral scale, for backgrounds, surfaces, borders, and
  ///   text.
  /// * [success] - The scale of success messages.
  /// * [warning] - The scale of warning messages.
  /// * [error] - The scale of error messages.
  /// * [info] - The scale of information messages.
  const DsBrandColors({
    required this.brand,
    required this.neutral,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  /// The brand's main scale, for actions and focus.
  final DsBrandScale brand;

  /// The neutral scale, for backgrounds, surfaces, borders, and text.
  final DsNeutralScale neutral;

  /// The scale of success messages.
  final DsStatusScale success;

  /// The scale of warning messages.
  final DsStatusScale warning;

  /// The scale of error messages.
  final DsStatusScale error;

  /// The scale of information messages.
  final DsStatusScale info;

  @override
  bool operator ==(Object other) =>
      other is DsBrandColors &&
      other.brand == brand &&
      other.neutral == neutral &&
      other.success == success &&
      other.warning == warning &&
      other.error == error &&
      other.info == info;

  @override
  int get hashCode =>
      Object.hash(brand, neutral, success, warning, error, info);
}
