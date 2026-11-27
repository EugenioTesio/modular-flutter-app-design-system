import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Use cases of the templates: DsPageScaffold.
abstract final class TemplateUseCases {
  /// Use cases of [DsPageScaffold].
  static List<WidgetbookUseCase> get pageScaffold => [
    WidgetbookUseCase(
      name: 'Body only',
      builder: (_) => const _PageScaffoldUseCase(),
    ),
    WidgetbookUseCase(
      name: 'With primary action',
      builder: (_) => const _PageScaffoldUseCase(withAction: true),
    ),
    WidgetbookUseCase(
      name: 'With back',
      builder: (_) => const _PageScaffoldUseCase(withBack: true),
    ),
  ];
}

final class _PageScaffoldUseCase extends StatelessWidget {
  const _PageScaffoldUseCase({this.withAction = false, this.withBack = false});

  final bool withAction;
  final bool withBack;

  @override
  Widget build(BuildContext context) {
    final knobs = context.knobs;
    return DsPageScaffold(
      title: knobs.string(label: 'title', initialValue: 'Send money'),
      onBack: knobs.boolean(label: 'back', initialValue: withBack)
          ? () {}
          : null,
      primaryAction: knobs.boolean(label: 'action', initialValue: withAction)
          ? DsButton(label: 'Continue', onPressed: () {})
          : null,
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DsTextField(label: 'Recipient'),
          DsGap(DsSpacingStep.md),
          DsTextField(label: 'Amount'),
        ],
      ),
    );
  }
}
