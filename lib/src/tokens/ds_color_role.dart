/// @docImport 'ds_colors.dart';
library;

/// Value that names one semantic color role of [DsColors].
///
/// Use this to read a role by name with [DsColors.role], for example when a
/// contrast report names the roles that failed.
///
/// This is **not** a color: [DsColors] resolves each role for the nearest
/// brand and the current mode.
///
/// Usage from a micro app:
/// ```dart
/// final color = context.dsColors.role(DsColorRole.textSecondary);
/// ```
enum DsColorRole {
  /// Background of a page.
  background,

  /// Raised content, such as cards, fields, and sheets.
  surface,

  /// Secondary surfaces, such as a selected row.
  surfaceVariant,

  /// Borders and dividers.
  border,

  /// Primary text.
  textPrimary,

  /// Supporting text.
  textSecondary,

  /// Text in disabled controls.
  textDisabled,

  /// Text on the primary action color.
  textOnAction,

  /// The primary action.
  actionPrimary,

  /// The primary action while pressed.
  actionPrimaryPressed,

  /// Fill of disabled controls.
  actionDisabled,

  /// The focus indicator.
  focus,

  /// Background of information messages.
  infoBackground,

  /// Text and icons of information messages.
  infoForeground,

  /// Background of success messages.
  successBackground,

  /// Text and icons of success messages.
  successForeground,

  /// Background of warning messages.
  warningBackground,

  /// Text and icons of warning messages.
  warningForeground,

  /// Background of error messages.
  errorBackground,

  /// Text and icons of error messages.
  errorForeground,
}
