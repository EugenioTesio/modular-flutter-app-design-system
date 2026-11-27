import '../components/atoms/ds_button.dart';
import '../components/atoms/ds_loading_indicator.dart';
import '../components/atoms/ds_text_field.dart';
import '../components/molecules/ds_card.dart';
import '../components/molecules/ds_empty_state.dart';
import '../components/molecules/ds_inline_message.dart';
import '../components/molecules/ds_list_tile.dart';
import '../components/templates/ds_page_scaffold.dart';
import 'ds_component_info.dart';

/// Catalog that lists the metadata of every design system component.
///
/// Use this to list the components, for example to check that a tool covers
/// all of them.
///
/// This is **not** a widget registry: it holds metadata only, and building a
/// component still means using its class.
///
/// Built-in: the Widgetbook builds its folders and labels from it, and the
/// package's tests fail when a public component is missing from it.
///
/// Rules: the list is in level order, atoms first, and holds one entry per
/// public component.
///
/// Usage from a micro app:
/// ```dart
/// final stable = DsComponentCatalog.all
///     .where((info) => info.status == DsComponentStatus.stable)
///     .map((info) => info.name);
/// ```
abstract final class DsComponentCatalog {
  /// Metadata of every component, in level order.
  static const List<DsComponentInfo> all = [
    DsButton.info,
    DsTextField.info,
    DsLoadingIndicator.info,
    DsCard.info,
    DsListTile.info,
    DsInlineMessage.info,
    DsEmptyState.info,
    DsPageScaffold.info,
  ];
}
