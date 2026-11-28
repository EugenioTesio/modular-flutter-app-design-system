import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../ds_lint_elements.dart';

/// Rule that reports literal spacing and corner radii in `lib/` code, which
/// ignore the nearest brand.
///
/// It reports each non-zero number literal passed to `EdgeInsets.*` and
/// `EdgeInsetsDirectional.*`, to `SizedBox` `width`, `height`, and
/// `dimension`, to `Row`, `Column`, and `Wrap` `spacing` and `runSpacing`,
/// and to `BorderRadius.circular` and `Radius.circular`. Zero, constants such
/// as `kMinInteractiveDimension`, and files outside `lib/` are never
/// reported.
final class DsAvoidLiteralSpacing extends AnalysisRule {
  /// Creates the rule.
  DsAvoidLiteralSpacing()
    : super(
        name: 'ds_avoid_literal_spacing',
        description:
            'Literal spacing and radii ignore the brand; use the spacing '
            'helpers and radius tokens.',
      );

  /// The diagnostic this rule reports.
  static const LintCode code = LintCode(
    'ds_avoid_literal_spacing',
    'Literal spacing or radius: it ignores the nearest brand.',
    correctionMessage:
        'Use `context.dsSpacing.<step>`, `DsGap(DsSpacingStep.<step>)`, or '
        '`context.dsRadius.<step>`.',
    severity: DiagnosticSeverity.WARNING,
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!context.isInLibDir) return;
    registry.addInstanceCreationExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final DsAvoidLiteralSpacing rule;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final constructor = node.constructorName.element;
    final type = constructor?.enclosingElement;
    final arguments = node.argumentList;
    bool isA(String name) => DsLintElements.isFlutterClass(type, name);

    final Iterable<Expression?> checked;
    if (isA('EdgeInsets') || isA('EdgeInsetsDirectional')) {
      checked = DsLintElements.allArguments(arguments);
    } else if ((isA('BorderRadius') || isA('Radius')) &&
        constructor?.name == 'circular') {
      checked = DsLintElements.allArguments(arguments);
    } else if (isA('SizedBox')) {
      checked = [
        for (final name in ['width', 'height', 'dimension'])
          DsLintElements.namedArgument(arguments, name),
      ];
    } else if (isA('Row') || isA('Column') || isA('Wrap')) {
      checked = [
        for (final name in ['spacing', 'runSpacing'])
          DsLintElements.namedArgument(arguments, name),
      ];
    } else {
      return;
    }

    for (final expression in checked.nonNulls) {
      final literal = DsLintElements.numberLiteral(expression, nonZero: true);
      if (literal != null) rule.reportAtNode(literal);
    }
  }
}
