/// @docImport '../brand_file/ds_brand_parser.dart';
/// @docImport '../theme/ds_brand_scope.dart';
/// @docImport '../theme/ds_theme.dart';
library;

import 'dart:ui' show Brightness;

import '../brand/ds_brand.dart';
import '../theme/ds_semantic_mapping.dart';
import '../tokens/ds_color_role.dart';
import 'ds_contrast.dart';
import 'ds_contrast_report.dart';

/// Check that measures every semantic color pair of a brand, in light and
/// dark mode, against its required WCAG contrast.
///
/// Use this in the tests of an App Shell or micro app that ships its own
/// brand file, so a color change that makes text unreadable fails the build.
///
/// This is **not** a parser check: [DsBrandParser] accepts a brand that
/// fails the gate, and the brand renders exactly as its file specifies.
///
/// Built-in: in debug builds, [DsTheme] and [DsBrandScope] run the gate when
/// they place a brand, and print one warning per failing brand that names
/// every failing pair. Release builds never run it.
///
/// Pairs, checked in both modes:
/// * at 4.5:1: `textPrimary` on `background`, `surface`, and
///   `surfaceVariant`; `textSecondary` on `background` and `surface`;
///   `textOnAction` on `actionPrimary` and `actionPrimaryPressed`;
///   `actionPrimary`, which tertiary buttons use as text, on `background`
///   and `surface`; and each status foreground on its background;
/// * at 3:1: `focus` on `background` and `surface`.
///
/// `textDisabled` and `actionDisabled` are exempt, as WCAG exempts inactive
/// components. A release that adds a pair lists it in the changelog.
///
/// Usage from a host test:
/// ```dart
/// test('Our brand file passes the contrast gate', () {
///   final brand = switch (DsBrandParser.parseJson(brandJson)) {
///     DsBrandParseSuccess(:final brand) => brand,
///     DsBrandParseFailure(:final exceptions) => throw StateError('$exceptions'),
///   };
///   final report = DsContrastGate.check(brand);
///   expect(report.violations, isEmpty, reason: report.violations.join('\n'));
/// });
/// ```
abstract final class DsContrastGate {
  /// The pair table: each foreground, its backgrounds, and the minimum.
  static const List<(DsColorRole, List<DsColorRole>, double)> _pairs = [
    (
      DsColorRole.textPrimary,
      [DsColorRole.background, DsColorRole.surface, DsColorRole.surfaceVariant],
      4.5,
    ),
    (
      DsColorRole.textSecondary,
      [DsColorRole.background, DsColorRole.surface],
      4.5,
    ),
    (
      DsColorRole.textOnAction,
      [DsColorRole.actionPrimary, DsColorRole.actionPrimaryPressed],
      4.5,
    ),
    (
      DsColorRole.actionPrimary,
      [DsColorRole.background, DsColorRole.surface],
      4.5,
    ),
    (DsColorRole.infoForeground, [DsColorRole.infoBackground], 4.5),
    (DsColorRole.successForeground, [DsColorRole.successBackground], 4.5),
    (DsColorRole.warningForeground, [DsColorRole.warningBackground], 4.5),
    (DsColorRole.errorForeground, [DsColorRole.errorBackground], 4.5),
    (DsColorRole.focus, [DsColorRole.background, DsColorRole.surface], 3.0),
  ];

  /// Checks every pair of [brand] in light and dark mode.
  ///
  /// Parameters:
  /// * [brand] - The brand to check.
  ///
  /// Returns a [DsContrastReport] whose violations list every pair below
  /// its minimum, light mode first. It never throws.
  static DsContrastReport check(DsBrand brand) => DsContrastReport(
    brandId: brand.id,
    violations: [
      for (final brightness in [Brightness.light, Brightness.dark])
        ...DsContrastGate._violationsIn(brand, brightness),
    ],
  );

  static Iterable<DsContrastViolation> _violationsIn(
    DsBrand brand,
    Brightness brightness,
  ) sync* {
    final colors = DsSemanticMapping.colorsFor(brand, brightness);
    for (final (foreground, backgrounds, minimum) in _pairs) {
      for (final background in backgrounds) {
        final ratio = DsContrast.ratio(
          colors.role(foreground),
          colors.role(background),
        );
        if (ratio < minimum) {
          yield DsContrastViolation(
            brightness: brightness,
            foreground: foreground,
            background: background,
            ratio: double.parse(ratio.toStringAsFixed(2)),
            requiredRatio: minimum,
          );
        }
      }
    }
  }
}
