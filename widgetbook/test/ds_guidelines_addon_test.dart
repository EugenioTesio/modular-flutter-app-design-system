// Feature: The Widgetbook's Guidelines toggle turns the developer guidelines
// overlay on and off for the use case, and starts off.
import 'package:design_system/design_system.dart';
import 'package:design_system_widgetbook/addons/ds_guidelines_addon.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  group('Given the guidelines addon', () {
    test('When its field is read, Then it is a "guidelines" toggle that '
        'starts off', () {
      // Given
      final addon = DsGuidelinesAddon();

      // When
      final field = addon.fields.single;

      // Then
      expect(addon.name, 'Guidelines');
      expect(field, isA<BooleanField>());
      expect(field.name, 'guidelines');
      expect(field.initialValue, isFalse);
      expect(addon.valueFromQueryGroup(const {}), isFalse);
      expect(addon.valueFromQueryGroup(const {'guidelines': 'true'}), isTrue);
    });

    for (final setting in [true, false]) {
      testWidgets('When the toggle is ${setting ? 'on' : 'off'}, '
          'Then the use case sits in DsGuidelines(enabled: $setting)', (
        tester,
      ) async {
        // Given
        final addon = DsGuidelinesAddon();
        late bool enabled;
        final useCase = Builder(
          builder: (context) {
            enabled = DsGuidelines.isEnabledOf(context);
            return const SizedBox();
          },
        );

        // When
        await tester.pumpWidget(
          Builder(
            builder: (context) => addon.buildUseCase(context, useCase, setting),
          ),
        );

        // Then
        expect(enabled, setting);
      });
    }
  });
}
