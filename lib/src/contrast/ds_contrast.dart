import 'package:flutter/painting.dart';

/// Helper that measures WCAG contrast between colors.
///
/// This is internal to the design system and is not exported.
abstract final class DsContrast {
  /// Returns the WCAG contrast ratio between [a] and [b], from 1 to 21.
  ///
  /// Parameters:
  /// * [a] - One color.
  /// * [b] - The other color. The order does not matter.
  static double ratio(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final lighter = la > lb ? la : lb;
    final darker = la > lb ? lb : la;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Returns whichever of [light] and [dark] contrasts more with
  /// [background].
  ///
  /// Parameters:
  /// * [background] - The color the text sits on.
  /// * [light] - The light text candidate.
  /// * [dark] - The dark text candidate.
  static Color bestText(
    Color background, {
    required Color light,
    required Color dark,
  }) => ratio(light, background) >= ratio(dark, background) ? light : dark;
}
