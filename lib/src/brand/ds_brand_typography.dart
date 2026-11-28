/// @docImport '../tokens/ds_typography.dart';
/// @docImport 'ds_brand.dart';
library;

import 'package:flutter/foundation.dart';

import 'ds_type_style.dart';

/// Value that holds a brand's type scale: one [DsTypeStyle] for each text
/// role.
///
/// Use this when you build a brand in code, for example in a test. Brands
/// usually come from a brand file instead.
///
/// This is **not** a set of text styles for screens: screens read
/// [DsTypography], which the design system builds from this scale.
///
/// Built-in: [DsBrand.typography] holds it.
///
/// Usage from a test:
/// ```dart
/// final body = DsBrand.whiteLabel.typography.body;
/// expect(body.fontSize, 16);
/// ```
@immutable
final class DsBrandTypography {
  /// Creates a type scale.
  ///
  /// Parameters:
  /// * [display] - Style of the largest text, such as an amount on a summary.
  /// * [headline] - Style of section and page headings.
  /// * [title] - Style of app bar titles and card titles.
  /// * [body] - Style of running text.
  /// * [bodyStrong] - Style of emphasized running text.
  /// * [label] - Style of button and field labels.
  /// * [caption] - Style of small supporting text.
  const DsBrandTypography({
    required this.display,
    required this.headline,
    required this.title,
    required this.body,
    required this.bodyStrong,
    required this.label,
    required this.caption,
  });

  /// Style of the largest text, such as an amount on a summary.
  final DsTypeStyle display;

  /// Style of section and page headings.
  final DsTypeStyle headline;

  /// Style of app bar titles and card titles.
  final DsTypeStyle title;

  /// Style of running text.
  final DsTypeStyle body;

  /// Style of emphasized running text.
  final DsTypeStyle bodyStrong;

  /// Style of button and field labels.
  final DsTypeStyle label;

  /// Style of small supporting text.
  final DsTypeStyle caption;

  @override
  bool operator ==(Object other) =>
      other is DsBrandTypography &&
      other.display == display &&
      other.headline == headline &&
      other.title == title &&
      other.body == body &&
      other.bodyStrong == bodyStrong &&
      other.label == label &&
      other.caption == caption;

  @override
  int get hashCode =>
      Object.hash(display, headline, title, body, bodyStrong, label, caption);
}
