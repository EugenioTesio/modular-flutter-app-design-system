import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Frame that shows a component use case on the brand's background, centered,
/// with the brand's medium padding.
final class UseCaseFrame extends StatelessWidget {
  /// Creates a use-case frame.
  const UseCaseFrame({super.key, required this.child, this.maxWidth = 420});

  /// The component to show.
  final Widget child;

  /// Widest the component may be, so fields and cards keep a phone width.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.dsColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: context.dsSpacing.all(DsSpacingStep.md),
            child: child,
          ),
        ),
      ),
    );
  }
}
