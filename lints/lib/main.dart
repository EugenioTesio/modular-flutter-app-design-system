/// The design system's analyzer plugin: four warning rules that keep code on
/// the design system's tokens.
///
/// Projects opt in from `analysis_options.yaml`:
///
/// ```yaml
/// plugins:
///   design_system_lints:
///     path: ../design-system/lints
/// ```
///
/// The plugin runs only inside the analysis server, so it never becomes a
/// runtime dependency and never changes which `design_system` version a
/// project resolves.
library;

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/rules/ds_avoid_literal_color.dart';
import 'src/rules/ds_avoid_literal_component_value.dart';
import 'src/rules/ds_avoid_literal_spacing.dart';
import 'src/rules/ds_avoid_primitive_color.dart';

/// The plugin instance the analysis server loads.
final plugin = DsLintsPlugin();

/// Analyzer plugin that registers the design system's warning rules.
///
/// Every rule is on as soon as the plugin is enabled, and each one can be
/// switched off under `diagnostics:` in `analysis_options.yaml`.
final class DsLintsPlugin extends Plugin {
  @override
  String get name => 'design_system_lints';

  @override
  void register(PluginRegistry registry) {
    registry
      ..registerWarningRule(DsAvoidLiteralColor())
      ..registerWarningRule(DsAvoidLiteralSpacing())
      ..registerWarningRule(DsAvoidLiteralComponentValue())
      ..registerWarningRule(DsAvoidPrimitiveColor());
  }
}
