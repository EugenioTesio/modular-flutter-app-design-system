import 'ds_brand_parse_exception.dart';

/// Exception thrown inside the brand-file parser when a token of the W3C
/// Design Tokens Format Module 2025.10 can't be resolved or converted.
///
/// This is internal to the design system and is not exported. The parser
/// catches it for each token and adds its problems to the report, so it never
/// reaches callers.
final class DsDesignTokensException implements Exception {
  /// Creates a design-tokens exception.
  ///
  /// Parameters:
  /// * [exceptions] - One exception for each problem found; never empty.
  const DsDesignTokensException(this.exceptions);

  /// Creates a design-tokens exception with one problem.
  ///
  /// Parameters:
  /// * [path] - The dot path of the token.
  /// * [type] - What kind of problem it is.
  /// * [message] - A human-readable explanation.
  DsDesignTokensException.single(
    String path,
    DsBrandParseExceptionType type,
    String message,
  ) : exceptions = [
        DsBrandParseException(path: path, type: type, message: message),
      ];

  /// One exception for each problem found; never empty.
  final List<DsBrandParseException> exceptions;

  @override
  String toString() => 'DsDesignTokensException: ${exceptions.join('; ')}';
}
