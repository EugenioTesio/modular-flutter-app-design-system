import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

import '../ds_lint_elements.dart';

/// Rule that reports literal colors in `lib/` code, which ignore the
/// nearest brand.
///
/// It reports every `Color(...)`, `Color.fromARGB(...)`,
/// `Color.fromRGBO(...)`, and `Color.from(...)` whose arguments are all
/// number literals, and every `Colors.<x>` or `CupertinoColors.<x>` except
/// `Colors.transparent`. A color built from computed values, such as a
/// parser's conversion, is not a literal color. Files outside `lib/`, such
/// as tests, are never reported.
final class DsAvoidLiteralColor extends AnalysisRule {
  /// Creates the rule.
  DsAvoidLiteralColor()
    : super(
        name: 'ds_avoid_literal_color',
        description:
            'Literal colors ignore the brand; use a semantic color role.',
      );

  /// The diagnostic this rule reports.
  static const LintCode code = LintCode(
    'ds_avoid_literal_color',
    'Literal color: it ignores the nearest brand.',
    correctionMessage: 'Use a semantic color: `context.dsColors.<role>`.',
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
    final visitor = _Visitor(this);
    registry
      ..addInstanceCreationExpression(this, visitor)
      ..addPrefixedIdentifier(this, visitor)
      ..addPropertyAccess(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final DsAvoidLiteralColor rule;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final constructor = node.constructorName.element;
    final allLiterals = node.argumentList.arguments.every(
      (argument) =>
          DsLintElements.numberLiteral(argument.argumentExpression) != null,
    );
    if (allLiterals &&
        DsLintElements.isFlutterClass(constructor?.enclosingElement, 'Color')) {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (_isPaletteConstant(node.prefix.element, node.identifier.name)) {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    final target = node.realTarget;
    final owner = target is Identifier ? target.element : null;
    if (_isPaletteConstant(owner, node.propertyName.name)) {
      rule.reportAtNode(node);
    }
  }

  bool _isPaletteConstant(Element? owner, String name) =>
      (DsLintElements.isFlutterClass(owner, 'Colors') &&
          name != 'transparent') ||
      DsLintElements.isFlutterClass(owner, 'CupertinoColors');
}
