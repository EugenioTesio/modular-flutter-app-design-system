import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../catalog/ds_component_info.dart';
import 'ds_guidelines.dart';
import 'ds_guidelines_colors.dart';
import 'ds_guidelines_mode.dart';

/// Widget that outlines a component in its level's color while the
/// developer guidelines overlay is on.
///
/// This is internal to the design system and is not exported. Every
/// component wraps its whole output in one, with its `info.level`.
///
/// The outline is a dashed rectangle painted over the child with a
/// foreground painter, so it never changes layout, hit testing, or
/// semantics.
/// * With neither a [DsGuidelines] above nor the build switch, it returns
///   the child as it is, so the tree is the same as without the overlay.
///   Release builds always take this path.
/// * Below a [DsGuidelines], it keeps its painter widget in the tree, with
///   no painter while the overlay is off, so toggling the overlay keeps the
///   child's state.
final class DsGuidelinesFrame extends StatelessWidget {
  /// Creates a guidelines frame.
  ///
  /// Parameters:
  /// * [level] - The component's atomic level, which sets the outline
  ///   color.
  /// * [child] - The component's output.
  const DsGuidelinesFrame({
    super.key,
    required this.level,
    required this.child,
  });

  /// The component's atomic level, which sets the outline color.
  final DsComponentLevel level;

  /// The component's output.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!DsGuidelinesMode.isSwitchable(context)) return child;
    return CustomPaint(
      foregroundPainter: DsGuidelines.isEnabledOf(context)
          ? _DsGuidelinesOutlinePainter(DsGuidelinesColors.forLevel(level))
          : null,
      child: child,
    );
  }
}

/// Painter of the dashed outline around a component.
final class _DsGuidelinesOutlinePainter extends CustomPainter {
  const _DsGuidelinesOutlinePainter(this.color);

  /// The outline color.
  final Color color;

  /// Width of the outline, in logical pixels.
  static const double _strokeWidth = 1;

  /// Length of each dash, in logical pixels.
  static const double _dashLength = 4;

  /// Length of the space between dashes, in logical pixels.
  static const double _spaceLength = 3;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= _strokeWidth || size.height <= _strokeWidth) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    // Inset by half the stroke, so the whole line stays inside the
    // component's bounds and survives clipping by its parent.
    final outline = Path()
      ..addRect((Offset.zero & size).deflate(_strokeWidth / 2));
    for (final metric in outline.computeMetrics()) {
      for (
        var start = 0.0;
        start < metric.length;
        start += _dashLength + _spaceLength
      ) {
        final end = math.min(start + _dashLength, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DsGuidelinesOutlinePainter oldDelegate) =>
      color != oldDelegate.color;
}
