import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ds_component_cases.dart';
import 'ds_test_brands.dart';

/// Golden images for every component state, test brand, and mode.
///
/// Each image holds one component in one state, cropped to the component
/// plus the brand's `spacing.md` padding, on the mode's `background` role.
/// It is drawn on a fixed surface per component at a pixel ratio of 2.0, and
/// lands at `goldens/<component>/<state>__<brand id>__<light|dark>.png`
/// next to the test file. Indeterminate progress indicators are captured at
/// a fixed [tick].
///
/// Text is drawn with the test fonts of `DsTestFonts`. A brand that names
/// only generic families, such as the white label, means "the platform
/// font". Widget tests emulate Android, whose platform font is Roboto, but
/// the test engine draws family-less text as blocks, so [themeFor] gives
/// such styles the `Roboto` family.
abstract final class DsGoldenMatrix {
  /// Pixel ratio of every golden image.
  static const double devicePixelRatio = 2.0;

  /// Time pumped after the first frame, so animations settle and spinners
  /// are captured at the same point of their cycle.
  static const Duration tick = Duration(milliseconds: 500);

  /// Test tag of every golden test, declared in `dart_test.yaml`.
  static const String tag = 'golden';

  static const Key _boundaryKey = ValueKey('ds_golden_boundary');

  /// Declares one golden test per state of [cases], per test brand, and per
  /// mode, tagged [tag].
  ///
  /// Parameters:
  /// * [cases] - The component's states, shared with the accessibility
  ///   harness.
  static void describeGoldens(DsComponentCases cases) {
    for (final MapEntry(key: state, value: build) in cases.states.entries) {
      for (final brand in DsTestBrands.all) {
        for (final brightness in Brightness.values) {
          final path = DsGoldenMatrix.imagePath(
            cases.info,
            state,
            brand,
            brightness,
          );
          testWidgets('When it is $state in ${brand.id} ${brightness.name}, '
              'Then it matches $path', (tester) async {
            // Given
            final theme = DsGoldenMatrix.themeFor(brand, brightness);

            // When
            await DsGoldenMatrix.pump(
              tester,
              build(),
              theme: theme,
              surfaceSize: cases.goldenSurfaceSize,
            );
            final image = await DsGoldenMatrix.capture(tester);

            // Then
            try {
              await expectLater(image, matchesGoldenFile(path));
            } finally {
              image.dispose();
            }
          }, tags: tag);
        }
      }
    }
  }

  /// Returns the golden image path of one state, brand, and mode, relative
  /// to the test file's folder.
  ///
  /// Parameters:
  /// * [info] - The component's catalog entry, which names the folder.
  /// * [state] - The state's key in its [DsComponentCases.states].
  /// * [brand] - The brand the image is drawn in.
  /// * [brightness] - The mode the image is drawn in.
  static String imagePath(
    DsComponentInfo info,
    String state,
    DsBrand brand,
    Brightness brightness,
  ) =>
      'goldens/${DsGoldenMatrix.componentFolder(info)}/'
      '${DsGoldenMatrix.stateName(state)}__${brand.id}__${brightness.name}.png';

  /// Returns the folder of a component's golden images, such as `ds_button`
  /// for `DsButton`.
  ///
  /// Parameters:
  /// * [info] - The component's catalog entry.
  static String componentFolder(DsComponentInfo info) => info.name
      .replaceAllMapped(
        RegExp('(?<=[a-z0-9])([A-Z])'),
        (match) => '_${match[1]}',
      )
      .toLowerCase();

  /// Returns the file-name form of a state key, such as
  /// `showing_an_error` for "showing an error".
  ///
  /// Parameters:
  /// * [state] - The state's key in its [DsComponentCases.states].
  static String stateName(String state) => state
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  /// Returns the theme golden images draw [brand] with in [brightness].
  ///
  /// It is [DsTheme.forBrightness], except that styles with no font family
  /// get `Roboto`, the platform font of the Android target that widget
  /// tests emulate.
  ///
  /// Parameters:
  /// * [brand] - The brand to draw.
  /// * [brightness] - The mode to draw.
  static ThemeData themeFor(DsBrand brand, Brightness brightness) {
    DsTypeStyle withFamily(DsTypeStyle style) => style.fontFamily != null
        ? style
        : DsTypeStyle(
            fontFamily: 'Roboto',
            fontFamilyFallback: style.fontFamilyFallback,
            fontSize: style.fontSize,
            fontWeight: style.fontWeight,
            lineHeight: style.lineHeight,
            letterSpacing: style.letterSpacing,
          );
    final type = brand.typography;
    final drawn = DsBrand(
      id: brand.id,
      name: brand.name,
      colors: brand.colors,
      typography: DsBrandTypography(
        display: withFamily(type.display),
        headline: withFamily(type.headline),
        title: withFamily(type.title),
        body: withFamily(type.body),
        bodyStrong: withFamily(type.bodyStrong),
        label: withFamily(type.label),
        caption: withFamily(type.caption),
      ),
      spacing: brand.spacing,
      radius: brand.radius,
      borderWidths: brand.borderWidths,
      opacities: brand.opacities,
      iconSizes: brand.iconSizes,
    );
    return DsTheme.forBrightness(drawn, brightness);
  }

  /// Pumps [child] the way golden images draw it, then waits one [tick].
  ///
  /// Parameters:
  /// * [tester] - The test's widget tester.
  /// * [child] - The component in one state.
  /// * [theme] - The brand and mode, from [themeFor].
  /// * [surfaceSize] - Logical size of the screen.
  static Future<void> pump(
    WidgetTester tester,
    Widget child, {
    required ThemeData theme,
    required Size surfaceSize,
  }) async {
    tester.view
      ..devicePixelRatio = devicePixelRatio
      ..physicalSize = surfaceSize * devicePixelRatio;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        // A new app per theme, so no theme animation or state carries over.
        key: ObjectKey(theme),
        debugShowCheckedModeBanner: false,
        theme: theme,
        themeAnimationStyle: AnimationStyle.noAnimation,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: RepaintBoundary(
              key: _boundaryKey,
              child: _DsGoldenFrame(child: child),
            ),
          ),
        ),
      ),
    );
    await tester.pump(tick);
  }

  /// Captures the component that [pump] drew, at [devicePixelRatio].
  ///
  /// Parameters:
  /// * [tester] - The test's widget tester, after [pump].
  ///
  /// Returns the image, which the caller disposes.
  static Future<ui.Image> capture(WidgetTester tester) async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(_boundaryKey),
    );
    final image = await tester.runAsync(
      () => boundary.toImage(pixelRatio: devicePixelRatio),
    );
    return image!;
  }
}

/// The component on the mode's background, padded by the brand's
/// `spacing.md`.
class _DsGoldenFrame extends StatelessWidget {
  const _DsGoldenFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.dsColors.background,
    child: Padding(
      padding: context.dsSpacing.all(DsSpacingStep.md),
      child: child,
    ),
  );
}
