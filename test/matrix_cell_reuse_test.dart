import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/features/step_player/widgets/matrix_cell_widget.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

Widget _grid(
  MatrixStep step, {
  int index = 0,
  void Function(int, int)? onCellTap,
  bool withCalculations = false,
}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SingleChildScrollView(
      child: MatrixDisplayGrid(
        staticStep: true,
        stepIndex: index,
        snapshot: step.matrixAfter,
        snapshotBefore: step.matrixBefore,
        transformation: step.transformation,
        highlights: step.highlights,
        subCalculations: withCalculations ? step.subCalculations : const [],
        onCellTap: onCellTap,
      ),
    ),
  ),
);

void main() {
  testWidgets('A step change rebuilds only the cells it changes', (
    tester,
  ) async {
    final a = Matrix.fromInts([
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
    ]);
    final steps = MatrixArithmeticSolver.add(a, a).steps;
    final additions = [
      for (final s in steps)
        if (s.transformation is MatrixElementAdditionTransformation) s,
    ];
    expect(additions.length, 9);

    List<MatrixCellWidget> cells() => tester
        .widgetList<MatrixCellWidget>(find.byType(MatrixCellWidget))
        .toList();

    await tester.pumpWidget(_grid(additions[3], index: 3));
    final before = cells();
    await tester.pumpWidget(_grid(additions[4], index: 4));
    final after = cells();
    expect(after.length, 9);

    // Step 5 finishes entry (2, 2) and moves the target off entry (2, 1);
    // every other entry keeps the very same widget.
    final changed = <int>[];
    for (var i = 0; i < 9; i++) {
      if (!identical(before[i], after[i])) changed.add(i);
    }
    expect(changed, [3, 4]);
    expect(after[4].value, Rational.fromInt(10));
    expect(after[4].pending, isFalse);
    expect(after[5].pending, isTrue);
  });

  testWidgets('A cell kept across updates calls the current tap callback', (
    tester,
  ) async {
    final solution = GaussJordanSolver.solve(
      Matrix.fromInts([
        [2, 1],
        [4, 3],
      ]),
    );
    final step = solution.steps.firstWhere(
      (s) =>
          s.transformation is RowEliminationTransformation &&
          s.subCalculations.isNotEmpty,
    );
    final calls = <String>[];
    await tester.pumpWidget(
      _grid(
        step,
        withCalculations: true,
        onCellTap: (r, c) => calls.add('old $r $c'),
      ),
    );
    final cell = step.subCalculations.first;
    final before = tester.widgetList<MatrixCellWidget>(
      find.byType(MatrixCellWidget),
    );
    await tester.pumpWidget(
      _grid(
        step,
        withCalculations: true,
        onCellTap: (r, c) => calls.add('new $r $c'),
      ),
    );
    final after = tester.widgetList<MatrixCellWidget>(
      find.byType(MatrixCellWidget),
    );
    expect(identical(before.first, after.first), isTrue);
    final index = cell.targetRow * step.matrixAfter.cols + cell.targetCol;
    after.elementAt(index).onTap!();
    expect(calls, ['new ${cell.targetRow} ${cell.targetCol}']);
  });
}
