/// @docImport '../../tokens/ds_colors.dart';
/// @docImport 'ds_inline_message.dart';
/// @docImport '../../qa/ds_qa_identifiers.dart';
library;

import 'package:flutter/material.dart';

import '../../catalog/ds_component_info.dart';
import '../../guidelines/ds_guidelines_frame.dart';
import '../../layout/ds_gap.dart';
import '../../qa/ds_qa_semantics.dart';
import '../../theme/ds_theme_context.dart';
import '../../tokens/ds_spacing.dart';
import '../atoms/ds_button.dart';

/// Widget that fills an area that has no content yet, and suggests what to
/// do next.
///
/// Use this when a list or section is empty, such as "No transfers yet", or
/// when a feature is unavailable and the screen has nothing else to show.
///
/// This is **not** an error inside other content: for a failed load next to
/// other content, use [DsInlineMessage].
///
/// Built-in:
/// * The content is centered: an optional icon in
///   [DsColors.textSecondary], the [title] as a heading in
///   [DsColors.textPrimary], the [message] in [DsColors.textSecondary], and
///   an optional primary [DsButton].
/// * The icon is decorative and hidden from screen readers.
///
/// **Status**: stable.
///
/// Usage from a micro app:
/// ```dart
/// DsEmptyState(
///   icon: Icons.receipt_long,
///   title: 'No transfers yet',
///   message: 'Transfers you make appear here.',
///   actionLabel: 'New transfer',
///   onAction: () => navigator.push('/transfers/new'),
/// )
/// ```
final class DsEmptyState extends StatelessWidget {
  /// Creates an empty state.
  ///
  /// Parameters:
  /// * [title] - What is missing, as a short heading. Localize it.
  /// * [message] - Optional explanation or next step below the title.
  /// * [icon] - Optional decorative icon above the title.
  /// * [actionLabel] - Optional label of the action button. Set it together
  ///   with [onAction].
  /// * [onAction] - Optional callback of the action button. Set it together
  ///   with [actionLabel].
  /// * [qaIdentifier] - Optional identifier that UI automation finds the
  ///   empty state by. It is exposed only in builds made with the QA switch
  ///   ([DsQaIdentifiers.enabled]), and never changes what screen readers
  ///   announce. Never put personal data in it.
  const DsEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.qaIdentifier,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'Set actionLabel and onAction together.',
       );

  /// Metadata of this component: molecule, stable since 0.1.0.
  static const DsComponentInfo info = DsComponentInfo(
    name: 'DsEmptyState',
    level: DsComponentLevel.molecule,
    status: DsComponentStatus.stable,
    since: '0.1.0',
  );

  /// What is missing, as a short heading.
  final String title;

  /// Optional explanation or next step below the title.
  final String? message;

  /// Optional decorative icon above the title.
  final IconData? icon;

  /// Optional label of the action button.
  final String? actionLabel;

  /// Optional callback of the action button.
  final VoidCallback? onAction;

  /// Optional identifier that UI automation finds the empty state by; exposed
  /// only in builds made with the QA switch.
  final String? qaIdentifier;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final message = this.message;
    final actionLabel = this.actionLabel;
    final emptyState = Center(
      child: Padding(
        padding: context.dsSpacing.all(DsSpacingStep.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              ExcludeSemantics(
                child: Icon(
                  icon,
                  size: context.dsIconSizes.lg,
                  color: colors.textSecondary,
                ),
              ),
              const DsGap(DsSpacingStep.md),
            ],
            Semantics(
              header: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: typography.title.copyWith(color: colors.textPrimary),
              ),
            ),
            if (message != null) ...[
              const DsGap(DsSpacingStep.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: typography.body.copyWith(color: colors.textSecondary),
              ),
            ],
            if (actionLabel != null) ...[
              const DsGap(DsSpacingStep.lg),
              DsButton(label: actionLabel, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
    return DsGuidelinesFrame(
      level: DsEmptyState.info.level,
      // An empty state forms no node of its own: its title, message, and
      // action keep their nodes, and the identifier gets a group node.
      child: DsQaSemantics.group(identifier: qaIdentifier, child: emptyState),
    );
  }
}
