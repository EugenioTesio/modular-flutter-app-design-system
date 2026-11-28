// Feature: A real visual change is caught
// (contracts/golden-tests.md, Required tests; quickstart V6).
//
// The primary-color list holds the images where the primary-action color
// fills a large area. Each of them must fail when the Forest brand's
// primary-action steps change: brand 600 in light mode and brand 300 in
// dark mode. The default-size loading indicator is left off: its ring fills
// under 5% of its image, so it stays within the tolerance.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/ds_component_cases.dart';
import '../support/ds_golden_comparator.dart';
import '../support/ds_golden_matrix.dart';
import '../support/ds_test_brands.dart';

/// The images where the primary-action color fills a large area, and the
/// brand that changes that color.
abstract final class _PrimaryColorList {
  /// Component states on the list, checked in light and dark mode.
  static final List<(DsComponentCases, String)> states = [
    (DsComponentCases.button, 'primary'),
    (DsComponentCases.button, 'loading'),
    (DsComponentCases.loadingIndicator, 'spinning at the large icon size'),
  ];

  /// The Forest brand with the brand steps behind the primary-action color
  /// replaced by magenta: 600 (light mode) and 300 (dark mode).
  static DsBrand get changedForest {
    final forest = DsTestBrands.forest;
    final scale = forest.colors.brand;
    return DsBrand(
      id: forest.id,
      name: forest.name,
      colors: DsBrandColors(
        brand: DsBrandScale(
          shade50: scale.shade50,
          shade100: scale.shade100,
          shade200: scale.shade200,
          shade300: const Color(0xFFE48AB9),
          shade400: scale.shade400,
          shade500: scale.shade500,
          shade600: const Color(0xFF8E1B5C),
          shade700: scale.shade700,
          shade800: scale.shade800,
          shade900: scale.shade900,
        ),
        neutral: forest.colors.neutral,
        success: forest.colors.success,
        warning: forest.colors.warning,
        error: forest.colors.error,
        info: forest.colors.info,
      ),
      typography: forest.typography,
      spacing: forest.spacing,
      radius: forest.radius,
      borderWidths: forest.borderWidths,
      opacities: forest.opacities,
      iconSizes: forest.iconSizes,
    );
  }
}

void main() {
  group('Given the Forest brand with its primary-action color changed', () {
    late Directory output;

    setUp(() {
      output = Directory.systemTemp.createTempSync('ds_golden_sensitivity');
    });

    tearDown(() => output.deleteSync(recursive: true));

    for (final (cases, state) in _PrimaryColorList.states) {
      for (final brightness in Brightness.values) {
        final path = DsGoldenMatrix.imagePath(
          cases.info,
          state,
          DsTestBrands.forest,
          brightness,
        );
        testWidgets(
          'When the $path golden runs, Then it fails by more than 5%',
          (tester) async {
            // Given
            final golden = File('test/components/$path').absolute.uri;
            final comparator = DsGoldenComparator(
              output.uri.resolve('golden_sensitivity_test.dart'),
            );
            final theme = DsGoldenMatrix.themeFor(
              _PrimaryColorList.changedForest,
              brightness,
            );

            // When
            await DsGoldenMatrix.pump(
              tester,
              cases.states[state]!(),
              theme: theme,
              surfaceSize: cases.goldenSurfaceSize,
            );
            final image = await DsGoldenMatrix.capture(tester);
            final outcome = await tester.runAsync(() async {
              final png = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              image.dispose();
              try {
                await comparator.compare(png!.buffer.asUint8List(), golden);
                return 'passed';
              } on FlutterError catch (error) {
                return error.message;
              }
            });

            // Then
            expect(
              outcome,
              contains('> 5.00% allowed'),
              reason: 'The changed primary color must not pass $path.',
            );
            expect(Directory('${output.path}/failures').existsSync(), isTrue);
          },
          tags: DsGoldenMatrix.tag,
          skip: autoUpdateGoldenFiles,
        );
      }
    }
  });
}
