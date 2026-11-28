import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';

/// Helpers that the design system's lint rules share to recognize Flutter
/// types, number literals, and component files.
abstract final class DsLintElements {
  /// URI prefix of the design system's component libraries.
  static const String componentsUriPrefix =
      'package:design_system/src/components/';

  /// Whether [element] is the class [name] from Flutter: `dart:ui` or any
  /// `package:flutter/` library.
  static bool isFlutterClass(Element? element, String name) {
    if (element is! InterfaceElement || element.name != name) return false;
    final uri = element.library.uri.toString();
    return uri == 'dart:ui' || uri.startsWith('package:flutter/');
  }

  /// Whether the library that [context] analyzes is a design system
  /// component, under `lib/src/components/`.
  static bool isInComponents(RuleContext context) =>
      context.libraryElement?.uri.toString().startsWith(componentsUriPrefix) ??
      false;

  /// Returns [expression] when it is a number literal, such as `12`, `0.5`,
  /// or `-8`, and null otherwise.
  ///
  /// When [nonZero] is true, zero literals return null too.
  static Expression? numberLiteral(
    Expression expression, {
    bool nonZero = false,
  }) {
    final literal = switch (expression) {
      PrefixExpression(
        operator: Token(type: TokenType.MINUS),
        :final operand,
      ) =>
        operand,
      _ => expression,
    };
    final value = switch (literal) {
      IntegerLiteral(:final value) => value,
      DoubleLiteral(:final value) => value,
      _ => null,
    };
    if (value == null || (nonZero && value == 0)) return null;
    return expression;
  }

  /// Returns the expression of the named argument [name] in [arguments], or
  /// null when it isn't passed.
  static Expression? namedArgument(ArgumentList arguments, String name) {
    for (final argument in arguments.arguments) {
      if (argument is NamedArgument && argument.name.lexeme == name) {
        return argument.argumentExpression;
      }
    }
    return null;
  }

  /// Returns every argument's expression in [arguments], positional and
  /// named.
  static Iterable<Expression> allArguments(ArgumentList arguments) =>
      arguments.arguments.map((argument) => argument.argumentExpression);
}
