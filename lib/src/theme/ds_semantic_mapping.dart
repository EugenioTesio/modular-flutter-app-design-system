import 'package:flutter/widgets.dart';

import '../brand/ds_brand.dart';
import '../contrast/ds_contrast.dart';
import '../tokens/ds_colors.dart';

/// Helper that maps a brand's primitive colors to the semantic roles of one
/// mode.
///
/// This is internal to the design system and is not exported. Brands can't
/// override it, and it never adjusts a primitive value: [DsColors.textOnAction]
/// is chosen between two existing neutrals.
abstract final class DsSemanticMapping {
  /// Returns the color roles of [brand] in [brightness].
  ///
  /// Parameters:
  /// * [brand] - The brand whose primitive scales are mapped.
  /// * [brightness] - The mode to map for.
  static DsColors colorsFor(DsBrand brand, Brightness brightness) {
    final n = brand.colors.neutral;
    final b = brand.colors.brand;
    final s = brand.colors.success;
    final w = brand.colors.warning;
    final e = brand.colors.error;
    final i = brand.colors.info;
    final isLight = brightness == Brightness.light;
    final action = isLight ? b.shade600 : b.shade300;
    return DsColors(
      background: isLight ? n.shade50 : n.shade900,
      surface: isLight ? n.shade0 : n.shade800,
      surfaceVariant: isLight ? n.shade100 : n.shade700,
      border: isLight ? n.shade300 : n.shade600,
      textPrimary: isLight ? n.shade900 : n.shade50,
      textSecondary: isLight ? n.shade600 : n.shade300,
      textDisabled: isLight ? n.shade400 : n.shade500,
      textOnAction: DsContrast.bestText(
        action,
        light: n.shade0,
        dark: n.shade900,
      ),
      actionPrimary: action,
      actionPrimaryPressed: isLight ? b.shade700 : b.shade200,
      actionDisabled: isLight ? n.shade200 : n.shade700,
      focus: action,
      infoBackground: isLight ? i.shade100 : i.shade700,
      infoForeground: isLight ? i.shade700 : i.shade100,
      successBackground: isLight ? s.shade100 : s.shade700,
      successForeground: isLight ? s.shade700 : s.shade100,
      warningBackground: isLight ? w.shade100 : w.shade700,
      warningForeground: isLight ? w.shade700 : w.shade100,
      errorBackground: isLight ? e.shade100 : e.shade700,
      errorForeground: isLight ? e.shade700 : e.shade100,
    );
  }
}
