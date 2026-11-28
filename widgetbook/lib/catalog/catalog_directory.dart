import 'package:design_system/design_system.dart';
import 'package:widgetbook/widgetbook.dart';

import '../brand_files/brand_file_loader.dart';
import '../brand_files/brand_file_use_cases.dart';

/// Builder of the Widgetbook directory from the design system's component
/// catalog, so folders and status labels always match each component's
/// metadata.
abstract final class CatalogDirectory {
  static const Map<DsComponentLevel, String> _levelNames = {
    DsComponentLevel.atom: 'Atoms',
    DsComponentLevel.molecule: 'Molecules',
    DsComponentLevel.organism: 'Organisms',
    DsComponentLevel.template: 'Templates',
  };

  /// Returns the directory: one category per atomic level that has
  /// components, then "Brand files".
  ///
  /// [useCases] maps a component's class name to its use cases. A component
  /// without use cases is left out, which [missingComponents] reports.
  static List<WidgetbookNode> build({
    required Map<String, List<WidgetbookUseCase>> useCases,
    required WidgetbookBrands brands,
  }) => [
    for (final level in DsComponentLevel.values)
      if (_components(level, useCases) case final components
          when components.isNotEmpty)
        WidgetbookCategory(name: _levelNames[level]!, children: components),
    BrandFileUseCases.category(brands),
  ];

  /// Returns the name of every catalog component that has no node with at
  /// least one use case in [directory].
  static List<String> missingComponents(List<WidgetbookNode> directory) {
    final covered = <String>{
      for (final category in directory.whereType<WidgetbookCategory>())
        for (final component
            in category.children!.whereType<WidgetbookComponent>())
          if (component.useCases.isNotEmpty) component.name,
    };
    return [
      for (final info in DsComponentCatalog.all)
        if (!covered.contains(label(info))) info.name,
    ];
  }

  /// Returns the node name of a component: its class name and its status,
  /// such as `DsButton · stable`.
  static String label(DsComponentInfo info) =>
      '${info.name} · ${info.status.name}';

  static List<WidgetbookNode> _components(
    DsComponentLevel level,
    Map<String, List<WidgetbookUseCase>> useCases,
  ) => [
    for (final info in DsComponentCatalog.all)
      if (info.level == level && (useCases[info.name]?.isNotEmpty ?? false))
        WidgetbookComponent(name: label(info), useCases: useCases[info.name]!),
  ];
}
