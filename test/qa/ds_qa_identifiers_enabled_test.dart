// Feature: QA identifiers reach UI automation when the QA switch is on.
//
// Run with:
//   flutter test --dart-define=DS_QA_IDENTIFIERS=true --tags qa
//
// Every component given a QA identifier can be found by it, the identifier
// sits on the component's own semantics node next to its accessible label,
// and screen readers announce the same nodes as without the identifier. A
// component that forms no node of its own gets an unlabelled group node
// that only holds the identifier.
@Tags(['qa'])
library;

import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/ds_qa_cases.dart';

void main() {
  const skipWhenDisabled = !DsQaIdentifiers.enabled;

  group('Given a build with the QA switch on', () {
    for (final qaCase in DsQaCases.all) {
      testWidgets('When ${qaCase.name} is given the identifier '
          '"${qaCase.identifier}", Then UI automation finds it by that '
          'identifier', (tester) async {
        // Given
        final semantics = tester.ensureSemantics();

        // When
        await DsQaCases.pump(tester, qaCase.build(qaCase.identifier));

        // Then
        final finder = find.bySemanticsIdentifier(qaCase.identifier);
        expect(finder, findsOneWidget);
        final node = tester.getSemantics(finder).getSemanticsData();
        expect(node.identifier, qaCase.identifier);
        final ownLabel = qaCase.ownLabel;
        if (ownLabel != null) {
          expect(node.label, ownLabel);
        } else {
          expect(node.label, isEmpty);
          expect(node.actions, 0);
        }
        semantics.dispose();
      }, skip: skipWhenDisabled);

      testWidgets('When ${qaCase.name} is given a QA identifier, '
          'Then screen readers announce the same nodes as without it', (
        tester,
      ) async {
        // Given
        final semantics = tester.ensureSemantics();
        await DsQaCases.pump(tester, qaCase.build(null));
        final withoutIdentifier = DsQaCases.announcedNodesOf(tester);

        // When
        await DsQaCases.pump(tester, qaCase.build(qaCase.identifier));

        // Then
        expect(DsQaCases.announcedNodesOf(tester), withoutIdentifier);
        semantics.dispose();
      }, skip: skipWhenDisabled);
    }
  });
}
