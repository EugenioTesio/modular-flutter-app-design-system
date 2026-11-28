// Feature: A brand is a complete, immutable set of primitive tokens, and the
// white label is built into the code.
import 'package:design_system/design_system.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/ds_test_brands.dart';

void main() {
  group('Given the white-label brand', () {
    const brand = DsBrand.whiteLabel;

    test('When its metadata is read, Then the id and name identify it', () {
      // Given / When
      final (id, name) = (brand.id, brand.name);

      // Then
      expect(id, 'white_label');
      expect(name, 'White label');
    });

    test('When its colors are read, '
        'Then they hold the documented scales', () {
      // Given
      final colors = brand.colors;

      // When / Then
      expect(colors.brand.shade50, const Color(0xFFEEF4FD));
      expect(colors.brand.shade300, const Color(0xFF8AB4F8));
      expect(colors.brand.shade600, const Color(0xFF1F5FD1));
      expect(colors.brand.shade900, const Color(0xFF0C2556));
      expect(colors.neutral.shade0, const Color(0xFFFFFFFF));
      expect(colors.neutral.shade900, const Color(0xFF14171C));
      expect(colors.success.shade700, const Color(0xFF1B6B39));
      expect(colors.warning.shade100, const Color(0xFFFDF1DC));
      expect(colors.error.shade500, const Color(0xFFD93838));
      expect(colors.info.shade700, const Color(0xFF184BA8));
    });

    test('When its dimensions are read, '
        'Then they hold the documented scales', () {
      // Given / When
      final spacing = brand.spacing;

      // Then
      expect([spacing.xxs, spacing.xs, spacing.sm, spacing.md], [4, 8, 12, 16]);
      expect([spacing.lg, spacing.xl, spacing.xxl], [24, 32, 48]);
      expect(
        [brand.radius.sm, brand.radius.md, brand.radius.lg, brand.radius.pill],
        [4, 8, 16, 999],
      );
      expect([brand.borderWidths.thin, brand.borderWidths.thick], [1, 2]);
      expect(
        [
          brand.opacities.hovered,
          brand.opacities.focused,
          brand.opacities.pressed,
        ],
        [0.08, 0.12, 0.12],
      );
      expect(
        [brand.iconSizes.sm, brand.iconSizes.md, brand.iconSizes.lg],
        [18, 24, 48],
      );
    });

    test('When its type scale is read, '
        'Then each style has the documented size, height, and weight', () {
      // Given
      final typography = brand.typography;

      // When
      final styles = [
        typography.display,
        typography.headline,
        typography.title,
        typography.body,
        typography.bodyStrong,
        typography.label,
        typography.caption,
      ];

      // Then
      expect(styles.map((style) => style.fontSize), [
        32,
        24,
        20,
        16,
        16,
        14,
        12,
      ]);
      expect(styles.map((style) => style.lineHeight), [
        1.25,
        1.3,
        1.3,
        1.5,
        1.5,
        1.4,
        1.4,
      ]);
      expect(styles.map((style) => style.fontWeight), [
        FontWeight.w700,
        FontWeight.w700,
        FontWeight.w600,
        FontWeight.w400,
        FontWeight.w600,
        FontWeight.w600,
        FontWeight.w400,
      ]);
      expect(styles.every((style) => style.fontFamily == null), isTrue);
      expect(styles.every((style) => style.letterSpacing == 0), isTrue);
    });

    test('When it is printed, Then only its id appears', () {
      // Given / When
      final text = brand.toString();

      // Then
      expect(text, 'DsBrand(white_label)');
    });
  });

  group('Given two brands built from the same values', () {
    test(
      'When they are compared, Then they are equal with equal hash codes',
      () {
        // Given
        final a = DsTestBrands.variant(brandScale: DsTestBrands.greenScale);
        final b = DsTestBrands.variant(brandScale: DsTestBrands.greenScale);

        // When / Then
        expect(a, b);
        expect(a.hashCode, b.hashCode);
      },
    );

    test('When one value differs, Then they are not equal', () {
      // Given
      final a = DsTestBrands.variant();
      final b = DsTestBrands.variant(spacing: DsTestBrands.wideSpacing);

      // When / Then
      expect(a, isNot(b));
    });
  });

  group('Given values outside their valid range', () {
    test('When a negative dimension is used, Then an assertion fails', () {
      // Given
      final negative = -1.0;

      // When / Then
      expect(
        () => DsSpacing(
          xxs: negative,
          xs: 8,
          sm: 12,
          md: 16,
          lg: 24,
          xl: 32,
          xxl: 48,
        ),
        throwsAssertionError,
      );
      expect(
        () => DsRadius(sm: negative, md: 8, lg: 16, pill: 999),
        throwsAssertionError,
      );
      expect(
        () => DsBorderWidths(thin: negative, thick: 2),
        throwsAssertionError,
      );
      expect(
        () => DsIconSizes(sm: negative, md: 24, lg: 48),
        throwsAssertionError,
      );
    });

    test('When an opacity is outside 0 to 1, Then an assertion fails', () {
      // Given
      final tooHigh = 1.5;

      // When / Then
      expect(
        () => DsOpacities(hovered: tooHigh, focused: 0.12, pressed: 0.12),
        throwsAssertionError,
      );
    });

    test('When a font size is 0, Then an assertion fails', () {
      // Given
      final zero = 0.0;

      // When / Then
      expect(
        () => DsTypeStyle(
          fontSize: zero,
          fontWeight: FontWeight.w400,
          lineHeight: 1.5,
          letterSpacing: 0,
        ),
        throwsAssertionError,
      );
    });
  });
}
