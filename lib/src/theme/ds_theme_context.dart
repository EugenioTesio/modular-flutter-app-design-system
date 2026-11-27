/// @docImport 'ds_brand_scope.dart';
/// @docImport 'ds_theme.dart';
library;

import 'package:flutter/material.dart';

import '../brand/ds_brand.dart';
import '../tokens/ds_border_widths.dart';
import '../tokens/ds_colors.dart';
import '../tokens/ds_icon_sizes.dart';
import '../tokens/ds_opacities.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_tokens.dart';
import '../tokens/ds_typography.dart';
import 'ds_debug_warnings.dart';

/// Extension that reads the tokens of the nearest brand above a widget.
///
/// Use this in every widget that needs a color, text style, spacing, or other
/// visual value: `context.dsColors`, `context.dsTypography`,
/// `context.dsSpacing`, and so on.
///
/// This is **not** a way to change the brand: the App Shell places the
/// top-level brand with [DsTheme], and a micro app wraps its screens in
/// another brand with [DsBrandScope].
///
/// Built-in:
/// * The getters read the [DsTokens] of the nearest [Theme], and register a
///   dependency on it, so the widget rebuilds when the brand or mode
///   changes.
/// * With no design system tokens above, they return the white label in the
///   ambient mode, and debug builds print one warning per run. Release
///   builds print nothing.
///
/// Usage from a micro app:
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   final colors = context.dsColors;
///   return Padding(
///     padding: context.dsSpacing.all(DsSpacingStep.md),
///     child: Text(
///       'Balance',
///       style: context.dsTypography.title.copyWith(color: colors.textPrimary),
///     ),
///   );
/// }
/// ```
extension DsThemeContext on BuildContext {
  /// All tokens of the nearest brand, or of the white label when no brand is
  /// placed.
  DsTokens get dsTokens {
    final theme = Theme.of(this);
    final tokens = theme.extension<DsTokens>();
    if (tokens != null) return tokens;
    DsDebugWarnings.warnOnce(
      #dsNoBrand,
      'Design system: no brand was placed above a component, so it uses the '
      'white label. Build the app theme with DsTheme.light() and '
      'DsTheme.dark().',
    );
    return theme.brightness == Brightness.dark
        ? _DsWhiteLabelTokens.dark
        : _DsWhiteLabelTokens.light;
  }

  /// The nearest brand.
  DsBrand get dsBrand => dsTokens.brand;

  /// Semantic color roles of the nearest brand in the current mode.
  DsColors get dsColors => dsTokens.colors;

  /// Text styles of the nearest brand.
  DsTypography get dsTypography => dsTokens.typography;

  /// Spacing scale of the nearest brand.
  DsSpacing get dsSpacing => dsTokens.spacing;

  /// Corner-radius scale of the nearest brand.
  DsRadius get dsRadius => dsTokens.radius;

  /// Border widths of the nearest brand.
  DsBorderWidths get dsBorderWidths => dsTokens.borderWidths;

  /// State-layer opacities of the nearest brand.
  DsOpacities get dsOpacities => dsTokens.opacities;

  /// Icon sizes of the nearest brand.
  DsIconSizes get dsIconSizes => dsTokens.iconSizes;
}

/// The white label's tokens, resolved once per mode for the fallback.
abstract final class _DsWhiteLabelTokens {
  static final DsTokens light = DsTokens.resolve(
    DsBrand.whiteLabel,
    Brightness.light,
  );

  static final DsTokens dark = DsTokens.resolve(
    DsBrand.whiteLabel,
    Brightness.dark,
  );
}
