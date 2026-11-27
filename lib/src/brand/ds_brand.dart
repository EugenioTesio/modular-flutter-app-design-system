/// @docImport '../theme/ds_brand_scope.dart';
/// @docImport '../theme/ds_theme.dart';
/// @docImport '../theme/ds_theme_context.dart';
/// @docImport '../tokens/ds_colors.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../tokens/ds_border_widths.dart';
import '../tokens/ds_icon_sizes.dart';
import '../tokens/ds_opacities.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import 'ds_brand_colors.dart';
import 'ds_brand_typography.dart';
import 'ds_color_scale.dart';
import 'ds_type_style.dart';

/// Value that holds a complete brand: every primitive token the design
/// system draws with.
///
/// Use this to place a brand in the widget tree: the App Shell passes one to
/// [DsTheme.light] and [DsTheme.dark] at startup, and a micro app can wrap
/// its screens in another with [DsBrandScope]. Every component below then
/// draws with the nearest brand.
///
/// This is **not** something components take as a parameter: they read the
/// nearest brand through `context.dsColors`, `context.dsSpacing`, and the
/// other getters of [DsThemeContext].
///
/// Built-in: [whiteLabel] is always available, with no setup, and is used
/// wherever no other brand is placed.
///
/// Rules:
/// * A brand carries primitive tokens only. The design system derives the
///   semantic roles of [DsColors] from them, for light and dark mode, and
///   never alters a primitive value.
/// * Two brands with the same values are equal.
/// * [id] is unique among the brands an app loads. The design system doesn't
///   check this, so an app that loads several brands keeps their ids
///   unique.
/// * [toString] shows only [id], so logs never dump a brand's values.
///
/// Usage from the App Shell:
/// ```dart
/// MaterialApp.router(
///   theme: DsTheme.light(brand: brand),
///   darkTheme: DsTheme.dark(brand: brand),
///   themeAnimationStyle: AnimationStyle.noAnimation,
///   routerConfig: router,
/// );
/// ```
@immutable
final class DsBrand {
  /// Creates a brand.
  ///
  /// Parameters:
  /// * [id] - Stable identifier, such as `forest`. Lowercase letters, digits,
  ///   and underscores.
  /// * [name] - Display name, such as "Forest".
  /// * [colors] - The color scales.
  /// * [typography] - The type scale.
  /// * [spacing] - The spacing scale.
  /// * [radius] - The corner-radius scale.
  /// * [borderWidths] - The border widths.
  /// * [opacities] - The state-layer opacities.
  /// * [iconSizes] - The icon sizes.
  const DsBrand({
    required this.id,
    required this.name,
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.radius,
    required this.borderWidths,
    required this.opacities,
    required this.iconSizes,
  });

  /// The white-label brand, built into the design system.
  ///
  /// It is used wherever no other brand is placed, and it passes the
  /// contrast checks in light and dark mode. Its text uses the platform
  /// font.
  static const DsBrand whiteLabel = DsBrand(
    id: 'white_label',
    name: 'White label',
    colors: DsBrandColors(
      brand: DsBrandScale(
        shade50: Color(0xFFEEF4FD),
        shade100: Color(0xFFD6E4FB),
        shade200: Color(0xFFB3CDF9),
        shade300: Color(0xFF8AB4F8),
        shade400: Color(0xFF5A8FEA),
        shade500: Color(0xFF3B74E0),
        shade600: Color(0xFF1F5FD1),
        shade700: Color(0xFF184BA8),
        shade800: Color(0xFF12387F),
        shade900: Color(0xFF0C2556),
      ),
      neutral: DsNeutralScale(
        shade0: Color(0xFFFFFFFF),
        shade50: Color(0xFFF7F8FA),
        shade100: Color(0xFFEEF0F3),
        shade200: Color(0xFFDDE1E6),
        shade300: Color(0xFFC3C8CF),
        shade400: Color(0xFF9AA1AB),
        shade500: Color(0xFF6E7681),
        shade600: Color(0xFF545B66),
        shade700: Color(0xFF3D434C),
        shade800: Color(0xFF272C33),
        shade900: Color(0xFF14171C),
      ),
      success: DsStatusScale(
        shade100: Color(0xFFE3F4E8),
        shade500: Color(0xFF2E9E57),
        shade700: Color(0xFF1B6B39),
      ),
      warning: DsStatusScale(
        shade100: Color(0xFFFDF1DC),
        shade500: Color(0xFFE09B1A),
        shade700: Color(0xFF7A4F00),
      ),
      error: DsStatusScale(
        shade100: Color(0xFFFCE6E6),
        shade500: Color(0xFFD93838),
        shade700: Color(0xFFA31F1F),
      ),
      info: DsStatusScale(
        shade100: Color(0xFFE3EEFD),
        shade500: Color(0xFF3B74E0),
        shade700: Color(0xFF184BA8),
      ),
    ),
    typography: DsBrandTypography(
      display: DsTypeStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        lineHeight: 1.25,
        letterSpacing: 0,
      ),
      headline: DsTypeStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        lineHeight: 1.3,
        letterSpacing: 0,
      ),
      title: DsTypeStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        lineHeight: 1.3,
        letterSpacing: 0,
      ),
      body: DsTypeStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        lineHeight: 1.5,
        letterSpacing: 0,
      ),
      bodyStrong: DsTypeStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        lineHeight: 1.5,
        letterSpacing: 0,
      ),
      label: DsTypeStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        lineHeight: 1.4,
        letterSpacing: 0,
      ),
      caption: DsTypeStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        lineHeight: 1.4,
        letterSpacing: 0,
      ),
    ),
    spacing: DsSpacing(xxs: 4, xs: 8, sm: 12, md: 16, lg: 24, xl: 32, xxl: 48),
    radius: DsRadius(sm: 4, md: 8, lg: 16, pill: 999),
    borderWidths: DsBorderWidths(thin: 1, thick: 2),
    opacities: DsOpacities(hovered: 0.08, focused: 0.12, pressed: 0.12),
    iconSizes: DsIconSizes(sm: 18, md: 24, lg: 48),
  );

  /// Stable identifier, such as `white_label` or `forest`.
  final String id;

  /// Display name, such as "White label".
  final String name;

  /// The color scales.
  final DsBrandColors colors;

  /// The type scale.
  final DsBrandTypography typography;

  /// The spacing scale.
  final DsSpacing spacing;

  /// The corner-radius scale.
  final DsRadius radius;

  /// The border widths.
  final DsBorderWidths borderWidths;

  /// The state-layer opacities.
  final DsOpacities opacities;

  /// The icon sizes.
  final DsIconSizes iconSizes;

  @override
  bool operator ==(Object other) =>
      other is DsBrand &&
      other.id == id &&
      other.name == name &&
      other.colors == colors &&
      other.typography == typography &&
      other.spacing == spacing &&
      other.radius == radius &&
      other.borderWidths == borderWidths &&
      other.opacities == opacities &&
      other.iconSizes == iconSizes;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    colors,
    typography,
    spacing,
    radius,
    borderWidths,
    opacities,
    iconSizes,
  );

  @override
  String toString() => 'DsBrand($id)';
}
