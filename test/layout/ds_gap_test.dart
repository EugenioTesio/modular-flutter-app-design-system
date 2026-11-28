// Feature: DsGap leaves a square gap of one spacing step of the nearest
// brand, so screens never need literal spacing values.
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/ds_test_brands.dart';

void main() {
  group('Given a gap of the md step', () {
    testWidgets('When it is shown under the white label, '
        'Then it is 16 by 16', (tester) async {
      // Given
      const gap = DsGap(DsSpacingStep.md);

      // When
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: const Center(child: gap),
        ),
      );

      // Then
      expect(tester.getSize(find.byType(DsGap)), const Size(16, 16));
    });

    testWidgets('When it is shown under a nested brand with wider spacing, '
        'Then it follows that brand', (tester) async {
      // Given
      final brand = DsTestBrands.variant(spacing: DsTestBrands.wideSpacing);

      // When
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: Theme(
            data: DsTheme.light(brand: brand),
            child: const Center(child: DsGap(DsSpacingStep.md)),
          ),
        ),
      );

      // Then
      expect(tester.getSize(find.byType(DsGap)), const Size(20, 20));
    });
  });
}
