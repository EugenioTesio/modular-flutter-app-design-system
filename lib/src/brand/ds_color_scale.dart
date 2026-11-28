/// @docImport '../theme/ds_theme_context.dart';
/// @docImport '../tokens/ds_colors.dart';
/// @docImport 'ds_brand_colors.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Value that holds a brand's main color scale, from the lightest step
/// ([shade50]) to the darkest ([shade900]).
///
/// Use this when you build a brand in code, for example in a test. Brands
/// usually come from a brand file instead.
///
/// This is **not** a set of colors for screens: screens and components read
/// the semantic roles in [DsColors], which the design system derives from
/// this scale.
///
/// Built-in: [DsBrandColors.brand] holds it. The primary action and focus
/// roles use step 600 in light mode and step 300 in dark mode.
///
/// Usage from a test:
/// ```dart
/// const scale = DsBrandScale(
///   shade50: Color(0xFFEDF7F2),
///   shade100: Color(0xFFD2EDE0),
///   shade200: Color(0xFFA6DBC2),
///   shade300: Color(0xFF6FC39D),
///   shade400: Color(0xFF3FA57A),
///   shade500: Color(0xFF1C8A61),
///   shade600: Color(0xFF0B6E4F),
///   shade700: Color(0xFF08573F),
///   shade800: Color(0xFF064030),
///   shade900: Color(0xFF042A20),
/// );
/// ```
@immutable
final class DsBrandScale {
  /// Creates a brand color scale.
  ///
  /// Parameters:
  /// * [shade50] - Step 50, the lightest.
  /// * [shade100] - Step 100.
  /// * [shade200] - Step 200.
  /// * [shade300] - Step 300.
  /// * [shade400] - Step 400.
  /// * [shade500] - Step 500.
  /// * [shade600] - Step 600.
  /// * [shade700] - Step 700.
  /// * [shade800] - Step 800.
  /// * [shade900] - Step 900, the darkest.
  const DsBrandScale({
    required this.shade50,
    required this.shade100,
    required this.shade200,
    required this.shade300,
    required this.shade400,
    required this.shade500,
    required this.shade600,
    required this.shade700,
    required this.shade800,
    required this.shade900,
  });

  /// Step 50, the lightest.
  final Color shade50;

  /// Step 100.
  final Color shade100;

  /// Step 200.
  final Color shade200;

  /// Step 300.
  final Color shade300;

  /// Step 400.
  final Color shade400;

  /// Step 500.
  final Color shade500;

  /// Step 600.
  final Color shade600;

  /// Step 700.
  final Color shade700;

  /// Step 800.
  final Color shade800;

  /// Step 900, the darkest.
  final Color shade900;

  @override
  bool operator ==(Object other) =>
      other is DsBrandScale &&
      other.shade50 == shade50 &&
      other.shade100 == shade100 &&
      other.shade200 == shade200 &&
      other.shade300 == shade300 &&
      other.shade400 == shade400 &&
      other.shade500 == shade500 &&
      other.shade600 == shade600 &&
      other.shade700 == shade700 &&
      other.shade800 == shade800 &&
      other.shade900 == shade900;

  @override
  int get hashCode => Object.hash(
    shade50,
    shade100,
    shade200,
    shade300,
    shade400,
    shade500,
    shade600,
    shade700,
    shade800,
    shade900,
  );
}

