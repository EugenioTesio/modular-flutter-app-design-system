/// @docImport '../../tokens/ds_colors.dart';
/// @docImport '../../qa/ds_qa_identifiers.dart';
library;

import 'package:flutter/material.dart';

import '../../catalog/ds_component_info.dart';
import '../../guidelines/ds_guidelines_frame.dart';
import '../../qa/ds_qa_semantics.dart';
import '../../theme/ds_theme_context.dart';
import '../../tokens/ds_spacing.dart';
import '../atoms/ds_button.dart';

/// Widget that lays out a whole screen: a title bar, a padded body, and an
/// optional primary action pinned at the bottom.
///
/// Use this as the root widget of every micro app screen, so screens share
/// one structure, padding, and back behavior.
///
/// This is **not** a navigation shell: tabs or a side menu shared by several
/// screens belong in a route group's layout.
///
/// Built-in:
/// * The page uses [DsColors.background], and the title bar shows [title]
///   in [DsColors.textPrimary].
/// * The [body] sits inside the safe area, padded by [DsSpacing.md] on every
///   side. Make it scrollable when it can be taller than the screen.
/// * The [primaryAction] is pinned at the bottom, inside the safe area, and
///   stretched to the full width, whatever its own `expand` setting.
/// * Back: when [onBack] is set, the title bar shows a back button that calls
///   it. Otherwise the platform behavior applies: a back button appears when
///   the route can be popped.
///
/// **Status**: stable.
///
/// Usage from a micro app:
/// ```dart
/// DsPageScaffold(
///   title: 'New transfer',
///   body: TransferForm(controller: controller),
///   primaryAction: DsButton(
///     label: 'Continue',
///     onPressed: controller.isValid ? submit : null,
///   ),
/// )
/// ```
final class DsPageScaffold extends StatelessWidget {
  /// Creates a page.
  ///
  /// Parameters:
  /// * [title] - The title shown in the title bar. Localize it.
  /// * [body] - The content of the page.
  /// * [primaryAction] - Optional main action, pinned at the bottom and
  ///   stretched to the full width.
  /// * [onBack] - Optional callback of the back button. When null, the
  ///   platform back behavior applies.
  /// * [qaIdentifier] - Optional identifier that UI automation finds the
  ///   page by. It is exposed only in builds made with the QA switch
  ///   ([DsQaIdentifiers.enabled]), and never changes what screen readers
  ///   announce. Never put personal data in it.
  const DsPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.primaryAction,
    this.onBack,
    this.qaIdentifier,
  });

  /// Metadata of this component: template, stable since 0.1.0.
  static const DsComponentInfo info = DsComponentInfo(
    name: 'DsPageScaffold',
    level: DsComponentLevel.template,
    status: DsComponentStatus.stable,
    since: '0.1.0',
  );

  /// The title shown in the title bar.
  final String title;

  /// The content of the page.
  final Widget body;

  /// Optional main action, pinned at the bottom.
  final DsButton? primaryAction;

  /// Optional callback of the back button.
  final VoidCallback? onBack;

  /// Optional identifier that UI automation finds the page by; exposed
  /// only in builds made with the QA switch.
  final String? qaIdentifier;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final onBack = this.onBack;
    final primaryAction = this.primaryAction;
    final page = Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(title),
        leading: onBack == null ? null : BackButton(onPressed: onBack),
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: context.dsTypography.title.copyWith(
          color: colors.textPrimary,
        ),
      ),
      body: SafeArea(
        child: Padding(padding: spacing.all(DsSpacingStep.md), child: body),
      ),
      bottomNavigationBar: primaryAction == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: spacing.only(
                  left: DsSpacingStep.md,
                  right: DsSpacingStep.md,
                  bottom: DsSpacingStep.md,
                ),
                child: SizedBox(width: double.infinity, child: primaryAction),
              ),
            ),
    );
    return DsGuidelinesFrame(
      level: DsPageScaffold.info.level,
      // A page forms no node of its own: its title bar, body, and action
      // keep their nodes, and the identifier gets a group node.
      child: DsQaSemantics.group(identifier: qaIdentifier, child: page),
    );
  }
}
