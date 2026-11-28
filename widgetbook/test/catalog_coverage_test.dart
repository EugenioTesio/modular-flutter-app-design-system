// Feature: The Widgetbook covers every public component, and a broken brand
// file never stops it.
import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:design_system_widgetbook/addons/ds_brand_addon.dart';
import 'package:design_system_widgetbook/brand_files/brand_file_loader.dart';
import 'package:design_system_widgetbook/brand_files/brand_file_use_cases.dart';
import 'package:design_system_widgetbook/catalog/catalog_directory.dart';
import 'package:design_system_widgetbook/use_cases/component_use_cases.dart';
import 'package:design_system_widgetbook/widgetbook_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetbook/widgetbook.dart';

Map<String, String> _repositoryFiles() => {
  for (final file in Directory('brands').listSync().whereType<File>())
    if (file.path.endsWith('.json'))
      file.uri.pathSegments.last: file.readAsStringSync(),
};

void main() {
  group('Given the Widgetbook directory', () {
    final brands = BrandFileLoader.fromContents(_repositoryFiles());
    final directories = CatalogDirectory.build(
      useCases: ComponentUseCases.all,
      brands: brands,
    );

    test('When it is compared with the component catalog, '
        'Then every component has a node with at least one use case', () {
      // Given
      const catalog = DsComponentCatalog.all;

      // When
      final missing = CatalogDirectory.missingComponents(directories);

      // Then
      expect(catalog, isNotEmpty);
      expect(missing, isEmpty);
    });

    test('When a component has no use cases, '
        'Then the check names that component', () {
      // Given
      final incomplete = {...ComponentUseCases.all}..remove('DsCard');

      // When
      final missing = CatalogDirectory.missingComponents(
        CatalogDirectory.build(useCases: incomplete, brands: brands),
      );

      // Then
      expect(missing, ['DsCard']);
    });

    test('When components are listed, '
        'Then each is grouped by level and labelled with its status', () {
      // Given
      final categories = directories.whereType<WidgetbookCategory>();

      // When
      final atoms = categories.firstWhere((node) => node.name == 'Atoms');

      // Then
      expect(
        atoms.children!.map((node) => node.name),
        containsAll(['DsButton · stable', 'DsTextField · stable']),
      );
    });
  });

  group('Given a brands folder with one invalid file', () {
    final files = {..._repositoryFiles(), 'broken.json': '{"color": '};

    test('When the Widgetbook loads it, '
        'Then the valid brands are listed and the invalid file is kept '
        'with its problems', () {
      // Given / When
      final brands = BrandFileLoader.fromContents(files);

      // Then
      expect(brands.selectable.map((brand) => brand.id), [
        'white_label',
        'forest',
      ]);
      final broken = brands.files.singleWhere(
        (file) => file.fileName == 'broken.json',
      );
      expect(broken.brand, isNull);
      expect(
        broken.exceptions.single.type,
        DsBrandParseExceptionType.malformedFile,
      );
    });

    test('When the directory is built, '
        'Then the invalid file appears only under Brand files', () {
      // Given
      final brands = BrandFileLoader.fromContents(files);

      // When
      final directories = CatalogDirectory.build(
        useCases: ComponentUseCases.all,
        brands: brands,
      );

      // Then
      final brandFiles = directories
          .whereType<WidgetbookCategory>()
          .singleWhere((node) => node.name == 'Brand files');
      expect(
        brandFiles.children!.map((node) => node.name),
        containsAll(['White label', 'Forest', '⚠ broken.json']),
      );
    });
  });

  group('Given a brands folder with one valid brand that fails the contrast '
      'gate', () {
    final files = {
      ..._repositoryFiles(),
      'pale_brand.json': File('../test/contrast/fixtures/pale_brand.json')
          .readAsStringSync(),
    };

    test('When the Widgetbook loads it, '
        'Then the brand is selectable and labelled with a warning', () {
      // Given
      final brands = BrandFileLoader.fromContents(files);

      // When
      final addon = DsBrandAddon(
        brands.selectable,
        failingContrast: brands.failingContrast,
      );

      // Then
      final pale = brands.selectable.singleWhere((brand) => brand.id == 'pale');
      expect(brands.failingContrast, {pale});
      expect(addon.label(pale), '⚠ Pale');
      expect(addon.label(DsBrand.whiteLabel), 'White label');
      final file = brands.files.singleWhere(
        (file) => file.fileName == 'pale_brand.json',
      );
      expect(file.contrast!.passed, isFalse);
    });

    testWidgets('When its Brand files page is shown, '
        'Then it lists every failing pair', (tester) async {
      // Given
      tester.view
        ..physicalSize = const Size(1200, 4000)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final brands = BrandFileLoader.fromContents(files);
      final file = brands.files.singleWhere(
        (file) => file.fileName == 'pale_brand.json',
      );
      final brandFiles =
          CatalogDirectory.build(
            useCases: ComponentUseCases.all,
            brands: brands,
          ).whereType<WidgetbookCategory>().singleWhere(
            (node) => node.name == 'Brand files',
          );

      // When
      final page = brandFiles.children!.singleWhere(
        (node) => node.name == '⚠ Pale',
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: Scaffold(
            body: BrandTokenPreview(
              brand: file.brand!,
              contrast: file.contrast,
            ),
          ),
        ),
      );

      // Then
      expect(page, isA<WidgetbookComponent>());
      for (final violation in file.contrast!.violations) {
        expect(find.textContaining(violation.toString()), findsOneWidget);
      }
    });
  });

  group('Given brand files that clash', () {
    test('When two files share an id, '
        'Then the second is invalid with a duplicate-id problem', () {
      // Given
      final forest = File('brands/sample_forest.json').readAsStringSync();
      final files = {'a_forest.json': forest, 'b_forest.json': forest};

      // When
      final brands = BrandFileLoader.fromContents(files);

      // Then
      expect(brands.selectable.map((brand) => brand.id), [
        'white_label',
        'forest',
      ]);
      final duplicate = brands.files.singleWhere(
        (file) => file.fileName == 'b_forest.json',
      );
      expect(duplicate.brand, isNull);
      expect(duplicate.exceptions.single.message, contains('duplicate id'));
    });

    test('When white_label.json no longer matches the built-in white label, '
        'Then the file is invalid and the built-in one is still listed', () {
      // Given
      final edited = File('brands/white_label.json')
          .readAsStringSync()
          .replaceFirst('"White label"', '"Renamed"');

      // When
      final brands = BrandFileLoader.fromContents({'white_label.json': edited});

      // Then
      expect(brands.selectable, [DsBrand.whiteLabel]);
      expect(brands.files.single.brand, isNull);
    });
  });

  group('Given the Widgetbook app', () {
    testWidgets('When it starts with the repository brands, '
        'Then it builds without errors', (tester) async {
      // Given
      tester.view
        ..physicalSize = const Size(1600, 1000)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final brands = BrandFileLoader.fromContents(_repositoryFiles());

      // When
      await tester.pumpWidget(DsWidgetbook(brands: brands));
      await tester.pumpAndSettle();

      // Then
      expect(tester.takeException(), isNull);
      expect(find.byType(Widgetbook), findsOneWidget);
    });
  });
}
