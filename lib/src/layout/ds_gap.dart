/// @docImport '../theme/ds_theme_context.dart';
library;

import 'package:flutter/widgets.dart';

import '../guidelines/ds_guidelines.dart';
import '../guidelines/ds_guidelines_colors.dart';
import '../guidelines/ds_guidelines_mode.dart';
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
/// Built-in:
/// * The size comes from [DsThemeContext.dsSpacing], so a nested brand with
///   another spacing scale changes it.
/// * While the developer guidelines overlay is on ([DsGuidelines]), the gap
///   is tinted, so reviewers can see which spacing comes from tokens. The
///   tint never changes its size, and release builds never show it.
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
  Widget build(BuildContext context) {
    final gap = SizedBox.square(dimension: context.dsSpacing[step]);
    // With nothing that can turn the overlay on, and always in release
    // builds, the gap is built as it is without the overlay. Below a
    // DsGuidelines, the painter widget stays, so toggling keeps the layout
    // tree stable.
    if (!DsGuidelinesMode.isSwitchable(context)) return gap;
    return CustomPaint(
      painter: DsGuidelines.isEnabledOf(context)
          ? const _DsGapTintPainter()
          : null,
      child: gap,
    );
  }
}

/// Painter that tints a gap while the guidelines overlay is on.
final class _DsGapTintPainter extends CustomPainter {
  const _DsGapTintPainter();

  @override
  void paint(Canvas canvas, Size size) => canvas.drawRect(
    Offset.zero & size,
    Paint()..color = DsGuidelinesColors.gapTint,
  );

  @override
  bool shouldRepaint(_DsGapTintPainter oldDelegate) => false;
}
