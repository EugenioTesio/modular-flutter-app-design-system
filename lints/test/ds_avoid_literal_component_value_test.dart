// Feature: ds_avoid_literal_component_value reports literal icon sizes,
// border widths, and opacities in design system components only
// (contracts/lint-rules.md).
import 'package:design_system_lints/src/rules/ds_avoid_literal_component_value.dart';
import 'package:test/test.dart';

import 'support/ds_rule_fixture.dart';

void main() {
  group('Given the ds_avoid_literal_component_value rule', () {
    late DsRuleFixture t;

    const literals = r'''
import 'package:flutter/widgets.dart';

final a = Icon(null, size: 31);
final b = BorderSide(width: 32);
final c = Color(0xFF000000).withValues(alpha: 0.33);
final d = Color(0xFF000000).withOpacity(0.34);
''';

    setUp(() => t = DsRuleFixture(DsAvoidLiteralComponentValue.new)..setUp());

    tearDown(() => t.tearDown());

    test(
      'When a component file uses literal icon sizes, border widths, or '
      'opacities, Then each literal is reported with the token fix',
      () async {
        // Given
        final path = t.pathOf('lib/src/components/atoms/ds_badge.dart');
        t.newFile(path, literals);

        // When / Then
        await t.assertDiagnosticsInFile(path, [
          t.lint(
            literals.indexOf('31'),
            2,
            correctionContains: 'context.dsIconSizes',
          ),
          t.at(literals, '32'),
          t.at(literals, '0.33'),
          t.at(literals, '0.34'),
        ]);
      },
    );

    test('When a component file reads the values from tokens, '
        'Then nothing is reported', () async {
      // Given
      final path = t.pathOf('lib/src/components/atoms/ds_badge.dart');
      t.newFile(path, r'''
import 'package:flutter/widgets.dart';

List<Object> parts(double iconSize, double thin, double hovered) => [
  Icon(null, size: iconSize),
  BorderSide(width: thin),
  Color(0xFF000000).withValues(alpha: hovered),
  Color(0xFF000000).withOpacity(hovered),
];
''');

      // When / Then
      await t.assertNoDiagnosticsInFile(path);
    });

    test('When the same literals are in a file outside src/components/, '
        'Then nothing is reported', () async {
      // Given
      final path = t.pathOf('lib/src/theme/ds_theme.dart');
      t.newFile(path, literals);

      // When / Then
      await t.assertNoDiagnosticsInFile(path);
    });

    test('When the same literals are in a test/ file, '
        'Then nothing is reported', () async {
      // Given
      final path = t.pathOf('test/components/ds_badge_test.dart');
      t.newFile(path, literals);

      // When / Then
      await t.assertNoDiagnosticsInFile(path);
    });
  });
}
