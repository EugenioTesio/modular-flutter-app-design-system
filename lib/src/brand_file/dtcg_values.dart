import 'dart:convert';
import 'dart:ui' show ColorSpace;

import 'package:flutter/painting.dart';

import '../brand/ds_type_style.dart';
import '../exceptions/dtcg_resolution_exception.dart';
import 'dtcg_reader.dart';
import '../exceptions/ds_brand_parse_exception.dart';

/// Converters from resolved design-tokens values to the design system's
/// values.
///
/// This is internal to the design system and is not exported. Each converter
/// throws a [DtcgResolutionException] naming [DsBrandParseExceptionType]
/// invalidValue or unsupportedFormat for a value it can't use.
abstract final class DtcgValues {
  /// Font family names that mean the platform font.
  static const Set<String> genericFamilies = {'system-ui', 'sans-serif'};

  static const Map<String, int> _weightKeywords = {
    'thin': 100,
    'hairline': 100,
    'extra-light': 200,
    'ultra-light': 200,
    'light': 300,
    'normal': 400,
    'regular': 400,
    'book': 400,
    'medium': 500,
    'semi-bold': 600,
    'demi-bold': 600,
    'bold': 700,
    'extra-bold': 800,
    'ultra-bold': 800,
    'black': 900,
    'heavy': 900,
    'extra-black': 950,
    'ultra-black': 950,
  };

  /// Returns the color a `color` value describes.
  ///
  /// Parameters:
  /// * [value] - The resolved value: `{colorSpace, components, alpha?,
  ///   hex?}`.
  /// * [path] - The token's dot path, for problems.
  ///
  /// sRGB, HSL, and HWB colors are rounded to 8 bits per channel, the
  /// precision of a hex color. Display-P3 colors keep their color space.
  static Color color(Object? value, String path) {
    final object = DtcgReader.asObject(value);
    if (object == null) throw _invalid(path, 'A color must be an object.');
    final space = object['colorSpace'];
    final components = object['components'];
    final alpha = object['alpha'] ?? 1;
    final hex = object['hex'];
    if (space is! String) throw _invalid(path, 'The colorSpace is missing.');
    if (components is! List || components.length != 3) {
      throw _invalid(path, 'A color needs three components.');
    }
    if (components.any((component) => component == 'none')) {
      throw _unsupported(path, 'Components of "none" are not supported.');
    }
    if (alpha is! num || alpha < 0 || alpha > 1) {
      throw _invalid(path, 'alpha must be a number from 0 to 1.');
    }
    switch (space) {
      case 'srgb':
        final [r, g, b] = _numbers(components, path, 1, 1, 1);
        return _rgb8(alpha, r, g, b);
      case 'hsl':
        final [h, s, l] = _numbers(components, path, double.infinity, 100, 100);
        final (r, g, b) = _hslToRgb(h, s / 100, l / 100);
        return _rgb8(alpha, r, g, b);
      case 'hwb':
        final [h, w, bl] = _numbers(
          components,
          path,
          double.infinity,
          100,
          100,
        );
        final (r, g, b) = _hwbToRgb(h, w / 100, bl / 100);
        return _rgb8(alpha, r, g, b);
      case 'display-p3':
        final [r, g, b] = _numbers(components, path, 1, 1, 1);
        return Color.from(
          alpha: alpha.toDouble(),
          red: r,
          green: g,
          blue: b,
          colorSpace: ColorSpace.displayP3,
        );
    }
    if (hex == null) {
      throw _unsupported(
        path,
        'The color space "$space" is not supported. Export sRGB, or include '
        'hex.',
      );
    }
    final match = hex is String
        ? RegExp(r'^#([0-9a-fA-F]{6})$').firstMatch(hex)
        : null;
    if (match == null) throw _invalid(path, 'hex must look like "#1f5fd1".');
    final rgb = int.parse(match.group(1)!, radix: 16);
    return Color.fromARGB(
      (alpha * 255).round(),
      rgb >> 16 & 0xFF,
      rgb >> 8 & 0xFF,
      rgb & 0xFF,
    );
  }

  /// Returns the logical pixels a `dimension` value describes.
  ///
  /// Parameters:
  /// * [value] - The resolved value: `{value, unit}`.
  /// * [path] - The token's dot path, for problems.
  /// * [allowNegative] - Whether a negative size is valid, as for letter
  ///   spacing. Defaults to false.
  ///
  /// `px` maps one to one, and `rem` is multiplied by 16.
  static double dimension(
    Object? value,
    String path, {
    bool allowNegative = false,
  }) {
    final object = DtcgReader.asObject(value);
    final number = object?['value'];
    final unit = object?['unit'];
    if (object == null || number is! num) {
      throw _invalid(path, 'A dimension must be {"value": number, "unit": …}.');
    }
    if (unit == null) {
      throw _invalid(path, 'A dimension needs a unit, even when it is 0.');
    }
    final size = switch (unit) {
      'px' => number.toDouble(),
      'rem' => (number * 16).toDouble(),
      _ => throw _unsupported(path, 'Use the unit "px" or "rem".'),
    };
    if (!allowNegative && size < 0) {
      throw _invalid(path, 'The size must be at least 0, not $number.');
    }
    return size;
  }

  /// Returns the number a `number` value holds.
  ///
  /// Parameters:
  /// * [value] - The resolved value.
  /// * [path] - The token's dot path, for problems.
  static double number(Object? value, String path) {
    if (value is! num) {
      throw _invalid(path, 'Expected a number, got ${_show(value)}.');
    }
    return value.toDouble();
  }

