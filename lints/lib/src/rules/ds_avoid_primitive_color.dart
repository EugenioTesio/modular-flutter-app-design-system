import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

import '../ds_lint_elements.dart';

/// Rule that reports reads of a brand's primitive color scales in design
/// system components, which must use semantic roles.
///
/// It applies only to `package:design_system/src/components/**`, and reports
/// every read of `DsBrand.colors`.
final class DsAvoidPrimitiveColor extends AnalysisRule {
  /// Creates the rule.
  DsAvoidPrimitiveColor()
    : super(
        name: 'ds_avoid_primitive_color',
        description:
            'Components use semantic color roles, never a brand\'s primitive '
            'scales.',
      );

  /// The diagnostic this rule reports.
  static const LintCode code = LintCode(
    'ds_avoid_primitive_color',
    'Primitive brand color in a design system component.',
    correctionMessage:
        'Components use semantic roles: `context.dsColors.<role>`.',
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
      ..addPrefixedIdentifier(this, visitor)
      ..addPropertyAccess(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final DsAvoidPrimitiveColor rule;

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (_isBrandColors(node.identifier.element)) rule.reportAtNode(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (_isBrandColors(node.propertyName.element)) rule.reportAtNode(node);
  }

  bool _isBrandColors(Element? element) {
    if (element is! PropertyAccessorElement || element.name != 'colors') {
      return false;
    }
    final owner = element.enclosingElement;
    return owner is InterfaceElement &&
        owner.name == 'DsBrand' &&
        owner.library.uri.toString().startsWith('package:design_system/');
  }
}
