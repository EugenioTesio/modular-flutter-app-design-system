import 'dart:convert';

import '../exceptions/ds_brand_parse_exception.dart';

/// One token of a file in the W3C Design Tokens Format Module 2025.10,
/// before its references are resolved.
///
/// This is internal to the design system and is not exported.
final class DsDesignToken {
  /// Creates a token.
  ///
  /// Parameters:
  /// * [path] - The token's dot path.
  /// * [type] - Optional `$type`, its own or inherited from a group.
  /// * [value] - The raw `$value`.
  const DsDesignToken({
    required this.path,
    required this.type,
    required this.value,
  });

  /// The token's dot path.
  final String path;

  /// Optional `$type`, its own or inherited from a group.
  final String? type;

  /// The raw `$value`.
  final Object? value;
}

/// A file in the W3C Design Tokens Format Module 2025.10, read into tokens
/// and groups.
///
/// This is internal to the design system and is not exported.
final class DsDesignTokensFile {
  /// Creates a read design-tokens file.
  ///
  /// Parameters:
  /// * [root] - The decoded file.
  /// * [tokens] - Every token, by dot path.
  /// * [groups] - The dot path of every group; the root group is `''`.
  /// * [problemGroups] - Structural problems. Problems in one group belong
  ///   together, such as every member of one cycle.
  const DsDesignTokensFile({
    required this.root,
    required this.tokens,
    required this.groups,
    required this.problemGroups,
  });

  /// The decoded file.
  final Map<String, Object?> root;

  /// Every token, by dot path.
  final Map<String, DsDesignToken> tokens;

  /// The dot path of every group; the root group is `''`.
  final Set<String> groups;

  /// Structural problems, in groups that are reported together.
  final List<List<DsBrandParseException>> problemGroups;
}

/// Reader for the structure of a file in the W3C Design Tokens Format
/// Module 2025.10: tokens, groups, `$type` inheritance, `$root`, and
/// `$extends`.
///
/// This is internal to the design system and is not exported. It records
/// problems instead of stopping, so one run finds them all.
abstract final class DsDesignTokensReader {
  /// Pattern of a curly-brace reference, such as `{color.brand.600}`.
  static final RegExp alias = RegExp(r'^\{([^{}]+)\}$');

  static const Set<String> _groupProperties = {
    r'$type',
    r'$description',
    r'$extensions',
    r'$deprecated',
    r'$extends',
  };

  /// Decodes [json] into a map.
  ///
  /// Parameters:
  /// * [json] - The file's text.
  ///
  /// Returns the decoded root object, or a malformedFile problem when the
  /// text is not JSON or its root is not an object.
  static (Map<String, Object?>?, DsBrandParseException?) decode(String json) {
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException catch (error) {
      final at = error.offset == null ? '' : ' (at character ${error.offset})';
      return (
        null,
        DsBrandParseException(
          path: '',
          type: DsBrandParseExceptionType.malformedFile,
          message: 'The file is not valid JSON$at.',
        ),
      );
    }
    final root = asObject(decoded);
    if (root == null) {
      return (
        null,
        const DsBrandParseException(
          path: '',
          type: DsBrandParseExceptionType.malformedFile,
          message: 'The root of the file must be a JSON object.',
        ),
      );
    }
    return (root, null);
  }

  /// Returns [value] as a map with string keys, or null when it isn't one.
  ///
  /// Parameters:
  /// * [value] - Any decoded JSON value.
  static Map<String, Object?>? asObject(Object? value) {
    if (value is Map<String, Object?>) return value;
    if (value is Map && value.keys.every((key) => key is String)) {
      return {
        for (final MapEntry(:key, :value) in value.entries)
          key as String: value,
      };
    }
    return null;
  }

  /// Reads the tokens and groups of [root].
  ///
  /// Parameters:
  /// * [root] - The decoded file.
  static DsDesignTokensFile read(Map<String, Object?> root) {
    final reader = _DsDesignTokensReaderRun(root);
    reader.walkGroup(root, const [], null);
    return DsDesignTokensFile(
      root: root,
      tokens: reader.tokens,
      groups: reader.groups,
      problemGroups: reader.problemGroups,
    );
  }
}

/// One run of [DsDesignTokensReader.read].
final class _DsDesignTokensReaderRun {
  _DsDesignTokensReaderRun(this.root);

  final Map<String, Object?> root;
  final Map<String, DsDesignToken> tokens = {};
  final Set<String> groups = {''};
  final List<List<DsBrandParseException>> problemGroups = [];

  void problem(String path, DsBrandParseExceptionType type, String message) =>
      problemGroups.add([
        DsBrandParseException(path: path, type: type, message: message),
      ]);

