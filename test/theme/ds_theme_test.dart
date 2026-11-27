// Feature: DsTheme builds a full ThemeData for a brand and a mode, so design
// system components and Material widgets inside it follow that brand.
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/ds_test_brands.dart';

void main() {
  group('Given no brand argument', () {
    test('When the light and dark themes are built, '
        'Then they carry the white label in their mode', () {
      // Given / When
      final light = DsTheme.light();
      final dark = DsTheme.dark();

      // Then
      final lightTokens = light.extension<DsTokens>()!;
      final darkTokens = dark.extension<DsTokens>()!;
      expect(lightTokens.brand, DsBrand.whiteLabel);
      expect(lightTokens.brightness, Brightness.light);
      expect(light.brightness, Brightness.light);
      expect(darkTokens.brand, DsBrand.whiteLabel);
      expect(darkTokens.brightness, Brightness.dark);
      expect(dark.brightness, Brightness.dark);
    });
  });

  group('Given a green brand', () {
    final brand = DsTestBrands.variant(brandScale: DsTestBrands.greenScale);

    test('When forBrightness builds a theme, '
        'Then it equals the matching light or dark theme', () {
      // Given / When
      final light = DsTheme.forBrightness(brand, Brightness.light);
      final dark = DsTheme.forBrightness(brand, Brightness.dark);

      // Then
      expect(
        light.extension<DsTokens>(),
        DsTheme.light(brand: brand).extension<DsTokens>(),
      );
      expect(
        dark.extension<DsTokens>(),
        DsTheme.dark(brand: brand).extension<DsTokens>(),
      );
    });

    test(
      'When the light theme is built, '
      'Then Material colors, cursor, selection, and text follow the brand',
      () {
        // Given
        final theme = DsTheme.light(brand: brand);
        final tokens = theme.extension<DsTokens>()!;

        // When
        final scheme = theme.colorScheme;
        final selection = theme.textSelectionTheme;

        // Then
        expect(scheme.primary, brand.colors.brand.shade600);
        expect(scheme.onPrimary, tokens.colors.textOnAction);
        expect(scheme.surface, tokens.colors.surface);
        expect(theme.scaffoldBackgroundColor, tokens.colors.background);
        expect(selection.cursorColor, tokens.colors.focus);
        expect(selection.selectionHandleColor, tokens.colors.focus);
        expect(theme.textTheme.bodyLarge?.fontSize, 16);
        expect(theme.textTheme.bodyLarge?.color, tokens.colors.textPrimary);
      },
    );

    testWidgets('When a Material TextField is shown in the theme, '
        'Then its cursor uses the brand focus color', (tester) async {
      // Given
      final theme = DsTheme.light(brand: brand);

      // When
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: TextField()),
        ),
      );

      // Then
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.cursorColor, brand.colors.brand.shade600);
    });
  });
}
