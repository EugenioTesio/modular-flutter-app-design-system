// Feature: QA identifiers stay hidden in a default build.
//
// A component given a QA identifier exposes nothing to UI automation unless
// the app is built with DS_QA_IDENTIFIERS=true, and its semantics tree is
// the same as without the identifier. The QA-switch run is in
// ds_qa_identifiers_enabled_test.dart.
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/ds_qa_cases.dart';

void main() {
  const skipWhenEnabled = DsQaIdentifiers.enabled
      ? 'Checks the default build; run it without DS_QA_IDENTIFIERS.'
      : false;

  group('Given a build without the QA switch', () {
    test('When the switch is read, Then it is off', () {
      // Given
      const fromEnvironment = bool.fromEnvironment('DS_QA_IDENTIFIERS');

      // When
      const enabled = DsQaIdentifiers.enabled;

      // Then
      expect(fromEnvironment, isFalse);
      expect(enabled, isFalse);
    }, skip: skipWhenEnabled);

    for (final qaCase in DsQaCases.all) {
      testWidgets('When ${qaCase.name} is given a QA identifier, '
          'Then no node exposes it and the semantics tree equals the one '
          'built without it', (tester) async {
        // Given
        final semantics = tester.ensureSemantics();
        await DsQaCases.pump(tester, qaCase.build(null));
        final withoutIdentifier = DsQaCases.semanticsTreeOf(tester);

        // When
        await DsQaCases.pump(tester, qaCase.build(qaCase.identifier));

        // Then
        expect(find.bySemanticsIdentifier(qaCase.identifier), findsNothing);
        expect(find.bySemanticsIdentifier(RegExp('.')), findsNothing);
        expect(DsQaCases.semanticsTreeOf(tester), withoutIdentifier);
        semantics.dispose();
      }, skip: skipWhenEnabled != false);
    }
  });
}
