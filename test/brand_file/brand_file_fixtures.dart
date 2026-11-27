import 'dart:convert';
import 'dart:io';

/// Builds brand-file fixtures by changing a fresh copy of the repository's
/// reference file, so each test shows exactly what is wrong with its file.
abstract final class BrandFileFixtures {
  /// Key of the design system's metadata in the root `$extensions`.
  static const String metadataKey = 'com.github.eugeniotesio.design_system';

  /// Path prefix of the metadata problems.
  static const String metadataPath = '\$extensions.$metadataKey';

  /// Returns a fresh, decoded copy of `widgetbook/brands/white_label.json`.
  static Map<String, Object?> whiteLabel() => read('white_label.json');

  /// Returns a fresh, decoded copy of a file in `widgetbook/brands/`.
  ///
  /// Parameters:
  /// * [fileName] - The file's name, such as `sample_forest.json`.
  static Map<String, Object?> read(String fileName) =>
      jsonDecode(File('widgetbook/brands/$fileName').readAsStringSync())
          as Map<String, Object?>;

  /// Returns the group or token at the dot [path] of [file].
  ///
  /// Parameters:
  /// * [file] - The decoded brand file.
  /// * [path] - A dot path such as `color.brand.600`.
  static Map<String, Object?> node(Map<String, Object?> file, String path) {
    var current = file;
    for (final segment in path.split('.')) {
      current = current[segment]! as Map<String, Object?>;
    }
    return current;
  }

  /// Replaces the `$value` of the token at [path].
  ///
  /// Parameters:
  /// * [file] - The decoded brand file.
  /// * [path] - The token's dot path.
  /// * [value] - The new `$value`.
  static void setValue(Map<String, Object?> file, String path, Object? value) =>
      node(file, path)[r'$value'] = value;

  /// Removes the token or group at [path].
  ///
  /// Parameters:
  /// * [file] - The decoded brand file.
  /// * [path] - The dot path to remove.
  static void remove(Map<String, Object?> file, String path) {
    final segments = path.split('.');
    final parent = segments.length == 1
        ? file
        : node(file, segments.sublist(0, segments.length - 1).join('.'));
    parent.remove(segments.last);
  }

  /// Returns the metadata object of [file].
  ///
  /// Parameters:
  /// * [file] - The decoded brand file.
  static Map<String, Object?> metadata(Map<String, Object?> file) =>
      (file[r'$extensions']! as Map<String, Object?>)[metadataKey]!
          as Map<String, Object?>;

  /// Returns an sRGB color value.
  ///
  /// Parameters:
  /// * [red] - Red component, from 0 to 1.
  /// * [green] - Green component, from 0 to 1.
  /// * [blue] - Blue component, from 0 to 1.
  static Map<String, Object?> srgb(double red, double green, double blue) => {
    'colorSpace': 'srgb',
    'components': [red, green, blue],
  };

  /// Returns a dimension value.
  ///
  /// Parameters:
  /// * [value] - The number.
  /// * [unit] - The unit. Defaults to `px`.
  static Map<String, Object?> dimension(num value, [String unit = 'px']) => {
    'value': value,
    'unit': unit,
  };
}
