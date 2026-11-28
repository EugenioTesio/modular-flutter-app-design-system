// Feature: No component takes a brand or tokens through its constructor;
// every component reads them from the nearest brand.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Given the component source files', () {
    test('When their fields are scanned, '
        'Then none holds a brand, tokens, or a token group', () {
      // Given
      final field = RegExp(
        r'^\s*final\s+(DsBrand|DsTokens|DsColors|DsTypography|DsSpacing|'
        r'DsRadius|DsBorderWidths|DsOpacities|DsIconSizes|DsBrandColors|'
        r'DsBrandTypography|DsBrandScale|DsNeutralScale|DsStatusScale|'
        r'DsTypeStyle)\??\s+\w+;',
        multiLine: true,
      );
      final files = Directory('lib/src/components')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      // When
      final offenders = [
        for (final file in files)
          for (final match in field.allMatches(file.readAsStringSync()))
            '${file.path}: ${match.group(0)!.trim()}',
      ];

      // Then
      expect(offenders, isEmpty);
    });
  });
}
