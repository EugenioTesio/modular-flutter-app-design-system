import 'dart:io';

import 'package:flutter/services.dart';

/// Fonts that only the tests use, so golden images draw readable text that
/// doesn't depend on the machine's fonts.
///
/// The files live in `test/fonts/` and are never declared as package assets.
/// Roboto is Apache-2.0 and MaterialIcons is CC BY 4.0; their licenses sit
/// next to them.
abstract final class DsTestFonts {
  /// Roboto files, registered under each family in [textFamilies].
  static const List<String> robotoFiles = [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
  ];

  /// Text families that render with Roboto: Material's default family and
  /// the Forest sample brand's family, which no app bundles.
  static const List<String> textFamilies = ['Roboto', 'Forest Sans'];

  /// Registers Roboto under every family in [textFamilies], and
  /// MaterialIcons under `MaterialIcons`.
  ///
  /// Call it once per test file, before any test runs, as
  /// `test/flutter_test_config.dart` does. Throws a [FileSystemException]
  /// when a font file is missing.
  static Future<void> load() async {
    for (final family in textFamilies) {
      final loader = FontLoader(family);
      for (final file in robotoFiles) {
        loader.addFont(DsTestFonts._read(file));
      }
      await loader.load();
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(DsTestFonts._read('MaterialIcons-Regular.otf'))).load();
  }

  static Future<ByteData> _read(String file) async =>
      ByteData.sublistView(await File('test/fonts/$file').readAsBytes());
}
