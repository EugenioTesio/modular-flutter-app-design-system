import 'package:flutter/widgets.dart';

import 'ds_qa_identifiers.dart';

/// Widget that puts a component's QA identifier on its semantics node when
/// the build exposes QA identifiers.
///
/// This is internal to the design system and is not exported. Components
/// apply their `qaIdentifier` through it, so the switch is read in one place.
///
/// When [DsQaIdentifiers.enabled] is false, or [identifier] is null, it
/// returns its child unchanged, so the semantics tree is the same as with no
/// identifier. When it is on, the constructor picks where the identifier
/// goes, so it lands on the component's own node and nothing a screen reader
/// announces changes:
/// * [DsQaSemantics.new] annotates the node the child forms when the child's
///   own semantics merges with annotations from above, as a `TextField`, a
///   `ListTile`, or a progress indicator does.
/// * [DsQaSemantics.merged] merges the identifier into a child that forms
///   exactly one node behind a semantics boundary, such as a Material button.
/// * [DsQaSemantics.group] adds an unlabelled group node that holds only the
///   identifier, for a component that forms no node of its own. The child's
///   nodes stay as they are.
///
/// A component that builds its own `Semantics` node passes
/// [DsQaSemantics.identifierOf] to that node's `identifier` instead.
final class DsQaSemantics extends StatelessWidget {
  /// Creates QA semantics that annotate the node [child] forms.
  ///
  /// Parameters:
  /// * [identifier] - The component's QA identifier, or null for none.
  /// * [child] - The component's output; its own semantics must accept
  ///   annotations from above.
  const DsQaSemantics({
    super.key,
    required this.identifier,
    required this.child,
  }) : _placement = _DsQaPlacement.childNode;

  /// Creates QA semantics that merge the identifier into the single node
  /// [child] forms.
  ///
  /// Parameters:
  /// * [identifier] - The component's QA identifier, or null for none.
  /// * [child] - The component's output. It must form exactly one semantics
  ///   node, or the merge would fold its other nodes into it.
  const DsQaSemantics.merged({
    super.key,
    required this.identifier,
    required this.child,
  }) : _placement = _DsQaPlacement.merged;

  /// Creates QA semantics that hold the identifier on a new, unlabelled group
  /// node around [child].
  ///
  /// Parameters:
  /// * [identifier] - The component's QA identifier, or null for none.
  /// * [child] - The component's output, which forms no node of its own.
  const DsQaSemantics.group({
    super.key,
    required this.identifier,
    required this.child,
  }) : _placement = _DsQaPlacement.group;

  /// Optional QA identifier; null exposes none.
  final String? identifier;

  /// The component's output.
  final Widget child;

  final _DsQaPlacement _placement;

  /// Returns [qaIdentifier] when the build exposes QA identifiers, and null
  /// otherwise.
  ///
  /// Parameters:
  /// * [qaIdentifier] - The component's QA identifier, or null for none.
  static String? identifierOf(String? qaIdentifier) =>
      DsQaIdentifiers.enabled ? qaIdentifier : null;

  @override
  Widget build(BuildContext context) {
    final identifier = DsQaSemantics.identifierOf(this.identifier);
    if (identifier == null) return child;
    return switch (_placement) {
      _DsQaPlacement.childNode => Semantics(
        identifier: identifier,
        child: child,
      ),
      _DsQaPlacement.merged => MergeSemantics(
        child: Semantics(identifier: identifier, child: child),
      ),
      _DsQaPlacement.group => Semantics(
        container: true,
        explicitChildNodes: true,
        identifier: identifier,
        child: child,
      ),
    };
  }
}

/// Where [DsQaSemantics] puts the identifier.
enum _DsQaPlacement {
  /// On the node the child forms.
  childNode,

  /// Merged into the single node the child forms.
  merged,

  /// On a new, unlabelled group node.
  group,
}
