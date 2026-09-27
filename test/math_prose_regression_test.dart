import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/core/widgets/math_text.dart';
import 'package:matriks/features/step_player/step_text.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';
import 'package:matrix_engine/matrix_engine.dart';

/// One lesson for each kind of exact eigen step.
Map<String, StepSolution> _exactEigenLessons() => {
  for (final (label, rows) in [
    (
      'eigen-2x2-complex-surd',
      [
        [1, -5],
        [1, 1],
      ],
    ),
    (
      'eigen-2x2-defective',
      [
        [2, 1],
        [0, 2],
      ],
    ),
    (
      'eigen-3x3-irrational-pair',
      [
        [3, 0, 0],
        [0, 0, 2],
        [0, 1, 0],
      ],
    ),
    (
      'eigen-3x3-complex-pair',
      [
        [2, 0, 0],
        [0, 0, -1],
        [0, 1, 0],
      ],
    ),
    (
      'eigen-3x3-cardano',
      [
        [0, 1, 0],
        [0, 0, 1],
        [2, 0, 0],
      ],
    ),
    (
      'eigen-3x3-cardano-surd',
      [
        [0, 1, 0],
        [0, 0, 1],
        [-1, -1, 0],
      ],
    ),
    (
      'eigen-3x3-trig',
      [
        [0, 1, 0],
        [0, 0, 1],
        [-1, 3, 0],
      ],
    ),
    (
      'eigen-3x3-trig-arccos',
      [
        [0, 1, 0],
        [0, 0, 1],
        [-7, 7, 0],
      ],
    ),
    (
      'eigen-3x3-eigenspace',
      [
        [2, 0, 1],
        [0, 2, 0],
        [0, 0, 5],
      ],
    ),
    (
      'eigen-3x3-defective',
      [
        [2, 1, 0],
        [0, 2, 0],
        [0, 0, 2],
      ],
    ),
  ])
    label: EigenSolver.solve(Matrix.fromInts(rows)),
};

