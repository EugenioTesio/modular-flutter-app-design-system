/// @docImport '../brand/ds_brand.dart';
/// @docImport '../brand/ds_color_scale.dart';
/// @docImport '../theme/ds_theme.dart';
/// @docImport '../theme/ds_theme_context.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'ds_color_role.dart';

/// Value that holds the semantic color roles of one brand in one mode.
///
/// Use this for every color in a screen, through `context.dsColors`: text in
/// [textPrimary] or [textSecondary], cards on [surface], and so on. A role
/// names what the color is for, so dark mode and brand changes restyle the
/// screen with no code change.
///
/// This is **not** a brand's palette: [DsBrand.colors] holds the primitive
/// scales, and only the design system reads them.
///
/// Built-in: the design system derives these roles from the nearest
/// [DsBrand], with one mapping it owns for light and dark mode. Brands can't
/// override a role, and no primitive value is ever adjusted.
///
/// Rules:
/// * [textOnAction] is the neutral end, white or near black, with more
///   contrast against [actionPrimary].
/// * [textDisabled] and [actionDisabled] have no contrast minimum, because
///   disabled controls are exempt.
/// * Whether a brand reaches the other contrast minimums is checked, never
///   corrected.
///
/// Usage from a micro app:
/// ```dart
/// final colors = context.dsColors;
/// return Text(
///   'Last updated today',
///   style: context.dsTypography.caption.copyWith(color: colors.textSecondary),
/// );
/// ```
@immutable
final class DsColors {
  /// Creates a set of color roles. The design system calls this; screens
  /// read the roles through `context.dsColors` instead.
  ///
  /// Parameters:
  /// * [background] - Background color of a page.
  /// * [surface] - Color of raised content on the page, such as cards, fields, and sheets.
  /// * [surfaceVariant] - Color of secondary surfaces, such as a selected row or a grouped area.
  /// * [border] - Color of borders and dividers.
  /// * [textPrimary] - Color of primary text on [background], [surface], and [surfaceVariant].
  /// * [textSecondary] - Color of supporting text, such as subtitles, hints, and helper text, on [background], [surface], and [surfaceVariant].
  /// * [textDisabled] - Color of text and icons in disabled controls.
  /// * [textOnAction] - Color of text and icons on [actionPrimary] and [actionPrimaryPressed].
  /// * [actionPrimary] - Color of the primary action: the primary button fill, and the text of secondary and tertiary buttons.
  /// * [actionPrimaryPressed] - Color of the primary action while it is pressed.
  /// * [actionDisabled] - Fill color of disabled controls.
  /// * [focus] - Color of the focus ring around the focused control.
  /// * [infoBackground] - Background color of information messages.
  /// * [infoForeground] - Color of text and icons on [infoBackground].
  /// * [successBackground] - Background color of success messages.
  /// * [successForeground] - Color of text and icons on [successBackground].
  /// * [warningBackground] - Background color of warning messages.
  /// * [warningForeground] - Color of text and icons on [warningBackground].
  /// * [errorBackground] - Background color of error messages.
  /// * [errorForeground] - Color of text and icons on [errorBackground], and of error text, such as a field's error, on [background] and [surface].
  const DsColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.textOnAction,
    required this.actionPrimary,
    required this.actionPrimaryPressed,
    required this.actionDisabled,
    required this.focus,
    required this.infoBackground,
    required this.infoForeground,
    required this.successBackground,
    required this.successForeground,
    required this.warningBackground,
    required this.warningForeground,
    required this.errorBackground,
    required this.errorForeground,
  });

  /// Background color of a page.
  final Color background;

  /// Color of raised content on the page, such as cards, fields, and sheets.
  final Color surface;

  /// Color of secondary surfaces, such as a selected row or a grouped area.
  final Color surfaceVariant;

  /// Color of borders and dividers.
  final Color border;

  /// Color of primary text on [background], [surface], and [surfaceVariant].
  final Color textPrimary;

  /// Color of supporting text, such as subtitles, hints, and helper text, on [background], [surface], and [surfaceVariant].
  final Color textSecondary;

  /// Color of text and icons in disabled controls.
  final Color textDisabled;

  /// Color of text and icons on [actionPrimary] and [actionPrimaryPressed].
  final Color textOnAction;

  /// Color of the primary action: the primary button fill, and the text of secondary and tertiary buttons.
  final Color actionPrimary;

  /// Color of the primary action while it is pressed.
  final Color actionPrimaryPressed;

  /// Fill color of disabled controls.
  final Color actionDisabled;

  /// Color of the focus ring around the focused control.
  final Color focus;

  /// Background color of information messages.
  final Color infoBackground;

  /// Color of text and icons on [infoBackground].
  final Color infoForeground;

  /// Background color of success messages.
  final Color successBackground;

  /// Color of text and icons on [successBackground].
  final Color successForeground;

  /// Background color of warning messages.
  final Color warningBackground;

  /// Color of text and icons on [warningBackground].
  final Color warningForeground;

  /// Background color of error messages.
  final Color errorBackground;

  /// Color of text and icons on [errorBackground], and of error text, such as a field's error, on [background] and [surface].
  final Color errorForeground;

  /// Returns the color of [role].
  ///
  /// Parameters:
  /// * [role] - The role to read.
  Color role(DsColorRole role) => switch (role) {
    DsColorRole.background => background,
    DsColorRole.surface => surface,
    DsColorRole.surfaceVariant => surfaceVariant,
    DsColorRole.border => border,
    DsColorRole.textPrimary => textPrimary,
    DsColorRole.textSecondary => textSecondary,
    DsColorRole.textDisabled => textDisabled,
    DsColorRole.textOnAction => textOnAction,
    DsColorRole.actionPrimary => actionPrimary,
    DsColorRole.actionPrimaryPressed => actionPrimaryPressed,
    DsColorRole.actionDisabled => actionDisabled,
    DsColorRole.focus => focus,
    DsColorRole.infoBackground => infoBackground,
    DsColorRole.infoForeground => infoForeground,
    DsColorRole.successBackground => successBackground,
    DsColorRole.successForeground => successForeground,
    DsColorRole.warningBackground => warningBackground,
    DsColorRole.warningForeground => warningForeground,
    DsColorRole.errorBackground => errorBackground,
    DsColorRole.errorForeground => errorForeground,
  };

  @override
  bool operator ==(Object other) =>
      other is DsColors &&
      other.background == background &&
      other.surface == surface &&
      other.surfaceVariant == surfaceVariant &&
      other.border == border &&
      other.textPrimary == textPrimary &&
      other.textSecondary == textSecondary &&
      other.textDisabled == textDisabled &&
      other.textOnAction == textOnAction &&
      other.actionPrimary == actionPrimary &&
      other.actionPrimaryPressed == actionPrimaryPressed &&
      other.actionDisabled == actionDisabled &&
      other.focus == focus &&
      other.infoBackground == infoBackground &&
      other.infoForeground == infoForeground &&
      other.successBackground == successBackground &&
      other.successForeground == successForeground &&
      other.warningBackground == warningBackground &&
      other.warningForeground == warningForeground &&
      other.errorBackground == errorBackground &&
      other.errorForeground == errorForeground;

  @override
  int get hashCode => Object.hashAll([
    background,
    surface,
    surfaceVariant,
    border,
    textPrimary,
    textSecondary,
    textDisabled,
    textOnAction,
    actionPrimary,
    actionPrimaryPressed,
    actionDisabled,
    focus,
    infoBackground,
    infoForeground,
    successBackground,
    successForeground,
    warningBackground,
    warningForeground,
    errorBackground,
    errorForeground,
  ]);
}
