// Feature: In debug builds, placing a brand that fails the contrast gate
// prints one warning per brand that names the failing pairs, and the brand
// still renders exactly as its file specifies.
import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:design_system/src/theme/ds_debug_warnings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/ds_test_brands.dart';

/// Brands, apps, and print capture for the tests below.
abstract final class _WarningFixtures {
  /// The pale fixture: the white label with a pale brand 600.
  static DsBrand get pale => _WarningFixtures.parse(
    File('test/contrast/fixtures/pale_brand.json').readAsStringSync(),
  );

  /// Another failing brand with the pale fixture's id: the same file with a
  /// different display name.
  static DsBrand get paleTwin => _WarningFixtures.parse(
    File('test/contrast/fixtures/pale_brand.json')
        .readAsStringSync()
        .replaceFirst('"Pale"', '"Pale twin"'),
  );

  /// Returns the brand of a valid brand file's [json].
  static DsBrand parse(String json) => switch (DsBrandParser.parseJson(json)) {
    DsBrandParseSuccess(:final brand) => brand,
    DsBrandParseFailure(:final exceptions) => throw StateError(
      exceptions.join('; '),
    ),
  };

  /// An app that places [brand] at the top level, in light and dark mode.
  static Widget app(DsBrand brand, {Widget? home}) => MaterialApp(
    theme: DsTheme.light(brand: brand),
    darkTheme: DsTheme.dark(brand: brand),
    themeAnimationStyle: AnimationStyle.noAnimation,
    home: Scaffold(
      body: home ?? DsButton(label: 'Pay', onPressed: () {}),
    ),
  );

  /// Runs [body] while recording what debugPrint prints, and restores
  /// debugPrint before the test ends, as widget tests require.
  static Future<List<String>> recordPrints(Future<void> Function() body) async {
    final printed = <String>[];
    final original = debugPrint;
    debugPrint = (message, {wrapWidth}) => printed.add(message ?? '');
    try {
      await body();
    } finally {
      debugPrint = original;
    }
    return printed;
  }

  /// The fill of the first [DsButton]'s material.
  static Color? buttonFill(WidgetTester tester) => tester
      .widget<Material>(
        find
            .descendant(
              of: find.byType(DsButton),
              matching: find.byType(Material),
            )
            .first,
      )
      .color;
}

void main() {
  setUp(DsDebugWarnings.debugReset);

  group('Given a brand that fails the contrast gate', () {
    testWidgets('When the App Shell places it at the top level and the app '
        'rebuilds, Then one warning names every failing pair', (tester) async {
      // Given
      final brand = _WarningFixtures.pale;

      // When
      final printed = await _WarningFixtures.recordPrints(() async {
        await tester.pumpWidget(_WarningFixtures.app(brand));
        await tester.pumpWidget(
          _WarningFixtures.app(brand, home: const Text('Rebuilt')),
        );
      });

      // Then
      expect(printed, hasLength(1));
      final warning = printed.single;
      expect(warning, contains('"pale"'));
      for (final violation in DsContrastGate.check(brand).violations) {
        expect(warning, contains(violation.toString()));
      }
    });

    testWidgets('When a micro app places it with DsBrandScope, '
        'Then one warning names the failing pairs', (tester) async {
      // Given
      final brand = _WarningFixtures.pale;

      // When
      final printed = await _WarningFixtures.recordPrints(
        () => tester.pumpWidget(
          _WarningFixtures.app(
            DsBrand.whiteLabel,
            home: DsBrandScope(
              brand: brand,
              child: DsButton(label: 'Pay', onPressed: () {}),
            ),
          ),
        ),
      );

      // Then
      expect(printed, hasLength(1));
      expect(printed.single, contains('light · focus on surface'));
    });

    testWidgets('When it is placed, '
        'Then it renders exactly as its file specifies', (tester) async {
      // Given
      final brand = _WarningFixtures.pale;

      // When
      await _WarningFixtures.recordPrints(
        () => tester.pumpWidget(_WarningFixtures.app(brand)),
      );

      // Then
      expect(_WarningFixtures.buttonFill(tester), brand.colors.brand.shade600);
    });
  });

  group('Given two different failing brands that share an id', () {
    testWidgets('When both are placed, Then each one warns once', (
      tester,
    ) async {
      // Given
      final pale = _WarningFixtures.pale;
      final twin = _WarningFixtures.paleTwin;
      expect(twin.id, pale.id);
      expect(twin, isNot(pale));

      // When
      final printed = await _WarningFixtures.recordPrints(() async {
        await tester.pumpWidget(_WarningFixtures.app(pale));
        await tester.pumpWidget(_WarningFixtures.app(twin));
        await tester.pumpWidget(_WarningFixtures.app(pale));
      });

      // Then
      expect(printed, hasLength(2));
    });
  });

  group('Given the repository brands, which pass the gate', () {
    testWidgets('When each one is placed, Then nothing is printed', (
      tester,
    ) async {
      // Given
      final brands = DsTestBrands.all;

      // When
      final printed = await _WarningFixtures.recordPrints(() async {
        for (final brand in brands) {
          await tester.pumpWidget(_WarningFixtures.app(brand));
        }
      });

      // Then
      expect(printed, isEmpty);
    });
  });
}
