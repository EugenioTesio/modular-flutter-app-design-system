// Feature: The contrast gate checks every semantic color pair of a brand in
// both modes, and reports every failing pair with its mode, roles, ratio,
// and required ratio (data-model.md, Contrast gate pairs).
import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/ds_test_brands.dart';

/// Brands and the pair table the tests below use.
abstract final class _GateFixtures {
  /// The pair table of data-model.md: each foreground, its backgrounds, and
  /// the minimum ratio.
  static const List<(DsColorRole, List<DsColorRole>, double)> pairs = [
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

  /// The pale fixture: the white label with a pale brand 600.
  static DsBrand get pale => _GateFixtures.parse(
    File('test/contrast/fixtures/pale_brand.json').readAsStringSync(),
  );

  /// A brand whose every color is the same gray, so every pair measures
  /// 1.00 and fails.
  static DsBrand get flat {
    const gray = Color(0xFF808080);
    const status = DsStatusScale(
      shade100: gray,
      shade500: gray,
      shade700: gray,
    );
    const base = DsBrand.whiteLabel;
    return DsBrand(
      id: 'flat',
      name: 'Flat',
      colors: const DsBrandColors(
        brand: DsBrandScale(
          shade50: gray,
          shade100: gray,
          shade200: gray,
          shade300: gray,
          shade400: gray,
          shade500: gray,
          shade600: gray,
          shade700: gray,
          shade800: gray,
          shade900: gray,
        ),
        neutral: DsNeutralScale(
          shade0: gray,
          shade50: gray,
          shade100: gray,
          shade200: gray,
          shade300: gray,
          shade400: gray,
          shade500: gray,
          shade600: gray,
          shade700: gray,
          shade800: gray,
          shade900: gray,
        ),
        success: status,
        warning: status,
        error: status,
        info: status,
      ),
      typography: base.typography,
      spacing: base.spacing,
      radius: base.radius,
      borderWidths: base.borderWidths,
      opacities: base.opacities,
      iconSizes: base.iconSizes,
    );
  }

  /// Returns the brand of a valid brand file's [json].
  static DsBrand parse(String json) => switch (DsBrandParser.parseJson(json)) {
    DsBrandParseSuccess(:final brand) => brand,
    DsBrandParseFailure(:final exceptions) => throw StateError(
      exceptions.join('; '),
    ),
  };

  /// Returns a violation's identity, without its measured ratio.
  static (Brightness, DsColorRole, DsColorRole, double) key(
    DsContrastViolation violation,
  ) => (
    violation.brightness,
    violation.foreground,
    violation.background,
    violation.requiredRatio,
  );
}

void main() {
  group('Given a brand whose every color is the same', () {
    test('When the gate checks it, '
        'Then every pair of the table fails in both modes at its minimum', () {
      // Given
      final brand = _GateFixtures.flat;

      // When
      final report = DsContrastGate.check(brand);

      // Then
      expect(report.brandId, 'flat');
      expect(report.passed, isFalse);
      expect(report.violations.map(_GateFixtures.key), [
        for (final brightness in [Brightness.light, Brightness.dark])
          for (final (foreground, backgrounds, minimum) in _GateFixtures.pairs)
            for (final background in backgrounds)
              (brightness, foreground, background, minimum),
      ]);
      expect(report.violations.map((v) => v.ratio).toSet(), {1.0});
    });
  });

  group('Given the pale fixture brand', () {
    test('When the gate checks it, '
        'Then it reports every failing pair with mode, roles, and ratios', () {
      // Given
      final brand = _GateFixtures.pale;

      // When
      final report = DsContrastGate.check(brand);

      // Then
      expect(report.brandId, 'pale');
      expect(report.passed, isFalse);
      expect(report.violations.map(_GateFixtures.key), [
        (
          Brightness.light,
          DsColorRole.textOnAction,
          DsColorRole.actionPrimaryPressed,
          4.5,
        ),
        (
          Brightness.light,
          DsColorRole.actionPrimary,
          DsColorRole.background,
          4.5,
        ),
        (Brightness.light, DsColorRole.actionPrimary, DsColorRole.surface, 4.5),
        (Brightness.light, DsColorRole.focus, DsColorRole.background, 3.0),
        (Brightness.light, DsColorRole.focus, DsColorRole.surface, 3.0),
      ]);
      for (final violation in report.violations) {
        expect(violation.ratio, lessThan(violation.requiredRatio));
        expect(
          violation.ratio,
          double.parse(violation.ratio.toStringAsFixed(2)),
        );
      }
    });

    test('When a violation is printed, '
        'Then it reads mode · foreground on background · ratio < required', () {
      // Given
      final report = DsContrastGate.check(_GateFixtures.pale);

      // When
      final lines = report.violations.map((v) => v.toString()).toList();

      // Then
      expect(
        lines,
        contains(matches(r'^light · focus on surface · \d\.\d\d < 3\.0$')),
      );
      expect(lines.first, startsWith('light · textOnAction on '));
    });

    test('When the same brand is checked twice, '
        'Then the two reports are equal', () {
      // Given
      final brand = _GateFixtures.pale;

      // When
      final first = DsContrastGate.check(brand);
      final second = DsContrastGate.check(brand);

      // Then
      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });

  group('Given the repository brands', () {
    test('When the gate checks the white label, '
        'Then it passes in both modes', () {
      // Given
      const brand = DsBrand.whiteLabel;

      // When
      final report = DsContrastGate.check(brand);

      // Then
      expect(report.violations, isEmpty);
      expect(report.passed, isTrue);
    });

    test('When the gate checks every file in widgetbook/brands/, '
        'Then each one passes in both modes', () {
      // Given
      final files = Directory('widgetbook/brands')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'));

      // When
      final reports = {
        for (final file in files)
          file.uri.pathSegments.last: DsContrastGate.check(
            _GateFixtures.parse(file.readAsStringSync()),
          ),
      };

      // Then
      expect(reports, isNotEmpty);
      for (final MapEntry(key: name, value: report) in reports.entries) {
        expect(report.violations, isEmpty, reason: '$name fails the gate');
      }
      expect(
        DsTestBrands.all.map((brand) => DsContrastGate.check(brand).passed),
        everyElement(isTrue),
      );
    });
  });
}
