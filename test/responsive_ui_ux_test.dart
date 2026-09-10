import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/app.dart';
import 'package:matriks/core/theme/app_theme.dart';
import 'package:matriks/core/widgets/custom_numpad.dart';
import 'package:matriks/features/step_player/widgets/matrix_cell_widget.dart';
import 'package:matriks/features/step_player/widgets/cell_calculation_sheet.dart';
import 'package:matrix_engine/matrix_engine.dart';

void main() {
  group('CustomNumpad Polish & Layout Tests', () {
    testWidgets(
      'CustomNumpad renders balanced 5-key bottom row and fires callbacks',
      (tester) async {
        String entered = '';
        bool nextCellTapped = false;
        bool cleared = false;
        bool backspaceTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: CustomNumpad(
                keyHeight: 40.0,
                onKeyPressed: (val) => entered += val,
                onBackspace: () => backspaceTapped = true,
                onClear: () => cleared = true,
                onNextCell: () => nextCellTapped = true,
                onPrevCell: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify all digits exist and each digit 0-9 is present exactly once (no duplicate zero)
        for (int i = 0; i <= 9; i++) {
          expect(find.text('$i'), findsOneWidget);
        }

        // Verify custom action keys exist
        expect(find.text('C'), findsOneWidget);
        expect(find.text('.'), findsOneWidget);
        expect(find.text('±'), findsOneWidget);
        expect(find.byIcon(Icons.keyboard_tab_rounded), findsOneWidget);
        expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);

        // Tap '5'
        await tester.tap(find.text('5'));
        expect(entered, '5');

        // Tap '±' (which inputs '-')
        await tester.tap(find.text('±'));
        expect(entered, '5-');

        // Tap backspace
        await tester.tap(find.byIcon(Icons.backspace_outlined));
        expect(backspaceTapped, isTrue);

        // Tap tab/next cell icon
        await tester.tap(find.byIcon(Icons.keyboard_tab_rounded));
        expect(nextCellTapped, isTrue);

        // Tap 'C' (clear)
        await tester.tap(find.text('C'));
        expect(cleared, isTrue);
      },
    );
  });

  group('MatrixInputScreen Responsiveness Flow Tests', () {
    testWidgets(
      'MatrixInputScreen renders without overflow on narrow 320x568 mobile viewport',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const MatrixEducatorApp());
        await tester.pumpAndSettle();

        // Tap Gauss-Jordan Elimination (RREF) topic (first topic, at top of screen)
        final rrefTopic = find.text('Gauss-Jordan Elimination (RREF)');
        await tester.scrollUntilVisible(
          rrefTopic,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(rrefTopic, findsOneWidget);
        await tester.tap(rrefTopic);
        await tester.pumpAndSettle();

        // Verify basic elements render without overflow
        expect(find.text('Solve'), findsOneWidget);
        expect(find.text('Size: '), findsOneWidget);
        expect(find.byType(CustomNumpad), findsOneWidget);
      },
    );

    testWidgets(
      'MatrixInputScreen keeps controls reachable in scrollable landscape (800x380) without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(800, 380);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const MatrixEducatorApp());
        await tester.pumpAndSettle();

        // Tap Gauss-Jordan topic
        final rrefTopic = find.text('Gauss-Jordan Elimination (RREF)');
        await tester.scrollUntilVisible(
          rrefTopic,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(rrefTopic, findsOneWidget);
        await tester.tap(rrefTopic);
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('Solve'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        // Controls remain reachable in the compact landscape layout.
        expect(find.text('Solve'), findsOneWidget);
        expect(find.byType(CustomNumpad), findsOneWidget);
      },
    );
  });

  group('StepPlayer & Calculation Sheet Accessibility & Polish Tests', () {
    testWidgets('MatrixCellWidget provides rich accessibility semantics', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatrixCellWidget(
              value: Rational(1, 2),
              highlight: const CellHighlight(
                row: 0,
                col: 0,
                type: HighlightType.pivot,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find cell semantics
      final semanticsFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            (widget.properties.label?.contains('Matrix cell, value') ??
                false) &&
            (widget.properties.label?.contains('pivot') ?? false),
      );
      expect(semanticsFinder, findsOneWidget);
    });

    testWidgets(
      'CellCalculationSheet renders without overflow on 320px viewport',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final calc = SubCalculation(
          targetRow: 1,
          targetCol: 2,
          formulaLatex: r'R_2 = R_2 - \frac{3}{4} R_1',
          result: Rational(-1, 8),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: Builder(
                builder: (ctx) => Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: ctx,
                        builder: (_) => CellCalculationSheet(
                          calculation: calc,
                          onClose: () => Navigator.of(ctx).pop(),
                        ),
                      );
                    },
                    child: const Text('Open Sheet'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        // Verify calculation sheet opened and shows close icon button
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      },
    );
  });
}
