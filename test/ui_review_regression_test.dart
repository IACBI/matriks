import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/core/theme/app_theme.dart';
import 'package:matriks/core/widgets/math_text.dart';
import 'package:matriks/features/matrix_input/matrix_input_cubit.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/settings/views/settings_screen.dart';
import 'package:matriks/features/step_player/widgets/matrix_cell_widget.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/features/step_player/widgets/solution_summary.dart';
import 'package:matriks/features/topics/models/topic_item.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

/// Defects found by driving the web build in a browser (2026-09-24).
Widget _host(Widget child, {double width = 1000}) => BlocProvider(
  create: (_) => SettingsCubit(),
  child: MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  ),
);

void main() {
  test('Wrapped formulas break between terms and keep operator spacing', () {
    expect(splitTexTerms(r'(-2) - 2 \cdot 1 = -4'), [
      '(-2)',
      r'{}- 2 \cdot 1',
      '{}= -4',
    ]);
    // Nothing inside braces or \left…\right is split.
    expect(splitTexTerms(r'\frac{a - b}{c} = d'), [
      r'\frac{a - b}{c}',
      '{}= d',
    ]);
    expect(splitTexTerms(r'\left(1 + 2\right) + 3'), [
      r'\left(1 + 2\right)',
      '{}+ 3',
    ]);
    expect(splitTexTerms('7'), ['7']);
  });

  test('Formulas are read as text, not as their glyphs', () {
    expect(mathSemanticsLabel(r'\frac{1}{2}'), '1/2');
    expect(mathSemanticsLabel(r'-\frac{3}{4}'), '-3/4');
    expect(
      mathSemanticsLabel(r'R_{2} \leftarrow R_{2} - 2 R_{1}'),
      'R₂ ← R₂ - 2 R₁',
    );
    expect(
      mathSemanticsLabel(r'A - 2I \;\Rightarrow\; \mathbf{v} = (1, 1)'),
      'A - 2I ⇒ v = (1, 1)',
    );
  });

  test('The theme falls back to the bundled symbol font', () {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      for (final style in [
        theme.textTheme.bodyMedium,
        theme.textTheme.titleMedium,
        theme.appBarTheme.titleTextStyle,
      ]) {
        expect(style?.fontFamilyFallback, contains('MatriksSymbols'));
      }
    }
  });

  testWidgets('A finished zero carries an icon check, not a ✓ character', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(MatrixCellWidget(value: Rational.zero, isZeroResult: true)),
    );
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.textContaining('✓'), findsNothing);
  });

  testWidgets('Eliminations write the factor without brackets', (tester) async {
    final step = GaussJordanSolver.solve(
      Matrix.fromInts([
        [1, 2],
        [2, 5],
      ]),
    ).steps.firstWhere((s) => s.transformation is RowEliminationTransformation);
    await tester.pumpWidget(
      _host(
        MatrixDisplayGrid(
          snapshot: step.matrixAfter,
          snapshotBefore: step.matrixBefore,
          transformation: step.transformation,
          highlights: step.highlights,
        ),
      ),
    );
    await tester.pump();
    expect(
      find.byWidgetPredicate(
        (w) => w is MathText && w.latex == r'R_{2} \leftarrow R_{2} - 2 R_{1}',
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('A 3x3 elimination fits a phone width without hiding a column', (
    tester,
  ) async {
    final step = GaussJordanSolver.solve(
      Matrix.fromInts([
        [1, 2, 1],
        [2, 5, 4],
        [1, 3, 3],
      ]),
    ).steps.firstWhere((s) => s.transformation is RowEliminationTransformation);
    const width = 358.0; // 390 px screen less the player's 16 px gutters
    await tester.pumpWidget(
      _host(
        MatrixDisplayGrid(
          snapshot: step.matrixAfter,
          snapshotBefore: step.matrixBefore,
          transformation: step.transformation,
          highlights: step.highlights,
        ),
        width: width,
      ),
    );
    await tester.pump();
    final cells = find.byType(MatrixCellWidget);
    final right = tester.getTopRight(cells.at(2)).dx;
    final left = tester.getTopLeft(find.byType(MatrixDisplayGrid)).dx;
    expect(right - left, lessThanOrEqualTo(width));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Results show a matrix once, and only when it is the answer', (
    tester,
  ) async {
    Future<void> show(StepSolution solution) => tester.pumpWidget(
      _host(
        SolutionSummary(solution: solution, decimal: false, onViewSteps: () {}),
      ),
    );
    final inverse = InverseSolver.solve(
      Matrix.fromInts([
        [1, 2, 3],
        [0, 1, 4],
        [5, 6, 0],
      ]),
    );
    await show(inverse);
    await tester.pumpAndSettle();
    expect(find.byType(MatrixDisplayGrid), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is MathText && w.latex == inverse.resultLatex,
      ),
      findsNothing,
    );

    await show(
      LUDecompositionSolver.solve(
        Matrix.fromInts([
          [2, 1, 1],
          [4, 3, 3],
          [8, 7, 9],
        ]),
      ),
    );
    await tester.pumpAndSettle();
    // L and U are named in the result; an unlabelled U would repeat it.
    expect(find.byType(MatrixDisplayGrid), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('Every topic opens on a worked example that solves', () {
    for (final topic in TopicItem.allTopics) {
      if (topic.type == TopicType.transform2d ||
          topic.type == TopicType.practice) {
        continue;
      }
      final state = MatrixInputCubit(topic).state;
      final a = state.toMatrixA();
      final identity = a.isSquare && a == Matrix.identity(a.rows);
      expect(identity, isFalse, reason: '${topic.type} opens on I');
      final solution = switch (topic.type) {
        TopicType.gauss => GaussJordanSolver.solve(
          a,
          const EliminationOptions(toRref: false),
        ),
        TopicType.rref => GaussJordanSolver.solve(a),
        TopicType.linearSystems => LinearSystemsSolver.solve(a),
        TopicType.determinant => DeterminantSolver.solve(a),
        TopicType.inverse => InverseSolver.solve(a),
        TopicType.rankNullity => RankNullitySolver.solve(a),
        TopicType.eigen => EigenSolver.solve(a),
        TopicType.lu => LUDecompositionSolver.solve(a),
        TopicType.add => MatrixArithmeticSolver.add(a, state.toMatrixB()),
        TopicType.multiply => MatrixArithmeticSolver.multiply(
          a,
          state.toMatrixB(),
        ),
        _ => throw StateError('no solver'),
      };
      expect(solution.isSuccess, isTrue, reason: '${topic.type}');
      expect(solution.steps, isNotEmpty, reason: '${topic.type}');
    }
    final eigen = EigenSolver.solve(
      MatrixInputCubit(TopicItem.of(TopicType.eigen)).state.toMatrixA(),
    );
    expect(eigen.completeness, ResultCompleteness.complete);
    expect(eigen.accuracy, ResultAccuracy.exact);
  });

  testWidgets('More options is its own control, not part of its card', (
    tester,
  ) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => SettingsCubit(),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );
    // On the web the tile's tap was merged into the whole Learning card.
    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('more-settings')),
        matching: find.byWidgetPredicate((w) => w is Semantics && w.container),
      ),
      findsWidgets,
    );
  });
}
