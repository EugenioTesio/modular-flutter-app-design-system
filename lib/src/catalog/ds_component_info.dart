/// @docImport 'ds_component_catalog.dart';
library;

import 'package:flutter/foundation.dart';

/// Value that names a component's atomic level.
///
/// Use this to group components, for example in the Widgetbook, or to read
/// how a component is built.
///
/// This is **not** a measure of importance: a template can be as small as an
/// atom in code.
///
/// Usage from a micro app:
/// ```dart
/// final isAtom = DsButton.info.level == DsComponentLevel.atom;
/// ```
enum DsComponentLevel {
  /// A basic building block, such as a button.
  atom,

  /// A small group of atoms, such as a list row.
  molecule,

  /// A larger section built from molecules.
  organism,

  /// A page layout.
  template,
}

/// Value that names how far consumers can rely on a component.
///
/// Use this to decide whether to adopt a component: build on stable ones,
/// try experimental ones knowing they may change, and move off deprecated
/// ones.
///
/// This is **not** a version: [DsComponentInfo.since] says when a component
/// arrived.
///
/// Rules:
/// * A new component starts [experimental]. It may change or be removed in
///   any minor release, and the change is listed in the changelog.
/// * A [deprecated] component names its replacement and the version that
///   removes it, and stays for at least one minor release.
///
/// Usage from a micro app:
/// ```dart
/// assert(DsButton.info.status == DsComponentStatus.stable);
/// ```
enum DsComponentStatus {
  /// New and still allowed to change in any minor release.
  experimental,

  /// Settled; it changes only in ways semantic versioning allows.
  stable,

  /// On its way out; a replacement exists.
  deprecated,
}

/// Value that describes a design system component: its name, level, status,
/// and versions.
///
/// Use this to read a component's metadata, for example `DsButton.info`.
///
/// This is **not** configuration: every component declares its own
/// `static const info`, and [DsComponentCatalog.all] lists them.
///
/// Built-in: the Widgetbook groups components by [level] and shows [status],
/// and the developer guidelines overlay outlines each component in its
/// level's color.
///
/// Rules: a [DsComponentStatus.deprecated] component names [removedIn].
///
/// Usage from a micro app:
/// ```dart
/// final info = DsButton.info;
/// debugPrint('${info.name} (${info.status.name}) since ${info.since}');
/// ```
@immutable
final class DsComponentInfo {
  /// Creates a component's metadata.
  ///
  /// Parameters:
  /// * [name] - The component's class name, such as `DsButton`.
  /// * [level] - The component's atomic level.
  /// * [status] - How far consumers can rely on the component.
  /// * [since] - The release that added the component, such as `0.1.0`.
  /// * [removedIn] - Optional release that removes the component. Required
  ///   when [status] is [DsComponentStatus.deprecated].
  const DsComponentInfo({
    required this.name,
    required this.level,
    required this.status,
    required this.since,
    this.removedIn,
  }) : assert(
         status != DsComponentStatus.deprecated || removedIn != null,
         'A deprecated component names the release that removes it.',
       );

  /// The component's class name, such as `DsButton`.
  final String name;

  /// The component's atomic level.
  final DsComponentLevel level;

  /// How far consumers can rely on the component.
  final DsComponentStatus status;

  /// The release that added the component, such as `0.1.0`.
  final String since;

  /// Optional release that removes the component; set when it is deprecated.
  final String? removedIn;

  @override
  bool operator ==(Object other) =>
      other is DsComponentInfo &&
      other.name == name &&
      other.level == level &&
      other.status == status &&
      other.since == since &&
      other.removedIn == removedIn;

  @override
  int get hashCode => Object.hash(name, level, status, since, removedIn);

  @override
  String toString() => '$name · ${status.name}';
}