/// Value that holds a brand's neutral color scale, from white ([shade0]) to
/// near black ([shade900]).
///
/// Use this when you build a brand in code. Brands usually come from a brand
/// file instead.
///
/// This is **not** a set of colors for screens: the design system derives
/// the background, surface, border, and text roles of [DsColors] from it.
///
/// Built-in: [DsBrandColors.neutral] holds it.
///
/// Usage from a test:
/// ```dart
/// final neutral = DsBrand.whiteLabel.colors.neutral;
/// expect(neutral.shade0, const Color(0xFFFFFFFF));
/// ```
@immutable
final class DsNeutralScale {
  /// Creates a neutral color scale.
  ///
  /// Parameters:
  /// * [shade0] - Step 0, usually white.
  /// * [shade50] - Step 50.
  /// * [shade100] - Step 100.
  /// * [shade200] - Step 200.
  /// * [shade300] - Step 300.
  /// * [shade400] - Step 400.
  /// * [shade500] - Step 500.
  /// * [shade600] - Step 600.
  /// * [shade700] - Step 700.
  /// * [shade800] - Step 800.
  /// * [shade900] - Step 900, usually near black.
  const DsNeutralScale({
    required this.shade0,
    required this.shade50,
    required this.shade100,
    required this.shade200,
    required this.shade300,
    required this.shade400,
    required this.shade500,
    required this.shade600,
    required this.shade700,
    required this.shade800,
    required this.shade900,
  });

  /// Step 0, usually white.
  final Color shade0;

  /// Step 50.
  final Color shade50;

  /// Step 100.
  final Color shade100;

  /// Step 200.
  final Color shade200;

  /// Step 300.
  final Color shade300;

  /// Step 400.
  final Color shade400;

  /// Step 500.
  final Color shade500;

  /// Step 600.
  final Color shade600;

  /// Step 700.
  final Color shade700;

  /// Step 800.
  final Color shade800;

  /// Step 900, usually near black.
  final Color shade900;

  @override
  bool operator ==(Object other) =>
      other is DsNeutralScale &&
      other.shade0 == shade0 &&
      other.shade50 == shade50 &&
      other.shade100 == shade100 &&
      other.shade200 == shade200 &&
      other.shade300 == shade300 &&
      other.shade400 == shade400 &&
      other.shade500 == shade500 &&
      other.shade600 == shade600 &&
      other.shade700 == shade700 &&
      other.shade800 == shade800 &&
      other.shade900 == shade900;

  @override
  int get hashCode => Object.hash(
    shade0,
    shade50,
    shade100,
    shade200,
    shade300,
    shade400,
    shade500,
    shade600,
    shade700,
    shade800,
    shade900,
  );
}

/// Value that holds one status color scale: a light tint, a mid tone, and a
/// dark tone.
///
/// Use this when you build a brand in code. Brands usually come from a brand
/// file instead.
///
/// This is **not** a set of colors for screens: the design system derives
/// the message roles of [DsColors] from it, such as
/// [DsColors.successBackground] and [DsColors.successForeground].
///
/// Built-in: [DsBrandColors.success], [DsBrandColors.warning],
/// [DsBrandColors.error], and [DsBrandColors.info] each hold one. Messages use
/// [shade100] and [shade700]; [shade500] is available to future components.
///
/// Usage from a test:
/// ```dart
/// const success = DsStatusScale(
///   shade100: Color(0xFFE3F4E8),
///   shade500: Color(0xFF2E9E57),
///   shade700: Color(0xFF1B6B39),
/// );
/// ```
@immutable
final class DsStatusScale {
  /// Creates a status color scale.
  ///
  /// Parameters:
  /// * [shade100] - The light tint, used as a message background in light
  ///   mode.
  /// * [shade500] - The mid tone.
  /// * [shade700] - The dark tone, used as a message foreground in light
  ///   mode.
  const DsStatusScale({
    required this.shade100,
    required this.shade500,
    required this.shade700,
  });

  /// The light tint, used as a message background in light mode.
  final Color shade100;

  /// The mid tone.
  final Color shade500;

  /// The dark tone, used as a message foreground in light mode.
  final Color shade700;

  @override
  bool operator ==(Object other) =>
      other is DsStatusScale &&
      other.shade100 == shade100 &&
      other.shade500 == shade500 &&
      other.shade700 == shade700;

  @override
  int get hashCode => Object.hash(shade100, shade500, shade700);
}
