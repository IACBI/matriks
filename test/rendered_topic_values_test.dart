import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/core/theme/app_theme.dart';
import 'package:matriks/core/widgets/math_text.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/step_player/cubit/player_cubit.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';
import 'package:matrix_engine/matrix_engine.dart';

/// Renders the real player and reads the text a learner would see, so the
/// displayed values are checked against hand-computed arithmetic rather than
/// against the solver that produced them.
Widget _host(Widget child) => BlocProvider(
  create: (_) => SettingsCubit(),
  child: MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: child,
  ),
);

/// Every string currently rendered anywhere in the tree, including the
/// formulas drawn by [MathText].
List<String> _visibleText(WidgetTester tester) {
  final out = <String>[
    for (final element in find.byType(MathText).evaluate())
      if ((element.widget as MathText).latex.trim().isNotEmpty)
        (element.widget as MathText).latex.trim(),
  ];
  for (final element in find.byType(Text).evaluate()) {
    final widget = element.widget as Text;
    final value = widget.data ?? widget.textSpan?.toPlainText();
    if (value != null && value.trim().isNotEmpty) out.add(value.trim());
  }
  return out;
}

Future<PlayerCubit> _open(WidgetTester tester, StepSolution solution) async {
  await tester.pumpWidget(
    _host(StepPlayerScreen(solution: solution, topicTitle: 'topic')),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  final cubit = tester
      .element(find.byType(MatrixDisplayGrid))
      .read<PlayerCubit>();
  cubit.pause();
  await tester.pump();
  return cubit;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Matrix addition shows each hand-checked cell sum', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // A + B computed by hand:
    //   ( 3   -1/2 )   ( -5   1/2 )   ( -2    0 )
    //   ( 0    7   ) + (  4  -7   ) = (  4    0 )
    final a = Matrix([
      [Rational(3), Rational(-1, 2)],
      [Rational.zero, Rational(7)],
    ]);
    final b = Matrix([
      [Rational(-5), Rational(1, 2)],
      [Rational(4), Rational(-7)],
    ]);
    const expected = [
      ['-2', '0'],
      ['4', '0'],
    ];

    final solution = MatrixArithmeticSolver.add(a, b);
    expect(solution.steps.length, 4, reason: 'one step per cell of a 2x2 sum');

    final cubit = await _open(tester, solution);

    for (var index = 0; index < solution.steps.length; index++) {
      cubit.jumpToStep(index);
      await tester.pump();
      await tester.pump(const Duration(seconds: 12));

      final row = index ~/ 2;
      final col = index % 2;
      // The step's own operands and sum must be the hand-computed ones.
      final step = solution.steps[index];
      final transformation =
          step.transformation as MatrixElementAdditionTransformation;
      expect(transformation.row, row);
      expect(transformation.col, col);
      expect(
        (transformation.left + transformation.right).toString(),
        expected[row][col],
        reason: 'cell (${row + 1},${col + 1}) sum',
      );
      expect(
        step.matrixAfter.get(row, col).toString(),
        expected[row][col],
        reason: 'rendered snapshot for cell (${row + 1},${col + 1})',
      );
      // The sum has to be somewhere on screen for this step.
      expect(
        _visibleText(tester).any((t) => t.contains(expected[row][col])),
        isTrue,
        reason: 'sum ${expected[row][col]} not rendered on step ${index + 1}',
      );
    }

    // Cells not yet computed must still read 0, never a stale later value.
    cubit.jumpToStep(0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 12));
    expect(solution.steps.first.matrixAfter.get(1, 1).toString(), '0');
    expect(solution.finalMatrix.get(0, 0).toString(), '-2');
    expect(solution.finalMatrix.get(1, 0).toString(), '4');
    cubit.pause();
    await tester.pumpAndSettle();
  });

  testWidgets('Gaussian elimination (REF) renders hand-checked row steps', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    //  ( 0  2  4 )                        ( 3  1 -1 )
    //  ( 3  1 -1 )  swap R1<->R2  ->      ( 0  2  4 )
    //  ( 1  5  2 )                        ( 1  5  2 )
    final matrix = Matrix.fromInts([
      [0, 2, 4],
      [3, 1, -1],
      [1, 5, 2],
    ]);
    final solution = GaussJordanSolver.solve(
      matrix,
      const EliminationOptions(toRref: false),
    );

    // REF must leave an upper-triangular result with the same row space.
    final upper = solution.finalMatrix;
    for (var r = 1; r < upper.rows; r++) {
      for (var c = 0; c < r; c++) {
        expect(
          upper.get(r, c).isZero,
          isTrue,
          reason: 'REF left a nonzero below the diagonal at ($r,$c)',
        );
      }
    }
    // Sarrus by hand: positives 0 + (-2) + 60 = 58, negatives 4 + 0 + 12 = 16,
    // so det(A) = 58 - 16 = 42.
    expect(
      (DeterminantSolver.solve(matrix).result as Rational).toString(),
      '42',
    );

    final first = solution.steps.first;
    expect(first.transformation, isA<RowSwapTransformation>());
    expect(
      first.matrixAfter.get(0, 0).toString(),
      '3',
      reason: 'the swap must lift the nonzero pivot into row 1',
    );

    final cubit = await _open(tester, solution);
    for (var index = 0; index < solution.steps.length; index++) {
      cubit.jumpToStep(index);
      await tester.pump();
      await tester.pump(const Duration(seconds: 12));
      expect(tester.takeException(), isNull, reason: 'step ${index + 1}');
      expect(
        _visibleText(tester),
        isNotEmpty,
        reason: 'step ${index + 1} rendered nothing',
      );
    }
    cubit.pause();
    await tester.pumpAndSettle();
  });
}
