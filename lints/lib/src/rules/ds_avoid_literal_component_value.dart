import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../ds_lint_elements.dart';

/// Rule that reports literal icon sizes, border widths, and opacities in
/// design system components, which must read them from the nearest brand.
///
/// It applies only to `package:design_system/src/components/**`. It reports
/// a number literal passed to `Icon` `size`, to `BorderSide` `width`, to
/// `Color.withValues` `alpha`, or to `Color.withOpacity`.
final class DsAvoidLiteralComponentValue extends AnalysisRule {
  /// Creates the rule.
  DsAvoidLiteralComponentValue()
    : super(
        name: 'ds_avoid_literal_component_value',
        description:
            'Components read icon sizes, border widths, and opacities from '
            'the brand.',
      );

  /// The diagnostic this rule reports.
  static const LintCode code = LintCode(
    'ds_avoid_literal_component_value',
    'Literal visual value in a design system component.',
    correctionMessage:
        'Use `context.dsIconSizes`, `context.dsBorderWidths`, or '
        '`context.dsOpacities`.',
    severity: DiagnosticSeverity.WARNING,
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!context.isInLibDir || !DsLintElements.isInComponents(context)) {
      return;
    }
    final visitor = _Visitor(this);
    registry
      ..addInstanceCreationExpression(this, visitor)
      ..addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final DsAvoidLiteralComponentValue rule;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final type = node.constructorName.element?.enclosingElement;
    final argument = switch (type) {
      _ when DsLintElements.isFlutterClass(type, 'Icon') =>
        DsLintElements.namedArgument(node.argumentList, 'size'),
      _ when DsLintElements.isFlutterClass(type, 'BorderSide') =>
        DsLintElements.namedArgument(node.argumentList, 'width'),
      _ => null,
    };
    _report(argument);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final owner = node.methodName.element?.enclosingElement;
    if (!DsLintElements.isFlutterClass(owner, 'Color')) return;
    final argument = switch (node.methodName.name) {
      'withValues' => DsLintElements.namedArgument(node.argumentList, 'alpha'),
      'withOpacity' =>
        node.argumentList.arguments.firstOrNull?.argumentExpression,
      _ => null,
    };
    _report(argument);
  }

  void _report(Expression? argument) {
    if (argument == null) return;
    final literal = DsLintElements.numberLiteral(argument);
    if (literal != null) rule.reportAtNode(literal);
  }
}
