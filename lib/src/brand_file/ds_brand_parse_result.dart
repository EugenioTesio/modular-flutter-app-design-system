/// @docImport '../theme/ds_brand_scope.dart';
/// @docImport '../theme/ds_theme.dart';
/// @docImport 'ds_brand_parser.dart';
library;

import '../brand/ds_brand.dart';
import '../exceptions/ds_brand_parse_exception.dart';

/// Value that holds the outcome of parsing a brand file: a brand, or every
/// problem found.
///
/// Use this with an exhaustive `switch`, so the code handles both the brand
/// and the failure.
///
/// This is **not** Foundations' result type: the design system can't depend
/// on Foundations, so the parser has its own.
///
/// Built-in: [DsBrandParser.parseJson] and [DsBrandParser.parseMap] return it.
///
/// Usage from a micro app:
/// ```dart
/// final brand = switch (DsBrandParser.parseJson(partnerJson)) {
///   DsBrandParseSuccess(:final brand) => brand,
///   DsBrandParseFailure() => null,
/// };
/// ```
sealed class DsBrandParseResult {
  /// Creates a parse result.
  const DsBrandParseResult();
}

/// Result of a brand file that parsed: it holds the [brand].
///
/// Use this to place the brand, through [DsTheme] or a [DsBrandScope].
///
/// This is **not** a check of contrast: a parsed brand may still fail the
/// contrast checks.
///
/// Usage from a micro app:
/// ```dart
/// if (result case DsBrandParseSuccess(:final brand)) {
///   partnerBrand = brand;
/// }
/// ```
final class DsBrandParseSuccess extends DsBrandParseResult {
  /// Creates a successful parse result.
  ///
  /// Parameters:
  /// * [brand] - The brand the file describes.
  const DsBrandParseSuccess(this.brand);

  /// The brand the file describes.
  final DsBrand brand;
}

/// Result of a brand file that was rejected: it holds one
/// [DsBrandParseException] for each problem found.
///
/// Use this to report every problem at once, and to fall back to another
/// brand, such as [DsBrand.whiteLabel].
///
/// This is **not** thrown: the parser returns it.
///
/// Rules: [exceptions] is never empty, and is ordered by path, then by type.
///
/// Usage from a micro app:
/// ```dart
/// if (result case DsBrandParseFailure(:final exceptions)) {
///   debugPrint('Partner brand rejected: ${exceptions.length} problems');
/// }
/// ```
final class DsBrandParseFailure extends DsBrandParseResult {
  /// Creates a failed parse result.
  ///
  /// Parameters:
  /// * [exceptions] - One exception for each problem found; must not be
  ///   empty.
  const DsBrandParseFailure(this.exceptions)
    : assert(exceptions.length > 0, 'A failed parse has an exception.');

  /// One exception for each problem found in the file, ordered by path;
  /// never empty.
  final List<DsBrandParseException> exceptions;
}
