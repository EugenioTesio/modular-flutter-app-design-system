/// @docImport '../templates/ds_page_scaffold.dart';
/// @docImport '../../brand/ds_brand.dart';
/// @docImport '../../tokens/ds_colors.dart';
library;

import 'package:flutter/material.dart';

import '../../catalog/ds_component_info.dart';
import '../../layout/ds_gap.dart';
import '../../theme/ds_theme_context.dart';
import '../../tokens/ds_spacing.dart';

/// Value that sets how prominent a [DsButton] is.
///
/// Use [primary] for the one main action of a screen, [secondary] for an
/// alternative next to it, and [tertiary] for low-emphasis actions such as
/// "Skip".
enum DsButtonVariant {
  /// Filled with the brand's action color.
  primary,

  /// Outlined in the action color, with no fill.
  secondary,

  /// Text in the action color, with no fill or outline.
  tertiary,
}

/// Widget that triggers an action: the design system's button.
///
/// Use this for every button in a screen. Pick the emphasis with [variant],
/// and give the screen at most one [DsButtonVariant.primary] button.
///
/// This is **not** a link to another screen's content: a row that opens
/// details is a `DsListTile` or a tappable `DsCard`.
///
/// Built-in:
/// * Every visual value comes from the nearest [DsBrand]. Colors come from
///   [DsColors]: the primary fill is [DsColors.actionPrimary] (darker while
///   pressed), its text is [DsColors.textOnAction], and a focused button
///   shows a ring in [DsColors.focus]. Changing the brand restyles every
///   button.
/// * The tap target is at least 48 × 48, and [label] is the accessible label.
/// * When [onPressed] is null, the button is disabled: it ignores taps and
///   uses [DsColors.actionDisabled] and [DsColors.textDisabled].
/// * When [isLoading] is true, it shows a spinner instead of the label,
///   ignores taps, keeps its size, and keeps [label] for screen readers.
///
/// **Status**: stable.
///
/// Usage from a micro app:
/// ```dart
/// DsButton(
///   label: 'Transfer',
///   icon: Icons.send,
///   isLoading: state.isSubmitting,
///   onPressed: state.canSubmit ? submit : null,
/// )
/// ```
final class DsButton extends StatelessWidget {
  /// Creates a button.
  ///
  /// Parameters:
  /// * [label] - The visible text, which is also the accessible label.
  ///   Localize it.
  /// * [onPressed] - Called when the button is tapped. Null disables the
  ///   button.
  /// * [variant] - How prominent the button is. Defaults to
  ///   [DsButtonVariant.primary].
  /// * [icon] - Optional icon shown before the label.
  /// * [isLoading] - Whether to show a spinner and ignore taps. Defaults to
  ///   false.
  /// * [expand] - Whether to fill the available width. Defaults to false.
  ///   [DsPageScaffold] makes its primary action full width on its own.
  const DsButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = DsButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  });

  /// Metadata of this component: atom, stable since 0.1.0.
  static const DsComponentInfo info = DsComponentInfo(
    name: 'DsButton',
    level: DsComponentLevel.atom,
    status: DsComponentStatus.stable,
    since: '0.1.0',
  );

  /// The visible text, which is also the accessible label.
  final String label;

  /// Optional callback for taps; null disables the button.
  final VoidCallback? onPressed;

  /// How prominent the button is.
  final DsButtonVariant variant;

  /// Optional icon shown before the label.
  final IconData? icon;

  /// Whether the button shows a spinner and ignores taps.
  final bool isLoading;

  /// Whether the button fills the available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final opacities = context.dsOpacities;
    final borderWidths = context.dsBorderWidths;
    final iconSizes = context.dsIconSizes;
    final isPrimary = variant == DsButtonVariant.primary;
    final foreground = isPrimary ? colors.textOnAction : colors.actionPrimary;
    // A loading button ignores taps but keeps its enabled colors.
    bool isDisabled(Set<WidgetState> states) =>
        !isLoading && states.contains(WidgetState.disabled);

    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(
        Size.square(kMinInteractiveDimension),
      ),
      tapTargetSize: MaterialTapTargetSize.padded,
      padding: WidgetStatePropertyAll(
        spacing.symmetric(
          horizontal: DsSpacingStep.md,
          vertical: DsSpacingStep.sm,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.dsRadius.md),
        ),
      ),
      textStyle: WidgetStatePropertyAll(context.dsTypography.label),
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (!isPrimary) return Colors.transparent;
        if (isDisabled(states)) return colors.actionDisabled;
        if (states.contains(WidgetState.pressed)) {
          return colors.actionPrimaryPressed;
        }
        return colors.actionPrimary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => isDisabled(states) ? colors.textDisabled : foreground,
      ),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return foreground.withValues(alpha: opacities.pressed);
        }
        if (states.contains(WidgetState.focused)) {
          return foreground.withValues(alpha: opacities.focused);
        }
        if (states.contains(WidgetState.hovered)) {
          return foreground.withValues(alpha: opacities.hovered);
        }
        return null;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return BorderSide(
            color: colors.focus,
            width: borderWidths.thick,
            strokeAlign: BorderSide.strokeAlignOutside,
          );
        }
        if (variant == DsButtonVariant.secondary) {
          return BorderSide(
            color: isDisabled(states)
                ? colors.actionDisabled
                : colors.actionPrimary,
            width: borderWidths.thin,
          );
        }
        return BorderSide.none;
      }),
    );

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSizes.sm),
          const DsGap(DsSpacingStep.xs),
        ],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
    if (isLoading) {
      content = Stack(
        alignment: Alignment.center,
        children: [
          Visibility(
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            maintainSemantics: true,
            child: content,
          ),
          ExcludeSemantics(
            child: SizedBox.square(
              dimension: iconSizes.sm,
              child: CircularProgressIndicator(
                strokeWidth: borderWidths.thick,
                color: foreground,
              ),
            ),
          ),
        ],
      );
    }

    final button = TextButton(
      style: style,
      onPressed: isLoading ? null : onPressed,
      child: content,
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
