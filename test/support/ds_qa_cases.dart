import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// One component state built with or without a QA identifier, for the QA
/// identifier tests.
final class DsQaCase {
  /// Creates a QA case.
  ///
  /// Parameters:
  /// * [info] - The component's catalog entry.
  /// * [state] - The state, such as `primary`; it completes test names.
  /// * [identifier] - The QA identifier the case passes when it has one.
  /// * [build] - Builds the component with the given QA identifier, or with
  ///   none when it is null.
  /// * [ownLabel] - Optional label of the component's own semantics node,
  ///   which holds the identifier. Null when the component forms no node of
  ///   its own, so the identifier sits on an unlabelled group node around
  ///   the component's nodes.
  const DsQaCase({
    required this.info,
    required this.state,
    required this.identifier,
    required this.build,
    this.ownLabel,
  });

  /// The component's catalog entry.
  final DsComponentInfo info;

  /// The state, such as `primary`.
  final String state;

  /// The QA identifier the case passes when it has one.
  final String identifier;

  /// Builds the component with the given QA identifier, or with none.
  final Widget Function(String? qaIdentifier) build;

  /// Optional label of the component's own semantics node.
  final String? ownLabel;

  /// The case's name in test names, such as `DsButton (primary)`.
  String get name => '${info.name} ($state)';
}

