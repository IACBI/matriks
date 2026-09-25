import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/core/number_format.dart';
import 'package:matriks/core/widgets/custom_numpad.dart';
import 'package:matriks/features/matrix_input/matrix_input_cubit.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/settings/cubit/settings_state.dart';
import 'package:matriks/features/step_player/cubit/player_cubit.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/features/step_player/widgets/determinant_lines_painter.dart';
import 'package:matriks/features/step_player/widgets/instruction_timeline.dart';
import 'package:matriks/features/step_player/widgets/matrix_cell_widget.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/features/step_player/widgets/prediction_card.dart';
import 'package:matriks/features/topics/models/topic_item.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

Widget _host(Widget child, {bool reduced = false}) => BlocProvider(
  create: (_) => SettingsCubit(),
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
      child: child!,
    ),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('Decimal view', () {
    test('exact decimals are exact and rounded ones are marked', () {
      expect(decimalLatex(Rational(1, 2)), '0.5');
      expect(decimalLatex(Rational(-7)), '-7');
      expect(decimalLatex(Rational(3, 8)), '0.375');
      expect(decimalLatex(Rational(1, 3)), r'\approx 0.3333');
      expect(decimalLatex(Rational(-2, 3)), r'\approx -0.6667');
    });
    test('tiny nonzero values never display as zero', () {
      expect(decimalLatex(Rational(1, 300000)), r'\approx 3.33 \times 10^{-6}');
      expect(
        decimalLatex(Rational(-1, 100001)),
        r'\approx -1.00 \times 10^{-5}',
      );
    });
    test('values beyond the double range stay finite text', () {
      final huge = Rational.parse('1${'0' * 400}') / Rational(3);
      expect(decimalLatex(huge), startsWith(r'\approx 333'));
      expect(decimalLatex(huge), isNot(contains('NaN')));
    });
  });

  test('Prediction choices use misconceptions and move the answer', () {
    final positions = <int>{};
    for (var seed = 0; seed < 3; seed++) {
      final choices = PredictionCard.choices(Rational(2), seed);
      expect(choices.toSet().length, 3);
      expect(choices, containsAll([Rational(2), Rational(-2), Rational(1, 2)]));
      positions.add(choices.indexOf(Rational(2)));
    }
    expect(positions, {0, 1, 2});
    final one = PredictionCard.choices(Rational.one, 0);
    expect(one.toSet().length, 3);
    expect(one, contains(Rational.one));
  });

  test('Row operations get more reading time for wider rows', () {
    final step = RowEliminationTransformation(
      targetRow: 1,
      sourceRow: 0,
      factor: Rational.minusOne,
    );
    expect(
      InstructionTimeline.forTransformation(step, columns: 2).operationMs,
      3600,
    );
    expect(
      InstructionTimeline.forTransformation(step, columns: 3).operationMs,
      3600,
    );
    expect(
      InstructionTimeline.forTransformation(step, columns: 5).operationMs,
      6000,
    );
  });

  testWidgets('Cells keep one width across swap and elimination steps', (
    tester,
  ) async {
    final solution = GaussJordanSolver.solve(
      Matrix.fromInts([
        [0, 2, 1],
        [1, -3, 2],
        [2, 1, -1],
      ]),
    );
    final hint = MatrixLayoutHint.forSolution(solution, decimal: false);
    expect(hint.reserveSwapLane, isTrue);
    expect(hint.reserveOperationWidth, isTrue);
    final swap = solution.steps.firstWhere(
      (s) => s.transformation is RowSwapTransformation,
    );
    final elimination = solution.steps.firstWhere(
      (s) => s.transformation is RowEliminationTransformation,
    );
    Future<(Size, Offset)> measure(MatrixStep step) async {
      await tester.pumpWidget(
        _host(
          SingleChildScrollView(
            child: MatrixDisplayGrid(
              snapshot: step.matrixAfter,
              snapshotBefore: step.matrixBefore,
              transformation: step.transformation,
              highlights: step.highlights,
              isAnimating: false,
              layoutHint: hint,
            ),
          ),
        ),
      );
      await tester.pump();
      final cell = find.byType(MatrixCellWidget).first;
      return (tester.getSize(cell), tester.getTopLeft(cell));
    }

    final (swapSize, swapOrigin) = await measure(swap);
    final (eliminationSize, eliminationOrigin) = await measure(elimination);
    expect(swapSize, eliminationSize);
    expect(swapOrigin.dx, eliminationOrigin.dx);
  });

  testWidgets('Uncomputed product entries show a placeholder, not zero', (
    tester,
  ) async {
    final solution = MatrixArithmeticSolver.multiply(
      Matrix.fromInts([
        [1, 2],
        [3, 4],
      ]),
      Matrix.fromInts([
        [5, 6],
        [7, 8],
      ]),
    );
    final step = solution.steps[1]; // entry (1, 2)
    await tester.pumpWidget(
      _host(
        SingleChildScrollView(
          child: MatrixDisplayGrid(
            snapshot: step.matrixAfter,
            snapshotBefore: step.matrixBefore,
            transformation: step.transformation,
            highlights: step.highlights,
            staticStep: true,
          ),
        ),
      ),
    );
    await tester.pump();
    final cells = tester
        .widgetList<MatrixCellWidget>(find.byType(MatrixCellWidget))
        .toList();
    expect(cells.map((c) => c.pending), [false, false, true, true]);
    expect(cells[0].value, Rational(19));
    final semantics = tester.ensureSemantics();
    await tester.pump();
    expect(
      find.bySemanticsLabel('Row 2, column 1, not calculated yet'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('Sarrus copies the first two columns for straight diagonals', (
    tester,
  ) async {
    final step = DeterminantSolver.solve(
      Matrix.fromInts([
        [1, 2, 3],
        [0, 1, 4],
        [5, 6, 0],
      ]),
    ).steps.first;
    expect(step.transformation, isA<DeterminantSarrusTransformation>());
    for (final reduced in [false, true]) {
      await tester.pumpWidget(
        _host(
          SingleChildScrollView(
            child: MatrixDisplayGrid(
              snapshot: step.matrixAfter,
              snapshotBefore: step.matrixBefore,
              transformation: step.transformation,
              highlights: step.highlights,
              isAnimating: false,
            ),
          ),
          reduced: reduced,
        ),
      );
      await tester.pump();
      final painters = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((p) => p.painter)
          .whereType<DeterminantLinesPainter>();
      // Reduced motion still shows which entries are multiplied, drawn at
      // once instead of traced.
      expect(painters.single.copiedColumnsGap, isNotNull);
      expect(painters.single.showAll, reduced);
      expect(find.byType(MatrixCellWidget), findsNWidgets(9));
    }
  });

  testWidgets('A finished lesson offers the result and a restart', (
    tester,
  ) async {
    final solution = DeterminantSolver.solve(
      Matrix.fromInts([
        [2, 3],
        [1, 4],
      ]),
    );
    var ownMatrix = 0;
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => SettingsCubit(
          initial: const SettingsState(solutionMode: SolutionMode.steps),
        ),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StepPlayerScreen(
            solution: solution,
            topicTitle: 'Determinant',
            workedExample: true,
            onOwnMatrix: () => ownMatrix++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('lesson-complete')), findsNothing);
    final player = tester
        .element(find.byType(MatrixDisplayGrid))
        .read<PlayerCubit>();
    player.jumpToStep(solution.steps.length - 1);
    await tester.pumpAndSettle();
    final card = find.byKey(const ValueKey('lesson-complete'));
    expect(card, findsOneWidget);
    await tester.ensureVisible(find.text('Try your own matrix'));
    await tester.tap(find.text('Try your own matrix'));
    expect(ownMatrix, 1);
    await tester.ensureVisible(find.text('Watch again'));
    await tester.tap(find.text('Watch again'));
    await tester.pumpAndSettle();
    expect(player.state.currentStepIndex, 0);
    expect(tester.takeException(), isNull);
  });

  group('Matrix input', () {
    test('a lone minus toggles back to zero, not an empty cell', () async {
      final cubit = MatrixInputCubit(TopicItem.of(TopicType.determinant));
      cubit.onClear();
      cubit.onKeyPressed('-');
      expect(cubit.state.dataA[0][0], '-');
      cubit.onKeyPressed('-');
      expect(cubit.state.dataA[0][0], '0');
      await cubit.close();
    });

    test('next row wraps within the column', () async {
      final cubit = MatrixInputCubit(TopicItem.of(TopicType.determinant));
      cubit.setFocus(2, 1);
      cubit.onNextRow();
      expect((cubit.state.focusedRow, cubit.state.focusedCol), (0, 1));
      await cubit.close();
    });

    test('random eigen examples have integer eigenvalues', () async {
      final cubit = MatrixInputCubit(TopicItem.of(TopicType.eigen));
      for (var i = 0; i < 25; i++) {
        cubit.presetRandom();
        final solution = EigenSolver.solve(cubit.state.toMatrixA());
        final result = solution.result as EigenResult;
        expect(solution.accuracy, ResultAccuracy.exact);
        expect(result.hasComplexEigenvalues, isFalse);
        for (final pair in result.realEigenpairs) {
          expect(pair.eigenvalue.isInteger, isTrue);
        }
      }
      await cubit.close();
    });

    test('random inverse examples are invertible', () async {
      final cubit = MatrixInputCubit(TopicItem.of(TopicType.inverse));
      for (var i = 0; i < 25; i++) {
        cubit.presetRandom();
        expect(InverseSolver.solve(cubit.state.toMatrixA()).isSuccess, isTrue);
      }
      await cubit.close();
    });

    test('a preset can be undone', () async {
      final cubit = MatrixInputCubit(TopicItem.of(TopicType.gauss));
      cubit.onKeyPressed('7');
      final before = cubit.state.dataA;
      cubit.presetClear();
      expect(cubit.state.dataA[0][0], '0');
      cubit.undoPreset();
      expect(cubit.state.dataA, before);
      await cubit.close();
    });
  });

  testWidgets('Numpad has one key per action and moves down a row', (
    tester,
  ) async {
    var nextRow = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CustomNumpad(
            onKeyPressed: (_) {},
            onBackspace: () {},
            onClear: () {},
            onNextCell: () {},
            onPrevCell: () {},
            onNextRow: () => nextRow++,
          ),
        ),
      ),
    );
    expect(find.text('-'), findsNothing);
    expect(find.text('±'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_rounded), findsNothing);
    await tester.tap(find.byIcon(Icons.arrow_downward_rounded));
    expect(nextRow, 1);
  });

  test('Settings compare by value so unchanged saves do not rebuild', () {
    expect(const SettingsState(), const SettingsState());
    expect(
      const SettingsState().copyWith(compact: true),
      isNot(const SettingsState()),
    );
    expect(
      const SettingsState().hashCode,
      const SettingsState().copyWith().hashCode,
    );
  });
}
