/// @docImport '../brand/ds_brand.dart';
/// @docImport '../layout/ds_gap.dart';
/// @docImport '../theme/ds_theme_context.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Value that names one step of the spacing scale.
///
/// Use this to pick a step for [DsSpacing.all], [DsSpacing.symmetric],
/// [DsSpacing.only], or [DsGap], so the size comes from the nearest brand.
///
/// This is **not** a size in pixels: the size of each step comes from the
/// brand, through `context.dsSpacing`.
///
/// Usage from a micro app:
/// ```dart
/// Padding(
///   padding: context.dsSpacing.all(DsSpacingStep.md),
///   child: const Text('Accounts'),
/// )
/// ```
enum DsSpacingStep {
  /// Extra-extra-small step.
  xxs,

  /// Extra-small step.
  xs,

  /// Small step.
  sm,

  /// Medium step, the default page padding.
  md,

  /// Large step.
  lg,

  /// Extra-large step.
  xl,

  /// Extra-extra-large step.
  xxl,
}

/// Value that holds a brand's spacing scale, in logical pixels.
///
/// Use this for every padding and gap in a screen, through
/// `context.dsSpacing`, so layouts follow the nearest brand's rhythm:
/// `context.dsSpacing.all(DsSpacingStep.md)` rather than
/// `EdgeInsets.all(16)`.
///
/// This is **not** a set of fixed constants: each brand supplies its own
/// scale, and a nested brand can change it for part of the screen.
///
/// Built-in: [DsBrand.spacing] holds it, and [DsThemeContext.dsSpacing]
/// reads the nearest brand's scale.
///
/// Rules: every step is at least 0. The white label's scale is
/// 4 · 8 · 12 · 16 · 24 · 32 · 48.
///
/// Usage from a micro app:
/// ```dart
/// final spacing = context.dsSpacing;
/// return Padding(
///   padding: spacing.symmetric(
///     horizontal: DsSpacingStep.md,
///     vertical: DsSpacingStep.sm,
///   ),
///   child: child,
/// );
/// ```
@immutable
final class DsSpacing {
  /// Creates a spacing scale.
  ///
  /// Parameters:
  /// * [xxs] - Extra-extra-small step.
  /// * [xs] - Extra-small step.
  /// * [sm] - Small step.
  /// * [md] - Medium step, the default page padding.
  /// * [lg] - Large step.
  /// * [xl] - Extra-large step.
  /// * [xxl] - Extra-extra-large step.
  ///
  /// Every step must be at least 0.
  const DsSpacing({
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  }) : assert(xxs >= 0, 'xxs must be at least 0'),
       assert(xs >= 0, 'xs must be at least 0'),
       assert(sm >= 0, 'sm must be at least 0'),
       assert(md >= 0, 'md must be at least 0'),
       assert(lg >= 0, 'lg must be at least 0'),
       assert(xl >= 0, 'xl must be at least 0'),
       assert(xxl >= 0, 'xxl must be at least 0');

  /// Extra-extra-small step.
  final double xxs;

  /// Extra-small step.
  final double xs;

  /// Small step.
  final double sm;

  /// Medium step, the default page padding.
  final double md;

  /// Large step.
  final double lg;

  /// Extra-large step.
  final double xl;

  /// Extra-extra-large step.
  final double xxl;

  /// Returns the size of [step], in logical pixels.
  ///
  /// Parameters:
  /// * [step] - The step to read.
  double operator [](DsSpacingStep step) => switch (step) {
    DsSpacingStep.xxs => xxs,
    DsSpacingStep.xs => xs,
    DsSpacingStep.sm => sm,
    DsSpacingStep.md => md,
    DsSpacingStep.lg => lg,
    DsSpacingStep.xl => xl,
    DsSpacingStep.xxl => xxl,
  };

  /// Returns insets of [step] on every side.
  ///
  /// Parameters:
  /// * [step] - The step to use on all four sides.
  EdgeInsets all(DsSpacingStep step) => EdgeInsets.all(this[step]);

  /// Returns insets of one step horizontally and another vertically.
  ///
  /// Parameters:
  /// * [horizontal] - Optional step for the left and right sides; null means
  ///   0.
  /// * [vertical] - Optional step for the top and bottom sides; null means 0.
  EdgeInsets symmetric({DsSpacingStep? horizontal, DsSpacingStep? vertical}) =>
      EdgeInsets.symmetric(
        horizontal: _size(horizontal),
        vertical: _size(vertical),
      );

  /// Returns insets with a step on each given side.
  ///
  /// Parameters:
  /// * [left] - Optional step for the left side; null means 0.
  /// * [top] - Optional step for the top side; null means 0.
  /// * [right] - Optional step for the right side; null means 0.
  /// * [bottom] - Optional step for the bottom side; null means 0.
  EdgeInsets only({
    DsSpacingStep? left,
    DsSpacingStep? top,
    DsSpacingStep? right,
    DsSpacingStep? bottom,
  }) => EdgeInsets.only(
    left: _size(left),
    top: _size(top),
    right: _size(right),
    bottom: _size(bottom),
  );

  double _size(DsSpacingStep? step) => step == null ? 0 : this[step];

  @override
  bool operator ==(Object other) =>
      other is DsSpacing &&
      other.xxs == xxs &&
      other.xs == xs &&
      other.sm == sm &&
      other.md == md &&
      other.lg == lg &&
      other.xl == xl &&
      other.xxl == xxl;

  @override
  int get hashCode => Object.hash(xxs, xs, sm, md, lg, xl, xxl);
}
