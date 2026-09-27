import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/core/widgets/math_text.dart';
import 'package:matriks/features/settings/cubit/settings_state.dart';
import 'package:matriks/features/step_player/cubit/player_cubit.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/features/step_player/widgets/matrix_cell_widget.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'product_accessibility_test.dart' show host;

void main() {
  group('Fractions inside a TeX matrix', () {
    test('are set in display style; integer matrices are unchanged', () {
      const vector =
          r'\mathbf{x} = \begin{pmatrix}\frac{27}{13} \\ -\frac{23}{65}\end{pmatrix}';
      expect(
        displayStyleMatrixCells(vector),
        r'\mathbf{x} = \begin{pmatrix}\rule[-0.95em]{0pt}{2.6em}\displaystyle \frac{27}{13} \\'
        r'\rule[-0.95em]{0pt}{2.6em}\displaystyle  -\frac{23}{65}\end{pmatrix}',
      );
      const integers = r'L = \begin{pmatrix}1 & 0 \\ 2 & 1\end{pmatrix}';
      expect(displayStyleMatrixCells(integers), integers);
      expect(displayStyleMatrixCells(r'\frac{1}{2}'), r'\frac{1}{2}');
    });

    testWidgets('render full size without a parse error', (tester) async {
      const vector =
          r'\begin{pmatrix}\frac{27}{13} \\ -\frac{23}{65} \\ -\frac{17}{65}\end{pmatrix}';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const MathText(vector, fontSize: 20),
                // What the vector looked like before: text-style fractions.
                Math.tex(vector, textStyle: TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(vector), findsNothing);
      final display = tester.getSize(find.byType(MathText));
      final text = tester.getSize(find.byType(Math).last);
      expect(display.height, greaterThan(text.height * 1.3));
    });
  });

  testWidgets(
    'On a phone the last inverse step opens on the inverse, not on I',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final solution = InverseSolver.solve(
        Matrix.fromInts([
          [2, 1, 0, 0, 1],
          [1, 3, 1, 0, 0],
          [0, 1, 4, 1, 0],
          [0, 0, 1, 5, 1],
          [1, 0, 0, 1, 6],
        ]),
      );
      await tester.pumpWidget(
        host(StepPlayerScreen(solution: solution, topicTitle: 'Inverse')),
      );
      await tester.pumpAndSettle();
      final cubit = tester
          .element(find.byType(MatrixDisplayGrid))
          .read<PlayerCubit>();
      cubit.setMode(SolutionMode.steps);
      cubit.jumpToStep(0);
      await tester.pumpAndSettle();
      // Scrolled all the way to I, as a learner might leave it; the last
      // step must bring A inverse into view by itself.
      tester
          .widget<SingleChildScrollView>(
            find.byKey(const ValueKey('matrix-viewport')),
          )
          .controller!
          .jumpTo(0);
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byType(MatrixCellWidget).first).left,
        greaterThanOrEqualTo(0),
      );
      cubit.jumpToStep(solution.steps.length - 1);
      await tester.pumpAndSettle();
      final step = solution.steps.last;
      final first = step.highlights.reduce((a, b) => a.col <= b.col ? a : b);
      final index = first.row * step.matrixAfter.cols + first.col;
      final cell = find.byType(MatrixCellWidget).at(index);
      final rect = tester.getRect(cell);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(390));
    },
  );

  testWidgets('A cell badge never covers a value as wide as the cell', (
    tester,
  ) async {
    for (final zero in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 72,
                height: 64,
                child: MatrixCellWidget(
                  value: zero ? Rational.zero : Rational(-2553, 37),
                  valueBefore: zero ? Rational(5) : null,
                  fontSize: 22,
                  isZeroResult: zero,
                  highlight: const CellHighlight(
                    row: 0,
                    col: 0,
                    type: HighlightType.target,
                    badgeText: '≠0',
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Test fonts draw the fraction far smaller than KaTeX does, so the
      // overlap itself cannot show here; the placement can. The badge sits
      // on the cell's corner, above its content box, not inside it.
      final cell = tester.getRect(
        find
            .descendant(
              of: find.byType(MatrixCellWidget),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      final badge = tester.getRect(
        find
            .ancestor(
              of: find.text(zero ? '0' : '≠0'),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(badge.top, lessThan(cell.top), reason: '$badge in $cell');
      expect(badge.right, greaterThan(cell.right), reason: '$badge in $cell');
    }
  });

  testWidgets('A row wider than the phone opens centred on its pivot', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final solution = GaussJordanSolver.solve(
      // Upper triangular, so REF only normalises rows: entries such as
      // 3/4000 make each cell wide enough that a row of five no longer fits
      // a phone, while one cell still does.
      Matrix.fromInts([
        [1000, 1, 2, 3, 4],
        [0, 2000, 5, 6, 7],
        [0, 0, 3000, 8, 9],
        [0, 0, 0, 4000, 1],
        [0, 0, 0, 0, 5000],
      ]),
      const EliminationOptions(toRref: false),
    );
    final index = solution.steps.lastIndexWhere(
      (step) => step.highlights.any(
        (h) => h.type == HighlightType.pivot && h.col == 4,
      ),
    );
    expect(index, isNonNegative);
    await tester.pumpWidget(
      host(StepPlayerScreen(solution: solution, topicTitle: 'REF')),
    );
    await tester.pumpAndSettle();
    final cubit = tester
        .element(find.byType(MatrixDisplayGrid))
        .read<PlayerCubit>();
    cubit.setMode(SolutionMode.steps);
    cubit.jumpToStep(0);
    await tester.pumpAndSettle();
    tester
        .widget<SingleChildScrollView>(
          find.byKey(const ValueKey('matrix-viewport')),
        )
        .controller!
        .jumpTo(0);
    await tester.pumpAndSettle();
    cubit.jumpToStep(index);
    await tester.pumpAndSettle();
    final step = solution.steps[index];
    final pivot = step.highlights.firstWhere(
      (h) => h.type == HighlightType.pivot,
    );
    // The row really is wider than the screen.
    final first = tester.getRect(
      find.byType(MatrixCellWidget).at(pivot.row * 5),
    );
    final last = tester.getRect(
      find.byType(MatrixCellWidget).at(pivot.row * 5 + 4),
    );
    expect(last.right - first.left, greaterThan(390));
    final rect = tester.getRect(
      find.byType(MatrixCellWidget).at(pivot.row * 5 + pivot.col),
    );
    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.right, lessThanOrEqualTo(390));
  });
}
