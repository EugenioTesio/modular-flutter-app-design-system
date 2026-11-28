// Feature: ds_avoid_literal_color reports literal colors in lib/ code and
// suggests a semantic color instead (contracts/lint-rules.md).
import 'package:design_system_lints/src/rules/ds_avoid_literal_color.dart';
import 'package:test/test.dart';

import 'support/ds_rule_fixture.dart';

void main() {
  group('Given the ds_avoid_literal_color rule', () {
    late DsRuleFixture t;

    setUp(() => t = DsRuleFixture(DsAvoidLiteralColor.new)..setUp());

    tearDown(() => t.tearDown());

    test('When lib/ code builds a Color with any constructor, '
        'Then each one is reported', () async {
      // Given
      const code = r'''
import 'package:flutter/painting.dart';

final a = Color(0xFF00FF00);
final b = Color.fromARGB(255, 0, 255, 0);
final c = Color.fromRGBO(0, 255, 0, 1);
final d = Color.from(alpha: 1, red: 0, green: 1, blue: 0);
''';

      // When / Then
      await t.assertDiagnostics(code, [
        t.at(code, 'Color(0xFF00FF00)'),
        t.at(code, 'Color.fromARGB(255, 0, 255, 0)'),
        t.at(code, 'Color.fromRGBO(0, 255, 0, 1)'),
        t.at(code, 'Color.from(alpha: 1, red: 0, green: 1, blue: 0)'),
      ]);
    });

    test('When lib/ code reads a Colors or CupertinoColors constant, '
        'Then it is reported with the semantic-color fix', () async {
      // Given
      const code = r'''
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final a = Container(color: Colors.red);
final b = Container(color: CupertinoColors.activeBlue);
''';

      // When / Then
      await t.assertDiagnostics(code, [
        t.lint(
          code.indexOf('Colors.red'),
          'Colors.red'.length,
          correctionContains: 'context.dsColors.<role>',
        ),
        t.at(code, 'CupertinoColors.activeBlue'),
      ]);
    });

    test('When lib/ code uses Colors.transparent or a token read, '
        'Then nothing is reported', () async {
      // Given
      const code = r'''
import 'package:flutter/material.dart';

final class Roles {
  const Roles(this.background);
  final Color background;
}

Widget build(Roles roles) => Container(
  color: Colors.transparent,
  child: Container(color: roles.background),
);
''';

      // When / Then
      await t.assertNoDiagnostics(code);
    });

    test(
      'When lib/ code converts computed channel values into a Color, '
      'Then nothing is reported, because it is not a literal color',
      () async {
        // Given
        const code = r'''
import 'package:flutter/painting.dart';

Color fromChannels(int a, int r, int g, int b, int value) => [
  Color.fromARGB(a, r, g, b),
  Color.fromARGB(255, r, g, b),
  Color(value),
].first;
''';

        // When / Then
        await t.assertNoDiagnostics(code);
      },
    );

    test('When a class of its own is named Color, '
        'Then building it is not reported', () async {
      // Given
      const code = r'''
class Color {
  const Color(int value);
}

final a = Color(0xFF00FF00);
''';

      // When / Then
      await t.assertNoDiagnostics(code);
    });

    test('When the same literal colors are in a test/ file, '
        'Then nothing is reported', () async {
      // Given
      final path = t.pathOf('test/widget_test.dart');
      t.newFile(path, r'''
import 'package:flutter/material.dart';

final a = Color(0xFF00FF00);
final b = Container(color: Colors.red);
''');

      // When / Then
      await t.assertNoDiagnosticsInFile(path);
    });
  });
}
