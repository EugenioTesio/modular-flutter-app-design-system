// Feature: Every public component declares its metadata, and the catalog
// lists all of them, so the Widgetbook, the overlay, and the agent read one
// source.
import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final componentFiles = Directory('lib/src/components')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();
  final classPattern = RegExp(
    r'^final class (Ds\w+) extends (?:StatelessWidget|StatefulWidget)',
    multiLine: true,
  );

  group('Given the component source files', () {
    test('When each public component class is read, '
        'Then it declares static const info named after itself', () {
      // Given
      final missing = <String>[];

      // When
      for (final file in componentFiles) {
        final source = file.readAsStringSync();
        for (final match in classPattern.allMatches(source)) {
          final name = match.group(1)!;
          final declaresInfo = RegExp(
            r'static const DsComponentInfo info = DsComponentInfo\(\s*'
            "name: '$name'",
          ).hasMatch(source);
          if (!declaresInfo) missing.add('${file.path}: $name');
        }
      }

      // Then
      expect(missing, isEmpty);
    });

    test('When the public components are listed, '
        'Then each one is exported and in the catalog', () {
      // Given
      final library = File('lib/design_system.dart').readAsStringSync();
      final catalogNames = DsComponentCatalog.all.map((info) => info.name);

      // When
      final names = [
        for (final file in componentFiles)
          for (final match in classPattern.allMatches(file.readAsStringSync()))
            (match.group(1)!, file.path.replaceFirst('lib/', '')),
      ];

      // Then
      expect(names.map((entry) => entry.$1), unorderedEquals(catalogNames));
      for (final (_, path) in names) {
        expect(library, contains("export '$path';"));
      }
    });
  });

  group('Given the catalog of the carried-over components', () {
    test('When it is read, Then it lists them in level order, all stable '
        'since 0.1.0', () {
      // Given
      const expected = {
        'DsButton': DsComponentLevel.atom,
        'DsTextField': DsComponentLevel.atom,
        'DsLoadingIndicator': DsComponentLevel.atom,
        'DsCard': DsComponentLevel.molecule,
        'DsListTile': DsComponentLevel.molecule,
        'DsInlineMessage': DsComponentLevel.molecule,
        'DsEmptyState': DsComponentLevel.molecule,
        'DsPageScaffold': DsComponentLevel.template,
      };

      // When
      final all = DsComponentCatalog.all;

      // Then
      expect({for (final info in all) info.name: info.level}, expected);
      final levels = all.map((info) => info.level.index).toList();
      expect(levels, [...levels]..sort());
      expect(
        all.every((info) => info.status == DsComponentStatus.stable),
        isTrue,
      );
      expect(all.every((info) => info.since == '0.1.0'), isTrue);
    });
  });

  group('Given component metadata', () {
    test('When a deprecated component names no removal version, '
        'Then an assertion fails', () {
      // Given
      const status = DsComponentStatus.deprecated;

      // When / Then
      expect(
        () => DsComponentInfo(
          name: 'DsOld',
          level: DsComponentLevel.atom,
          status: status,
          since: '0.1.0',
        ),
        throwsAssertionError,
      );
    });
  });
}
