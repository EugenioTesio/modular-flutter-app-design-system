// Feature: Golden comparison tolerates cross-platform rendering
// (contracts/golden-tests.md, Comparator).
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ds_golden_comparator.dart';

/// Builds the PNG images the comparisons use.
abstract final class _TestImages {
  /// Width and height of every image, so 100 pixels are 1%.
  static const int side = 100;

  /// Returns a white PNG whose first [changedPixels] pixels are black.
  static Future<Uint8List> png({required int changedPixels}) async {
    final rgba = Uint8List(side * side * 4)..fillRange(0, side * side * 4, 255);
    for (var pixel = 0; pixel < changedPixels; pixel++) {
      rgba.fillRange(pixel * 4, pixel * 4 + 3, 0);
    }
    final buffer = await ui.ImmutableBuffer.fromUint8List(rgba);
    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: side,
      height: side,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await descriptor.instantiateCodec();
    final image = (await codec.getNextFrame()).image;
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    codec.dispose();
    descriptor.dispose();
    buffer.dispose();
    return bytes!.buffer.asUint8List();
  }
}

void main() {
  group('Given a committed golden image', () {
    final golden = Uri.parse('goldens/sample.png');
    late Directory folder;
    late DsGoldenComparator comparator;
    late List<String> printed;

    Future<bool> compare(Uint8List image, Uri goldenUri) => runZoned(
      () => comparator.compare(image, goldenUri),
      zoneSpecification: ZoneSpecification(
        print: (_, _, _, line) => printed.add(line),
      ),
    );

    setUp(() async {
      folder = Directory.systemTemp.createTempSync('ds_golden_comparator');
      comparator = DsGoldenComparator(folder.uri.resolve('sample_test.dart'));
      printed = [];
      File('${folder.path}/goldens/sample.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(await _TestImages.png(changedPixels: 0));
    });

    tearDown(() => folder.deleteSync(recursive: true));

    test('When an identical image is compared, '
        'Then the comparison passes and reports nothing', () async {
      // Given
      final image = await _TestImages.png(changedPixels: 0);

      // When
      final passed = await compare(image, golden);

      // Then
      expect(passed, isTrue);
      expect(printed, isEmpty);
    });

    test('When an image differing in 3% of its pixels is compared, '
        'Then the comparison passes and reports 3.00%', () async {
      // Given
      final image = await _TestImages.png(changedPixels: 300);

      // When
      final passed = await compare(image, golden);

      // Then
      expect(passed, isTrue);
      expect(printed, ['goldens/sample.png: 3.00% (tolerated)']);
      expect(Directory('${folder.path}/failures').existsSync(), isFalse);
    });

    test('When an image differing in exactly 5% of its pixels is compared, '
        'Then the comparison passes', () async {
      // Given
      final image = await _TestImages.png(changedPixels: 500);

      // When
      final passed = await compare(image, golden);

      // Then
      expect(passed, isTrue);
      expect(DsGoldenComparator.threshold, 0.05);
    });

    test(
      'When an image differing in 6% of its pixels is compared, '
      'Then it fails, names the image, reports 6.00%, and writes failures/',
      () async {
        // Given
        final image = await _TestImages.png(changedPixels: 600);

        // When
        final comparison = compare(image, golden);

        // Then
        await expectLater(
          comparison,
          throwsA(
            isA<FlutterError>().having(
              (error) => error.message,
              'message',
              allOf(
                contains('goldens/sample.png'),
                contains('6.00%'),
                contains('5.00% allowed'),
              ),
            ),
          ),
        );
        final failures = Directory('${folder.path}/failures');
        expect(failures.existsSync(), isTrue);
        expect(failures.listSync(), isNotEmpty);
      },
    );

    test('When the golden image does not exist, '
        'Then it fails and the message names --update-goldens', () async {
      // Given
      final image = await _TestImages.png(changedPixels: 0);
      final missing = Uri.parse('goldens/missing.png');

      // When
      final comparison = compare(image, missing);

      // Then
      await expectLater(
        comparison,
        throwsA(
          isA<TestFailure>().having(
            (failure) => failure.message,
            'message',
            allOf(
              contains('goldens/missing.png'),
              contains('--update-goldens'),
            ),
          ),
        ),
      );
    });
  });
}