  /// Returns the family and fallbacks a `fontFamily` value names.
  ///
  /// Parameters:
  /// * [value] - The resolved value: a name, or a list of names.
  /// * [path] - The token's dot path, for problems.
  ///
  /// The family is the first name that isn't generic, or null when all of
  /// them are, which means the platform font. The other names that aren't
  /// generic become the fallbacks.
  static (String?, List<String>) fontFamily(Object? value, String path) {
    final names = switch (value) {
      final String name => [name],
      final List<Object?> list when list.every((name) => name is String) =>
        list.cast<String>(),
      _ => throw _invalid(path, 'A font family is a name or a list of names.'),
    };
    if (names.isEmpty) throw _invalid(path, 'The font family list is empty.');
    final specific = names
        .where((name) => !genericFamilies.contains(name))
        .toList();
    return specific.isEmpty
        ? (null, const <String>[])
        : (specific.first, specific.sublist(1));
  }

  /// Returns the nearest [FontWeight] to a `fontWeight` value.
  ///
  /// Parameters:
  /// * [value] - The resolved value: a number from 1 to 1000, or a keyword.
  /// * [path] - The token's dot path, for problems.
  static FontWeight fontWeight(Object? value, String path) {
    final weight = switch (value) {
      final num number when number >= 1 && number <= 1000 => number,
      final String keyword when _weightKeywords.containsKey(keyword) =>
        _weightKeywords[keyword]!,
      _ => throw _invalid(path, 'A font weight is 1 to 1000, or a keyword.'),
    };
    final index = (weight / 100).round().clamp(1, 9) - 1;
    return FontWeight.values[index];
  }

  /// Returns the text style a `typography` value describes.
  ///
  /// Parameters:
  /// * [value] - The resolved value, with fontFamily, fontSize, fontWeight,
  ///   letterSpacing, and lineHeight.
  /// * [path] - The token's dot path, for problems.
  ///
  /// Each missing or invalid part is reported on its own, at
  /// `<path>.<part>`.
  static DsTypeStyle typeStyle(Object? value, String path) {
    final object = DtcgReader.asObject(value);
    if (object == null) throw _invalid(path, 'A text style must be an object.');
    final problems = <DsBrandParseException>[];
    T? part<T>(String name, T Function(Object? value, String path) convert) {
      final partPath = '$path.$name';
      if (!object.containsKey(name)) {
        problems.add(
          DsBrandParseException(
            path: partPath,
            type: DsBrandParseExceptionType.invalidValue,
            message: 'The text style misses its $name.',
          ),
        );
        return null;
      }
      try {
        return convert(object[name], partPath);
      } on DtcgResolutionException catch (error) {
        problems.addAll(error.exceptions);
        return null;
      }
    }

    final family = part('fontFamily', fontFamily);
    final size = part('fontSize', dimension);
    final weight = part('fontWeight', fontWeight);
    final spacing = part(
      'letterSpacing',
      (value, path) => dimension(value, path, allowNegative: true),
    );
    final height = part('lineHeight', number);
    if (size != null && size <= 0) {
      problems.add(
        DsBrandParseException(
          path: '$path.fontSize',
          type: DsBrandParseExceptionType.invalidValue,
          message: 'The font size must be greater than 0.',
        ),
      );
    }
    if (height != null && height <= 0) {
      problems.add(
        DsBrandParseException(
          path: '$path.lineHeight',
          type: DsBrandParseExceptionType.invalidValue,
          message: 'The line height must be greater than 0.',
        ),
      );
    }
    if (problems.isNotEmpty) throw DtcgResolutionException(problems);
    return DsTypeStyle(
      fontFamily: family!.$1,
      fontFamilyFallback: family.$2,
      fontSize: size!,
      fontWeight: weight!,
      lineHeight: height!,
      letterSpacing: spacing!,
    );
  }

  static List<double> _numbers(
    List<Object?> components,
    String path,
    double max0,
    double max1,
    double max2,
  ) {
    final maxima = [max0, max1, max2];
    return [
      for (var index = 0; index < 3; index++)
        switch (components[index]) {
          final num value when value >= 0 && value <= maxima[index] =>
            value.toDouble(),
          _ => throw _invalid(
            path,
            'Color component ${index + 1} is out of range.',
          ),
        },
    ];
  }

  static Color _rgb8(num alpha, double r, double g, double b) => Color.fromARGB(
    (alpha * 255).round(),
    (r * 255).round(),
    (g * 255).round(),
    (b * 255).round(),
  );

  static (double, double, double) _hslToRgb(double h, double s, double l) {
    double channel(int n) {
      final k = (n + h / 30) % 12;
      final a = s * (l < 1 - l ? l : 1 - l);
      final m = [k - 3, 9 - k, 1.0].reduce((x, y) => x < y ? x : y);
      return l - a * (m > -1 ? m : -1);
    }

    return (channel(0), channel(8), channel(4));
  }

  static (double, double, double) _hwbToRgb(double h, double w, double b) {
    if (w + b >= 1) {
      final gray = w / (w + b);
      return (gray, gray, gray);
    }
    final (r, g, bl) = _hslToRgb(h, 1, 0.5);
    double mix(double channel) => channel * (1 - w - b) + w;
    return (mix(r), mix(g), mix(bl));
  }

  static String _show(Object? value) {
    String text;
    try {
      text = value is String ? '"$value"' : jsonEncode(value);
    } on JsonUnsupportedObjectError {
      text = 'a ${value.runtimeType}';
    }
    return text.length > 40 ? '${text.substring(0, 37)}...' : text;
  }

  static DtcgResolutionException _invalid(String path, String message) =>
      DtcgResolutionException.single(
        path,
        DsBrandParseExceptionType.invalidValue,
        message,
      );

  static DtcgResolutionException _unsupported(String path, String message) =>
      DtcgResolutionException.single(
        path,
        DsBrandParseExceptionType.unsupportedFormat,
        message,
      );
}
