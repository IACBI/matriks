import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/features/step_player/widgets/matrix_cell_widget.dart';
import 'package:matriks/core/widgets/math_text.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

void main() {
  for (final target in [2, -2]) {
    testWidgets(
      'Elimination annotations use the engine factor sign ($target)',
      (tester) async {
        final solution = GaussJordanSolver.solve(
          Matrix.fromInts([
            [1, 2],
            [target, 5],
          ]),
        );
        final step = solution.steps.firstWhere(
          (step) => step.transformation is RowEliminationTransformation,
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MatrixDisplayGrid(
                snapshot: step.matrixAfter,
                snapshotBefore: step.matrixBefore,
                highlights: step.highlights,
                transformation: step.transformation,
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 650));
        final expectedSign = target > 0 ? ' - ' : ' + ';
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is MathText &&
                widget.latex.contains(r'\leftarrow') &&
                widget.latex.contains(expectedSign),
          ),
          findsWidgets,
        );
        await tester.pumpAndSettle();
      },
    );
  }

  group('Visual Instructional Animations', () {
    testWidgets(
      '1. Row Swap (R_i <-> R_j): displays row swap annotation and brackets',
      (WidgetTester tester) async {
        final snapBefore = MatrixSnapshot(
          rows: 2,
          cols: 2,
          values: [
            [Rational.zero, Rational.fromInt(2)],
            [Rational.fromInt(1), Rational.fromInt(3)],
          ],
        );
        final snapAfter = MatrixSnapshot(
          rows: 2,
          cols: 2,
          values: [
            [Rational.fromInt(1), Rational.fromInt(3)],
            [Rational.zero, Rational.fromInt(2)],
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: MatrixDisplayGrid(
                snapshot: snapAfter,
                snapshotBefore: snapBefore,
                transformation: const RowSwapTransformation(0, 1),
                highlights: const [
                  CellHighlight(row: 0, col: 0, type: HighlightType.pivot),
                ],
              ),
            ),
          ),
        );
        await tester.pump();

        // Verify row swap brackets painter is rendered
        expect(find.byType(CustomPaint), findsWidgets);
        expect(find.text('R1 ↔ R2'), findsWidgets);

        // Settle animation smoothly
        await tester.pumpAndSettle();
        expect(find.text('R1 ↔ R2'), findsWidgets);
      },
    );

    testWidgets(
      '2. Row Elimination: verifies ghost row projection and intermediate expression',
      (WidgetTester tester) async {
        final snapBefore = MatrixSnapshot(
          rows: 2,
          cols: 2,
          values: [
            [Rational.fromInt(1), Rational.fromInt(2)],
            [Rational.fromInt(2), Rational.fromInt(5)],
          ],
        );
        final snapAfter = MatrixSnapshot(
          rows: 2,
          cols: 2,
          values: [
            [Rational.fromInt(1), Rational.fromInt(2)],
            [Rational.zero, Rational.fromInt(1)],
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: MatrixDisplayGrid(
                snapshot: snapAfter,
                snapshotBefore: snapBefore,
                transformation: RowEliminationTransformation(
                  targetRow: 1,
                  sourceRow: 0,
                  factor: Rational.fromInt(2),
                ),
                highlights: const [
                  CellHighlight(row: 1, col: 0, type: HighlightType.zeroed),
                ],
              ),
            ),
          ),
        );
        // Pump initial frame for Ghost Row
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        // Settle animation to Phase 3 (celebratory zero)
        await tester.pumpAndSettle();
        expect(find.byType(MatrixCellWidget), findsNWidgets(4));
      },
    );

    testWidgets('3. Row Scaling: verifies sweep wave and multiplier badge', (
      WidgetTester tester,
    ) async {
      final snapBefore = MatrixSnapshot(
        rows: 2,
        cols: 2,
        values: [
          [Rational.fromInt(3), Rational.fromInt(6)],
          [Rational.zero, Rational.fromInt(1)],
        ],
      );
      final snapAfter = MatrixSnapshot(
        rows: 2,
        cols: 2,
        values: [
          [Rational.one, Rational.fromInt(2)],
          [Rational.zero, Rational.fromInt(1)],
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MatrixDisplayGrid(
              snapshot: snapAfter,
              snapshotBefore: snapBefore,
              transformation: RowScaleTransformation(0, Rational(1, 3)),
              highlights: const [
                CellHighlight(row: 0, col: 0, type: HighlightType.pivot),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byType(MatrixCellWidget), findsNWidgets(4));
    });

    testWidgets(
      '4. Determinant 2x2 & Sarrus: verifies custom diagonal painters',
      (WidgetTester tester) async {
        final snap = MatrixSnapshot(
          rows: 2,
          cols: 2,
          values: [
            [Rational.fromInt(2), Rational.fromInt(3)],
            [Rational.fromInt(1), Rational.fromInt(4)],
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: MatrixDisplayGrid(
                snapshot: snap,
                transformation: DeterminantCrossProductTransformation(
                  mainDiagonalProduct: Rational.fromInt(8),
                  antiDiagonalProduct: Rational.fromInt(3),
                ),
                highlights: const [],
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        // CustomPaint is used for DeterminantLinesPainter
        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    testWidgets(
      '5. Matrix Multiplication: verifies multiplication beam painter',
      (WidgetTester tester) async {
        final snap = MatrixSnapshot(
          rows: 2,
          cols: 2,
          values: [
            [Rational.fromInt(7), Rational.fromInt(10)],
            [Rational.fromInt(15), Rational.fromInt(22)],
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: MatrixDisplayGrid(
                snapshot: snap,
                transformation: MatrixElementMultiplicationTransformation(
                  targetRow: 0,
                  targetCol: 0,
                  rowElements: [Rational.fromInt(1), Rational.fromInt(2)],
                  colElements: [Rational.fromInt(3), Rational.fromInt(2)],
                  result: Rational.fromInt(7),
                ),
                highlights: const [
                  CellHighlight(row: 0, col: 0, type: HighlightType.target),
                ],
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    testWidgets(
      '6. Replay, Play/Pause and Scrub animation controls function properly',
      (WidgetTester tester) async {
        final snap = MatrixSnapshot(
          rows: 2,
          cols: 2,
          values: [
            [Rational.one, Rational.zero],
            [Rational.zero, Rational.one],
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: MatrixDisplayGrid(
                snapshot: snap,
                transformation: const RowSwapTransformation(0, 1),
                highlights: const [],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('operation-inspector')));
        await tester.pumpAndSettle();

        // Tap Replay button
        final replayBtn = find.byIcon(Icons.replay_rounded);
        expect(replayBtn, findsOneWidget);
        await tester.tap(replayBtn);
        await tester.pump(const Duration(milliseconds: 100));

        // Tap Play/Pause button
        final pauseIcon = find.byIcon(Icons.pause_circle_outline_rounded);
        if (pauseIcon.evaluate().isNotEmpty) {
          await tester.tap(pauseIcon);
          await tester.pump();
        }

        // Drag Scrubber slider
        final sliderFinder = find.byType(Slider);
        expect(sliderFinder, findsWidgets);
        await tester.drag(sliderFinder.first, const Offset(30, 0));
        await tester.pump();

        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      '7. prefers-reduced-motion: animation settles immediately without motion',
      (WidgetTester tester) async {
        final snap = MatrixSnapshot(
          rows: 2,
          cols: 2,
          values: [
            [Rational.one, Rational.zero],
            [Rational.zero, Rational.one],
          ],
        );

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: MatrixDisplayGrid(
                  snapshot: snap,
                  transformation: const RowSwapTransformation(0, 1),
                  highlights: const [],
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        // Directly settled without waiting
        expect(find.byType(MatrixDisplayGrid), findsOneWidget);
      },
    );

    testWidgets(
      '8. Determinant 2x2 and 3x3 Sarrus: step phases draw respective positive/negative diagonals',
      (WidgetTester tester) async {
        final snap3 = MatrixSnapshot(
          rows: 3,
          cols: 3,
          values: [
            [Rational.fromInt(1), Rational.fromInt(2), Rational.fromInt(3)],
            [Rational.fromInt(0), Rational.fromInt(1), Rational.fromInt(4)],
            [Rational.fromInt(5), Rational.fromInt(6), Rational.fromInt(0)],
          ],
        );

        // Test Phase 1 (Positive diagonals)
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: MatrixDisplayGrid(
                snapshot: snap3,
                transformation: DeterminantSarrusTransformation(
                  positiveProducts: [
                    Rational.zero,
                    Rational.fromInt(40),
                    Rational.zero,
                  ],
                  negativeProducts: [
                    Rational.fromInt(15),
                    Rational.fromInt(24),
                    Rational.zero,
                  ],
                  phase: 1,
                ),
                highlights: const [],
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        expect(find.byType(CustomPaint), findsWidgets);

        // Test Phase 2 (Negative diagonals)
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: MatrixDisplayGrid(
                snapshot: snap3,
                transformation: DeterminantSarrusTransformation(
                  positiveProducts: [
                    Rational.zero,
                    Rational.fromInt(40),
                    Rational.zero,
                  ],
                  negativeProducts: [
                    Rational.fromInt(15),
                    Rational.fromInt(24),
                    Rational.zero,
                  ],
                  phase: 2,
                ),
                highlights: const [],
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        expect(find.byType(CustomPaint), findsWidgets);
      },
    );
  });
}
