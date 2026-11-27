// Feature: A micro app wraps one screen, or a group of screens, in its own
// brand. Every component inside uses the nearest brand, overlays keep it,
// and it follows the app's light or dark mode.
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/ds_test_brands.dart';

/// Widget that reports the tokens it reads.
final class _Probe extends StatelessWidget {
  const _Probe(this.onRead);

  final void Function(DsTokens tokens) onRead;

  @override
  Widget build(BuildContext context) {
    onRead(context.dsTokens);
    return const SizedBox.shrink();
  }
}

/// An app-specific theme extension, which a brand area must keep.
final class _AppExtension extends ThemeExtension<_AppExtension> {
  const _AppExtension();

  @override
  _AppExtension copyWith() => this;

  @override
  _AppExtension lerp(
    covariant ThemeExtension<_AppExtension>? other,
    double t,
  ) => this;
}

/// A red brand scale, for a third brand in nested scopes.
const _redScale = DsBrandScale(
  shade50: Color(0xFFFDECEC),
  shade100: Color(0xFFFAD0D0),
  shade200: Color(0xFFF4A3A3),
  shade300: Color(0xFFEC7070),
  shade400: Color(0xFFDE4545),
  shade500: Color(0xFFC62828),
  shade600: Color(0xFFA51F1F),
  shade700: Color(0xFF861818),
  shade800: Color(0xFF661212),
  shade900: Color(0xFF470C0C),
);

Widget _app(
  Widget home, {
  DsBrand brand = DsBrand.whiteLabel,
  ThemeMode themeMode = ThemeMode.light,
}) => MaterialApp(
  theme: DsTheme.light(brand: brand),
  darkTheme: DsTheme.dark(brand: brand),
  themeMode: themeMode,
  themeAnimationStyle: AnimationStyle.noAnimation,
  home: Scaffold(body: home),
);

