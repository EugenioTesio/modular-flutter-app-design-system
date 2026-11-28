// Feature: Every component documents its lifecycle status, and every
// deprecated element names its replacement and the release that removes it,
// at least one minor release away.
import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final libraryFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();
  final componentFiles = libraryFiles
      .where((file) => file.path.startsWith('lib/src/components/'))
      .toList();
  final infoByName = {
    for (final info in DsComponentCatalog.all) info.name: info,
  };

  group('Given the documentation of every component', () {
    test('When its **Status** line is read, Then it matches info.status', () {
      // Given
      final mismatches = <String>[];
      var checked = 0;

      // When
      for (final file in componentFiles) {
        final source = file.readAsStringSync();
        for (final match in _LifecycleSource.componentClass.allMatches(
          source,
        )) {
          final name = match.group(1)!;
          final status = _LifecycleSource.documentedStatus(
            source.substring(0, match.start),
          );
          final info = infoByName[name];
          checked++;
          if (info == null || status != info.status.name) {
            mismatches.add('$name: documented $status, info ${info?.status}');
          }
        }
      }

      // Then
      expect(checked, DsComponentCatalog.all.length);
      expect(mismatches, isEmpty);
    });

    test('When a component is deprecated, Then its @Deprecated message names '
        'the same removal release as its info', () {
      // Given
      final deprecated = DsComponentCatalog.all.where(
        (info) => info.status == DsComponentStatus.deprecated,
      );
      final mismatches = <String>[];

      // When
      for (final info in deprecated) {
        final file = componentFiles.singleWhere(
          (file) =>
              file.readAsStringSync().contains('final class ${info.name} '),
        );
        final declaration = RegExp(
          "@Deprecated\\('Use [^']+\\. Removed in "
          '${RegExp.escape(info.removedIn ?? '?')}'
          r"\.'\)\s*final class "
          '${info.name} ',
        );
        if (!declaration.hasMatch(file.readAsStringSync())) {
          mismatches.add(info.name);
        }
      }

      // Then
      expect(mismatches, isEmpty);
    });
  });

  group('Given every deprecated element in lib/', () {
    test('When its @Deprecated message is read, Then it reads "Use <X>. '
        'Removed in <version>." and the version is a later minor release', () {
      // Given
      final current = _LifecycleSource.packageVersion();
      final problems = <String>[];

      // When
      for (final file in libraryFiles) {
        final source = file.readAsStringSync();
        for (final annotation
            in _LifecycleSource.deprecatedAnnotation.allMatches(source)) {
          final message = _LifecycleSource.deprecationMessage.firstMatch(
            annotation.group(0)!,
          );
          if (message == null) {
            problems.add('${file.path}: ${annotation.group(0)}');
            continue;
          }
          final removedIn = message.group(2)!.split('.').map(int.parse);
          final (major, minor) = (removedIn.first, removedIn.elementAt(1));
          final isLaterMinor =
              major > current.$1 || (major == current.$1 && minor > current.$2);
          if (!isLaterMinor) {
            problems.add(
              '${file.path}: removed too soon (${message.group(2)})',
            );
          }
        }
      }

      // Then
      expect(problems, isEmpty);
    });
  });

  group('Given the 0.1.0 brand name DsBrand.standard', () {
    test('When it is read, Then it is deprecated in favor of '
        'DsBrand.whiteLabel and removed in 0.3.0', () {
      // Given
      final source = File('lib/src/brand/ds_brand.dart').readAsStringSync();

      // When
      // ignore: deprecated_member_use_from_same_package
      const standard = DsBrand.standard;

      // Then
      expect(standard, same(DsBrand.whiteLabel));
      expect(
        source,
        matches(
          RegExp(
            r"@Deprecated\('Use DsBrand\.whiteLabel\. Removed in 0\.3\.0\.'\)"
            r'\s*static const DsBrand standard = whiteLabel;',
          ),
        ),
      );
    });
  });
}

/// Source patterns the lifecycle tests read.
abstract final class _LifecycleSource {
  /// A public component class declaration; group 1 is its name.
  static final RegExp componentClass = RegExp(
    r'^final class (Ds\w+) extends (?:StatelessWidget|StatefulWidget)',
    multiLine: true,
  );

  /// A whole `@Deprecated(...)` annotation, possibly over several lines.
  static final RegExp deprecatedAnnotation = RegExp(
    r'@Deprecated\((?:[^()]|\([^()]*\))*\)',
  );

  /// The required message; group 1 is the replacement, group 2 the version.
  static final RegExp deprecationMessage = RegExp(
    r"^@Deprecated\(\s*'Use ([^']+)\. Removed in (\d+\.\d+\.\d+)\.'\s*\)$",
  );

  /// Returns the status named by the `**Status**:` line of the doc comment
  /// that ends [before], or null when there is none.
  static String? documentedStatus(String before) {
    final docLines = before
        .trimRight()
        .split('\n')
        .reversed
        .takeWhile((line) => line.trimLeft().startsWith('///'))
        .toList();
    for (final line in docLines) {
      final match = RegExp(r'\*\*Status\*\*: (\w+)\.').firstMatch(line);
      if (match != null) return match.group(1);
    }
    return null;
  }

  /// Returns the major and minor parts of the version in `pubspec.yaml`.
  static (int, int) packageVersion() {
    final version = RegExp(
      r'^version: (\d+)\.(\d+)\.\d+',
      multiLine: true,
    ).firstMatch(File('pubspec.yaml').readAsStringSync())!;
    return (int.parse(version.group(1)!), int.parse(version.group(2)!));
  }
}
