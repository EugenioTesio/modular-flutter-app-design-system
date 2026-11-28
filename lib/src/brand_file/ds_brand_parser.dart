/// @docImport '../theme/ds_brand_scope.dart';
/// @docImport '../theme/ds_theme.dart';
library;

import 'package:flutter/painting.dart';

import '../brand/ds_brand.dart';
import '../brand/ds_brand_colors.dart';
import '../brand/ds_brand_typography.dart';
import '../brand/ds_color_scale.dart';
import '../brand/ds_type_style.dart';
import '../exceptions/ds_brand_parse_exception.dart';
import '../exceptions/ds_design_tokens_exception.dart';
import '../tokens/ds_border_widths.dart';
import '../tokens/ds_icon_sizes.dart';
import '../tokens/ds_opacities.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import 'ds_brand_parse_result.dart';
import 'ds_design_tokens_reader.dart';
import 'ds_design_tokens_resolver.dart';
import 'ds_design_tokens_value_converter.dart';

/// Parser that turns a brand file into a [DsBrand].
///
/// Use this once you have a brand file's contents, for example in the App
/// Shell at startup, or in a micro app before it wraps its screens in its
/// own brand with [DsBrandScope]. Where the file comes from is the caller's choice: bundled
/// assets, the network, or a cache.
///
/// This is **not** a loader: it never reads files, assets, or the network.
/// Pass it the text or the decoded JSON.
///
/// Built-in: the file uses the W3C Design Tokens format (2025.10), which
/// Figma Variables and Tokens Studio export. The parser resolves references
/// (`{group.token}` aliases, `$ref` pointers, `$extends`, and `$root`).
///
/// Rules:
/// * Parsing is strict and complete. It returns a brand, or a
///   [DsBrandParseFailure] with one [DsBrandParseException] per problem,
///   each with its path. It never throws for a bad file.
/// * The file supplies every primitive token of the brand schema, and states
///   its metadata in the root `$extensions` under
///   `com.github.eugeniotesio.design_system`: `id`, `name`, and
///   `schemaVersion`, which must be in [supportedSchemaVersions].
/// * Tokens the design system doesn't use are ignored, even broken ones.
/// * Two equivalent files give equal brands. sRGB, HSL, and HWB colors are
///   read at 8 bits per channel, the precision of a hex color.
/// * Problem messages never repeat the file's contents beyond the offending
///   value, so they are safe to log.
///
/// Usage from the App Shell:
/// ```dart
/// final brand = switch (DsBrandParser.parseJson(brandJson)) {
///   DsBrandParseSuccess(:final brand) => brand,
///   DsBrandParseFailure(:final exceptions) => () {
///     debugPrint('Brand rejected: ${exceptions.length} problems');
///     return DsBrand.whiteLabel;
///   }(),
/// };
/// runApp(ShellApp(theme: DsTheme.light(brand: brand)));
/// ```
abstract final class DsBrandParser {
  /// Brand-schema versions this release of the design system accepts.
  static const Set<int> supportedSchemaVersions = {1};

  static const String _metadataKey = 'com.github.eugeniotesio.design_system';
  static const String _metadataPath = '\$extensions.$_metadataKey';
  static final RegExp _idPattern = RegExp(r'^[a-z0-9_]+$');

  static const List<String> _brandSteps = [
    '50', '100', '200', '300', '400', '500', '600', '700', '800', '900', //
  ];
  static const List<String> _neutralSteps = ['0', ..._brandSteps];
  static const List<String> _statusSteps = ['100', '500', '700'];
  static const List<String> _statusScales = [
    'success',
    'warning',
    'error',
    'info',
  ];
  static const List<String> _textRoles = [
    'display', 'headline', 'title', 'body', 'bodyStrong', 'label', 'caption', //
  ];
  static const List<String> _spacingSteps = [
    'xxs', 'xs', 'sm', 'md', 'lg', 'xl', 'xxl', //
  ];

  /// Every token brand-schema version 1 requires, with its type.
  static final Map<String, String> _required = {
    for (final step in _brandSteps) 'color.brand.$step': 'color',
    for (final step in _neutralSteps) 'color.neutral.$step': 'color',
    for (final scale in _statusScales)
      for (final step in _statusSteps) 'color.$scale.$step': 'color',
    for (final role in _textRoles) 'typography.$role': 'typography',
    for (final step in _spacingSteps) 'spacing.$step': 'dimension',
    for (final step in ['sm', 'md', 'lg', 'pill']) 'radius.$step': 'dimension',
    for (final step in ['thin', 'thick']) 'borderWidth.$step': 'dimension',
    for (final state in ['hovered', 'focused', 'pressed'])
      'opacity.$state': 'number',
    for (final step in ['sm', 'md', 'lg']) 'iconSize.$step': 'dimension',
  };

