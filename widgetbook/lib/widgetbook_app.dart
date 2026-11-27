import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'addons/ds_brand_addon.dart';
import 'brand_files/brand_file_loader.dart';
import 'catalog/catalog_directory.dart';
import 'use_cases/component_use_cases.dart';

/// The design system's Widgetbook: every component in every brand, mode, and
/// viewport.
final class DsWidgetbook extends StatelessWidget {
  /// Creates the Widgetbook for [brands].
  const DsWidgetbook({super.key, required this.brands});

  /// The brands read from the `brands/` folder.
  final WidgetbookBrands brands;

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: CatalogDirectory.build(
        useCases: ComponentUseCases.all,
        brands: brands,
      ),
      // Outermost first: the viewport sizes the use case, the theme addon
      // sets the mode, and the brand addon places the brand in that mode.
      addons: [
        ViewportAddon([
          Viewports.none,
          IosViewports.iPhone13,
          IosViewports.iPadAir4,
        ]),
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: DsTheme.light()),
            WidgetbookTheme(name: 'Dark', data: DsTheme.dark()),
          ],
        ),
        DsBrandAddon(brands.selectable),
      ],
    );
  }
}