/// Step explanations are prose, not TeX. Anything a solver puts into
/// `explanationParams` reaches the reader through [readableMathProse], so no
/// backslash command or caret may survive that conversion.
void main() {
  group('Solver explanations never show raw LaTeX', () {
    final solutions = <String, StepSolution>{
      'rref': GaussJordanSolver.solve(
        Matrix.fromInts([
          [2, 4, 6],
          [1, 3, 5],
          [0, 1, 2],
        ]),
      ),
      'ref': GaussJordanSolver.solve(
        Matrix.fromInts([
          [0, 2, 1],
          [3, 1, 4],
          [1, 1, 1],
        ]),
        const EliminationOptions(toRref: false),
      ),
      'system-unique': LinearSystemsSolver.solve(
        Matrix.fromInts([
          [2, 1, 5],
          [1, -3, -1],
        ]),
      ),
      'system-infinite': LinearSystemsSolver.solve(
        Matrix.fromInts([
          [1, 1, 1, 3],
          [2, 2, 2, 6],
        ]),
      ),
      'system-inconsistent': LinearSystemsSolver.solve(
        Matrix.fromInts([
          [1, 1, 1],
          [1, 1, 2],
        ]),
      ),
      'det-2x2': DeterminantSolver.solve(
        Matrix.fromInts([
          [3, -2],
          [4, 5],
        ]),
      ),
      'det-3x3': DeterminantSolver.solve(
        Matrix.fromInts([
          [2, -1, 3],
          [0, 4, -2],
          [1, 1, 5],
        ]),
      ),
      'det-4x4': DeterminantSolver.solve(
        Matrix.fromInts([
          [1, 2, 3, 4],
          [0, 1, 2, 3],
          [2, 0, 1, 1],
          [1, 1, 0, 2],
        ]),
      ),
      'inverse-2x2': InverseSolver.solve(
        Matrix.fromInts([
          [3, -2],
          [4, 5],
        ]),
      ),
      'inverse-3x3': InverseSolver.solve(
        Matrix.fromInts([
          [2, 0, 1],
          [1, 3, 2],
          [1, 1, 3],
        ]),
      ),
      'inverse-singular': InverseSolver.solve(
        Matrix.fromInts([
          [1, 2],
          [2, 4],
        ]),
      ),
      'rank': RankNullitySolver.solve(
        Matrix.fromInts([
          [1, 2, 0],
          [0, 1, 4],
          [1, 3, 4],
        ]),
      ),
      'eigen-2x2-exact': EigenSolver.solve(
        Matrix.fromInts([
          [4, 1],
          [2, 3],
        ]),
      ),
      'eigen-2x2-irrational': EigenSolver.solve(
        Matrix.fromInts([
          [1, 1],
          [1, 0],
        ]),
      ),
      'eigen-2x2-complex': EigenSolver.solve(
        Matrix.fromInts([
          [0, -1],
          [1, 0],
        ]),
      ),
      'eigen-2x2-repeated': EigenSolver.solve(Matrix.identity(2)),
      'eigen-3x3': EigenSolver.solve(
        Matrix.fromInts([
          [2, 0, 0],
          [1, 3, 0],
          [0, 1, 4],
        ]),
      ),
      'eigen-3x3-no-rational-root': EigenSolver.solve(
        Matrix.fromInts([
          [1, 1, 0],
          [1, 0, 1],
          [0, 1, 1],
        ]),
      ),
      ..._exactEigenLessons(),
      'lu': LUDecompositionSolver.solve(
        Matrix.fromInts([
          [0, 2, 1],
          [3, 1, 4],
          [1, 1, 1],
        ]),
      ),
      'add': MatrixArithmeticSolver.add(
        Matrix.fromInts([
          [1, -2],
          [3, 4],
        ]),
        Matrix.fromInts([
          [5, -6],
          [-7, 8],
        ]),
      ),
      'multiply': MatrixArithmeticSolver.multiply(
        Matrix.fromInts([
          [1, -2],
          [3, 4],
        ]),
        Matrix.fromInts([
          [5, -6],
          [-7, 8],
        ]),
      ),
    };

    solutions.forEach((label, solution) {
      test(label, () {
        for (final step in solution.steps) {
          for (final entry in {
            ...step.explanationParams,
            ...step.titleParams,
          }.entries) {
            final prose = readableMathProse(entry.value.toString());
            expect(
              prose,
              isNot(contains(r'\')),
              reason: '$label · ${step.explanationKey} · ${entry.key}',
            );
            expect(
              prose,
              isNot(contains('^')),
              reason: '$label · ${step.explanationKey} · ${entry.key}',
            );
          }
        }
      });
    });
  });

  group('readableMathProse conversions', () {
    test('column vectors become comma separated tuples', () {
      final pair =
          EigenSolver.solve(
                Matrix.fromInts([
                  [4, 1],
                  [2, 3],
                ]),
              ).result
              as EigenResult;
      expect(
        readableMathProse(pair.realEigenpairs.first.vectorLatex),
        'v = (1, 1)',
      );
      final triple =
          EigenSolver.solve(
                Matrix.fromInts([
                  [2, 0, 0],
                  [1, 3, 0],
                  [0, 1, 4],
                ]),
              ).result
              as EigenResult;
      expect(
        readableMathProse(triple.realEigenpairs.first.vectorLatex),
        'v = (2, -2, 1)',
      );
    });

    test('exponents, plus-minus and Greek subscripts are readable', () {
      expect(
        readableMathProse(r'\lambda^2 - 7 \lambda + 10 = 0'),
        'λ² - 7 λ + 10 = 0',
      );
      expect(
        readableMathProse(r'-\lambda^3 + (9)\lambda^2 - (26)\lambda = 0'),
        '-λ³ + (9)λ² - (26)λ = 0',
      );
      expect(readableMathProse(r'0 \pm 1.00i'), '0 ± 1.00i');
      expect(readableMathProse('λ_{1}'), 'λ₁');
      expect(
        readableMathProse(r'\text{No Solution } (\emptyset)'),
        'No Solution (∅)',
      );
    });

    test('existing row-operation notation is unchanged', () {
      expect(readableMathProse(r'R_2 \leftarrow R_2 - 2R_1'), 'R₂ ← R₂ - 2R₁');
      expect(readableMathProse(r'R_1 \leftrightarrow R_2'), 'R₁ ↔ R₂');
      expect(
        readableMathProse(r'\frac{1}{2} \cdot \frac{-3}{4}'),
        '1/2 · -3/4',
      );
    });
  });

  group('Eigen step titles are prose, not TeX', () {
    test('exact and irrational eigenvalue titles read cleanly', () {
      for (final matrix in [
        Matrix.fromInts([
          [4, 1],
          [2, 3],
        ]),
        Matrix.fromInts([
          [1, 1],
          [1, 0],
        ]),
      ]) {
        for (final step in EigenSolver.solve(matrix).steps) {
          for (final value in step.titleParams.values) {
            final prose = readableMathProse(value.toString());
            expect(prose, isNot(contains(r'\')));
            expect(prose, isNot(contains('^')));
          }
        }
      }
      // The ARB title itself carries a Greek subscript that must render.
      expect(
        readableMathProse('Eigenvector for λ_1 = 5'),
        'Eigenvector for λ₁ = 5',
      );
      expect(
        readableMathProse(r'Approximate vector for λ_2 ≈ \frac{809}{500}'),
        'Approximate vector for λ₂ ≈ 809/500',
      );
    });
  });

  group('No step formula prints a bare negative after an operator', () {
    // "3 + -15", "195 - -2" and "1 * -5" are not acceptable notation; a
    // negative operand must be bracketed.
    final bare = RegExp(r'(?:\+|-|\cdot|·|−)\s*-\d');

    final solutions = <String, StepSolution>{
      'add-negatives': MatrixArithmeticSolver.add(
        Matrix([
          [Rational(3), Rational(-1, 2)],
          [Rational.zero, Rational(7)],
        ]),
        Matrix([
          [Rational(-15), Rational(1, 2)],
          [Rational(4), Rational(-17)],
        ]),
      ),
      'multiply-negatives': MatrixArithmeticSolver.multiply(
        Matrix.fromInts([
          [1, -5],
          [-3, 4],
        ]),
        Matrix.fromInts([
          [-2, 6],
          [7, -8],
        ]),
      ),
      'det-2x2-negative-anti': DeterminantSolver.solve(
        Matrix.fromInts([
          [13, -1],
          [4, 15],
        ]),
      ),
      'det-3x3-negatives': DeterminantSolver.solve(
        Matrix.fromInts([
          [-2, 1, 2],
          [6, -1, 5],
          [6, 1, 1],
        ]),
      ),
      'elimination-negative-multiplier': GaussJordanSolver.solve(
        Matrix.fromInts([
          [1, 2],
          [-3, 5],
        ]),
      ),
      'lu-negative-multiplier': LUDecompositionSolver.solve(
        Matrix.fromInts([
          [2, 1],
          [-4, 3],
        ]),
      ),
      ..._exactEigenLessons(),
    };

    solutions.forEach((label, solution) {
      test(label, () {
        for (final step in solution.steps) {
          for (final sub in step.subCalculations) {
            expect(
              bare.hasMatch(sub.formulaLatex),
              isFalse,
              reason:
                  '$label cell (${sub.targetRow},${sub.targetCol}): '
                  '"${sub.formulaLatex}"',
            );
          }
          for (final entry in step.explanationParams.entries) {
            final text = readableMathProse(entry.value.toString());
            expect(
              bare.hasMatch(text),
              isFalse,
              reason: '$label ${step.explanationKey}.${entry.key}: "$text"',
            );
          }
        }
      });
    });
  });

  group('Exact eigen lessons read as prose in every language', () {
    // Irrational, complex and cubic eigenvalues reach the step text as plain
    // text (√, ±, i) or as TeX that readableMathProse supports; either way
    // the reader never sees a command, a caret or an approximation.
    for (final locale in AppLocalizations.supportedLocales) {
      test(locale.languageCode, () {
        final l10n = lookupAppLocalizations(locale);
        _exactEigenLessons().forEach((label, solution) {
          for (final step in solution.steps) {
            for (final (key, params) in [
              (step.titleKey, step.titleParams),
              (step.explanationKey, step.explanationParams),
            ]) {
              final text = readableMathProse(
                localizedStepText(l10n, key, params),
              );
              final reason = '$label · $key: $text';
              expect(text, isNot(key), reason: reason);
              expect(text, isNot(contains(r'\')), reason: reason);
              expect(text, isNot(contains('^')), reason: reason);
              expect(text, isNot(contains('≈')), reason: reason);
              expect(text, isNot(matches(RegExp(r'\d\.\d'))), reason: reason);
            }
          }
        });
      });
    }
  });

  group('Eigenvector description never subtracts a negative eigenvalue', () {
    for (final locale in AppLocalizations.supportedLocales) {
      test(locale.languageCode, () {
        final text = lookupAppLocalizations(locale)
            .eigen_vector_desc('-4', '(1, 0)');
        expect(text, contains('λ = -4'));
        expect(text, isNot(contains('- -4')));
        expect(text, isNot(contains('− -4')));
      });
    }
  });

  group('2x2 determinant subtraction brackets a negative operand', () {
    for (final locale in AppLocalizations.supportedLocales) {
      test(locale.languageCode, () {
        final l10n = lookupAppLocalizations(locale);
        // det([[13, -1], [4, 15]]) = 195 - (-4); an unbracketed "195 - -4"
        // is not acceptable mathematical notation.
        final text = l10n.det_2x2_final_desc('-4', '199', '195');
        expect(text, contains('(-4)'));
        expect(text, isNot(contains('- -4')));
        expect(text, isNot(contains('− -4')));
        expect(text, contains('(195)'));
      });
    }
  });
}
