/// @docImport '../components/atoms/ds_button.dart';
library;

/// Build switch that exposes the components' QA identifiers to UI
/// automation.
///
/// Use this to check, in a test or a debug screen, whether the running build
/// exposes QA identifiers. Give components a `qaIdentifier`, such as
/// [DsButton.qaIdentifier], and turn the switch on when you build the app for
/// automated UI tests:
///
/// ```bash
/// flutter build apk --dart-define=DS_QA_IDENTIFIERS=true
/// ```
///
/// This is **not** a runtime setting: [enabled] is a compile-time constant,
/// so nothing at runtime, such as a remote flag, can turn identifiers on in
/// a build made without the switch.
///
/// Built-in: every component accepts an optional `qaIdentifier`.
/// * With the switch off, the default in every build mode, components ignore
///   their identifiers, and the accessibility tree is the same as a build
///   without them.
/// * With the switch on, a component puts its identifier on its own
///   semantics node, the one that holds its accessible label. A component
///   that forms no node of its own, such as a static `DsCard`, a
///   `DsEmptyState`, or a `DsPageScaffold`, gets an unlabelled group node
///   that holds only the identifier.
/// * Identifiers never change what screen readers announce: labels, hints,
///   values, and actions stay the same.
///
/// Rules:
/// * Identifiers are for automation only. Never put credentials or personal
///   data in them, because automation logs record them.
/// * Keep identifiers unique on a screen. The design system can't see the
///   whole screen, so it doesn't check this.
///
/// Usage from a micro app:
/// ```dart
/// DsButton(
///   label: 'Sign in',
///   onPressed: submit,
///   qaIdentifier: 'login-submit',
/// )
/// ```
///
/// Usage from an automated UI test:
/// ```dart
/// // Built with --dart-define=DS_QA_IDENTIFIERS=true.
/// final semantics = tester.ensureSemantics();
/// await tester.tap(find.bySemanticsIdentifier('login-submit'));
/// semantics.dispose();
/// ```
abstract final class DsQaIdentifiers {
  /// Whether this build exposes QA identifiers, from the compile-time
  /// `DS_QA_IDENTIFIERS` define. Defaults to false.
  static const bool enabled = bool.fromEnvironment('DS_QA_IDENTIFIERS');
}
