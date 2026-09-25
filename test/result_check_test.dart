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

  test('Rounded eigenvalues and plain arithmetic offer no check', () {
    expect(
      resultChecks(
        EigenSolver.solve(
          Matrix.fromInts([
            [0, 2],
            [1, 0],
          ]),
        ),
        l,
      ),
      isEmpty,
    );
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
