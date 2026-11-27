// Feature: The design system derives the semantic color roles of light and
// dark mode from a brand's primitive tokens, with one mapping it owns, and
// never adjusts a primitive.
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/ds_test_brands.dart';

void main() {
  group('Given the white-label brand', () {
    const brand = DsBrand.whiteLabel;
    final n = brand.colors.neutral;
    final b = brand.colors.brand;
    final s = brand.colors.success;
    final w = brand.colors.warning;
    final e = brand.colors.error;
    final i = brand.colors.info;

    final expected = <DsColorRole, (Color, Color)>{
      DsColorRole.background: (n.shade50, n.shade900),
      DsColorRole.surface: (n.shade0, n.shade800),
      DsColorRole.surfaceVariant: (n.shade100, n.shade700),
      DsColorRole.border: (n.shade300, n.shade600),
      DsColorRole.textPrimary: (n.shade900, n.shade50),
      DsColorRole.textSecondary: (n.shade600, n.shade300),
      DsColorRole.textDisabled: (n.shade400, n.shade500),
      DsColorRole.actionPrimary: (b.shade600, b.shade300),
      DsColorRole.actionPrimaryPressed: (b.shade700, b.shade200),
      DsColorRole.actionDisabled: (n.shade200, n.shade700),
      DsColorRole.focus: (b.shade600, b.shade300),
      DsColorRole.infoBackground: (i.shade100, i.shade700),
      DsColorRole.infoForeground: (i.shade700, i.shade100),
      DsColorRole.successBackground: (s.shade100, s.shade700),
      DsColorRole.successForeground: (s.shade700, s.shade100),
      DsColorRole.warningBackground: (w.shade100, w.shade700),
      DsColorRole.warningForeground: (w.shade700, w.shade100),
      DsColorRole.errorBackground: (e.shade100, e.shade700),
      DsColorRole.errorForeground: (e.shade700, e.shade100),
    };

    for (final MapEntry(key: role, value: (light, dark)) in expected.entries) {
      test('When the $role role is resolved, '
          'Then light and dark use the mapped primitive steps', () {
        // Given
        final lightColors = DsTokens.resolve(brand, Brightness.light).colors;
        final darkColors = DsTokens.resolve(brand, Brightness.dark).colors;

        // When / Then
        expect(lightColors.role(role), light);
        expect(darkColors.role(role), dark);
      });
    }

    test(
      'When textOnAction is resolved, '
      'Then it is the neutral end with more contrast on the action color',
      () {
        // Given / When
        final light = DsTokens.resolve(brand, Brightness.light).colors;
        final dark = DsTokens.resolve(brand, Brightness.dark).colors;

        // Then
        expect(light.textOnAction, n.shade0);
        expect(dark.textOnAction, n.shade900);
      },
    );

    test('When every role is listed, Then there are 20 roles', () {
      // Given / When
      final roles = DsColorRole.values;

      // Then
      expect(roles, hasLength(20));
    });
  });

  group('Given a brand whose action color is very light', () {
    const pale = Color(0xFFB3CDF9);
    final brand = DsTestBrands.variant(
      id: 'pale',
      brandScale: DsBrandScale(
        shade50: pale,
        shade100: pale,
        shade200: pale,
        shade300: pale,
        shade400: pale,
        shade500: pale,
        shade600: pale,
        shade700: pale,
        shade800: pale,
        shade900: pale,
      ),
    );

    test('When the light roles are resolved, '
        'Then the action color is used unchanged and text on it is dark', () {
      // Given / When
      final colors = DsTokens.resolve(brand, Brightness.light).colors;

      // Then
      expect(colors.actionPrimary, pale);
      expect(colors.textOnAction, brand.colors.neutral.shade900);
    });
  });
}
