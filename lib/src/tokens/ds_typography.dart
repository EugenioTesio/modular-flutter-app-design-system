/// @docImport '../brand/ds_brand.dart';
/// @docImport '../theme/ds_theme_context.dart';
/// @docImport 'ds_colors.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../brand/ds_brand_typography.dart';

/// Value that holds the text styles of one brand.
///
/// Use this for every text style in a screen, through `context.dsTypography`,
/// and add the color from [DsColors]: `typography.body.copyWith(color:
/// colors.textSecondary)`.
///
/// This is **not** a color source: the styles carry font, size, weight, line
/// height, and letter spacing only, so the same style works on any
/// background.
///
/// Built-in: the design system builds it from the nearest [DsBrand]'s type
/// scale. A font family that the app doesn't bundle falls back to the
/// platform font. The styles scale with the user's text size setting.
///
/// Usage from a micro app:
/// ```dart
/// final typography = context.dsTypography;
/// return Text(
///   'Accounts',
///   style: typography.headline.copyWith(color: context.dsColors.textPrimary),
/// );
/// ```
@immutable
final class DsTypography {
  /// Creates a set of text styles. The design system calls this; screens
  /// read the styles through `context.dsTypography` instead.
  ///
  /// Parameters:
  /// * [display] - Style of the largest text, such as an amount on a summary.
  /// * [headline] - Style of section and page headings.
  /// * [title] - Style of app bar titles and card titles.
  /// * [body] - Style of running text.
  /// * [bodyStrong] - Style of emphasized running text.
  /// * [label] - Style of button and field labels.
  /// * [caption] - Style of small supporting text.
  const DsTypography({
    required this.display,
    required this.headline,
    required this.title,
    required this.body,
    required this.bodyStrong,
    required this.label,
    required this.caption,
  });

  /// Creates the text styles of a brand's type scale.
  ///
  /// Parameters:
  /// * [typography] - The brand's type scale.
  DsTypography.fromBrand(DsBrandTypography typography)
    : display = typography.display.toTextStyle(),
      headline = typography.headline.toTextStyle(),
      title = typography.title.toTextStyle(),
      body = typography.body.toTextStyle(),
      bodyStrong = typography.bodyStrong.toTextStyle(),
      label = typography.label.toTextStyle(),
      caption = typography.caption.toTextStyle();

  /// Style of the largest text, such as an amount on a summary.
  final TextStyle display;

  /// Style of section and page headings.
  final TextStyle headline;

  /// Style of app bar titles and card titles.
  final TextStyle title;

  /// Style of running text.
  final TextStyle body;

  /// Style of emphasized running text.
  final TextStyle bodyStrong;

  /// Style of button and field labels.
  final TextStyle label;

  /// Style of small supporting text.
  final TextStyle caption;

  @override
  bool operator ==(Object other) =>
      other is DsTypography &&
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
