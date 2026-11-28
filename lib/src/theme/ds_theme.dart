/// @docImport 'ds_theme_context.dart';
library;

import 'package:flutter/material.dart';

import '../brand/ds_brand.dart';
import '../contrast/ds_contrast_gate.dart';
import '../tokens/ds_tokens.dart';
import 'ds_debug_warnings.dart';

/// Factory for the [ThemeData] of a brand in light or dark mode: how the App
/// Shell places the top-level brand.
///
/// Use this once, in the App Shell's `MaterialApp`: `theme:
/// DsTheme.light(brand: brand)` and `darkTheme: DsTheme.dark(brand:
/// brand)`, with the same brand for both.
///
/// This is **not** something components call: they read the nearest brand
/// through `context.dsColors` and the other getters of [DsThemeContext].
///
/// Built-in: each theme installs the brand's [DsTokens] as its single design
/// system [ThemeExtension], and aligns the Material color scheme, text
/// theme, text selection, and component themes (app bar, input fields, list
/// tiles, cards, dividers, and progress indicators) with the same tokens.
/// Material widgets used next to design system components therefore match
/// the brand. In debug builds, the first time a brand is placed, it is
/// checked with [DsContrastGate]; a brand that fails prints one warning that
/// names every failing pair, and still renders exactly as its file
/// specifies. Release builds never run the gate.
///
/// Rules:
/// * Brand and mode switches are instant. Pass `themeAnimationStyle:
///   AnimationStyle.noAnimation` to `MaterialApp`; replacing the brand then
///   keeps the navigator and every widget's state, and shows the new brand
///   on the next frame.
/// * Light and dark mode come from the app's `themeMode`, never from the
///   brand.
///
/// Usage from the App Shell:
/// ```dart
/// MaterialApp.router(
///   theme: DsTheme.light(brand: brand),
///   darkTheme: DsTheme.dark(brand: brand),
///   themeMode: themeMode,
///   themeAnimationStyle: AnimationStyle.noAnimation,
///   routerConfig: router,
/// );
/// ```
abstract final class DsTheme {
  /// Returns the light theme of [brand].
  ///
  /// Parameters:
  /// * [brand] - The brand to place. Defaults to [DsBrand.whiteLabel].
  static ThemeData light({DsBrand brand = DsBrand.whiteLabel}) =>
      forBrightness(brand, Brightness.light);

  /// Returns the dark theme of [brand].
  ///
  /// Parameters:
  /// * [brand] - The brand to place. Defaults to [DsBrand.whiteLabel].
  static ThemeData dark({DsBrand brand = DsBrand.whiteLabel}) =>
      forBrightness(brand, Brightness.dark);

  /// Returns the theme of [brand] in [brightness].
  ///
  /// Parameters:
  /// * [brand] - The brand to place.
  /// * [brightness] - The mode to build the theme for.
  static ThemeData forBrightness(DsBrand brand, Brightness brightness) {
    // Debug builds check each placed brand once; release builds never run
    // the gate.
    DsDebugWarnings.warnOnceIfNeeded((
      'contrast gate',
      brand,
    ), () => DsTheme._contrastWarning(brand));
    final tokens = DsTokens.resolve(brand, brightness);
    final colors = tokens.colors;
    final typography = tokens.typography;
    final radius = BorderRadius.circular(tokens.radius.md);
    final thin = tokens.borderWidths.thin;
    final thick = tokens.borderWidths.thick;
    OutlineInputBorder outline(Color color, double width) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: width),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: typography.body.fontFamily,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.actionPrimary,
        onPrimary: colors.textOnAction,
        secondary: colors.actionPrimary,
        onSecondary: colors.textOnAction,
        error: colors.errorForeground,
        onError: colors.errorBackground,
        errorContainer: colors.errorBackground,
        onErrorContainer: colors.errorForeground,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        onSurfaceVariant: colors.textSecondary,
        surfaceContainerHighest: colors.surfaceVariant,
        outline: colors.border,
        outlineVariant: colors.border,
      ),
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      dividerColor: colors.border,
      focusColor: colors.focus.withValues(alpha: tokens.opacities.focused),
      hoverColor: colors.textPrimary.withValues(
        alpha: tokens.opacities.hovered,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.focus,
        selectionHandleColor: colors.focus,
      ),
      textTheme: TextTheme(
        displayLarge: typography.display,
        headlineMedium: typography.headline,
        titleLarge: typography.title,
        titleMedium: typography.bodyStrong,
        bodyLarge: typography.body,
        bodyMedium: typography.body,
        labelLarge: typography.label,
        bodySmall: typography.caption,
      ).apply(bodyColor: colors.textPrimary, displayColor: colors.textPrimary),
      iconTheme: IconThemeData(
        color: colors.textSecondary,
        size: tokens.iconSizes.md,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: typography.title.copyWith(color: colors.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        labelStyle: typography.body.copyWith(color: colors.textSecondary),
        floatingLabelStyle: typography.label.copyWith(
          color: colors.textPrimary,
        ),
        hintStyle: typography.body.copyWith(color: colors.textSecondary),
        helperStyle: typography.caption.copyWith(color: colors.textSecondary),
        errorStyle: typography.caption.copyWith(color: colors.errorForeground),
        border: outline(colors.border, thin),
        enabledBorder: outline(colors.textSecondary, thin),
        focusedBorder: outline(colors.focus, thick),
        errorBorder: outline(colors.errorForeground, thin),
        focusedErrorBorder: outline(colors.errorForeground, thick),
        disabledBorder: outline(colors.actionDisabled, thin),
      ),
      listTileTheme: ListTileThemeData(
        textColor: colors.textPrimary,
        iconColor: colors.textSecondary,
        titleTextStyle: typography.body.copyWith(color: colors.textPrimary),
        subtitleTextStyle: typography.caption.copyWith(
          color: colors.textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: colors.border, width: thin),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: thin,
        space: thin,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.actionPrimary,
      ),
      extensions: [tokens],
    );
  }

  /// Returns the debug warning for [brand], or null when it passes the
  /// contrast gate. The text names the brand by id and the failing pairs
  /// by role, never anything else.
  static String? _contrastWarning(DsBrand brand) {
    final report = DsContrastGate.check(brand);
    if (report.passed) return null;
    return [
      'design_system: brand "${brand.id}" fails the contrast gate in '
          '${report.violations.length} pair(s). It renders exactly as its '
          'file specifies; change the brand file\'s colors to fix:',
      for (final violation in report.violations) '  $violation',
    ].join('\n');
  }
}
