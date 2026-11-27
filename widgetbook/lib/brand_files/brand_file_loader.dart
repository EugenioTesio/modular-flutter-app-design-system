import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// One file of the brands folder, with the brand it describes or the
/// exceptions that rejected it.
@immutable
final class WidgetbookBrandFile {
  /// Creates a brand file entry.
  const WidgetbookBrandFile({
    required this.fileName,
    this.brand,
    this.exceptions = const [],
  });

  /// The file's name, such as `sample_forest.json`.
  final String fileName;

  /// Optional brand the file describes; null when the file is invalid.
  final DsBrand? brand;

  /// Every exception that rejected the file; empty when it is valid.
  final List<DsBrandParseException> exceptions;
}

/// The brands the Widgetbook offers, and every file it read.
@immutable
final class WidgetbookBrands {
  /// Creates the Widgetbook's brands.
  const WidgetbookBrands({required this.selectable, required this.files});

  /// Brands the brand switcher lists: the white label first, then every
  /// valid brand file, sorted by name.
  final List<DsBrand> selectable;

  /// Every file of the brands folder, valid or not, sorted by file name.
  final List<WidgetbookBrandFile> files;
}

/// Loader of the Widgetbook's `brands/` folder.
abstract final class BrandFileLoader {
  static const String _folder = 'brands/';

  /// Reads every `.json` file under `brands/` from [bundle].
  ///
  /// In profile builds it prints how long each file took to parse.
  static Future<WidgetbookBrands> load(AssetBundle bundle) async {
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    final paths = manifest.listAssets().where(
      (path) => path.startsWith(_folder) && path.endsWith('.json'),
    );
    final contents = {
      for (final path in paths)
        path.substring(_folder.length): await bundle.loadString(path),
    };
    return fromContents(contents, logParseTimes: kProfileMode);
  }

  /// Parses brand files from their contents, keyed by file name.
  ///
  /// Rules:
  /// * The white label is always listed first, from the built-in brand. A
  ///   `white_label` file must parse to exactly that brand; otherwise it is
  ///   invalid.
  /// * When two files share an id, the second one, by file name, is invalid.
  /// * An invalid file never stops the others.
  static WidgetbookBrands fromContents(
    Map<String, String> contents, {
    bool logParseTimes = false,
  }) {
    final files = <WidgetbookBrandFile>[];
    final ids = <String>{DsBrand.whiteLabel.id};
    final brands = <DsBrand>[];
    final names = contents.keys.toList()..sort();
    for (final fileName in names) {
      final watch = Stopwatch()..start();
      final result = DsBrandParser.parseJson(contents[fileName]!);
      watch.stop();
      if (logParseTimes) {
        debugPrint(
          'Brand file $fileName parsed in '
          '${(watch.elapsedMicroseconds / 1000).toStringAsFixed(1)} ms',
        );
      }
      files.add(switch (result) {
        DsBrandParseFailure(:final exceptions) => WidgetbookBrandFile(
          fileName: fileName,
          exceptions: exceptions,
        ),
        DsBrandParseSuccess(:final brand) => _accept(
          fileName,
          brand,
          ids,
          brands,
        ),
      });
    }
    brands.sort((a, b) => a.name.compareTo(b.name));
    return WidgetbookBrands(
      selectable: [DsBrand.whiteLabel, ...brands],
      files: files,
    );
  }

  static WidgetbookBrandFile _accept(
    String fileName,
    DsBrand brand,
    Set<String> ids,
    List<DsBrand> brands,
  ) {
    if (brand.id == DsBrand.whiteLabel.id) {
      return brand == DsBrand.whiteLabel
          ? WidgetbookBrandFile(fileName: fileName, brand: brand)
          : _invalid(
              fileName,
              'This file no longer matches DsBrand.whiteLabel. Keep the two '
              'in step.',
            );
    }
    if (!ids.add(brand.id)) {
      return _invalid(
        fileName,
        'duplicate id: another brand file already uses "${brand.id}".',
      );
    }
    brands.add(brand);
    return WidgetbookBrandFile(fileName: fileName, brand: brand);
  }

  static WidgetbookBrandFile _invalid(String fileName, String message) =>
      WidgetbookBrandFile(
        fileName: fileName,
        exceptions: [
          DsBrandParseException(
            path: r'$extensions.com.github.eugeniotesio.design_system.id',
            type: DsBrandParseExceptionType.invalidValue,
            message: message,
          ),
        ],
      );
}
