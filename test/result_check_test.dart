import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/step_player/result_check.dart';
import 'package:matriks/features/step_player/widgets/solution_summary.dart';
import 'package:matriks/features/transform_visualizer/views/transform_visualizer_screen.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

void main() {
  final l = lookupAppLocalizations(const Locale('en'));

  test('Every operation with an independent check passes it', () {
    final solutions = {
      'inverse': InverseSolver.solve(
        Matrix.fromInts([
          [2, 1, 0],
          [1, 3, 1],
          [0, 1, 4],
        ]),
      ),
      'det 2x2': DeterminantSolver.solve(
        Matrix.fromInts([
          [3, 8],
          [4, 6],
        ]),
      ),
      'det 4x4': DeterminantSolver.solve(
        Matrix.fromInts([
          [1, 0, 2, -1],
          [3, 0, 0, 5],
          [2, 1, 4, -3],
          [1, 0, 5, 0],
        ]),
      ),
      'lu with swap': LUDecompositionSolver.solve(
        Matrix.fromInts([
          [0, 2, 1],
          [1, 1, 1],
          [2, 1, 3],
        ]),
      ),
      'system': LinearSystemsSolver.solve(
        Matrix.fromInts([
          [1, 2, 5],
          [3, 4, 11],
        ]),
      ),
      'rank': RankNullitySolver.solve(
        Matrix.fromInts([
          [1, 2, 3],
          [2, 4, 6],
        ]),
      ),
      'eigen': EigenSolver.solve(
        Matrix.fromInts([
          [4, 1],
          [2, 3],
        ]),
      ),
    };
    solutions.forEach((label, solution) {
      final checks = resultChecks(solution, l);
      expect(checks, isNotEmpty, reason: label);
      for (final check in checks) {
        expect(check.holds, isTrue, reason: '$label: ${check.latex}');
      }
    });
    expect(
      resultChecks(solutions['eigen']!, l),
      hasLength(2),
      reason: 'one Av = λv per eigenpair',
    );
  });

  test('Irrational, complex and cubic eigenpairs are all checked exactly', () {
    final cases = {
      '±√2': (
        [
          [0, 2],
          [1, 0],
        ],
        2,
      ),
      '2 ± i': (
        [
          [1, -2],
          [1, 3],
        ],
        2,
      ),
      'rational and ±√2': (
        [
          [3, 0, 0],
          [0, 0, 2],
          [0, 1, 0],
        ],
        3,
      ),
      'x³ - 2': (
        [
          [0, 1, 0],
          [0, 0, 1],
          [2, 0, 0],
        ],
        3,
      ),
      'x³ - 3x + 1': (
        [
          [0, 1, 0],
          [0, 0, 1],
          [-1, 3, 0],
        ],
        3,
      ),
      // λ = 2 with a two-dimensional eigenspace: one check per basis vector.
      'eigenspace': (
        [
          [2, 0, 1],
          [0, 2, 0],
          [0, 0, 5],
        ],
        3,
      ),
    };
    cases.forEach((label, entry) {
      final (rows, count) = entry;
      final checks = resultChecks(EigenSolver.solve(Matrix.fromInts(rows)), l);
      expect(checks, hasLength(count), reason: label);
      for (final check in checks) {
        expect(check.holds, isTrue, reason: '$label: ${check.latex}');
        expect(check.latex, isNot(contains(r'\approx')), reason: label);
      }
    });
    final root2 = resultChecks(
      EigenSolver.solve(
        Matrix.fromInts([
          [0, 2],
          [1, 0],
        ]),
      ),
      l,
    );
    expect(root2.first.latex, contains(r'\sqrt{2}'));
    expect(root2.first.latex, contains(r'\lambda_{1}\,\mathbf{v}_{1}'));
  });

  test('The eigen check recomputes Av and fails a wrong vector', () {
    final matrix = Matrix.fromInts([
      [1, 1],
      [1, 0],
    ]);
    final solution = EigenSolver.solve(matrix);
    final result = solution.result as EigenResult;
    final pair = result.eigenpairs.first;
    final field = pair.eigenvalue.field;
    StepSolution withVector(List<NumberFieldElement> vector) => StepSolution(
      operationKey: 'op_eigen',
      initialMatrix: matrix,
      steps: const [],
      finalMatrix: matrix,
      result: EigenResult(
        characteristicPolynomialLatex: result.characteristicPolynomialLatex,
        realEigenpairs: const [],
        eigenpairs: [
          ExactEigenpair(
            eigenvalue: pair.eigenvalue,
            eigenspaceBasis: [vector],
          ),
        ],
      ),
    );
    final v = pair.eigenspaceBasis.single;
    expect(resultChecks(withVector(v), l).single.holds, isTrue);
    // A perturbed vector, or the zero vector, must fail.
    expect(
      resultChecks(withVector([v[0], v[1] + field.one]), l).single.holds,
      isFalse,
    );
    expect(
      resultChecks(withVector([field.zero, field.zero]), l).single.holds,
      isFalse,
    );
  });

  test('Plain arithmetic offers no check', () {
    expect(
      resultChecks(
        MatrixArithmeticSolver.multiply(
          Matrix.fromInts([
            [1, 2],
          ]),
          Matrix.fromInts([
            [3],
            [4],
          ]),
        ),
        l,
      ),
      isEmpty,
    );
  });

  testWidgets('A 2x2 eigen result links to the transformation view', (
    tester,
  ) async {
    final solution = EigenSolver.solve(
      Matrix.fromInts([
        [4, 1],
        [2, 3],
      ]),
    );
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => SettingsCubit(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SolutionSummary(
              solution: solution,
              decimal: false,
              onViewSteps: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('result-checks')), findsOneWidget);
    expect(find.text('Holds'), findsNWidgets(2));
    final link = find.byKey(const ValueKey('transform-link'));
    await tester.ensureVisible(link);
    await tester.tap(link);
    await tester.pumpAndSettle();
    final screen = tester.widget<TransformVisualizerScreen>(
      find.byType(TransformVisualizerScreen),
    );
    expect(screen.initial?.a, 4);
    expect(screen.initial?.b, 1);
    expect(screen.initial?.c, 2);
    expect(screen.initial?.d, 3);
    expect(tester.takeException(), isNull);
  });
}
