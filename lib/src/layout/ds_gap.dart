/// @docImport '../theme/ds_theme_context.dart';
library;

import 'package:flutter/widgets.dart';

import '../theme/ds_theme_context.dart';
import '../tokens/ds_spacing.dart';

/// Widget that leaves a square gap of one spacing step of the nearest
/// brand.
///
/// Use this between the children of a `Row` or `Column`, instead of a
/// `SizedBox` with a literal size, so the gap follows the nearest brand.
///
/// This is **not** a component: it draws nothing and has no metadata.
///
/// Built-in: the size comes from [DsThemeContext.dsSpacing], so a nested
/// brand with another spacing scale changes it.
///
/// Usage from a micro app:
/// ```dart
/// Column(
///   children: [
///     const Text('Accounts'),
///     const DsGap(DsSpacingStep.sm),
///     DsListTile(title: 'Checking', onTap: openChecking),
///   ],
/// )
/// ```
final class DsGap extends StatelessWidget {
  /// Creates a gap.
  ///
  /// Parameters:
  /// * [step] - The spacing step that sets the gap's width and height.
  const DsGap(this.step, {super.key});

  /// The spacing step that sets the gap's width and height.
  final DsSpacingStep step;

  @override
  Widget build(BuildContext context) =>
      SizedBox.square(dimension: context.dsSpacing[step]);
}
