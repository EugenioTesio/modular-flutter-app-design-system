import 'ds_brand_parse_exception.dart';

/// Exception thrown inside the brand-file parser when a token can't be
/// resolved or converted.
///
/// This is internal to the design system and is not exported. The parser
/// catches it for each token and adds its problems to the report, so it never
/// reaches callers.
final class DtcgResolutionException implements Exception {
  /// Creates a resolution exception.
  ///
  /// Parameters:
  /// * [exceptions] - One exception for each problem found; never empty.
  const DtcgResolutionException(this.exceptions);

  /// Creates a resolution exception with one problem.
  ///
  /// Parameters:
  /// * [path] - The dot path of the token.
  /// * [type] - What kind of problem it is.
  /// * [message] - A human-readable explanation.
  DtcgResolutionException.single(
    String path,
    DsBrandParseExceptionType type,
    String message,
  ) : exceptions = [
        DsBrandParseException(path: path, type: type, message: message),
      ];

  /// One exception for each problem found; never empty.
  final List<DsBrandParseException> exceptions;

  @override
  String toString() => 'DtcgResolutionException: ${exceptions.join('; ')}';
}
