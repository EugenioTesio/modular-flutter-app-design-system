/// @docImport '../brand_file/ds_brand_parser.dart';
/// @docImport '../brand_file/ds_brand_parse_result.dart';
library;

/// Value that names why part of a brand file was rejected.
///
/// Use this to group or count the exceptions of a [DsBrandParseFailure], for
/// example to show designers which kind of fix a file needs.
///
/// This is **not** a severity: every type rejects the file.
///
/// Usage from the App Shell:
/// ```dart
/// final missing = failure.exceptions
///     .where((e) => e.type == DsBrandParseExceptionType.missingToken)
///     .map((e) => e.path);
/// ```
enum DsBrandParseExceptionType {
  /// The text is not JSON, or its root is not an object.
  malformedFile,

  /// A required token or metadata field is missing.
  missingToken,

  /// A required token has another type, or no type at all.
  wrongType,

  /// A value doesn't match its type or is out of range.
  invalidValue,

  /// A reference names something that doesn't exist, or a group.
  unresolvedReference,

  /// References loop back on themselves.
  circularReference,

  /// A color space, unit, or value form the design system can't use.
  unsupportedFormat,

  /// The file targets a brand-schema version the design system doesn't
  /// accept.
  unsupportedSchemaVersion,
}

/// Exception returned when part of a brand file is rejected: where it is
/// and why.
///
/// Use this to show designers exactly what to fix: [path] points to the
/// token, [type] says what kind of problem it is, and [message] explains it.
///
/// This is **not** thrown: [DsBrandParser] returns every exception of a file
/// at once, in [DsBrandParseFailure.exceptions], so a bad file never crashes
/// the app and one run lists everything to fix.
///
/// Rules:
/// * [path] is the token's dot path in the file, such as `spacing.md`. It is
///   empty for an exception about the whole file. Metadata exceptions use
///   `$extensions.com.github.eugeniotesio.design_system.<field>`.
/// * [message] never repeats the file's contents beyond the offending value,
///   so it is safe to log.
///
/// Usage from the App Shell:
/// ```dart
/// switch (DsBrandParser.parseJson(brandJson)) {
///   case DsBrandParseSuccess(:final brand):
///     runApp(ShellApp(brand: brand));
///   case DsBrandParseFailure(:final exceptions):
///     for (final exception in exceptions) {
///       debugPrint('$exception');
///     }
///     runApp(const ShellApp(brand: DsBrand.whiteLabel));
/// }
/// ```
final class DsBrandParseException implements Exception {
  /// Creates a brand-parse exception.
  ///
  /// Parameters:
  /// * [path] - The dot path of the token or field; empty for the whole
  ///   file.
  /// * [type] - What kind of problem it is.
  /// * [message] - A human-readable explanation, safe to log.
  const DsBrandParseException({
    required this.path,
    required this.type,
    required this.message,
  });

  /// Dot path of the token or field that was rejected; empty for the whole
  /// file.
  final String path;

  /// What kind of problem it is.
  final DsBrandParseExceptionType type;

  /// Human-readable explanation, safe to log.
  final String message;

  @override
  bool operator ==(Object other) =>
      other is DsBrandParseException &&
      other.path == path &&
      other.type == type &&
      other.message == message;

  @override
  int get hashCode => Object.hash(path, type, message);

  @override
  String toString() =>
      'DsBrandParseException: ${path.isEmpty ? '(file)' : path} · '
      '${type.name} · $message';
}
