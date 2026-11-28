import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// The states of one component that the accessibility harness checks and
/// the golden matrix draws, so every checked state also has golden images.
final class DsComponentCases {
  /// Creates a component's case list.
  ///
  /// Parameters:
  /// * [info] - The component's catalog entry; its name gives the golden
  ///   folder, such as `ds_button`.
  /// * [goldenSurfaceSize] - Logical size of the screen the golden images
  ///   are drawn on. It bounds components that fill the available width.
  /// * [states] - Builders keyed by state, such as `loading`. The keys
  ///   complete "When it is …" in test names and give the golden file names.
  const DsComponentCases({
    required this.info,
    required this.goldenSurfaceSize,
    required this.states,
  });

  /// The component's catalog entry.
  final DsComponentInfo info;

  /// Logical size of the screen the golden images are drawn on.
  final Size goldenSurfaceSize;

  /// Builders keyed by state, such as `loading`.
  final Map<String, Widget Function()> states;

  /// [DsButton] in each variant and state.
  static final DsComponentCases button = DsComponentCases(
    info: DsButton.info,
    goldenSurfaceSize: const Size(360, 160),
    states: {
      'primary': () =>
          const DsButton(label: 'Continue', onPressed: DsComponentCases._noop),
      'secondary': () => const DsButton(
        label: 'Cancel',
        onPressed: DsComponentCases._noop,
        variant: DsButtonVariant.secondary,
      ),
      'tertiary': () => const DsButton(
        label: 'Skip',
        onPressed: DsComponentCases._noop,
        variant: DsButtonVariant.tertiary,
      ),
      'primary with an icon and a long label': () => const DsButton(
        label: 'Send the transfer to a saved recipient',
        icon: Icons.send,
        onPressed: DsComponentCases._noop,
        expand: true,
      ),
      'disabled': () => const DsButton(label: 'Continue', onPressed: null),
      'loading': () => const DsButton(
        label: 'Continue',
        onPressed: DsComponentCases._noop,
        isLoading: true,
      ),
    },
  );

  /// [DsTextField] in each state.
  static final DsComponentCases textField = DsComponentCases(
    info: DsTextField.info,
    goldenSurfaceSize: const Size(360, 200),
    states: {
      'labeled': () => const DsTextField(label: 'Email'),
      'showing a hint and helper text': () => const DsTextField(
        label: 'Email',
        hint: 'name@example.com',
        helperText: 'We send the receipt to this address.',
      ),
      'showing an error': () => const DsTextField(
        label: 'Amount',
        errorText: 'Enter an amount greater than zero.',
      ),
      'disabled': () => const DsTextField(label: 'Email', enabled: false),
    },
  );

  /// [DsLoadingIndicator] at the default size and at the brand's large icon
  /// size. Only the large one fills enough of its image for a color change
  /// to go over the golden threshold.
  static final DsComponentCases loadingIndicator = DsComponentCases(
    info: DsLoadingIndicator.info,
    goldenSurfaceSize: const Size(200, 200),
    states: {
      'spinning': () =>
          const DsLoadingIndicator(semanticsLabel: 'Loading accounts'),
      'spinning at the large icon size': () => Builder(
        builder: (context) => DsLoadingIndicator(
          semanticsLabel: 'Loading accounts',
          size: context.dsIconSizes.lg,
        ),
      ),
    },
  );

  /// [DsCard], static and tappable.
  static final DsComponentCases card = DsComponentCases(
    info: DsCard.info,
    goldenSurfaceSize: const Size(360, 200),
    states: {
      'static': () => const DsCard(child: Text('Checking account')),
      'tappable with a label': () => DsCard(
        onTap: DsComponentCases._noop,
        semanticsLabel: 'Checking account, balance 1,250',
        child: const Text('Checking account'),
      ),
      'tappable without a label': () => const DsCard(
        onTap: DsComponentCases._noop,
        child: Text('Savings account'),
      ),
    },
  );

  /// [DsListTile] with one slot and with every slot.
  static final DsComponentCases listTile = DsComponentCases(
    info: DsListTile.info,
    goldenSurfaceSize: const Size(360, 200),
    states: {
      'a title only': () => const DsListTile(title: 'Checking'),
      'tappable with every slot': () => const DsListTile(
        title: 'Everyday checking account with a long name',
        subtitle: '•••• 4821 · Opened in 2019 at the downtown branch',
        leading: Icon(Icons.account_balance),
        trailing: Icon(Icons.chevron_right),
        onTap: DsComponentCases._noop,
      ),
    },
  );

  /// [DsInlineMessage] in each tone, and with a message only.
  static final DsComponentCases inlineMessage = DsComponentCases(
    info: DsInlineMessage.info,
    goldenSurfaceSize: const Size(360, 280),
    states: {
      for (final tone in DsMessageTone.values)
        'in the ${tone.name} tone with a title and an action': () =>
            DsInlineMessage(
              tone: tone,
              title: 'Balance unavailable',
              message: 'Check your connection and try again in a minute.',
              actionLabel: 'Retry',
              onAction: DsComponentCases._noop,
            ),
      'a message only': () =>
          const DsInlineMessage(message: 'Transfers made today appear here.'),
    },
  );

  /// [DsEmptyState] with and without an action.
  static final DsComponentCases emptyState = DsComponentCases(
    info: DsEmptyState.info,
    goldenSurfaceSize: const Size(360, 320),
    states: {
      'without an action': () => const DsEmptyState(
        icon: Icons.receipt_long,
        title: 'No transfers yet',
        message: 'Transfers you make appear here.',
      ),
      'with an action': () => const DsEmptyState(
        icon: Icons.receipt_long,
        title: 'No transfers yet',
        message: 'Transfers you make appear here.',
        actionLabel: 'New transfer',
        onAction: DsComponentCases._noop,
      ),
    },
  );

  /// [DsPageScaffold] with and without a primary action. It fills the
  /// screen, so the harness checks it without a scroll view.
  static final DsComponentCases pageScaffold = DsComponentCases(
    info: DsPageScaffold.info,
    goldenSurfaceSize: const Size(360, 640),
    states: {
      'with a body and a primary action': () => const DsPageScaffold(
        title: 'New transfer to a saved recipient',
        body: Text('Choose who receives the money.'),
        primaryAction: DsButton(
          label: 'Continue',
          onPressed: DsComponentCases._noop,
        ),
        onBack: DsComponentCases._noop,
      ),
      'with a body only': () => const DsPageScaffold(
        title: 'Accounts',
        body: Text('No accounts yet.'),
      ),
    },
  );

  /// Every component's cases, in catalog order.
  static final List<DsComponentCases> all = [
    button,
    textField,
    loadingIndicator,
    card,
    listTile,
    inlineMessage,
    emptyState,
    pageScaffold,
  ];

  static void _noop() {}
}