void main() {
  final forest = DsTestBrands.forest;
  final red = DsTestBrands.variant(id: 'red', brandScale: _redScale);

  group('Given the App Shell brand and a screen wrapped in Forest', () {
    testWidgets('When both render, '
        'Then components inside use Forest and outside use the App Shell '
        'brand', (tester) async {
      // Given
      DsTokens? inside;
      DsTokens? outside;

      // When
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              _Probe((tokens) => outside = tokens),
              DsBrandScope(
                brand: forest,
                child: _Probe((tokens) => inside = tokens),
              ),
            ],
          ),
        ),
      );

      // Then
      expect(inside?.brand, forest);
      expect(inside?.colors.actionPrimary, forest.colors.brand.shade600);
      expect(outside?.brand, DsBrand.whiteLabel);
    });

    testWidgets('When a DsButton renders inside the scope, '
        'Then its fill is the Forest action color', (tester) async {
      // Given
      final button = DsButton(label: 'Pay', onPressed: () {});

      // When
      await tester.pumpWidget(_app(DsBrandScope(brand: forest, child: button)));

      // Then
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(DsButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, forest.colors.brand.shade600);
    });
  });

  group('Given brands nested three levels deep', () {
    testWidgets('When components render at each level, '
        'Then each uses the nearest brand', (tester) async {
      // Given
      final read = <String, DsBrand>{};

      // When
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              _Probe((tokens) => read['top'] = tokens.brand),
              DsBrandScope(
                brand: forest,
                child: Column(
                  children: [
                    _Probe((tokens) => read['middle'] = tokens.brand),
                    DsBrandScope(
                      brand: red,
                      child: _Probe((tokens) => read['inner'] = tokens.brand),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      // Then
      expect(read, {'top': DsBrand.whiteLabel, 'middle': forest, 'inner': red});
    });
  });

  group('Given a screen wrapped in Forest that opens overlays', () {
    for (final (name, open) in <(String, void Function(BuildContext, Widget))>[
      (
        'a dialog',
        (context, child) => showDialog<void>(
          context: context,
          builder: (_) => Dialog(child: child),
        ),
      ),
      (
        'a bottom sheet',
        (context, child) =>
            showModalBottomSheet<void>(context: context, builder: (_) => child),
      ),
      (
        'a menu',
        (context, child) => showMenu<void>(
          context: context,
          position: RelativeRect.fill,
          items: [PopupMenuItem<void>(child: child)],
        ),
      ),
    ]) {
      testWidgets('When it opens $name, Then the overlay uses Forest', (
        tester,
      ) async {
        // Given
        DsTokens? read;
        await tester.pumpWidget(
          _app(
            DsBrandScope(
              brand: forest,
              child: Builder(
                builder: (context) => TextButton(
                  onPressed: () =>
                      open(context, _Probe((tokens) => read = tokens)),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        // When
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Then
        expect(read?.brand, forest);
      });
    }
  });

  group('Given a screen wrapped in Forest in a light app', () {
    testWidgets('When the app switches to dark mode, '
        'Then the screen uses Forest dark colors on the next frame', (
      tester,
    ) async {
      // Given
      DsTokens? read;
      Widget home() =>
          DsBrandScope(brand: forest, child: _Probe((tokens) => read = tokens));
      await tester.pumpWidget(_app(home()));

      // When
      await tester.pumpWidget(_app(home(), themeMode: ThemeMode.dark));

      // Then
      expect(read?.brightness, Brightness.dark);
      expect(read?.colors.actionPrimary, forest.colors.brand.shade300);
    });

    testWidgets('When the App Shell replaces its top-level brand, '
        'Then the screen keeps Forest', (tester) async {
      // Given
      DsTokens? read;
      Widget home() =>
          DsBrandScope(brand: forest, child: _Probe((tokens) => read = tokens));
      await tester.pumpWidget(_app(home()));

      // When
      await tester.pumpWidget(_app(home(), brand: red));

      // Then
      expect(read?.brand, forest);
    });

    testWidgets('When the scope switches to another brand, '
        'Then the screen uses it on the next frame', (tester) async {
      // Given
      DsTokens? read;
      Widget home(DsBrand brand) =>
          DsBrandScope(brand: brand, child: _Probe((tokens) => read = tokens));
      await tester.pumpWidget(_app(home(forest)));

      // When
      await tester.pumpWidget(_app(home(red)));

      // Then
      expect(read?.brand, red);
    });
  });

  group('Given a group of screens with a shared layout wrapped in Forest', () {
    testWidgets('When the group navigates to its second screen, '
        'Then that screen and the shared layout both use Forest', (
      tester,
    ) async {
      // Given
      DsTokens? layout;
      DsTokens? second;
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        _app(
          DsBrandScope(
            brand: forest,
            child: Column(
              children: [
                _Probe((tokens) => layout = tokens),
                Expanded(
                  child: Navigator(
                    key: navigator,
                    onGenerateRoute: (settings) => MaterialPageRoute<void>(
                      builder: (_) => const Text('First'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // When
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => _Probe((tokens) => second = tokens),
        ),
      );
      await tester.pumpAndSettle();

      // Then
      expect(layout?.brand, forest);
      expect(second?.brand, forest);
    });
  });

  group('Given an App Shell theme with its own platform and extension', () {
    testWidgets('When a scope places Forest, '
        'Then the scope keeps the platform and the app extension', (
      tester,
    ) async {
      // Given
      ThemeData? inside;
      final appTheme = DsTheme.light().copyWith(
        platform: TargetPlatform.iOS,
        extensions: [
          ...DsTheme.light().extensions.values,
          const _AppExtension(),
        ],
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme,
          home: DsBrandScope(
            brand: forest,
            child: Builder(
              builder: (context) {
                inside = Theme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      // Then
      expect(inside?.platform, TargetPlatform.iOS);
      expect(inside?.extension<_AppExtension>(), isNotNull);
      expect(inside?.extension<DsTokens>()?.brand, forest);
    });
  });
}
