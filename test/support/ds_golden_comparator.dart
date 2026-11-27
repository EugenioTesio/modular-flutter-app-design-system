import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Comparator that accepts golden images differing by at most [threshold] of
/// their pixels.
///
/// Use this to compare golden images that one machine generated with images
/// another machine draws, such as macOS goldens checked on Linux, where text
/// and edges rasterize slightly differently.
///
/// This is **not** part of the package's public API. It lives under `test/`
/// and is never exported.
///
/// Built-in: `test/flutter_test_config.dart` installs it for every test file,
/// so `matchesGoldenFile` uses it everywhere.
///
/// Behavior:
/// * A tolerated difference prints the image and the measured share, such as
///   `goldens/ds_button/primary__forest__light.png: 1.84% (tolerated)`.
/// * A larger difference writes the difference images to `failures/` next to
///   the test file, which git ignores, and throws a [FlutterError] that names
///   the image and the measured share.
/// * A missing golden image fails with a message that names the regenerate
///   command.
final class DsGoldenComparator extends LocalFileComparator {
  /// Creates a comparator that reads golden images relative to the folder of
  /// [testFile].
  ///
  /// Parameters:
  /// * [testFile] - A file in the folder that golden paths are relative to.
  DsGoldenComparator(super.testFile);

  /// Largest share of pixels that may differ, as a fraction from 0 to 1.
  ///
  /// This is the single place the tolerance is set: 5% of the pixels.
  static const double threshold = 0.05;

  /// Command that regenerates the golden images after an intentional change.
  static const String updateCommand =
      'flutter test --update-goldens --tags golden';

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    final measured = DsGoldenComparator.percent(result.diffPercent);
    if (result.passed || result.diffPercent <= threshold) {
      if (!result.passed) {
        // The tolerated difference is the comparator's report to the
        // developer, so it goes to the test output.
        // ignore: avoid_print
        print('$golden: $measured (tolerated)');
      }
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(
      '$error\nMeasured $measured > ${DsGoldenComparator.percent(threshold)} '
      'allowed. If the change is intentional, run `$updateCommand` and '
      'review the new images.',
    );
  }

  @override
  Future<List<int>> getGoldenBytes(Uri golden) async {
    if (!File.fromUri(basedir.resolveUri(golden)).existsSync()) {
      fail(
        'Golden image "$golden" does not exist. Run `$updateCommand` to '
        'generate it, then review and commit it.',
      );
    }
    return super.getGoldenBytes(golden);
  }

  /// Returns [fraction] as a percentage with two decimals, such as `3.00%`.
  ///
  /// Parameters:
  /// * [fraction] - A share from 0 to 1.
  static String percent(double fraction) =>
      '${(fraction * 100).toStringAsFixed(2)}%';
}
