import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/painting.dart';

/// Brands the package's tests run against.
abstract final class DsTestBrands {
  /// Every repository test brand: the white label and the Forest sample,
  /// read from `widgetbook/brands/` through the parser. The accessibility
  /// harness and the golden images run each case for each of them, in light
  /// and dark mode.
  static final List<DsBrand> all = [
    fromFile('white_label.json'),
    fromFile('sample_forest.json'),
  ];

  /// The Forest sample brand.
  static DsBrand get forest => all[1];

  /// Returns the brand of a file in `widgetbook/brands/`.
  ///
  /// Parameters:
  /// * [fileName] - The file's name, such as `sample_forest.json`.
  ///
  /// Throws a [StateError] naming every problem when the file is invalid.
  static DsBrand fromFile(String fileName) {
    final json = File('widgetbook/brands/$fileName').readAsStringSync();
    return switch (DsBrandParser.parseJson(json)) {
      DsBrandParseSuccess(:final brand) => brand,
      DsBrandParseFailure(:final exceptions) => throw StateError(
        '$fileName is not a valid brand file: ${exceptions.join('; ')}',
      ),
    };
  }

  /// A green brand scale, used to tell a brand apart from the white label.
  static const DsBrandScale greenScale = DsBrandScale(
    shade50: Color(0xFFEDF7F2),
    shade100: Color(0xFFD2EDE0),
    shade200: Color(0xFFA6DBC2),
    shade300: Color(0xFF6FC39D),
    shade400: Color(0xFF3FA57A),
    shade500: Color(0xFF1C8A61),
    shade600: Color(0xFF0B6E4F),
    shade700: Color(0xFF08573F),
    shade800: Color(0xFF064030),
    shade900: Color(0xFF042A20),
  );

  /// Returns a copy of the white label with the given groups replaced.
  ///
  /// Parameters:
  /// * [id] - The copy's id. Defaults to `variant`.
  /// * [brandScale] - Optional brand color scale.
  /// * [spacing] - Optional spacing scale.
  /// * [radius] - Optional corner-radius scale.
  static DsBrand variant({
    String id = 'variant',
    DsBrandScale? brandScale,
    DsSpacing? spacing,
    DsRadius? radius,
  }) {
    const base = DsBrand.whiteLabel;
    return DsBrand(
      id: id,
      name: 'Variant',
      colors: DsBrandColors(
        brand: brandScale ?? base.colors.brand,
        neutral: base.colors.neutral,
        success: base.colors.success,
        warning: base.colors.warning,
        error: base.colors.error,
        info: base.colors.info,
      ),
      typography: base.typography,
      spacing: spacing ?? base.spacing,
      radius: radius ?? base.radius,
      borderWidths: base.borderWidths,
      opacities: base.opacities,
      iconSizes: base.iconSizes,
    );
  }

  /// A spacing scale that differs from the white label's at every step.
  static const DsSpacing wideSpacing = DsSpacing(
    xxs: 4,
    xs: 8,
    sm: 12,
    md: 20,
    lg: 28,
    xl: 36,
    xxl: 52,
  );
}
