import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'use_case_frame.dart';

/// Use cases of the molecules: DsCard, DsListTile, DsInlineMessage, and
/// DsEmptyState.
abstract final class MoleculeUseCases {
  /// Use cases of [DsCard].
  static List<WidgetbookUseCase> get card => [
    WidgetbookUseCase(name: 'Static', builder: (_) => const _CardUseCase()),
    WidgetbookUseCase(
      name: 'Tappable',
      builder: (_) => const _CardUseCase(tappable: true),
    ),
  ];

  /// Use cases of [DsListTile].
  static List<WidgetbookUseCase> get listTile => [
    WidgetbookUseCase(
      name: 'Title only',
      builder: (_) => const _ListTileUseCase(),
    ),
    WidgetbookUseCase(
      name: 'All slots',
      builder: (_) => const _ListTileUseCase(allSlots: true),
    ),
    WidgetbookUseCase(
      name: 'Tappable',
      builder: (_) => const _ListTileUseCase(allSlots: true, tappable: true),
    ),
  ];

  /// Use cases of [DsInlineMessage], one per tone, plus an action.
  static List<WidgetbookUseCase> get inlineMessage => [
    for (final tone in DsMessageTone.values)
      WidgetbookUseCase(
        name: '${tone.name[0].toUpperCase()}${tone.name.substring(1)}',
        builder: (_) => _InlineMessageUseCase(tone: tone),
      ),
    WidgetbookUseCase(
      name: 'With action',
      builder: (_) => const _InlineMessageUseCase(
        tone: DsMessageTone.error,
        withAction: true,
      ),
    ),
  ];

  /// Use cases of [DsEmptyState].
  static List<WidgetbookUseCase> get emptyState => [
    WidgetbookUseCase(
      name: 'Title only',
      builder: (_) => const _EmptyStateUseCase(),
    ),
    WidgetbookUseCase(
      name: 'With action',
      builder: (_) => const _EmptyStateUseCase(withAction: true),
    ),
  ];
}

final class _CardUseCase extends StatelessWidget {
  const _CardUseCase({this.tappable = false});

  final bool tappable;

  @override
  Widget build(BuildContext context) {
    final knobs = context.knobs;
    final typography = context.dsTypography;
    final colors = context.dsColors;
    final isTappable = knobs.boolean(label: 'tappable', initialValue: tappable);
    return UseCaseFrame(
      child: DsCard(
        onTap: isTappable ? () {} : null,
        semanticsLabel: isTappable
            ? knobs.stringOrNull(
                label: 'semanticsLabel',
                initialValue: 'Checking account, balance 1,250.00',
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Checking account',
              style: typography.title.copyWith(color: colors.textPrimary),
            ),
            const DsGap(DsSpacingStep.xs),
            Text(
              '1,250.00',
              style: typography.display.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ListTileUseCase extends StatelessWidget {
  const _ListTileUseCase({this.allSlots = false, this.tappable = false});

  final bool allSlots;
  final bool tappable;

  @override
  Widget build(BuildContext context) {
    final knobs = context.knobs;
    final slots = knobs.boolean(label: 'slots', initialValue: allSlots);
    return UseCaseFrame(
      child: DsListTile(
        title: knobs.string(label: 'title', initialValue: 'Checking account'),
        subtitle: slots
            ? knobs.stringOrNull(label: 'subtitle', initialValue: '•••• 4821')
            : null,
        leading: slots ? const Icon(Icons.account_balance) : null,
        trailing: slots ? const Icon(Icons.chevron_right) : null,
        onTap: knobs.boolean(label: 'tappable', initialValue: tappable)
            ? () {}
            : null,
      ),
    );
  }
}

final class _InlineMessageUseCase extends StatelessWidget {
  const _InlineMessageUseCase({required this.tone, this.withAction = false});

  final DsMessageTone tone;
  final bool withAction;

  @override
  Widget build(BuildContext context) {
    final knobs = context.knobs;
    final action = knobs.boolean(label: 'action', initialValue: withAction);
    return UseCaseFrame(
      child: DsInlineMessage(
        tone: knobs.object.dropdown(
          label: 'tone',
          options: DsMessageTone.values,
          initialOption: tone,
          labelBuilder: (value) => value.name,
        ),
        title: knobs.stringOrNull(
          label: 'title',
          initialValue: 'Transfer scheduled',
        ),
        message: knobs.string(
          label: 'message',
          initialValue: 'The money arrives within one business day.',
        ),
        actionLabel: action ? 'Try again' : null,
        onAction: action ? () {} : null,
      ),
    );
  }
}

final class _EmptyStateUseCase extends StatelessWidget {
  const _EmptyStateUseCase({this.withAction = false});

  final bool withAction;

  @override
  Widget build(BuildContext context) {
    final knobs = context.knobs;
    final action = knobs.boolean(label: 'action', initialValue: withAction);
    return UseCaseFrame(
      child: DsEmptyState(
        title: knobs.string(label: 'title', initialValue: 'No transfers yet'),
        message: knobs.stringOrNull(
          label: 'message',
          initialValue: 'Transfers you send appear here.',
        ),
        icon: knobs.boolean(label: 'icon', initialValue: true)
            ? Icons.swap_horiz
            : null,
        actionLabel: action ? 'New transfer' : null,
        onAction: action ? () {} : null,
      ),
    );
  }
}
