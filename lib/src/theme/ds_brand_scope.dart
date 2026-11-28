/// @docImport '../brand_file/ds_brand_parser.dart';
/// @docImport 'ds_theme_context.dart';
library;

import 'package:flutter/material.dart';

import '../brand/ds_brand.dart';
import '../tokens/ds_tokens.dart';
import 'ds_theme.dart';

/// Widget that places a brand over part of the widget tree, so every design
/// system component below draws with it.
///
/// Use this when a micro app needs its own look for one screen or a group of
/// screens, such as a partner section with co-branded colors. Wrap the
/// screen, or the shared layout of the group, once the brand is parsed.
///
/// This is **not** how the App Shell places the top-level brand: it passes
/// [DsTheme.light] and [DsTheme.dark] to `MaterialApp`. It is also **not** a
/// loader: where and when the brand file is fetched is up to the micro app,
/// and [DsBrandParser] turns its contents into a [DsBrand].
///
/// Built-in: it builds a [Theme] for [brand], so components read it through
/// the getters of [DsThemeContext], and Material widgets inside, such as the
/// text cursor and selection handles, follow it too.
///
/// Rules:
/// * The nearest brand wins: a scope inside another scope replaces it for
///   its subtree.
/// * Dialogs, bottom sheets, and menus opened from inside the scope through
///   the standard functions (`showDialog`, `showModalBottomSheet`, and
///   `showMenu`) use its brand.
/// * Light and dark mode come from the app: the scope uses the brightness of
///   the enclosing [Theme], and follows it when it changes.
/// * Replacing the App Shell's brand leaves the scope's brand in place.
///   Changing [brand] shows the new brand on the next frame, with no
///   animation and no lost state.
/// * The scope keeps the enclosing theme's platform, visual density,
///   tap-target size, page transitions, and the app's own theme extensions.
///   Everything the brand defines is replaced.
///
/// Usage from a micro app:
/// ```dart
/// final class PartnerOffersPage extends StatelessWidget {
///   const PartnerOffersPage({super.key, required this.partnerBrand});
///
///   final DsBrand partnerBrand;
///
///   @override
///   Widget build(BuildContext context) {
///     return DsBrandScope(
///       brand: partnerBrand,
///       child: const PartnerOffersScreen(),
///     );
///   }
/// }
/// ```
final class DsBrandScope extends StatelessWidget {
  /// Creates a brand scope.
  ///
  /// Parameters:
  /// * [brand] - The brand that every design system component below uses.
  /// * [child] - The screen or group of screens to brand.
  const DsBrandScope({super.key, required this.brand, required this.child});

  /// The brand that every design system component below uses.
  final DsBrand brand;

  /// The screen or group of screens to brand.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final enclosing = Theme.of(context);
    final branded = DsTheme.forBrightness(brand, enclosing.brightness);
    return Theme(
      data: branded.copyWith(
        platform: enclosing.platform,
        visualDensity: enclosing.visualDensity,
        materialTapTargetSize: enclosing.materialTapTargetSize,
        pageTransitionsTheme: enclosing.pageTransitionsTheme,
        extensions: [
          for (final extension in enclosing.extensions.values)
            if (extension is! DsTokens) extension,
          ...branded.extensions.values,
        ],
      ),
      child: child,
    );
  }
}
