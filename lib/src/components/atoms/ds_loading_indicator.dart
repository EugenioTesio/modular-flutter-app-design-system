/// @docImport '../../tokens/ds_colors.dart';
/// @docImport '../../tokens/ds_icon_sizes.dart';
/// @docImport 'ds_button.dart';
library;

import 'package:flutter/material.dart';

import '../../catalog/ds_component_info.dart';
import '../../theme/ds_theme_context.dart';

/// Widget that shows that content is loading, in the action color.
///
/// Use this while a screen or section waits for data, for example in place of
/// a list until the first page arrives.
///
/// This is **not** for a button that is busy: set [DsButton.isLoading]
/// instead, so the button keeps its size and label.
///
/// Built-in: the spinner uses [DsColors.actionPrimary] and is announced to
/// screen readers with [semanticsLabel]. It animates until it is removed.
///
/// **Status**: stable.
///
/// Usage from a micro app:
/// ```dart
/// if (accounts == null) {
///   return const Center(
///     child: DsLoadingIndicator(semanticsLabel: 'Loading accounts'),
///   );
/// }
/// ```
final class DsLoadingIndicator extends StatelessWidget {
  /// Creates a loading indicator.
  ///
  /// Parameters:
  /// * [semanticsLabel] - What is loading, announced to screen readers, such
  ///   as "Loading accounts". Localize it.
  /// * [size] - Optional diameter in logical pixels. Null means the nearest
  ///   brand's regular icon size, [DsIconSizes.md].
  const DsLoadingIndicator({
    super.key,
    required this.semanticsLabel,
    this.size,
  });

  /// Metadata of this component: atom, stable since 0.1.0.
  static const DsComponentInfo info = DsComponentInfo(
    name: 'DsLoadingIndicator',
    level: DsComponentLevel.atom,
    status: DsComponentStatus.stable,
    since: '0.1.0',
  );

  /// What is loading, announced to screen readers.
  final String semanticsLabel;

  /// Optional diameter in logical pixels; null means the brand's regular
  /// icon size.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final diameter = size ?? context.dsIconSizes.md;
    return SizedBox.square(
      dimension: diameter,
      child: CircularProgressIndicator(
        semanticsLabel: semanticsLabel,
        strokeWidth: diameter / 8,
        color: context.dsColors.actionPrimary,
      ),
    );
  }
}
