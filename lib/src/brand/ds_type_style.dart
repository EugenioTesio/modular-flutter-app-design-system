/// @docImport '../tokens/ds_typography.dart';
/// @docImport 'ds_brand_typography.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Value that holds one text style of a brand's type scale: its font, size,
/// weight, line height, and letter spacing.
///
/// Use this when you build a brand in code, for example in a test. Brands
/// usually come from a brand file instead.
///
/// This is **not** a [TextStyle] for screens: screens read the styles of
/// [DsTypography], which the design system builds from these values.
///
/// Built-in: [DsBrandTypography] holds one for each of its seven roles.
///
/// Rules:
/// * [fontFamily] is null when the brand names only generic families, such
///   as `system-ui`, which means the platform font.
/// * A family that the app doesn't bundle falls back to [fontFamilyFallback],
///   then to the platform font.
/// * [fontSize] is greater than 0.
///
/// Usage from a test:
/// ```dart
/// const body = DsTypeStyle(
///   fontFamily: 'Inter',
///   fontSize: 16,
///   fontWeight: FontWeight.w400,
///   lineHeight: 1.5,
///   letterSpacing: 0,
/// );
/// ```
@immutable
final class DsTypeStyle {
  /// Creates a type style.
  ///
  /// Parameters:
  /// * [fontFamily] - Optional font family; null means the platform font.
  /// * [fontFamilyFallback] - Families to try when [fontFamily] isn't
  ///   available. Defaults to none.
  /// * [fontSize] - Size in logical pixels, greater than 0.
  /// * [fontWeight] - Weight of the glyphs.
  /// * [lineHeight] - Line height as a multiple of [fontSize].
  /// * [letterSpacing] - Extra space between letters, in logical pixels.
  const DsTypeStyle({
    this.fontFamily,
    this.fontFamilyFallback = const [],
    required this.fontSize,
    required this.fontWeight,
    required this.lineHeight,
    required this.letterSpacing,
  }) : assert(fontSize > 0, 'fontSize must be greater than 0');

  /// Optional font family; null means the platform font.
  final String? fontFamily;

  /// Families to try when [fontFamily] isn't available.
  final List<String> fontFamilyFallback;

  /// Size in logical pixels.
  final double fontSize;

  /// Weight of the glyphs.
  final FontWeight fontWeight;

  /// Line height as a multiple of [fontSize].
  final double lineHeight;

  /// Extra space between letters, in logical pixels.
  final double letterSpacing;

  /// Returns this style as a [TextStyle] with no color.
  TextStyle toTextStyle() => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback.isEmpty ? null : fontFamilyFallback,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: lineHeight,
    letterSpacing: letterSpacing,
  );

  @override
  bool operator ==(Object other) =>
      other is DsTypeStyle &&
      other.fontFamily == fontFamily &&
      listEquals(other.fontFamilyFallback, fontFamilyFallback) &&
      other.fontSize == fontSize &&
      other.fontWeight == fontWeight &&
      other.lineHeight == lineHeight &&
      other.letterSpacing == letterSpacing;

  @override
  int get hashCode => Object.hash(
    fontFamily,
    Object.hashAll(fontFamilyFallback),
    fontSize,
    fontWeight,
    lineHeight,
    letterSpacing,
  );
}
