/// @docImport '../brand/ds_brand.dart';
/// @docImport 'ds_contrast_gate.dart';
library;

import 'package:flutter/foundation.dart';

import '../tokens/ds_color_role.dart';

/// Value that lists the semantic color pairs of one brand that fall below
/// their required contrast, as [DsContrastGate.check] returns it.
///
/// Use this to fail a test when a brand file stops being readable, or to
/// show a designer what to fix: each [DsContrastViolation] names the mode,
/// the two roles, the measured ratio, and the required ratio.
///
/// This is **not** a parse failure: a brand that fails the gate is still a
/// valid brand, and it renders exactly as its file specifies.
///
/// Built-in: in debug builds, placing a brand that fails the gate prints one
/// warning per brand with the same pairs. Release builds never run the gate.
///
/// Rules:
/// * [violations] are in light mode first, then dark mode, each in the
///   order of the gate's pair table.
/// * Two reports with the same brand id and violations are equal.
///
/// Usage from a host test:
/// ```dart
/// final report = DsContrastGate.check(brand);
/// expect(report.violations, isEmpty, reason: report.violations.join('\n'));
/// ```
@immutable
final class DsContrastReport {
  /// Creates a contrast report.
  ///
  /// Parameters:
  /// * [brandId] - The id of the brand that was checked.
  /// * [violations] - Every failing pair; empty when the brand passes.
  const DsContrastReport({required this.brandId, required this.violations});

  /// Id of the brand that was checked, such as `forest`.
  final String brandId;

  /// Every pair below its required contrast, light mode first; empty when
  /// the brand passes.
  final List<DsContrastViolation> violations;

  /// Whether the brand passes the gate: no pair is below its minimum in
  /// either mode.
  bool get passed => violations.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is DsContrastReport &&
      other.brandId == brandId &&
      listEquals(other.violations, violations);

  @override
  int get hashCode => Object.hash(brandId, Object.hashAll(violations));

  @override
  String toString() => passed
      ? 'DsContrastReport($brandId: passed)'
      : 'DsContrastReport($brandId: ${violations.length} failing pair(s))';
}

/// Value that describes one semantic color pair below its required contrast.
///
/// Use this to tell a designer exactly what to change: the mode, the
/// foreground and background roles, how far the pair is from its minimum.
///
/// This is **not** a fix: the design system never adjusts a brand's colors
/// to reach a ratio.
///
/// Rules:
/// * [ratio] is the WCAG contrast ratio, rounded to two decimals.
/// * [toString] reads `light · textOnAction on actionPrimary · 2.31 < 4.5`.
///
/// Usage from a host test:
/// ```dart
/// for (final violation in DsContrastGate.check(brand).violations) {
///   print(violation); // light · focus on surface · 1.82 < 3.0
/// }
/// ```
@immutable
final class DsContrastViolation {
  /// Creates a contrast violation.
  ///
  /// Parameters:
  /// * [brightness] - The mode in which the pair fails.
  /// * [foreground] - The role drawn on top, such as text.
  /// * [background] - The role underneath.
  /// * [ratio] - The measured WCAG ratio, rounded to two decimals.
  /// * [requiredRatio] - The minimum the pair needs: 4.5 or 3.0.
  const DsContrastViolation({
    required this.brightness,
    required this.foreground,
    required this.background,
    required this.ratio,
    required this.requiredRatio,
  });

  /// Mode in which the pair fails.
  final Brightness brightness;

  /// Role drawn on top, such as `textOnAction`.
  final DsColorRole foreground;

  /// Role underneath, such as `actionPrimary`.
  final DsColorRole background;

  /// Measured WCAG contrast ratio, rounded to two decimals.
  final double ratio;

  /// Minimum ratio the pair needs: 4.5 for text, 3.0 for the focus
  /// indicator.
  final double requiredRatio;

  @override
  bool operator ==(Object other) =>
      other is DsContrastViolation &&
      other.brightness == brightness &&
      other.foreground == foreground &&
      other.background == background &&
      other.ratio == ratio &&
      other.requiredRatio == requiredRatio;

  @override
  int get hashCode =>
      Object.hash(brightness, foreground, background, ratio, requiredRatio);

  @override
  String toString() =>
      '${brightness.name} · ${foreground.name} on ${background.name} · '
      '${ratio.toStringAsFixed(2)} < ${requiredRatio.toStringAsFixed(1)}';
}