  void walkGroup(
    Map<String, Object?> node,
    List<String> segments,
    String? inheritedType,
  ) {
    final path = segments.join('.');
    final group = mergedGroup(node, path, [path]);
    final ownType = group[r'$type'];
    if (ownType != null && ownType is! String) {
      problem(
        path,
        DsBrandParseExceptionType.invalidValue,
        r'$type must be text.',
      );
    }
    final type = ownType is String ? ownType : inheritedType;
    for (final MapEntry(:key, :value) in group.entries) {
      if (key == r'$root') {
        walkNode(value, [...segments, r'$root'], type);
      } else if (key.startsWith(r'$')) {
        if (!DsDesignTokensReader._groupProperties.contains(key)) {
          problem(
            path,
            DsBrandParseExceptionType.invalidValue,
            'Unknown group property "$key".',
          );
        }
      } else if (key.contains('{') || key.contains('}') || key.contains('.')) {
        problem(
          [...segments, key].join('.'),
          DsBrandParseExceptionType.invalidValue,
          'Names may not contain "{", "}", or ".".',
        );
      } else {
        walkNode(value, [...segments, key], type);
      }
    }
  }

  void walkNode(Object? value, List<String> segments, String? inheritedType) {
    final path = segments.join('.');
    final node = DsDesignTokensReader.asObject(value);
    if (node == null) {
      problem(
        path,
        DsBrandParseExceptionType.invalidValue,
        'Must be a token or a group object.',
      );
      return;
    }
    if (!node.containsKey(r'$value')) {
      groups.add(path);
      walkGroup(node, segments, inheritedType);
      return;
    }
    if (node.keys.any((key) => !key.startsWith(r'$'))) {
      problem(
        path,
        DsBrandParseExceptionType.invalidValue,
        r'A token with $value may not have child tokens.',
      );
    }
    final ownType = node[r'$type'];
    if (ownType != null && ownType is! String) {
      problem(
        path,
        DsBrandParseExceptionType.invalidValue,
        r'$type must be text.',
      );
    }
    tokens[path] = DsDesignToken(
      path: path,
      type: ownType is String ? ownType : inheritedType,
      value: node[r'$value'],
    );
  }

  /// Returns [node] with its `$extends` group merged in, local values first.
  Map<String, Object?> mergedGroup(
    Map<String, Object?> node,
    String path,
    List<String> stack,
  ) {
    final target = node[r'$extends'];
    if (target == null) return node;
    final local = {...node}..remove(r'$extends');
    final match = target is String
        ? DsDesignTokensReader.alias.firstMatch(target)
        : null;
    if (match == null) {
      problem(
        path,
        DsBrandParseExceptionType.invalidValue,
        r'$extends must be a reference such as "{group.name}".',
      );
      return local;
    }
    final targetPath = match.group(1)!;
    final cycleStart = stack.indexOf(targetPath);
    if (cycleStart >= 0) {
      final members = stack.sublist(cycleStart);
      problemGroups.add([
        for (final member in members)
          DsBrandParseException(
            path: member,
            type: DsBrandParseExceptionType.circularReference,
            message:
                r'$extends forms a cycle: '
                '${[...members, targetPath].join(' → ')}.',
          ),
      ]);
      return local;
    }
    final base = DsDesignTokensReader.asObject(lookup(targetPath));
    if (base == null) {
      problem(
        path,
        DsBrandParseExceptionType.unresolvedReference,
        r'$extends names "{'
        '$targetPath}", which is not a group in the file.',
      );
      return local;
    }
    if (base.containsKey(r'$value')) {
      problem(
        path,
        DsBrandParseExceptionType.invalidValue,
        r'$extends must name a group, not a token.',
      );
      return local;
    }
    return deepMerge(
      mergedGroup(base, targetPath, [...stack, targetPath]),
      local,
    );
  }

  Object? lookup(String path) {
    Object? current = root;
    for (final segment in path.split('.')) {
      final object = DsDesignTokensReader.asObject(current);
      if (object == null) return null;
      current = object[segment];
    }
    return current;
  }

  static Map<String, Object?> deepMerge(
    Map<String, Object?> base,
    Map<String, Object?> local,
  ) {
    final merged = {...base};
    for (final MapEntry(:key, :value) in local.entries) {
      final baseChild = DsDesignTokensReader.asObject(merged[key]);
      final localChild = DsDesignTokensReader.asObject(value);
      final bothGroups =
          baseChild != null &&
          localChild != null &&
          !baseChild.containsKey(r'$value') &&
          !localChild.containsKey(r'$value');
      merged[key] = bothGroups ? deepMerge(baseChild, localChild) : value;
    }
    return merged;
  }
}
