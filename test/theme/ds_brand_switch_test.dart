// Feature: The App Shell brands the whole app from a brand file, and replacing
// the brand at runtime updates every component on the next frame, with no
// animation and no lost state.
import 'package:design_system/design_system.dart';
import 'package:design_system/src/theme/ds_debug_warnings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../brand_file/brand_file_fixtures.dart';

DsBrand _forest() => switch (DsBrandParser.parseMap(
  BrandFileFixtures.read('sample_forest.json'),
)) {
  DsBrandParseSuccess(:final brand) => brand,
  DsBrandParseFailure(:final exceptions) => throw StateError(
    exceptions.join('; '),
  ),
};

/// A screen with every kind of token use the tests below check.
final class _Screen extends StatelessWidget {
  const _Screen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DsButton(label: 'Pay', onPressed: () {}),
          const DsGap(DsSpacingStep.md),
          const DsTextField(label: 'Note'),
          const DsCard(child: Text('Card')),
          Expanded(
            child: ListView(
              children: [
                for (var row = 0; row < 30; row++)
                  DsListTile(title: 'Row $row'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _app(DsBrand brand, {ThemeMode themeMode = ThemeMode.light}) =>
    MaterialApp(
      theme: DsTheme.light(brand: brand),
      darkTheme: DsTheme.dark(brand: brand),
      themeMode: themeMode,
      themeAnimationStyle: AnimationStyle.noAnimation,
      home: const _Screen(),
    );

Color? _buttonFill(WidgetTester tester) => tester
    .widget<Material>(
      find.descendant(
        of: find.byType(DsButton),
        matching: find.byType(Material),
      ),
    )
    .color;

void main() {
  final forest = _forest();

  setUp(DsDebugWarnings.debugReset);

  group('Given the App Shell placed the Forest brand from its file', () {
    testWidgets('When the screen renders, '
        'Then every component uses Forest tokens', (tester) async {
      // Given / When
      await tester.pumpWidget(_app(forest));

      // Then
      expect(_buttonFill(tester), forest.colors.brand.shade600);
      expect(tester.getSize(find.byType(DsGap)), const Size(20, 20));
      final cardText = tester.getTopLeft(find.text('Card'));
      final card = tester.getTopLeft(find.byType(DsCard));
      expect(cardText - card, const Offset(20, 20));
      expect(tester.takeException(), isNull);
    });

    testWidgets('When the brand is replaced by the white label, '
        'Then one frame later every component uses it and state is kept', (
      tester,
    ) async {
      // Given
      await tester.pumpWidget(_app(forest));
      await tester.enterText(find.byType(TextField), 'Rent');
      await tester.drag(find.byType(ListView), const Offset(0, -120));
      await tester.pump();
      final scrollable = tester.state<ScrollableState>(
        find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
      final offset = scrollable.position.pixels;
      expect(offset, greaterThan(0));

      // When
      await tester.pumpWidget(_app(DsBrand.whiteLabel));

      // Then
      expect(_buttonFill(tester), DsBrand.whiteLabel.colors.brand.shade600);
      expect(find.text('Rent'), findsOneWidget);
      expect(scrollable.position.pixels, offset);
    });

    testWidgets('When the app switches to dark mode, '
        'Then one frame later components use Forest dark colors', (
      tester,
    ) async {
      // Given
      await tester.pumpWidget(_app(forest));

      // When
      await tester.pumpWidget(_app(forest, themeMode: ThemeMode.dark));

      // Then
      expect(_buttonFill(tester), forest.colors.brand.shade300);
    });

    testWidgets('When text uses the Forest font, which no app bundles, '
        'Then it renders with the fallback font and no error', (tester) async {
      // Given
      expect(forest.typography.body.fontFamily, 'Forest Sans');
      // The golden tests register Roboto as "Forest Sans", so this test
      // renames the family to one that no test registers.
      final file = BrandFileFixtures.read('sample_forest.json');
      BrandFileFixtures.setValue(file, 'font.family.base', [
        'Unbundled Forest Sans',
        'system-ui',
      ]);
      final unbundled = switch (DsBrandParser.parseMap(file)) {
        DsBrandParseSuccess(:final brand) => brand,
        DsBrandParseFailure(:final exceptions) => throw StateError(
          exceptions.join('; '),
        ),
      };
      expect(unbundled.typography.body.fontFamily, 'Unbundled Forest Sans');

      // When
      await tester.pumpWidget(_app(unbundled));

      // Then
      expect(find.text('Card'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
