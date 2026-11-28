// The overlay's colors are fixed debug colors, not brand tokens: they must
// look the same in every brand, so a reviewer can read an atom's outline the
// same way on any screen. Release builds never show them.
// ignore_for_file: design_system_lints/ds_avoid_literal_color
/// @docImport 'ds_guidelines_frame.dart';
library;

import 'package:flutter/painting.dart';

import '../catalog/ds_component_info.dart';

/// Fixed debug colors of the developer guidelines overlay.
///
/// This is internal to the design system and is not exported. The colors
/// don't follow the brand, so outlines look the same in every brand.
abstract final class DsGuidelinesColors {
  /// Outline color of atoms: pink.
  static const Color atom = Color(0xFFE91E63);

  /// Outline color of molecules: blue.
  static const Color molecule = Color(0xFF1E88E5);

  /// Outline color of organisms: orange.
  static const Color organism = Color(0xFFFB8C00);

  /// Outline color of templates: green.
  static const Color template = Color(0xFF43A047);

  /// Translucent violet that tints spacing gaps.
  static const Color gapTint = Color(0x598E24AA);

  /// Returns the outline color of [level], as [DsGuidelinesFrame] draws it.
  ///
  /// Parameters:
  /// * [level] - The component's atomic level.
  static Color forLevel(DsComponentLevel level) => switch (level) {
    DsComponentLevel.atom => atom,
    DsComponentLevel.molecule => molecule,
    DsComponentLevel.organism => organism,
    DsComponentLevel.template => template,
  };
}
