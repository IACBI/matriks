import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/features/step_player/step_text.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

Matrix _m(List<List<int>> rows) => Matrix.fromInts(rows);

/// One solution per solver branch, so every title and explanation key the
/// engine can emit is looked up at least once.
List<StepSolution> _solutions() => [
  GaussJordanSolver.solve(
    _m([
      [0, 2, 1],
      [1, -3, 2],
      [2, 1, -1],
    ]),
  ),
  GaussJordanSolver.solve(
    _m([
      [1, 0],
      [0, 1],
    ]),
  ),
  DeterminantSolver.solve(
    _m([
      [7],
    ]),
  ),
  DeterminantSolver.solve(
    _m([
      [2, 3],
      [1, 4],
    ]),
  ),
  DeterminantSolver.solve(
    _m([
      [1, 2, 3],
      [0, 1, 4],
      [5, 6, 0],
    ]),
  ),
  DeterminantSolver.solve(
    _m([
      [0, 1, 0, 0],
      [1, 0, 0, 0],
      [0, 0, 2, 0],
      [0, 0, 0, 3],
    ]),
  ),
  DeterminantSolver.solve(
    _m([
      [1, 2, 0, 0],
      [2, 4, 0, 0],
      [0, 0, 1, 0],
      [0, 0, 0, 1],
    ]),
  ),
  InverseSolver.solve(
    _m([
      [4, 7],
      [2, 6],
    ]),
  ),
  InverseSolver.solve(
    _m([
      [1, 2],
      [2, 4],
    ]),
  ),
  InverseSolver.solve(
    _m([
      [1, 2, 0],
      [0, 1, 0],
      [2, 0, 1],
    ]),
  ),
  MatrixArithmeticSolver.add(Matrix.identity(2), Matrix.identity(2)),
  MatrixArithmeticSolver.multiply(Matrix.identity(2), Matrix.identity(2)),
  LinearSystemsSolver.solve(
    _m([
      [1, 2, 5],
      [3, 4, 11],
    ]),
  ),
  LinearSystemsSolver.solve(
    _m([
      [1, 2, 3],
      [2, 4, 6],
    ]),
  ),
  LinearSystemsSolver.solve(
    _m([
      [1, 2, 3],
      [2, 4, 7],
    ]),
  ),
  RankNullitySolver.solve(
    _m([
      [1, 2],
      [2, 4],
    ]),
  ),
  EigenSolver.solve(
    _m([
      [4, 1],
      [2, 3],
    ]),
  ),
  EigenSolver.solve(
    _m([
      [0, 2],
      [1, 0],
    ]),
  ),
  EigenSolver.solve(
    _m([
      [0, -1],
      [1, 0],
    ]),
  ),
  EigenSolver.solve(
    _m([
      [2, 0, 0],
      [0, 3, 0],
      [0, 0, 4],
    ]),
  ),
  EigenSolver.solve(
    _m([
      [3, 0, 0],
      [0, 0, 2],
      [0, 1, 0],
    ]),
  ),
  EigenSolver.solve(
    _m([
      [2, 0, 0],
      [0, 0, -1],
      [0, 1, 0],
    ]),
  ),
  EigenSolver.solve(
    _m([
      [0, 1, 0],
      [0, 0, 1],
      [1, 3, 0],
    ]),
  ),
  EigenSolver.solve(
    Matrix([
      [Rational.parse('1${'0' * 30}'), Rational.one, Rational.zero],
      [Rational.zero, -Rational.parse('1${'0' * 30}'), Rational.one],
      [Rational.one, Rational.zero, Rational(7)],
    ]),
  ),
  LUDecompositionSolver.solve(
    _m([
      [0, 2, 1],
      [2, 1, 0],
      [1, 3, 2],
    ]),
  ),
];

void main() {
  test('Every step text the engine emits resolves in all five languages', () {
    final solutions = _solutions();
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(locale);
      for (final solution in solutions) {
        for (final step in solution.steps) {
          for (final (key, params) in [
            (step.titleKey, step.titleParams),
            (step.explanationKey, step.explanationParams),
          ]) {
            final text = localizedStepText(l10n, key, params);
            expect(
              text,
              isNot(key),
              reason: '${locale.languageCode}: $key did not resolve',
            );
            expect(text.trim(), isNotEmpty);
          }
        }
      }
    }
  });

  test('Solver errors map to their messages and unknown keys fall back', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(
      localizedSolverError(l10n, 'error_matrix_is_singular'),
      l10n.error_matrix_is_singular,
    );
    expect(localizedSolverError(l10n, null), l10n.solveFallbackError);
    expect(localizedSolverError(l10n, 'no_such_key'), l10n.solveFallbackError);
  });
}