/// Every component's QA cases, and the helpers the QA tests share.
abstract final class DsQaCases {
  /// Every component's cases, in catalog order. Every component appears, and
  /// each state with a different semantics shape has its own case.
  static final List<DsQaCase> all = [
    DsQaCase(
      info: DsButton.info,
      state: 'primary',
      identifier: 'login-submit',
      ownLabel: 'Sign in',
      build: (id) => DsButton(
        label: 'Sign in',
        onPressed: DsQaCases._noop,
        qaIdentifier: id,
      ),
    ),
    DsQaCase(
      info: DsButton.info,
      state: 'loading',
      identifier: 'login-submit-busy',
      ownLabel: 'Sign in',
      build: (id) => DsButton(
        label: 'Sign in',
        onPressed: DsQaCases._noop,
        isLoading: true,
        qaIdentifier: id,
      ),
    ),
    DsQaCase(
      info: DsButton.info,
      state: 'disabled',
      identifier: 'login-submit-off',
      ownLabel: 'Sign in',
      build: (id) =>
          DsButton(label: 'Sign in', onPressed: null, qaIdentifier: id),
    ),
    DsQaCase(
      info: DsTextField.info,
      state: 'labeled',
      identifier: 'login-email',
      ownLabel: 'Email',
      build: (id) => DsTextField(label: 'Email', qaIdentifier: id),
    ),
    DsQaCase(
      info: DsTextField.info,
      state: 'showing an error',
      identifier: 'transfer-amount',
      ownLabel: 'Amount',
      build: (id) => DsTextField(
        label: 'Amount',
        errorText: 'Enter an amount greater than zero.',
        qaIdentifier: id,
      ),
    ),
    DsQaCase(
      info: DsLoadingIndicator.info,
      state: 'spinning',
      identifier: 'accounts-loading',
      ownLabel: 'Loading accounts',
      build: (id) => DsLoadingIndicator(
        semanticsLabel: 'Loading accounts',
        qaIdentifier: id,
      ),
    ),
    DsQaCase(
      info: DsCard.info,
      state: 'static',
      identifier: 'balance-card',
      build: (id) => DsCard(
        qaIdentifier: id,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [Text('Checking account'), Text('1,250.00')],
        ),
      ),
    ),
    DsQaCase(
      info: DsCard.info,
      state: 'tappable with a label',
      identifier: 'checking-card',
      ownLabel: 'Checking account, balance 1,250',
      build: (id) => DsCard(
        onTap: DsQaCases._noop,
        semanticsLabel: 'Checking account, balance 1,250',
        qaIdentifier: id,
        child: const Text('Checking account'),
      ),
    ),
    DsQaCase(
      info: DsCard.info,
      state: 'tappable without a label',
      identifier: 'savings-card',
      ownLabel: 'Savings account',
      build: (id) => DsCard(
        onTap: DsQaCases._noop,
        qaIdentifier: id,
        child: const Text('Savings account'),
      ),
    ),
    DsQaCase(
      info: DsListTile.info,
      state: 'a title only',
      identifier: 'account-row',
      ownLabel: 'Checking',
      build: (id) => DsListTile(title: 'Checking', qaIdentifier: id),
    ),
    DsQaCase(
      info: DsListTile.info,
      state: 'tappable with every slot',
      identifier: 'account-row-open',
      ownLabel: 'Checking\n•••• 4821',
      build: (id) => DsListTile(
        title: 'Checking',
        subtitle: '•••• 4821',
        leading: const Icon(Icons.account_balance),
        trailing: const Icon(Icons.chevron_right),
        onTap: DsQaCases._noop,
        qaIdentifier: id,
      ),
    ),
    DsQaCase(
      info: DsInlineMessage.info,
      state: 'a message only',
      identifier: 'transfers-note',
      ownLabel: 'Transfers made today appear here.',
      build: (id) => DsInlineMessage(
        message: 'Transfers made today appear here.',
        qaIdentifier: id,
      ),
    ),
    DsQaCase(
      info: DsInlineMessage.info,
      state: 'with a title and an action',
      identifier: 'balance-error',
      ownLabel: 'Balance unavailable\nCheck your connection.',
      build: (id) => DsInlineMessage(
        tone: DsMessageTone.error,
        title: 'Balance unavailable',
        message: 'Check your connection.',
        actionLabel: 'Retry',
        onAction: DsQaCases._noop,
        qaIdentifier: id,
      ),
    ),
    DsQaCase(
      info: DsEmptyState.info,
      state: 'with an action',
      identifier: 'transfers-empty',
      build: (id) => DsEmptyState(
        icon: Icons.receipt_long,
        title: 'No transfers yet',
        message: 'Transfers you make appear here.',
        actionLabel: 'New transfer',
        onAction: DsQaCases._noop,
        qaIdentifier: id,
      ),
    ),
    DsQaCase(
      info: DsPageScaffold.info,
      state: 'with a body and a primary action',
      identifier: 'transfer-page',
      build: (id) => DsPageScaffold(
        title: 'New transfer',
        body: const Text('Choose who receives the money.'),
        primaryAction: const DsButton(
          label: 'Continue',
          onPressed: DsQaCases._noop,
        ),
        onBack: DsQaCases._noop,
        qaIdentifier: id,
      ),
    ),
  ];

  /// Pumps [child] alone in an app with the white label in light mode.
  ///
  /// Each call builds a new app, so nothing carries over between builds.
  static Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        theme: DsTheme.light(),
        themeAnimationStyle: AnimationStyle.noAnimation,
        home: Scaffold(body: Center(child: child)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Returns the whole semantics tree as text, without node ids and object
  /// hashes, such as `SemanticsNode#4`, which differ between builds.
  static String semanticsTreeOf(WidgetTester tester) =>
      DsQaCases._root(tester)
          .toStringDeep(childOrder: DebugSemanticsDumpOrder.traversalOrder)
          .replaceAll(RegExp('#[0-9a-f]+'), '');

  /// Returns what a screen reader can reach, in traversal order: one line
  /// per node that has a label, value, hint, tooltip, action, or flag.
  ///
  /// Nodes merged into a parent are read through that parent, and nodes
  /// with nothing to announce, such as a group that only holds a QA
  /// identifier, are left out.
  static List<String> announcedNodesOf(WidgetTester tester) {
    final lines = <String>[];
    void visit(SemanticsNode node) {
      if (!node.isMergedIntoParent) {
        final data = node.getSemanticsData();
        final flags = data.flagsCollection.toStrings();
        final hasContent =
            data.label.isNotEmpty ||
            data.value.isNotEmpty ||
            data.hint.isNotEmpty ||
            data.tooltip.isNotEmpty ||
            data.actions != 0 ||
            flags.isNotEmpty;
        if (hasContent) {
          lines.add(
            [
              'label: ${data.label}',
              'value: ${data.value}',
              'hint: ${data.hint}',
              'tooltip: ${data.tooltip}',
              'actions: ${data.actions}',
              'flags: ${flags.join(', ')}',
              'role: ${data.role.name}',
            ].join(' | '),
          );
        }
      }
      if (node.mergeAllDescendantsIntoThisNode) return;
      for (final child in node.debugListChildrenInOrder(
        DebugSemanticsDumpOrder.traversalOrder,
      )) {
        visit(child);
      }
    }

    visit(DsQaCases._root(tester));
    return lines;
  }

  static SemanticsNode _root(WidgetTester tester) => tester
      .renderObject(find.byType(MaterialApp))
      .owner!
      .semanticsOwner!
      .rootSemanticsNode!;

  static void _noop() {}
}
