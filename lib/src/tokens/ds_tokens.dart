/// @docImport 'package:flutter/material.dart';
/// @docImport '../theme/ds_brand_scope.dart';
/// @docImport '../theme/ds_theme.dart';
/// @docImport '../theme/ds_theme_context.dart';
library;

import 'package:flutter/material.dart';

import '../brand/ds_brand.dart';
import '../theme/ds_debug_warnings.dart';
import '../theme/ds_semantic_mapping.dart';
import 'ds_border_widths.dart';
import 'ds_colors.dart';
import 'ds_icon_sizes.dart';
import 'ds_opacities.dart';
import 'ds_radius.dart';
import 'ds_spacing.dart';
import 'ds_typography.dart';

/// Value that holds every resolved token of one brand in one mode, carried
/// in the [ThemeData] of a brand area.
///
/// Use this when you need the whole set at once, through
/// `context.dsTokens`. Most code reads one group instead, such as
/// `context.dsColors` or `context.dsSpacing`.
///
/// This is **not** how a brand is placed: [DsTheme] installs it for you,
/// and so does [DsBrandScope] for a nested brand.
///
/// Built-in: [DsTheme] resolves it from a [DsBrand] and installs it as the
/// single design system [ThemeExtension], so every component below reads the
/// nearest brand.
///
/// Rules:
/// * Brand and mode switches are instant. [lerp] never interpolates: it
///   returns these tokens before the middle of a theme animation and the
///   target tokens from the middle on, so no frame mixes two brands.
/// * The App Shell turns off the app's theme animation
///   (`themeAnimationStyle: AnimationStyle.noAnimation`). If an animation
///   runs anyway, debug builds print one warning per run.
/// * Two token sets for the same brand and mode are equal.
///
/// Usage from a micro app:
/// ```dart
/// final tokens = context.dsTokens;
/// final isDark = tokens.brightness == Brightness.dark;
/// ```
@immutable
final class DsTokens extends ThemeExtension<DsTokens> {
  /// Creates a set of tokens. The design system calls this through
  /// [DsTokens.resolve].
  ///
  /// Parameters:
  /// * [brand] - The brand the tokens come from.
  /// * [brightness] - The mode the colors were resolved for.
  /// * [colors] - The semantic color roles.
  /// * [typography] - The text styles.
  /// * [spacing] - The spacing scale.
  /// * [radius] - The corner-radius scale.
  /// * [borderWidths] - The border widths.
  /// * [opacities] - The state-layer opacities.
  /// * [iconSizes] - The icon sizes.
  const DsTokens({
    required this.brand,
    required this.brightness,
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.radius,
    required this.borderWidths,
    required this.opacities,
    required this.iconSizes,
  });

  /// Creates the tokens of [brand] in [brightness], applying the design
  /// system's semantic mapping.
  ///
  /// Parameters:
  /// * [brand] - The brand to resolve.
  /// * [brightness] - The mode to resolve the colors for.
  factory DsTokens.resolve(DsBrand brand, Brightness brightness) => DsTokens(
    brand: brand,
    brightness: brightness,
    colors: DsSemanticMapping.colorsFor(brand, brightness),
    typography: DsTypography.fromBrand(brand.typography),
    spacing: brand.spacing,
    radius: brand.radius,
    borderWidths: brand.borderWidths,
    opacities: brand.opacities,
    iconSizes: brand.iconSizes,
  );

  /// The brand the tokens come from.
  final DsBrand brand;

  /// The mode the colors were resolved for.
  final Brightness brightness;

  /// The semantic color roles.
  final DsColors colors;

  /// The text styles.
  final DsTypography typography;

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

  /// Returns the tokens of another brand or mode.
  ///
  /// Parameters:
  /// * [brand] - Optional brand to resolve instead of [brand].
  /// * [brightness] - Optional mode to resolve instead of [brightness].
  ///
  /// The groups are resolved again from the resulting brand and mode, so
  /// they always match each other.
  @override
  DsTokens copyWith({DsBrand? brand, Brightness? brightness}) =>
      DsTokens.resolve(brand ?? this.brand, brightness ?? this.brightness);

  /// Returns these tokens or [other], without interpolating.
  ///
  /// Parameters:
  /// * [other] - The target tokens. When it is not a [DsTokens], these
  ///   tokens are returned.
  /// * [t] - The position of a theme animation, from 0 to 1.
  ///
  /// Returns these tokens for [t] below 0.5, and [other] from 0.5 on. A [t]
  /// strictly between 0 and 1 means a theme animation is running, so debug
  /// builds print one warning per run that switches aren't instant.
  @override
  DsTokens lerp(covariant ThemeExtension<DsTokens>? other, double t) {
    if (other is! DsTokens) return this;
    if (t > 0 && t < 1) {
      DsDebugWarnings.warnOnce(
        #dsThemeAnimation,
        'Design system: a theme animation is running, so brand and mode '
        "switches aren't instant. Pass themeAnimationStyle: "
        'AnimationStyle.noAnimation to MaterialApp.',
      );
    }
    return t < 0.5 ? this : other;
  }

  @override
  bool operator ==(Object other) =>
      other is DsTokens &&
      other.brand == brand &&
      other.brightness == brightness &&
      other.colors == colors &&
      other.typography == typography &&
      other.spacing == spacing &&
      other.radius == radius &&
      other.borderWidths == borderWidths &&
      other.opacities == opacities &&
      other.iconSizes == iconSizes;

  @override
  int get hashCode => Object.hash(
    brand,
    brightness,
    colors,
    typography,
    spacing,
    radius,
    borderWidths,
    opacities,
    iconSizes,
  );
}