  /// Parses a brand file from its text.
  ///
  /// Parameters:
  /// * [json] - The file's contents, as JSON text.
  ///
  /// Returns a [DsBrandParseSuccess] with the brand, or a
  /// [DsBrandParseFailure] with one [DsBrandParseException] per problem.
  /// Text that is not JSON, or whose root is not an object, gives one
  /// exception of type [DsBrandParseExceptionType.malformedFile].
  static DsBrandParseResult parseJson(String json) {
    final (root, problem) = DsDesignTokensReader.decode(json);
    if (root == null) {
      return DsBrandParseFailure([problem!]);
    }
    return parseMap(root);
  }

  /// Parses a brand file that is already decoded from JSON.
  ///
  /// Parameters:
  /// * [map] - The file's root object, as `jsonDecode` returns it.
  ///
  /// Returns a [DsBrandParseSuccess] with the brand, or a
  /// [DsBrandParseFailure] with one [DsBrandParseException] per problem.
  static DsBrandParseResult parseMap(Map<String, Object?> map) {
    final tokensFile = DsDesignTokensReader.read(map);
    final problems = <DsBrandParseException>[
      for (final group in tokensFile.problemGroups)
        if (group.any((problem) => _onRequiredPath(problem.path))) ...group,
    ];
    final (id, name) = _readMetadata(map, problems);

    final references = DsDesignTokensResolver(tokensFile);
    final values = <String, Object>{};
    for (final MapEntry(key: path, value: expectedType) in _required.entries) {
      if (!tokensFile.tokens.containsKey(path)) {
        problems.add(
          DsBrandParseException(
            path: path,
            type: DsBrandParseExceptionType.missingToken,
            message: 'This required $expectedType token is missing.',
          ),
        );
        continue;
      }
      final type = references.typeOf(path);
      if (type != expectedType) {
        problems.add(
          DsBrandParseException(
            path: path,
            type: DsBrandParseExceptionType.wrongType,
            message: type == null
                ? 'The token has no \$type; it must be "$expectedType".'
                : 'The token is a "$type"; it must be "$expectedType".',
          ),
        );
        continue;
      }
      try {
        values[path] = _convert(path, expectedType, references.resolve(path));
      } on DsDesignTokensException catch (error) {
        problems.addAll(error.exceptions);
      }
    }

    if (problems.isNotEmpty) {
      return DsBrandParseFailure(_sorted(problems));
    }
    return DsBrandParseSuccess(_brand(id!, name!, values));
  }

  static Object _convert(String path, String type, Object? value) {
    switch (type) {
      case 'color':
        return DsDesignTokensValueConverter.color(value, path);
      case 'typography':
        return DsDesignTokensValueConverter.typeStyle(value, path);
      case 'number':
        final number = DsDesignTokensValueConverter.number(value, path);
        if (path.startsWith('opacity.') && (number < 0 || number > 1)) {
          throw DsDesignTokensException.single(
            path,
            DsBrandParseExceptionType.invalidValue,
            'An opacity must be from 0 to 1, not $number.',
          );
        }
        return number;
      default:
        return DsDesignTokensValueConverter.dimension(value, path);
    }
  }

