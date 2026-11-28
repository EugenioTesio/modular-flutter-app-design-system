import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';

/// Widgetbook addon that switches the brand of every use case.
///
/// It wraps each use case in a [DsBrandScope], the same widget a micro app
/// uses, so the Widgetbook exercises the real nested-brand path. The
/// brightness comes from the theme addon outside it.
final class DsBrandAddon extends WidgetbookAddon<DsBrand> {
  /// Creates a brand addon.
  ///
  /// [brands] lists the brands to offer, the first one selected.
  /// [failingContrast] holds the brands that fail the contrast gate; they
  /// stay selectable, labelled with a warning.
  DsBrandAddon(this.brands, {this.failingContrast = const {}})
    : assert(brands.isNotEmpty, 'The brand addon needs a brand.'),
      super(name: 'Brand');

  /// The brands the switcher offers.
  final List<DsBrand> brands;

  /// Brands that fail the contrast gate.
  final Set<DsBrand> failingContrast;

  /// Label of a brand in the switcher: its name, plus its id when another
  /// brand has the same name, after `⚠ ` when it fails the contrast gate.
  String label(DsBrand brand) {
    final sameName = brands.where((other) => other.name == brand.name).length;
    final name = sameName > 1 ? '${brand.name} (${brand.id})' : brand.name;
    return failingContrast.contains(brand) ? '⚠ $name' : name;
  }

  @override
  List<Field> get fields => [
    ObjectDropdownField<DsBrand>(
      name: 'brand',
      values: brands,
      initialValue: brands.first,
      labelBuilder: label,
    ),
  ];

  @override
  DsBrand valueFromQueryGroup(Map<String, String> group) =>
      valueOf<DsBrand>('brand', group) ?? brands.first;

  @override
  Widget buildUseCase(BuildContext context, Widget child, DsBrand setting) =>
      DsBrandScope(brand: setting, child: child);
}
