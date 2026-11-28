import '../exceptions/ds_design_tokens_exception.dart';
import 'ds_design_tokens_reader.dart';
import '../exceptions/ds_brand_parse_exception.dart';

/// Resolver of the references in a file in the W3C Design Tokens Format
/// Module 2025.10: curly-brace aliases to tokens and JSON Pointer `$ref`
/// objects, followed in chains, with cycle detection.
///
/// This is internal to the design system and is not exported.
final class DsDesignTokensResolver {
  /// Creates a resolver.
  ///
  /// Parameters:
  /// * [tokensFile] - The file read by [DsDesignTokensReader].
  DsDesignTokensResolver(this.tokensFile);

  /// The file whose references are resolved.
  final DsDesignTokensFile tokensFile;

  /// Returns the type of the token at [path]: its own or inherited `$type`,
  /// or, for an alias with neither, the type of the token it names.
  ///
  /// Parameters:
  /// * [path] - The token's dot path.
  ///
  /// Returns null when the token has no type. Types are never inferred from
  /// values.
  String? typeOf(String path) => _typeOf(path, const []);

  String? _typeOf(String path, List<String> stack) {
    final token = tokensFile.tokens[path];
    if (token == null || stack.contains(path)) return null;
    if (token.type != null) return token.type;
    final value = token.value;
    final match = value is String
        ? DsDesignTokensReader.alias.firstMatch(value)
        : null;
    return match == null ? null : _typeOf(match.group(1)!, [...stack, path]);
  }

  /// Returns the `$value` of the token at [path] with every reference in it
  /// replaced by what it names.
  ///
  /// Parameters:
  /// * [path] - The token's dot path.
  ///
  /// Throws a [DsDesignTokensException] with an unresolvedReference problem
  /// at [path] when a reference names nothing or names a group, and with one
  /// circularReference problem per member when references form a cycle.
  Object? resolve(String path) => _resolveToken(path, path, const []);

  Object? _resolveToken(String path, String origin, List<String> stack) {
    final cycleStart = stack.indexOf(path);
    if (cycleStart >= 0) throw _cycle(stack.sublist(cycleStart));
    final token = tokensFile.tokens[path];
    if (token == null) {
      final what = tokensFile.groups.contains(path)
          ? 'a group, not a token'
          : 'nothing in the file';
      throw DsDesignTokensException.single(
        origin,
        DsBrandParseExceptionType.unresolvedReference,
        'The reference "{$path}" names $what.',
      );
    }
    return _resolveValue(token.value, origin, [...stack, path]);
  }

  Object? _resolveValue(Object? value, String origin, List<String> stack) {
    if (value is String) {
      final match = DsDesignTokensReader.alias.firstMatch(value);
      return match == null
          ? value
          : _resolveToken(match.group(1)!, origin, stack);
    }
    if (value is List) {
      return [for (final item in value) _resolveValue(item, origin, stack)];
    }
    final object = DsDesignTokensReader.asObject(value);
    if (object == null) return value;
    if (object.length == 1 && object.containsKey(r'$ref')) {
      return _resolvePointer(object[r'$ref'], origin, stack);
    }
    return {
      for (final MapEntry(:key, :value) in object.entries)
        key: _resolveValue(value, origin, stack),
    };
  }

  Object? _resolvePointer(Object? pointer, String origin, List<String> stack) {
    if (pointer is! String || !pointer.startsWith('#')) {
      throw DsDesignTokensException.single(
        origin,
        DsBrandParseExceptionType.unresolvedReference,
        r'A $ref must be a JSON Pointer within the file, such as "#/a/b".',
      );
    }
    final key = _pointerPath(pointer);
    final cycleStart = stack.indexOf(key);
    if (cycleStart >= 0) throw _cycle(stack.sublist(cycleStart));
    final (found, target) = _lookupPointer(pointer);
    if (!found) {
      throw DsDesignTokensException.single(
        origin,
        DsBrandParseExceptionType.unresolvedReference,
        r'The $ref "'
        '$pointer" points to nothing in the file.',
      );
    }
    return _resolveValue(target, origin, [...stack, key]);
  }

  (bool, Object?) _lookupPointer(String pointer) {
    final body = pointer.substring(1);
    if (body.isEmpty) return (true, tokensFile.root);
    if (!body.startsWith('/')) return (false, null);
    Object? current = tokensFile.root;
    for (final raw in body.substring(1).split('/')) {
      final segment = raw.replaceAll('~1', '/').replaceAll('~0', '~');
      if (current is List) {
        final index = int.tryParse(segment);
        if (index == null || index < 0 || index >= current.length) {
          return (false, null);
        }
        current = current[index];
      } else {
        final object = DsDesignTokensReader.asObject(current);
        if (object == null || !object.containsKey(segment)) {
          return (false, null);
        }
        current = object[segment];
      }
    }
    return (true, current);
  }

  /// Returns the dot path a pointer names, for cycle reports: the pointer
  /// `#/spacing/md/$value` becomes `spacing.md`.
  static String _pointerPath(String pointer) {
    final segments = pointer
        .replaceFirst(RegExp('^#/?'), '')
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .toList();
    final valueAt = segments.indexOf(r'$value');
    return (valueAt >= 0 ? segments.sublist(0, valueAt) : segments).join('.');
  }

  static DsDesignTokensException _cycle(List<String> members) =>
      DsDesignTokensException([
        for (final member in members)
          DsBrandParseException(
            path: member,
            type: DsBrandParseExceptionType.circularReference,
            message:
                'References form a cycle: '
                '${[...members, members.first].join(' → ')}.',
          ),
      ]);
}
