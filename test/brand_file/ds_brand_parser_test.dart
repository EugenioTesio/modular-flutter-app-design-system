// Feature: A brand file in the W3C Design Tokens format is parsed strictly:
// it yields a brand, or one report that names every problem with its path.
import 'dart:convert';
import 'dart:ui' show ColorSpace;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'brand_file_fixtures.dart';

typedef _Problem = (String path, DsBrandParseExceptionType type);

List<_Problem> _problems(DsBrandParseResult result) => switch (result) {
  DsBrandParseSuccess() => fail('Expected a failure, got a brand'),
  DsBrandParseFailure(:final exceptions) => [
    for (final exception in exceptions) (exception.path, exception.type),
  ],
};

DsBrand _brand(DsBrandParseResult result) => switch (result) {
  DsBrandParseSuccess(:final brand) => brand,
  DsBrandParseFailure(:final exceptions) => fail(
    'Expected a brand: ${exceptions.join('; ')}',
  ),
};

void main() {
  const meta = BrandFileFixtures.metadataPath;
  late Map<String, Object?> file;

  setUp(() => file = BrandFileFixtures.whiteLabel());

  group('Given the reference white-label file', () {
    test('When it is parsed, Then it yields the built-in white label', () {
      // Given / When
      final result = DsBrandParser.parseMap(file);

      // Then
      expect(_brand(result), DsBrand.whiteLabel);
    });

    test(
      'When it is parsed from its JSON text, Then the brand is the same',
      () {
        // Given
        final json = jsonEncode(file);

        // When
        final result = DsBrandParser.parseJson(json);

        // Then
        expect(_brand(result), DsBrand.whiteLabel);
      },
    );
  });

  group('Given a file with one problem of each type', () {
    test('When the text is not JSON, '
        'Then there is one malformedFile problem for the whole file', () {
      // Given
      const json = '{"color": ';

      // When
      final result = DsBrandParser.parseJson(json);

      // Then
      expect(_problems(result), [
        ('', DsBrandParseExceptionType.malformedFile),
      ]);
    });

    test('When a required token is missing, Then it is a missingToken', () {
      // Given
      BrandFileFixtures.remove(file, 'spacing.md');

      // When
      final result = DsBrandParser.parseMap(file);

      // Then
      expect(_problems(result), [
        ('spacing.md', DsBrandParseExceptionType.missingToken),
      ]);
    });

    test(
      'When a required token has the wrong type, Then it is a wrongType',
      () {
        // Given
        BrandFileFixtures.node(file, 'radius.md')[r'$type'] = 'color';

        // When
        final result = DsBrandParser.parseMap(file);

        // Then
        expect(_problems(result), [
          ('radius.md', DsBrandParseExceptionType.wrongType),
        ]);
      },
    );

    test(
      'When a required token has no type at all, Then it is a wrongType',
      () {
        // Given
        BrandFileFixtures.node(file, 'opacity').remove(r'$type');
        for (final step in ['hovered', 'focused']) {
          BrandFileFixtures.node(file, 'opacity.$step')[r'$type'] = 'number';
        }

        // When
        final result = DsBrandParser.parseMap(file);

        // Then
        expect(_problems(result), [
          ('opacity.pressed', DsBrandParseExceptionType.wrongType),
        ]);
      },
    );

    test('When a value is out of range, Then it is an invalidValue', () {
      // Given
      BrandFileFixtures.setValue(file, 'opacity.pressed', 1.5);

      // When
      final result = DsBrandParser.parseMap(file);

      // Then
      expect(_problems(result), [
        ('opacity.pressed', DsBrandParseExceptionType.invalidValue),
      ]);
    });

    test('When a reference names a token that does not exist, '
        'Then it is an unresolvedReference', () {
      // Given
      final body = BrandFileFixtures.node(file, 'typography.body');
      (body[r'$value']! as Map<String, Object?>)['fontFamily'] =
          '{font.family.missing}';

      // When
      final result = DsBrandParser.parseMap(file);

      // Then
      expect(_problems(result), [
        ('typography.body', DsBrandParseExceptionType.unresolvedReference),
      ]);
    });

    test('When two tokens reference each other, '
        'Then each member of the cycle is a circularReference', () {
      // Given
      BrandFileFixtures.setValue(file, 'spacing.md', '{spacing.lg}');
      BrandFileFixtures.setValue(file, 'spacing.lg', '{spacing.md}');

      // When
      final result = DsBrandParser.parseMap(file);

      // Then
      expect(_problems(result), [
        ('spacing.lg', DsBrandParseExceptionType.circularReference),
        ('spacing.md', DsBrandParseExceptionType.circularReference),
      ]);
    });

    test('When a color uses an unsupported color space without hex, '
        'Then it is an unsupportedFormat', () {
      // Given
      BrandFileFixtures.setValue(file, 'color.brand.600', {
        'colorSpace': 'oklch',
        'components': [0.5, 0.1, 250],
      });

      // When
      final result = DsBrandParser.parseMap(file);

      // Then
      expect(_problems(result), [
        ('color.brand.600', DsBrandParseExceptionType.unsupportedFormat),
      ]);
    });

    test('When the schema version is not supported, '
        'Then it is an unsupportedSchemaVersion naming version 1', () {
      // Given
      BrandFileFixtures.metadata(file)['schemaVersion'] = 2;

      // When
      final result = DsBrandParser.parseMap(file);

      // Then
      expect(_problems(result), [
        (
          '$meta.schemaVersion',
          DsBrandParseExceptionType.unsupportedSchemaVersion,
        ),
      ]);
      final failure = result as DsBrandParseFailure;
      expect(failure.exceptions.single.message, contains('1'));
      expect(DsBrandParser.supportedSchemaVersions, {1});
    });
  });

  group('Given a file with seven problems of mixed types', () {
    test('When it is parsed, '
        'Then exactly seven problems are reported, ordered by path', () {
      // Given
      BrandFileFixtures.remove(file, 'spacing.md');
      BrandFileFixtures.node(file, 'radius.md')[r'$type'] = 'color';
      BrandFileFixtures.setValue(file, 'opacity.pressed', -0.2);
      final caption = BrandFileFixtures.node(file, 'typography.caption');
      (caption[r'$value']! as Map<String, Object?>)['fontFamily'] = '{nope}';
      BrandFileFixtures.setValue(file, 'color.error.700', {
        'colorSpace': 'lab',
        'components': [40, 50, 30],
      });
      BrandFileFixtures.metadata(file)
        ..['schemaVersion'] = 3
        ..remove('name');

      // When
      final result = DsBrandParser.parseMap(file);

      // Then
      expect(_problems(result), [
        ('$meta.name', DsBrandParseExceptionType.missingToken),
        (
          '$meta.schemaVersion',
          DsBrandParseExceptionType.unsupportedSchemaVersion,
        ),
        ('color.error.700', DsBrandParseExceptionType.unsupportedFormat),
        ('opacity.pressed', DsBrandParseExceptionType.invalidValue),
        ('radius.md', DsBrandParseExceptionType.wrongType),
        ('spacing.md', DsBrandParseExceptionType.missingToken),
        ('typography.caption', DsBrandParseExceptionType.unresolvedReference),
      ]);
    });
  });

  group('Given metadata problems', () {
    test('When the metadata is missing, '
        'Then id, name, and schemaVersion are each a missingToken', () {
      // Given
      file.remove(r'$extensions');

      // When
      final result = DsBrandParser.parseMap(file);

      // Then
      expect(_problems(result), [
        ('$meta.id', DsBrandParseExceptionType.missingToken),
        ('$meta.name', DsBrandParseExceptionType.missingToken),
        ('$meta.schemaVersion', DsBrandParseExceptionType.missingToken),
      ]);
    });

    test('When the id has uppercase letters and the name is empty, '
        'Then both are an invalidValue', () {
      // Given
      BrandFileFixtures.metadata(file)
        ..['id'] = 'Forest'
        ..['name'] = '';

      // When
      final result = DsBrandParser.parseMap(file);

      // Then
      expect(_problems(result), [
        ('$meta.id', DsBrandParseExceptionType.invalidValue),
        ('$meta.name', DsBrandParseExceptionType.invalidValue),
      ]);
    });
  });

  group('Given references in the format', () {
    test('When a token aliases an alias, Then the chain is followed', () {
      // Given
      BrandFileFixtures.node(file, 'spacing')['gutter'] = {
        r'$value': '{spacing.lg}',
      };
      BrandFileFixtures.setValue(file, 'spacing.md', '{spacing.gutter}');

      // When
      final brand = _brand(DsBrandParser.parseMap(file));

      // Then
      expect(brand.spacing.md, 24);
    });

    test(r'When a value uses a $ref pointer into another token, '
        'Then the pointed sub-value is used', () {
      // Given
      BrandFileFixtures.setValue(file, 'radius.md', {
        'value': {r'$ref': '#/spacing/xs/\$value/value'},
        'unit': 'px',
      });

      // When
      final brand = _brand(DsBrandParser.parseMap(file));

      // Then
      expect(brand.radius.md, 8);
    });

    test(r'When a group $extends another, '
        'Then it inherits its tokens and its own tokens win', () {
      // Given
      final spacing = BrandFileFixtures.node(file, 'spacing');
      file['baseSpacing'] = {
        for (final entry in spacing.entries) entry.key: entry.value,
      };
      file['spacing'] = {
        r'$extends': '{baseSpacing}',
        'md': {r'$value': BrandFileFixtures.dimension(20)},
      };

      // When
      final brand = _brand(DsBrandParser.parseMap(file));

      // Then
      expect(brand.spacing.md, 20);
      expect(brand.spacing.lg, 24);
    });

    test(r'When two groups $extends each other, '
        'Then both are a circularReference', () {
      // Given
      file['other'] = {r'$extends': '{spacing}'};
      BrandFileFixtures.node(file, 'spacing')[r'$extends'] = '{other}';

      // When
      final result = DsBrandParser.parseMap(file);

      // Then
      expect(_problems(result), [
        ('other', DsBrandParseExceptionType.circularReference),
        ('spacing', DsBrandParseExceptionType.circularReference),
      ]);
    });

    test(
      r'When a token aliases a group $root, Then the root token is used',
      () {
        // Given
        BrandFileFixtures.node(file, 'color.brand')[r'$root'] = {
          r'$value': BrandFileFixtures.srgb(1, 0, 0),
        };
        BrandFileFixtures.setValue(
          file,
          'color.brand.600',
          '{color.brand.\$root}',
        );

        // When
        final brand = _brand(DsBrandParser.parseMap(file));

        // Then
        expect(brand.colors.brand.shade600, const Color(0xFFFF0000));
      },
    );

    test(
      'When a reference names a group, Then it is an unresolvedReference',
      () {
        // Given
        BrandFileFixtures.setValue(file, 'spacing.md', '{spacing}');

        // When
        final result = DsBrandParser.parseMap(file);

        // Then
        expect(_problems(result), [
          ('spacing.md', DsBrandParseExceptionType.unresolvedReference),
        ]);
      },
    );
  });

  group('Given the supported value formats', () {
    test('When colors use hsl, hwb, display-p3, or another space with hex, '
        'Then each is converted', () {
      // Given
      BrandFileFixtures.setValue(file, 'color.brand.50', {
        'colorSpace': 'hsl',
        'components': [0, 100, 50],
      });
      BrandFileFixtures.setValue(file, 'color.brand.100', {
        'colorSpace': 'hwb',
        'components': [120, 0, 0],
      });
      BrandFileFixtures.setValue(file, 'color.brand.200', {
        'colorSpace': 'display-p3',
        'components': [0, 0, 1],
        'alpha': 0.5,
      });
      BrandFileFixtures.setValue(file, 'color.brand.300', {
        'colorSpace': 'oklch',
        'components': [0.7, 0.1, 250],
        'hex': '#8ab4f8',
      });

      // When
      final scale = _brand(DsBrandParser.parseMap(file)).colors.brand;

      // Then
      expect(scale.shade50, const Color(0xFFFF0000));
      expect(scale.shade100, const Color(0xFF00FF00));
      expect(scale.shade200.colorSpace, ColorSpace.displayP3);
      expect(scale.shade200.b, 1);
      expect(scale.shade200.a, 0.5);
      expect(scale.shade300, const Color(0xFF8AB4F8));
    });

    test(
      'When a color component is "none", Then it is an unsupportedFormat',
      () {
        // Given
        BrandFileFixtures.setValue(file, 'color.neutral.0', {
          'colorSpace': 'srgb',
          'components': ['none', 1, 1],
        });

        // When
        final result = DsBrandParser.parseMap(file);

        // Then
        expect(_problems(result), [
          ('color.neutral.0', DsBrandParseExceptionType.unsupportedFormat),
        ]);
      },
    );

    test('When dimensions use rem, Then they are multiplied by 16', () {
      // Given
      BrandFileFixtures.setValue(
        file,
        'spacing.md',
        BrandFileFixtures.dimension(1.25, 'rem'),
      );

      // When
      final brand = _brand(DsBrandParser.parseMap(file));

      // Then
      expect(brand.spacing.md, 20);
    });

    test('When a dimension has no unit, a negative value, or an unknown unit, '
        'Then each is reported', () {
      // Given
      BrandFileFixtures.setValue(file, 'spacing.md', {'value': 0});
      BrandFileFixtures.setValue(
        file,
        'spacing.lg',
        BrandFileFixtures.dimension(-4),
      );
      BrandFileFixtures.setValue(
        file,
        'spacing.xl',
        BrandFileFixtures.dimension(2, 'em'),
      );

      // When
      final result = DsBrandParser.parseMap(file);

      // Then
      expect(_problems(result), [
        ('spacing.lg', DsBrandParseExceptionType.invalidValue),
        ('spacing.md', DsBrandParseExceptionType.invalidValue),
        ('spacing.xl', DsBrandParseExceptionType.unsupportedFormat),
      ]);
    });

    test('When font families and weights use names and keywords, '
        'Then they are converted', () {
      // Given
      BrandFileFixtures.setValue(file, 'font.family.base', [
        'Inter',
        'Roboto',
        'sans-serif',
      ]);
      final label = BrandFileFixtures.node(file, 'typography.label');
      (label[r'$value']! as Map<String, Object?>)['fontWeight'] = 'semi-bold';
      final display = BrandFileFixtures.node(file, 'typography.display');
      (display[r'$value']! as Map<String, Object?>)['fontWeight'] = 950;

      // When
      final typography = _brand(DsBrandParser.parseMap(file)).typography;

      // Then
      expect(typography.body.fontFamily, 'Inter');
      expect(typography.body.fontFamilyFallback, ['Roboto']);
      expect(typography.label.fontWeight, FontWeight.w600);
      expect(typography.display.fontWeight, FontWeight.w900);
    });

    test(
      'When a text style misses parts, Then each missing part is reported',
      () {
        // Given
        final body = BrandFileFixtures.node(file, 'typography.body');
        (body[r'$value']! as Map<String, Object?>)
          ..remove('lineHeight')
          ..remove('letterSpacing');

        // When
        final result = DsBrandParser.parseMap(file);

        // Then
        expect(_problems(result), [
          (
            'typography.body.letterSpacing',
            DsBrandParseExceptionType.invalidValue,
          ),
          (
            'typography.body.lineHeight',
            DsBrandParseExceptionType.invalidValue,
          ),
        ]);
      },
    );
  });

  group('Given content the design system does not use', () {
    test('When the file has extra tokens, even broken ones, '
        'Then they are ignored', () {
      // Given
      file['shadow'] = {
        r'$type': 'shadow',
        'card': {r'$value': 'not a shadow'},
      };
      BrandFileFixtures.node(file, 'spacing')['huge'] = {
        r'$value': '{does.not.exist}',
      };
      BrandFileFixtures.node(file, 'color')['bad.name'] = {r'$value': 1};

      // When
      final result = DsBrandParser.parseMap(file);

      // Then
      expect(_brand(result), DsBrand.whiteLabel);
    });
  });

  group('Given two equivalent files', () {
    test('When both are parsed, Then the brands are equal', () {
      // Given
      final other = BrandFileFixtures.whiteLabel();
      BrandFileFixtures.setValue(other, 'color.brand.600', {
        'colorSpace': 'srgb',
        'components': [0x1F / 255, 0x5F / 255, 0xD1 / 255],
      });

      // When
      final a = _brand(DsBrandParser.parseMap(file));
      final b = _brand(DsBrandParser.parseJson(jsonEncode(other)));

      // Then
      expect(a, b);
    });
  });

  group('Given input that is not a brand file at all', () {
    for (final json in ['', '[]', 'null', '{', '"text"', '{"color": 5}']) {
      test('When "$json" is parsed, Then it fails without throwing', () {
        // Given / When
        final result = DsBrandParser.parseJson(json);

        // Then
        expect(result, isA<DsBrandParseFailure>());
      });
    }
  });

  group('Given a file with private text and a problem', () {
    test(
      'When the report is read, Then no message repeats the file contents',
      () {
        // Given
        file[r'$description'] = 'PRIVATE-NOTE';
        BrandFileFixtures.setValue(file, 'opacity.pressed', 'PRIVATE-VALUE');
        BrandFileFixtures.remove(file, 'spacing.md');

        // When
        final failure = DsBrandParser.parseMap(file) as DsBrandParseFailure;

        // Then
        final text = failure.exceptions.join('\n');
        expect(text, isNot(contains('PRIVATE-NOTE')));
        expect(failure.exceptions, hasLength(2));
      },
    );
  });
}
