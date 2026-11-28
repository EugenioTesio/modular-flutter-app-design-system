// Feature: ds_avoid_primitive_color reports reads of a brand's primitive
// color scales in design system components only (contracts/lint-rules.md).
import 'package:design_system_lints/src/rules/ds_avoid_primitive_color.dart';
import 'package:test/test.dart';

import 'support/ds_rule_fixture.dart';

void main() {
  group('Given the ds_avoid_primitive_color rule', () {
    late DsRuleFixture t;

    const reads = r'''
import 'package:design_system/src/brand/ds_brand.dart';

final class Holder {
  const Holder(this.brand);
  final DsBrand brand;
}

Object fill(DsBrand brand) => brand.colors.brand.shade600;
Object border(Holder holder) => holder.brand.colors.brand.shade600;
''';

    setUp(() => t = DsRuleFixture(DsAvoidPrimitiveColor.new)..setUp());

    tearDown(() => t.tearDown());

    test('When a component file reads DsBrand.colors, '
        'Then each read is reported with the semantic-role fix', () async {
      // Given
      final path = t.pathOf('lib/src/components/atoms/ds_badge.dart');
      t.newFile(path, reads);

      // When / Then
      await t.assertDiagnosticsInFile(path, [
        t.lint(
          reads.indexOf('brand.colors'),
          'brand.colors'.length,
          correctionContains: 'context.dsColors.<role>',
        ),
        t.at(reads, 'holder.brand.colors'),
      ]);
    });

    test('When a component file reads other brand fields, '
        'Then nothing is reported', () async {
      // Given
      final path = t.pathOf('lib/src/components/atoms/ds_badge.dart');
      t.newFile(path, r'''
import 'package:design_system/src/brand/ds_brand.dart';

Object scale(DsBrandColors colors) => colors.brand;
''');

      // When / Then
      await t.assertNoDiagnosticsInFile(path);
    });

    test('When the same reads are in a file outside src/components/, '
        'Then nothing is reported', () async {
      // Given
      final path = t.pathOf('lib/src/theme/ds_semantic_mapping.dart');
      t.newFile(path, reads);

      // When / Then
      await t.assertNoDiagnosticsInFile(path);
    });

    test('When the same reads are in a test/ file, '
        'Then nothing is reported', () async {
      // Given
      final path = t.pathOf('test/components/ds_badge_test.dart');
      t.newFile(path, reads);

      // When / Then
      await t.assertNoDiagnosticsInFile(path);
    });
  });
}
