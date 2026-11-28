import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';

/// Widgetbook addon that turns the developer guidelines overlay on and off.
///
/// It wraps each use case in a [DsGuidelines], the same widget the App Shell
/// places, so reviewers see each component outlined in its level's color and
/// its gaps tinted. The toggle starts off, and has no effect in a release
/// build, where the overlay never shows.
final class DsGuidelinesAddon extends WidgetbookAddon<bool> {
  /// Creates a guidelines addon.
  DsGuidelinesAddon() : super(name: 'Guidelines');

  @override
  List<Field> get fields => [
    BooleanField(name: 'guidelines', initialValue: false),
  ];

  @override
  bool valueFromQueryGroup(Map<String, String> group) =>
      valueOf<bool>('guidelines', group) ?? false;

  @override
  Widget buildUseCase(BuildContext context, Widget child, bool setting) =>
      DsGuidelines(enabled: setting, child: child);
}
