import 'package:widgetbook/widgetbook.dart';

import 'atom_use_cases.dart';
import 'molecule_use_cases.dart';
import 'template_use_cases.dart';

/// Registry of every component's use cases, keyed by the component's class
/// name as `DsComponentInfo.name` gives it.
abstract final class ComponentUseCases {
  /// Fresh use cases of every component. Widgetbook nodes remember their
  /// parent, so each directory build gets its own.
  static Map<String, List<WidgetbookUseCase>> get all => {
    'DsButton': AtomUseCases.button,
    'DsTextField': AtomUseCases.textField,
    'DsLoadingIndicator': AtomUseCases.loadingIndicator,
    'DsCard': MoleculeUseCases.card,
    'DsListTile': MoleculeUseCases.listTile,
    'DsInlineMessage': MoleculeUseCases.inlineMessage,
    'DsEmptyState': MoleculeUseCases.emptyState,
    'DsPageScaffold': TemplateUseCases.pageScaffold,
  };
}
