import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/core/widgets/math_text.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/settings/cubit/settings_state.dart';
import 'package:matriks/features/step_player/cubit/player_cubit.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/features/step_player/widgets/determinant_lines_painter.dart';
import 'package:matriks/features/step_player/widgets/instruction_lesson.dart';
import 'package:matriks/features/step_player/widgets/instruction_timeline.dart';
import 'package:matriks/features/step_player/widgets/matrix_cell_widget.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

Widget _host(Widget child) => BlocProvider(
  create: (_) => SettingsCubit(),
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

Widget _grid(MatrixStep step) => _host(
  MatrixDisplayGrid(
    snapshot: step.matrixAfter,
    snapshotBefore: step.matrixBefore,
    transformation: step.transformation,
    highlights: step.highlights,
  ),
);

MatrixCellWidget _cell(WidgetTester tester, int index) => tester
    .widgetList<MatrixCellWidget>(find.byType(MatrixCellWidget))
    .elementAt(index);

void main() {
  test('Row operations skip columns they cannot change', () {
    final solution = GaussJordanSolver.solve(
      Matrix.fromInts([
        [1, 2, 1],
        [2, 5, 4],
        [1, 3, 3],
      ]),
      const EliminationOptions(toRref: false, normalizePivotToOne: false),
    );
    final step = solution.steps.lastWhere(
      (s) => s.transformation is RowEliminationTransformation,
    );
    final t = step.transformation as RowEliminationTransformation;
    expect(step.matrixBefore.get(t.sourceRow, 0), Rational.zero);
    final changing = changingColumns(t, step.matrixBefore, 3);
    expect(changing, [1, 2]);
    final lesson = InstructionLesson.forStep(
      transformation: t,
      before: step.matrixBefore,
      after: step.matrixAfter,
    );
    expect(lesson.calculations, hasLength(2));
    expect(lesson.calculations.first, startsWith('(${step.matrixBefore.get(t.targetRow, 1)})'));
  });

  testWidgets('Steps without teaching text do not show placeholder phases', (
    tester,
  ) async {
    final eigen = EigenSolver.solve(
      Matrix.fromInts([
        [4, 1],
        [2, 3],
      ]),
    );
    await tester.pumpWidget(_grid(eigen.steps.first));
    await tester.pump();
    expect(find.byKey(const ValueKey('phase-dots')), findsNothing);

    final gauss = GaussJordanSolver.solve(
      Matrix.fromInts([
        [1, 2],
        [2, 5],
      ]),
    );
    await tester.pumpWidget(
      _grid(
        gauss.steps.firstWhere(
          (s) => s.transformation is RowEliminationTransformation,
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('phase-dots')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('The adjugate negates b and c while a and d move', (
    tester,
  ) async {
    final step = InverseSolver.solve(
      Matrix.fromInts([
        [4, 7],
        [2, 6],
      ]),
    ).steps[1];
    await tester.pumpWidget(_grid(step));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2600));
    expect(_cell(tester, 1).calculationLatex, '-7');
    expect(_cell(tester, 2).calculationLatex, '-2');
    expect(_cell(tester, 0).calculationLatex, isNull);
    expect(_cell(tester, 0).value, Rational(6));
    expect(
      find.ancestor(
        of: find.byWidget(_cell(tester, 0)),
        matching: find.byType(Transform),
      ),
      findsWidgets,
    );
    await tester.pumpAndSettle();
    expect(_cell(tester, 1).value, Rational(-7));
    expect(_cell(tester, 1).calculationLatex, isNull);
  });

  testWidgets('Scaling by 1/det shows one product at a time', (tester) async {
    final step = InverseSolver.solve(
      Matrix.fromInts([
        [4, 7],
        [2, 6],
      ]),
    ).steps[2];
    await tester.pumpWidget(_grid(step));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1950));
    expect(_cell(tester, 0).calculationLatex, r'6 \cdot \frac{1}{10}');
    expect(_cell(tester, 1).calculationLatex, isNull);
    expect(_cell(tester, 1).value, Rational(-7));
    await tester.pumpAndSettle();
    expect(_cell(tester, 0).value, Rational(3, 5));
  });

  testWidgets('LU elimination shows L with the multiplier just written', (
    tester,
  ) async {
    final step = LUDecompositionSolver.solve(
      Matrix.fromInts([
        [2, 1, 1],
        [4, 3, 3],
        [8, 7, 9],
      ]),
    ).steps.firstWhere((s) => s.transformation is LUEliminationTransformation);
    await tester.pumpWidget(_grid(step));
    await tester.pump();
    expect(
      find.byWidgetPredicate((w) => w is MathText && w.latex == 'L ='),
      findsOneWidget,
    );
    // The first multiplier is 4 / 2 = 2; later entries are still pending.
    expect(
      find.byWidgetPredicate((w) => w is MathText && w.latex == '2'),
      findsWidgets,
    );
    expect(
      find.byWidgetPredicate((w) => w is MathText && w.latex == r'\cdot'),
      findsNWidgets(2),
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('The determinant recap lists products and animates only the sum', (
    tester,
  ) async {
    final step = DeterminantSolver.solve(
      Matrix.fromInts([
        [2, 3],
        [1, 4],
      ]),
    ).steps.last;
    await tester.pumpWidget(_grid(step));
    await tester.pump();
    expect(
      tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((p) => p.painter)
          .whereType<DeterminantLinesPainter>(),
      isEmpty,
    );
    final explanation = find.byType(InstructionExplanation);
    expect(
      find.descendant(of: explanation, matching: find.byType(MathText)),
      findsNWidgets(2),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: explanation, matching: find.byType(MathText)),
      findsNWidgets(3),
    );
  });

  testWidgets('The step description appears only when it adds something', (
    tester,
  ) async {
    final solution = GaussJordanSolver.solve(
      Matrix.fromInts([
        [0, 2, 1],
        [1, -3, 2],
        [2, 1, -1],
      ]),
    );
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => SettingsCubit(
          initial: const SettingsState(solutionMode: SolutionMode.steps),
        ),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StepPlayerScreen(solution: solution, topicTitle: 'RREF'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final player = tester
        .element(find.byType(MatrixDisplayGrid))
        .read<PlayerCubit>();
    expect(solution.steps.first.transformation, isA<RowSwapTransformation>());
    // A swap's description says why the rows move.
    expect(find.byIcon(Icons.lightbulb_outline_rounded), findsOneWidget);
    player.jumpToStep(
      solution.steps.indexWhere(
        (s) => s.transformation is RowEliminationTransformation,
      ),
    );
    await tester.pumpAndSettle();
    // An elimination's formula is already the operation shown above the matrix.
    expect(find.byIcon(Icons.lightbulb_outline_rounded), findsNothing);
    expect(find.text('Cell calculations (3)'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
