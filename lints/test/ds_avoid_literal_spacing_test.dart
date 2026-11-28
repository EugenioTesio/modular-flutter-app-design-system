// Feature: ds_avoid_literal_spacing reports literal spacing and radius values
// in lib/ code and suggests the spacing helpers instead
// (contracts/lint-rules.md).
import 'package:design_system_lints/src/rules/ds_avoid_literal_spacing.dart';
import 'package:test/test.dart';

import 'support/ds_rule_fixture.dart';

void main() {
  group('Given the ds_avoid_literal_spacing rule', () {
    late DsRuleFixture t;

    setUp(() => t = DsRuleFixture(DsAvoidLiteralSpacing.new)..setUp());

    tearDown(() => t.tearDown());

    test('When lib/ code passes non-zero literals to EdgeInsets, '
        'Then each literal is reported with the spacing fix', () async {
      // Given
      const code = r'''
import 'package:flutter/painting.dart';

final a = EdgeInsets.all(11);
final b = EdgeInsets.symmetric(horizontal: 12, vertical: 0);
final c = EdgeInsets.only(left: 13);
final d = EdgeInsets.fromLTRB(14, 0, 15, 0.0);
''';

      // When / Then
      await t.assertDiagnostics(code, [
        t.lint(
          code.indexOf('11'),
          2,
          correctionContains: 'DsGap(DsSpacingStep.<step>)',
        ),
        t.at(code, '12'),
        t.at(code, '13'),
        t.at(code, '14'),
        t.at(code, '15'),
      ]);
    });

    test('When lib/ code passes non-zero literals to EdgeInsetsDirectional, '
        'Then each literal is reported', () async {
      // Given
      const code = r'''
import 'package:flutter/painting.dart';

final a = EdgeInsetsDirectional.all(21);
final b = EdgeInsetsDirectional.symmetric(horizontal: 22);
final c = EdgeInsetsDirectional.only(start: 23);
final d = EdgeInsetsDirectional.fromSTEB(24, 0, 0, 0);
''';

      // When / Then
      await t.assertDiagnostics(code, [
        t.at(code, '21'),
        t.at(code, '22'),
        t.at(code, '23'),
        t.at(code, '24'),
      ]);
    });

    test('When lib/ code sizes a SizedBox or spaces a Row, Column, or Wrap '
        'with literals, Then each literal is reported', () async {
      // Given
      const code = r'''
import 'package:flutter/widgets.dart';

final a = SizedBox(width: 31, height: 32);
final b = SizedBox.square(dimension: 33);
final c = Row(spacing: 34);
final d = Column(spacing: 35);
final e = Wrap(spacing: 36, runSpacing: 37);
final f = SizedBox(height: -38);
''';

      // When / Then
      await t.assertDiagnostics(code, [
        t.at(code, '31'),
        t.at(code, '32'),
        t.at(code, '33'),
        t.at(code, '34'),
        t.at(code, '35'),
        t.at(code, '36'),
        t.at(code, '37'),
        t.at(code, '-38'),
      ]);
    });

    test('When lib/ code rounds corners with literals, '
        'Then each literal is reported with the radius fix', () async {
      // Given
      const code = r'''
import 'package:flutter/painting.dart';

final a = BorderRadius.circular(41);
final b = Radius.circular(42);
''';

      // When / Then
      await t.assertDiagnostics(code, [
        t.lint(
          code.indexOf('41'),
          2,
          correctionContains: 'context.dsRadius.<step>',
        ),
        t.at(code, '42'),
      ]);
    });

    test('When lib/ code uses zero, kMinInteractiveDimension, or token reads, '
        'Then nothing is reported', () async {
      // Given
      const code = r'''
import 'package:flutter/material.dart';

Widget build(double gap) => Column(
  spacing: gap,
  children: [
    SizedBox(width: kMinInteractiveDimension, height: 0),
    SizedBox.square(dimension: 0.0),
    Container(padding: EdgeInsets.all(gap)),
  ],
);
''';

      // When / Then
      await t.assertNoDiagnostics(code);
    });

    test('When the same literals are in a test/ file, '
        'Then nothing is reported', () async {
      // Given
      final path = t.pathOf('test/widget_test.dart');
      t.newFile(path, r'''
import 'package:flutter/widgets.dart';

final a = SizedBox(width: 31);
final b = EdgeInsets.all(11);
''');

      // When / Then
      await t.assertNoDiagnosticsInFile(path);
    });
  });
}