  static (String?, String?) _readMetadata(
    Map<String, Object?> map,
    List<DsBrandParseException> problems,
  ) {
    final extensions = DsDesignTokensReader.asObject(map[r'$extensions']);
    final metadata =
        DsDesignTokensReader.asObject(extensions?[_metadataKey]) ?? {};
    void add(String field, DsBrandParseExceptionType type, String message) =>
        problems.add(
          DsBrandParseException(
            path: '$_metadataPath.$field',
            type: type,
            message: message,
          ),
        );
    void missing(String field) => add(
      field,
      DsBrandParseExceptionType.missingToken,
      'The brand metadata needs "$field".',
    );

    final id = metadata['id'];
    if (id == null) {
      missing('id');
    } else if (id is! String || !_idPattern.hasMatch(id)) {
      add(
        'id',
        DsBrandParseExceptionType.invalidValue,
        'The id uses lowercase letters, digits, and underscores only.',
      );
    }
    final name = metadata['name'];
    if (name == null) {
      missing('name');
    } else if (name is! String || name.trim().isEmpty) {
      add('name', DsBrandParseExceptionType.invalidValue, 'The name is empty.');
    }
    final version = metadata['schemaVersion'];
    final supported = supportedSchemaVersions.join(', ');
    if (version == null) {
      missing('schemaVersion');
    } else if (version is! num || version != version.truncate()) {
      add(
        'schemaVersion',
        DsBrandParseExceptionType.invalidValue,
        'The schemaVersion is a whole number. Supported versions: $supported.',
      );
    } else if (!supportedSchemaVersions.contains(version.toInt())) {
      add(
        'schemaVersion',
        DsBrandParseExceptionType.unsupportedSchemaVersion,
        'The file targets brand-schema version $version. Supported '
            'versions: $supported.',
      );
    }
    return (id is String ? id : null, name is String ? name : null);
  }

  /// Whether a problem at [path] concerns a required token or the path to
  /// one; problems elsewhere are ignored.
  static bool _onRequiredPath(String path) =>
      path.isEmpty ||
      _required.keys.any(
        (required) =>
            required == path ||
            required.startsWith('$path.') ||
            path.startsWith('$required.'),
      );

  static List<DsBrandParseException> _sorted(
    List<DsBrandParseException> problems,
  ) {
    final seen = <(String, DsBrandParseExceptionType)>{};
    return [
      for (final problem in problems)
        if (seen.add((problem.path, problem.type))) problem,
    ]..sort((a, b) => a.path.compareTo(b.path));
  }

  static DsBrand _brand(String id, String name, Map<String, Object> values) {
    Color color(String path) => values[path]! as Color;
    double size(String path) => values[path]! as double;
    DsTypeStyle style(String role) =>
        values['typography.$role']! as DsTypeStyle;
    DsStatusScale status(String scale) => DsStatusScale(
      shade100: color('color.$scale.100'),
      shade500: color('color.$scale.500'),
      shade700: color('color.$scale.700'),
    );

    return DsBrand(
      id: id,
      name: name,
      colors: DsBrandColors(
        brand: DsBrandScale(
          shade50: color('color.brand.50'),
          shade100: color('color.brand.100'),
          shade200: color('color.brand.200'),
          shade300: color('color.brand.300'),
          shade400: color('color.brand.400'),
          shade500: color('color.brand.500'),
          shade600: color('color.brand.600'),
          shade700: color('color.brand.700'),
          shade800: color('color.brand.800'),
          shade900: color('color.brand.900'),
        ),
        neutral: DsNeutralScale(
          shade0: color('color.neutral.0'),
          shade50: color('color.neutral.50'),
          shade100: color('color.neutral.100'),
          shade200: color('color.neutral.200'),
          shade300: color('color.neutral.300'),
          shade400: color('color.neutral.400'),
          shade500: color('color.neutral.500'),
          shade600: color('color.neutral.600'),
          shade700: color('color.neutral.700'),
          shade800: color('color.neutral.800'),
          shade900: color('color.neutral.900'),
        ),
        success: status('success'),
        warning: status('warning'),
        error: status('error'),
        info: status('info'),
      ),
      typography: DsBrandTypography(
        display: style('display'),
        headline: style('headline'),
        title: style('title'),
        body: style('body'),
        bodyStrong: style('bodyStrong'),
        label: style('label'),
        caption: style('caption'),
      ),
      spacing: DsSpacing(
        xxs: size('spacing.xxs'),
        xs: size('spacing.xs'),
        sm: size('spacing.sm'),
        md: size('spacing.md'),
        lg: size('spacing.lg'),
        xl: size('spacing.xl'),
        xxl: size('spacing.xxl'),
      ),
      radius: DsRadius(
        sm: size('radius.sm'),
        md: size('radius.md'),
        lg: size('radius.lg'),
        pill: size('radius.pill'),
      ),
      borderWidths: DsBorderWidths(
        thin: size('borderWidth.thin'),
        thick: size('borderWidth.thick'),
      ),
      opacities: DsOpacities(
        hovered: size('opacity.hovered'),
        focused: size('opacity.focused'),
        pressed: size('opacity.pressed'),
      ),
      iconSizes: DsIconSizes(
        sm: size('iconSize.sm'),
        md: size('iconSize.md'),
        lg: size('iconSize.lg'),
      ),
    );
  }
}
