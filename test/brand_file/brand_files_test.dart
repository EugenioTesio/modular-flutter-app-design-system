// Feature: The repository's brand files stay valid: the reference file
// mirrors the built-in white label, and parsing stays fast.
import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Given the brands folder of the Widgetbook', () {
    final files = Directory('widgetbook/brands')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .toList();

    test('When white_label.json is parsed, '
        'Then it equals the built-in white label', () {
      // Given
      final json = File('widgetbook/brands/white_label.json')
          .readAsStringSync();

      // When
      final result = DsBrandParser.parseJson(json);

      // Then
      expect(result, isA<DsBrandParseSuccess>());
      expect((result as DsBrandParseSuccess).brand, DsBrand.whiteLabel);
    });

    test('When every brand file is parsed, Then each yields a brand', () {
      // Given
      expect(files, isNotEmpty);

      // When
      final failures = {
        for (final file in files)
          if (DsBrandParser.parseJson(file.readAsStringSync())
              case DsBrandParseFailure(:final exceptions))
            file.path: exceptions.join('; '),
      };

      // Then
      expect(failures, isEmpty);
    });

    test('When sample_forest.json is parsed 20 times, '
        'Then the median parse takes under 100 ms', () {
      // Given
      final json = File('widgetbook/brands/sample_forest.json')
          .readAsStringSync();

      // When
      final durations = [
        for (var run = 0; run < 20; run++)
          () {
            final watch = Stopwatch()..start();
            DsBrandParser.parseJson(json);
            return watch.elapsedMicroseconds;
          }(),
      ]..sort();

      // Then
      expect(durations[durations.length ~/ 2], lessThan(100000));
    });
  });
}
