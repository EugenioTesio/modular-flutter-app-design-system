// Feature: The developer guidelines overlay outlines components by atomic
// level, tints spacing gaps, never moves anything, and never shows in a
// release build.
import 'package:design_system/design_system.dart';
import 'package:design_system/src/guidelines/ds_guidelines_colors.dart';
import 'package:design_system/src/guidelines/ds_guidelines_frame.dart';
import 'package:design_system/src/guidelines/ds_guidelines_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/ds_component_cases.dart';

void main() {
  const skipWhenBuildEnabled = DsGuidelines.buildEnabled;

  group('Given the guidelines turned on with DsGuidelines(enabled: true)', () {
    for (final cases in DsComponentCases.all) {
      final info = cases.info;
      final color = DsGuidelinesColors.forLevel(info.level);
      for (final MapEntry(key: state, value: build) in cases.states.entries) {
        testWidgets('When ${info.name} is $state, Then it paints a dashed '
            'outline in the ${info.level.name} color', (tester) async {
          // Given
          final component = build();

          // When
          await _GuidelinesHarness.pumpCase(
            tester,
            component,
            guidelines: true,
          );

          // Then
          final frame = _GuidelinesHarness.ownFrame();
          expect(tester.widget<DsGuidelinesFrame>(frame).level, info.level);
          final painter = _GuidelinesHarness.outlineOf(tester, frame);
          expect(painter, isNotNull);
          final size = tester.getSize(frame);
          var segments = 0;
          expect(
            (Canvas canvas) => painter!.paint(canvas, size),
            paints..everything((method, arguments) {
              if (method != #drawPath) {
                throw 'drew $method instead of an outline segment';
              }
              final paint = arguments[1] as Paint;
              segments++;
              return paint.color.toARGB32() == color.toARGB32() &&
                  paint.style == PaintingStyle.stroke;
            }),
          );
          // A dashed outline has more segments than a rectangle has sides.
          expect(segments, greaterThan(4));
        });

        testWidgets('When ${info.name} is $state, Then every box keeps the '
            'size and position it has with the guidelines off', (tester) async {
          // Given
          await _GuidelinesHarness.pumpCase(tester, build(), guidelines: false);
          final layoutOff = _GuidelinesHarness.layoutOf(tester);

          // When
          await _GuidelinesHarness.pumpCase(tester, build(), guidelines: true);

          // Then
          expect(_GuidelinesHarness.layoutOf(tester), layoutOff);
        });
      }
    }

    testWidgets('When a DsGap renders, Then it is tinted and keeps its size', (
      tester,
    ) async {
      // Given
      const gap = DsGap(DsSpacingStep.lg);
      await _GuidelinesHarness.pumpCase(tester, gap, guidelines: false);
      final sizeOff = tester.getSize(find.byType(DsGap));

      // When
      await _GuidelinesHarness.pumpCase(tester, gap, guidelines: true);

      // Then
      final gapFinder = find.byType(DsGap);
      expect(tester.getSize(gapFinder), sizeOff);
      final tint = _GuidelinesHarness.tintOf(tester, gapFinder);
      expect(tint, isNotNull);
      expect(
        (Canvas canvas) => tint!.paint(canvas, sizeOff),
        paints..rect(
          rect: Offset.zero & sizeOff,
          color: DsGuidelinesColors.gapTint,
        ),
      );
    });

    testWidgets('When a component holds another, Then each is outlined in '
        'its own level color', (tester) async {
      // Given
      const emptyState = DsEmptyState(
        title: 'No transfers yet',
        actionLabel: 'New transfer',
        onAction: _GuidelinesHarness.noop,
      );

      // When
      await _GuidelinesHarness.pumpCase(tester, emptyState, guidelines: true);

      // Then
      final frames = tester
          .widgetList<DsGuidelinesFrame>(find.byType(DsGuidelinesFrame))
          .map((frame) => frame.level);
      expect(frames, [DsComponentLevel.molecule, DsComponentLevel.atom]);
    });
  });

  group('Given the guidelines left off', () {
    for (final cases in DsComponentCases.all) {
      final info = cases.info;
      final build = cases.states.values.first;
      testWidgets('When ${info.name} renders with no DsGuidelines, '
          'Then nothing is outlined and the frames add nothing to the tree', (
        tester,
      ) async {
        // Given
        final component = build();

        // When
        await _GuidelinesHarness.pumpCase(tester, component);

        // Then
        final frames = find.byType(DsGuidelinesFrame);
        expect(frames, findsWidgets);
        for (final frame in frames.evaluate()) {
          expect(
            _GuidelinesHarness.onlyChildOf(frame).widget,
            same((frame.widget as DsGuidelinesFrame).child),
          );
        }
      }, skip: skipWhenBuildEnabled);

      testWidgets('When ${info.name} renders under '
          'DsGuidelines(enabled: false), Then nothing is outlined', (
        tester,
      ) async {
        // Given
        final component = build();

        // When
        await _GuidelinesHarness.pumpCase(tester, component, guidelines: false);

        // Then
        expect(
          _GuidelinesHarness.outlineOf(tester, _GuidelinesHarness.ownFrame()),
          isNull,
        );
      }, skip: skipWhenBuildEnabled);
    }

    testWidgets('When a DsGap renders with no DsGuidelines, Then it is not '
        'tinted and builds only its box', (tester) async {
      // Given
      const gap = DsGap(DsSpacingStep.lg);

      // When
      await _GuidelinesHarness.pumpCase(tester, gap);

      // Then
      final gapElement = tester.element(find.byType(DsGap));
      expect(
        _GuidelinesHarness.onlyChildOf(gapElement).widget,
        isA<SizedBox>(),
      );
    }, skip: skipWhenBuildEnabled);

    testWidgets('When a DsGap renders under DsGuidelines(enabled: false), '
        'Then it is not tinted', (tester) async {
      // Given
      const gap = DsGap(DsSpacingStep.lg);

      // When
      await _GuidelinesHarness.pumpCase(tester, gap, guidelines: false);

      // Then
      expect(_GuidelinesHarness.tintOf(tester, find.byType(DsGap)), isNull);
    }, skip: skipWhenBuildEnabled);
  });

  group('Given where the guidelines are asked for', () {
    testWidgets('When there is no DsGuidelines above, Then they are off', (
      tester,
    ) async {
      // Given
      late bool enabled;

      // When
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            enabled = DsGuidelines.isEnabledOf(context);
            return const SizedBox();
          },
        ),
      );

      // Then
      expect(enabled, isFalse);
    }, skip: skipWhenBuildEnabled);

    testWidgets('When a nested DsGuidelines turns them off, '
        'Then the nearest one wins', (tester) async {
      // Given
      late bool outer;
      late bool inner;

      // When
      await tester.pumpWidget(
        DsGuidelines(
          enabled: true,
          child: Builder(
            builder: (context) {
              outer = DsGuidelines.isEnabledOf(context);
              return DsGuidelines(
                enabled: false,
                child: Builder(
                  builder: (context) {
                    inner = DsGuidelines.isEnabledOf(context);
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );

      // Then
      expect(outer, isTrue);
      expect(inner, isFalse);
    }, skip: skipWhenBuildEnabled);

    testWidgets('When DsGuidelines toggles, Then a component keeps its state', (
      tester,
    ) async {
      // Given
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      Widget app({required bool guidelines}) => MaterialApp(
        theme: DsTheme.light(),
        home: Scaffold(
          body: DsGuidelines(
            enabled: guidelines,
            child: const DsTextField(label: 'Email'),
          ),
        ),
      );
      await tester.pumpWidget(app(guidelines: false));
      await tester.enterText(find.byType(TextField), 'ada@example.com');
      final state = tester.state(find.byType(TextField));

      // When
      await tester.pumpWidget(app(guidelines: true));

      // Then
      expect(tester.state(find.byType(TextField)), same(state));
      expect(find.text('ada@example.com'), findsOneWidget);
    });

    testWidgets('When the app is built with DS_GUIDELINES=true, '
        'Then components are outlined with no DsGuidelines', (tester) async {
      // Given
      const component = DsButton(
        label: 'Continue',
        onPressed: _GuidelinesHarness.noop,
      );

      // When
      await _GuidelinesHarness.pumpCase(tester, component);

      // Then
      expect(
        _GuidelinesHarness.outlineOf(tester, _GuidelinesHarness.ownFrame()),
        isNotNull,
      );
    }, skip: !DsGuidelines.buildEnabled);
  });

  group('Given the rule that decides whether the overlay is active', () {
    test('When the build is a release build, Then the overlay is off '
        'whatever is asked for', () {
      // Given
      const releaseMode = true;

      // When
      final whenAsked = DsGuidelinesMode.isActive(
        releaseMode: releaseMode,
        requested: true,
      );
      final whenNotAsked = DsGuidelinesMode.isActive(
        releaseMode: releaseMode,
        requested: false,
      );

      // Then
      expect(whenAsked, isFalse);
      expect(whenNotAsked, isFalse);
    });

    test('When the build is a debug or profile build, '
        'Then the overlay follows what is asked for', () {
      // Given
      const releaseMode = false;

      // When
      final whenAsked = DsGuidelinesMode.isActive(
        releaseMode: releaseMode,
        requested: true,
      );
      final whenNotAsked = DsGuidelinesMode.isActive(
        releaseMode: releaseMode,
        requested: false,
      );

      // Then
      expect(whenAsked, isTrue);
      expect(whenNotAsked, isFalse);
    });
  });

  group('Given the level colors', () {
    test('When each level is looked up, Then the four colors are fixed and '
        'distinct, and the gap tint is translucent', () {
      // Given
      const levels = DsComponentLevel.values;

      // When
      final colors = {
        for (final level in levels) DsGuidelinesColors.forLevel(level),
      };

      // Then
      expect(colors, hasLength(levels.length));
      expect(
        DsGuidelinesColors.forLevel(DsComponentLevel.atom),
        DsGuidelinesColors.atom,
      );
      expect(
        DsGuidelinesColors.forLevel(DsComponentLevel.molecule),
        DsGuidelinesColors.molecule,
      );
      expect(
        DsGuidelinesColors.forLevel(DsComponentLevel.organism),
        DsGuidelinesColors.organism,
      );
      expect(
        DsGuidelinesColors.forLevel(DsComponentLevel.template),
        DsGuidelinesColors.template,
      );
      expect(DsGuidelinesColors.gapTint.a, inExclusiveRange(0, 1));
    });
  });
}

/// Helpers shared by the guidelines tests.
abstract final class _GuidelinesHarness {
  /// Pumps [child] alone in a new app, under `DsGuidelines(enabled:)` when
  /// [guidelines] is not null.
  static Future<void> pumpCase(
    WidgetTester tester,
    Widget child, {
    bool? guidelines,
  }) async {
    final content = guidelines == null
        ? child
        : DsGuidelines(enabled: guidelines, child: child);
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        theme: DsTheme.light(),
        themeAnimationStyle: AnimationStyle.noAnimation,
        home: Scaffold(body: Center(child: content)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Finds the component's own frame: the first one in tree order, because
  /// each component wraps its whole output in one.
  static Finder ownFrame() => find.byType(DsGuidelinesFrame).first;

  /// Returns the outline painter of [frame], or null when it paints none.
  static CustomPainter? outlineOf(WidgetTester tester, Finder frame) => tester
      .widget<CustomPaint>(
        find.descendant(of: frame, matching: find.byType(CustomPaint)).first,
      )
      .foregroundPainter;

  /// Returns the tint painter of [gap], or null when it paints none.
  static CustomPainter? tintOf(WidgetTester tester, Finder gap) => tester
      .widget<CustomPaint>(
        find.descendant(of: gap, matching: find.byType(CustomPaint)).first,
      )
      .painter;

  /// Returns every laid-out box in the app, with its size and position on
  /// screen, in tree order.
  static List<String> layoutOf(WidgetTester tester) {
    final boxes = <String>[];
    void visit(RenderObject object) {
      if (object is RenderBox && object.hasSize) {
        boxes.add(
          '${object.runtimeType} ${object.size} '
          '${object.localToGlobal(Offset.zero)}',
        );
      }
      object.visitChildren(visit);
    }

    tester.binding.renderViews.first.visitChildren(visit);
    return boxes;
  }

  /// Returns the single child element of [element].
  static Element onlyChildOf(Element element) {
    final children = <Element>[];
    element.visitChildElements(children.add);
    expect(children, hasLength(1));
    return children.single;
  }

  /// Does nothing; the callback of tappable test components.
  static void noop() {}
}
