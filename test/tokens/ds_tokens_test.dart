// Feature: DsTokens carries one brand's resolved tokens for one mode, and a
// brand or mode switch never shows values between two brands.
import 'package:design_system/design_system.dart';
import 'package:design_system/src/theme/ds_debug_warnings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/ds_test_brands.dart';

void main() {
  late List<String> printed;
  late DebugPrintCallback originalDebugPrint;

  setUp(() {
    printed = [];
    originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => printed.add(message ?? '');
    DsDebugWarnings.debugReset();
  });

  tearDown(() => debugPrint = originalDebugPrint);

  group('Given a brand and a brightness', () {
    final brand = DsTestBrands.variant(
      brandScale: DsTestBrands.greenScale,
      spacing: DsTestBrands.wideSpacing,
    );

    test('When tokens are resolved, '
        'Then they carry the brand, the brightness, and its scales', () {
      // Given / When
      final tokens = DsTokens.resolve(brand, Brightness.dark);

      // Then
      expect(tokens.brand, brand);
      expect(tokens.brightness, Brightness.dark);
      expect(tokens.colors.actionPrimary, brand.colors.brand.shade300);
      expect(tokens.typography.body.fontSize, 16);
      expect(tokens.typography.body.color, isNull);
      expect(tokens.spacing, brand.spacing);
      expect(tokens.radius, brand.radius);
      expect(tokens.borderWidths, brand.borderWidths);
      expect(tokens.opacities, brand.opacities);
      expect(tokens.iconSizes, brand.iconSizes);
    });

    test(
      'When the same brand is resolved twice, Then the tokens are equal',
      () {
        // Given / When
        final a = DsTokens.resolve(brand, Brightness.light);
        final b = DsTokens.resolve(brand, Brightness.light);

        // Then
        expect(a, b);
        expect(a.hashCode, b.hashCode);
        expect(a, isNot(DsTokens.resolve(brand, Brightness.dark)));
      },
    );

    test('When copyWith replaces the brand, '
        'Then the tokens are resolved again for that brand and mode', () {
      // Given
      final tokens = DsTokens.resolve(DsBrand.whiteLabel, Brightness.light);

      // When
      final copy = tokens.copyWith(brand: brand);

      // Then
      expect(copy, DsTokens.resolve(brand, Brightness.light));
      expect(copy.brightness, Brightness.light);
    });
  });

  group('Given tokens for two brands', () {
    final from = DsTokens.resolve(DsBrand.whiteLabel, Brightness.light);
    final to = DsTokens.resolve(
      DsTestBrands.variant(brandScale: DsTestBrands.greenScale),
      Brightness.light,
    );

    test('When lerp is asked for a point before the middle, '
        'Then it returns the starting tokens unchanged', () {
      // Given / When
      final result = from.lerp(to, 0.3);

      // Then
      expect(identical(result, from), isTrue);
    });

    test('When lerp is asked for the middle or later, '
        'Then it returns the target tokens unchanged', () {
      // Given / When
      final atMiddle = from.lerp(to, 0.5);
      final atEnd = from.lerp(to, 1);

      // Then
      expect(identical(atMiddle, to), isTrue);
      expect(identical(atEnd, to), isTrue);
    });

    test('When lerp is called partway through an animation several times, '
        'Then debug builds print one warning per run', () {
      // Given / When
      from.lerp(to, 0.2);
      from.lerp(to, 0.7);
      from.lerp(to, 0.9);

      // Then
      expect(printed, hasLength(1));
      expect(printed.single, contains('themeAnimationStyle'));
    });

    test('When lerp is called at the ends only, Then nothing is printed', () {
      // Given / When
      from.lerp(to, 0);
      from.lerp(to, 1);

      // Then
      expect(printed, isEmpty);
    });
  });
}
