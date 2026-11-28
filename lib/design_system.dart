/// Library of the design system of the modular Flutter app: brands, tokens,
/// and accessible components that draw with the nearest brand.
///
/// Use this through `package:foundations/foundations.dart`, which re-exports
/// it unchanged. Micro apps never import it directly. It provides:
///
/// * **Brands**: [DsBrand], with the built-in [DsBrand.whiteLabel], and its
///   primitive value classes ([DsBrandColors], [DsBrandTypography],
///   [DsSpacing], [DsRadius], [DsBorderWidths], [DsOpacities], and
///   [DsIconSizes]).
/// * **Brand files**: [DsBrandParser] parses a W3C Design Tokens file into a
///   brand, and returns a [DsBrandParseResult]: a [DsBrandParseSuccess], or a
///   [DsBrandParseFailure] with one [DsBrandParseException] per problem.
/// * **Placing a brand**: [DsTheme.light] and [DsTheme.dark] for the
///   top-level brand, and [DsBrandScope] for a micro app's own screens.
/// * **Reading tokens**: [DsTokens] and the getters of [DsThemeContext], such
///   as `context.dsColors`, `context.dsTypography`, and `context.dsSpacing`,
///   plus [DsGap] for gaps between children.
/// * **Atoms**: [DsButton], [DsTextField], and [DsLoadingIndicator].
/// * **Molecules**: [DsCard], [DsListTile], [DsInlineMessage], and
///   [DsEmptyState].
/// * **Template**: [DsPageScaffold].
/// * **Metadata**: [DsComponentInfo] on every component, listed by
///   [DsComponentCatalog].
/// * **Guardrails**: [DsContrastGate] checks a brand's color pairs in both
///   modes and returns a [DsContrastReport] of [DsContrastViolation]s.
///
/// This is **not** a widget library to extend by subclassing: every class is
/// `final`, so screens compose components instead.
///
/// Built-in: no component takes a brand. Each one reads every color, text
/// style, spacing, radius, border width, opacity, and icon size from the
/// nearest brand above it, and falls back to the white label when there is
/// none. Every component meets the tap-target, labeling, and text-contrast
/// guidelines, and lays out at twice the default text size on a 320-wide
/// screen.
///
/// Usage from a micro app:
/// ```dart
/// import 'package:foundations/foundations.dart';
///
/// final class SignInScreen extends StatelessWidget {
///   const SignInScreen({super.key, required this.onSubmit});
///
///   final VoidCallback onSubmit;
///
///   @override
///   Widget build(BuildContext context) {
///     return DsPageScaffold(
///       title: 'Sign in',
///       body: const Column(
///         children: [
///           DsTextField(label: 'Email'),
///           DsGap(DsSpacingStep.md),
///           DsTextField(label: 'Password', obscureText: true),
///         ],
///       ),
///       primaryAction: DsButton(label: 'Sign in', onPressed: onSubmit),
///     );
///   }
/// }
/// ```
///
/// @docImport 'src/brand/ds_brand.dart';
/// @docImport 'src/brand/ds_brand_colors.dart';
/// @docImport 'src/brand/ds_brand_typography.dart';
/// @docImport 'src/brand/ds_color_scale.dart';
/// @docImport 'src/brand/ds_type_style.dart';
/// @docImport 'src/brand_file/ds_brand_parser.dart';
/// @docImport 'src/brand_file/ds_brand_parse_result.dart';
/// @docImport 'src/catalog/ds_component_catalog.dart';
/// @docImport 'src/catalog/ds_component_info.dart';
/// @docImport 'src/components/atoms/ds_button.dart';
/// @docImport 'src/components/atoms/ds_loading_indicator.dart';
/// @docImport 'src/components/atoms/ds_text_field.dart';
/// @docImport 'src/components/molecules/ds_card.dart';
/// @docImport 'src/components/molecules/ds_empty_state.dart';
/// @docImport 'src/components/molecules/ds_inline_message.dart';
/// @docImport 'src/components/molecules/ds_list_tile.dart';
/// @docImport 'src/components/templates/ds_page_scaffold.dart';
/// @docImport 'src/contrast/ds_contrast_gate.dart';
/// @docImport 'src/contrast/ds_contrast_report.dart';
/// @docImport 'src/exceptions/ds_brand_parse_exception.dart';
/// @docImport 'src/layout/ds_gap.dart';
/// @docImport 'src/theme/ds_brand_scope.dart';
/// @docImport 'src/theme/ds_theme.dart';
/// @docImport 'src/theme/ds_theme_context.dart';
/// @docImport 'src/tokens/ds_border_widths.dart';
/// @docImport 'src/tokens/ds_color_role.dart';
/// @docImport 'src/tokens/ds_colors.dart';
/// @docImport 'src/tokens/ds_icon_sizes.dart';
/// @docImport 'src/tokens/ds_opacities.dart';
/// @docImport 'src/tokens/ds_radius.dart';
/// @docImport 'src/tokens/ds_spacing.dart';
/// @docImport 'src/tokens/ds_tokens.dart';
/// @docImport 'src/tokens/ds_typography.dart';
library;

export 'src/brand/ds_brand.dart';
export 'src/brand/ds_brand_colors.dart';
export 'src/brand/ds_brand_typography.dart';
export 'src/brand/ds_color_scale.dart';
export 'src/brand/ds_type_style.dart';
export 'src/brand_file/ds_brand_parser.dart';
export 'src/brand_file/ds_brand_parse_result.dart';
export 'src/catalog/ds_component_catalog.dart';
export 'src/catalog/ds_component_info.dart';
export 'src/components/atoms/ds_button.dart';
export 'src/components/atoms/ds_loading_indicator.dart';
export 'src/components/atoms/ds_text_field.dart';
export 'src/components/molecules/ds_card.dart';
export 'src/components/molecules/ds_empty_state.dart';
export 'src/components/molecules/ds_inline_message.dart';
export 'src/components/molecules/ds_list_tile.dart';
export 'src/components/templates/ds_page_scaffold.dart';
export 'src/contrast/ds_contrast_gate.dart';
export 'src/contrast/ds_contrast_report.dart';
export 'src/exceptions/ds_brand_parse_exception.dart';
export 'src/layout/ds_gap.dart';
export 'src/theme/ds_brand_scope.dart';
export 'src/theme/ds_theme.dart';
export 'src/theme/ds_theme_context.dart';
export 'src/tokens/ds_border_widths.dart';
export 'src/tokens/ds_color_role.dart';
export 'src/tokens/ds_colors.dart';
export 'src/tokens/ds_icon_sizes.dart';
export 'src/tokens/ds_opacities.dart';
export 'src/tokens/ds_radius.dart';
export 'src/tokens/ds_spacing.dart';
export 'src/tokens/ds_tokens.dart';
export 'src/tokens/ds_typography.dart';
