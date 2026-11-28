/// @docImport '../../tokens/ds_colors.dart';
/// @docImport 'ds_list_tile.dart';
/// @docImport '../../qa/ds_qa_identifiers.dart';
library;

import 'package:flutter/material.dart';

import '../../catalog/ds_component_info.dart';
import '../../guidelines/ds_guidelines_frame.dart';
import '../../qa/ds_qa_semantics.dart';
import '../../theme/ds_theme_context.dart';
import '../../tokens/ds_spacing.dart';

/// Widget that groups related content on a raised surface.
///
/// Use this to set a block of content apart from the page, such as an
/// account summary or a promotion. Set [onTap] to make the whole card one
/// tappable element.
///
/// This is **not** a list row: for a row with a title, a subtitle, and an
/// optional icon, use [DsListTile].
///
/// Built-in:
/// * The card uses [DsColors.surface], a [DsColors.border] outline, and
///   rounded corners.
/// * When [onTap] is set, the card is one button for screen readers, at
///   least 48 high. Its label is [semanticsLabel] when set, and otherwise the
///   text inside the card.
///
/// **Status**: stable.
///
/// Usage from a micro app:
/// ```dart
/// DsCard(
///   onTap: () => navigator.push('/accounts/details/${account.id}'),
///   semanticsLabel: 'Checking account, balance ${account.balance}',
///   child: AccountSummary(account: account),
/// )
/// ```
final class DsCard extends StatelessWidget {
  /// Creates a card.
  ///
  /// Parameters:
  /// * [child] - The content of the card.
  /// * [onTap] - Optional callback that makes the whole card tappable.
  /// * [semanticsLabel] - Optional label that replaces the content for
  ///   screen readers. Set it whenever [onTap] is set and the content is not
  ///   a short, clear text. Localize it.
  /// * [padding] - Optional space around [child]. Null means the nearest
  ///   brand's medium spacing step on every side.
  /// * [qaIdentifier] - Optional identifier that UI automation finds the
  ///   card by. It is exposed only in builds made with the QA switch
  ///   ([DsQaIdentifiers.enabled]), and never changes what screen readers
  ///   announce. Never put personal data in it.
  const DsCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticsLabel,
    this.padding,
    this.qaIdentifier,
  });

  /// Metadata of this component: molecule, stable since 0.1.0.
  static const DsComponentInfo info = DsComponentInfo(
    name: 'DsCard',
    level: DsComponentLevel.molecule,
    status: DsComponentStatus.stable,
    since: '0.1.0',
  );

  /// The content of the card.
  final Widget child;

  /// Optional callback that makes the whole card tappable.
  final VoidCallback? onTap;

  /// Optional label that replaces the content for screen readers.
  final String? semanticsLabel;

  /// Optional space around [child]; null means the brand's medium spacing
  /// step on every side.
  final EdgeInsetsGeometry? padding;

  /// Optional identifier that UI automation finds the card by; exposed
  /// only in builds made with the QA switch.
  final String? qaIdentifier;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(context.dsRadius.md),
      side: BorderSide(
        color: colors.border,
        width: context.dsBorderWidths.thin,
      ),
    );
    final content = Padding(
      padding: padding ?? context.dsSpacing.all(DsSpacingStep.md),
      child: child,
    );
    final tap = onTap;
    if (tap == null) {
      return DsGuidelinesFrame(
        level: DsCard.info.level,
        // A static card forms no node of its own: its content keeps its
        // nodes, and the identifier gets an unlabelled group node.
        child: DsQaSemantics.group(
          identifier: qaIdentifier,
          child: Material(
            color: colors.surface,
            shape: shape,
            clipBehavior: Clip.antiAlias,
            child: content,
          ),
        ),
      );
    }

    final card = Semantics(
      container: true,
      button: true,
      identifier: DsQaSemantics.identifierOf(qaIdentifier),
      label: semanticsLabel,
      onTap: tap,
      excludeSemantics: semanticsLabel != null,
      child: Material(
        color: colors.surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: tap,
          customBorder: shape,
          focusColor: colors.focus.withValues(
            alpha: context.dsOpacities.focused,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
              minWidth: kMinInteractiveDimension,
            ),
            child: content,
          ),
        ),
      ),
    );
    return DsGuidelinesFrame(
      level: DsCard.info.level,
      child: semanticsLabel == null ? MergeSemantics(child: card) : card,
    );
  }
}
