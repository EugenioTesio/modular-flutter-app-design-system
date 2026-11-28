// Feature: Components read tokens from the nearest brand above them, and fall
// back to the white label, with one debug warning, when there is none.
import 'package:design_system/design_system.dart';
import 'package:design_system/src/theme/ds_debug_warnings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/ds_test_brands.dart';

/// Widget that records the tokens it reads, for the tests below.
final class _TokenProbe extends StatelessWidget {
  const _TokenProbe(this.onRead);

  final void Function(DsTokens tokens, DsColors colors, DsSpacing spacing)
  onRead;

  @override
  Widget build(BuildContext context) {
    onRead(context.dsTokens, context.dsColors, context.dsSpacing);
    return const SizedBox.shrink();
  }
}

/// Runs [body] while recording what debugPrint prints, and restores
/// debugPrint before the test ends, as widget tests require.
Future<List<String>> _recordPrints(Future<void> Function() body) async {
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

void main() {
  setUp(DsDebugWarnings.debugReset);

  group('Given an app themed with a green brand', () {
    final brand = DsTestBrands.variant(
      brandScale: DsTestBrands.greenScale,
      spacing: DsTestBrands.wideSpacing,
    );

    testWidgets('When a widget reads the getters, '
        'Then they return the brand tokens', (tester) async {
      // Given
      DsTokens? tokens;
      DsColors? colors;
      DsSpacing? spacing;

      // When
      final printed = await _recordPrints(
        () => tester.pumpWidget(
          MaterialApp(
            theme: DsTheme.light(brand: brand),
            home: _TokenProbe(
              (t, c, s) => (tokens, colors, spacing) = (t, c, s),
            ),
          ),
        ),
      );

      // Then
      expect(tokens?.brand, brand);
      expect(colors?.actionPrimary, brand.colors.brand.shade600);
      expect(spacing?.md, 20);
      expect(printed, isEmpty);
    });

    testWidgets('When a nested Theme holds another brand, '
        'Then the nearest one wins', (tester) async {
      // Given
      DsTokens? tokens;

      // When
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(brand: brand),
          home: Theme(
            data: DsTheme.dark(),
            child: _TokenProbe((t, _, _) => tokens = t),
          ),
        ),
      );

      // Then
      expect(tokens?.brand, DsBrand.whiteLabel);
      expect(tokens?.brightness, Brightness.dark);
    });
  });

  group('Given an app whose theme has no design system tokens', () {
    testWidgets('When widgets read the getters in light and dark mode, '
        'Then they get the white label and one warning per run', (
      tester,
    ) async {
      // Given
      final read = <DsTokens>[];

      // When
      final printed = await _recordPrints(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            themeAnimationStyle: AnimationStyle.noAnimation,
            home: Column(
              children: [
                _TokenProbe((t, _, _) => read.add(t)),
                _TokenProbe((t, _, _) => read.add(t)),
              ],
            ),
          ),
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            themeAnimationStyle: AnimationStyle.noAnimation,
            home: _TokenProbe((t, _, _) => read.add(t)),
          ),
        );
      });

      // Then
      expect(read.map((t) => t.brand), everyElement(DsBrand.whiteLabel));
      expect(read.first.brightness, Brightness.light);
      expect(read.last.brightness, Brightness.dark);
      expect(printed, hasLength(1));
      expect(printed.single, contains('DsTheme'));
    });
  });
}
