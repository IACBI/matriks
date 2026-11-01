import 'package:matrix_engine/matrix_engine.dart';
import 'package:test/test.dart';

/// A negative operand is bracketed wherever a calculation is written out, so
/// no formula reads "2 \cdot -4", "3 + -15" or "5 - -2".
void main() {
  final unbracketed = RegExp(r'(\\cdot|[+\-]) -');

  Iterable<String> formulas(StepSolution solution) sync* {
    for (final step in solution.steps) {
      for (final sub in step.subCalculations) {
        yield sub.formulaLatex;
      }
      for (final value in [
        ...step.titleParams.values,
        ...step.explanationParams.values,
      ]) {
        if (value is String) yield value;
      }
    }
  }

  final negative = [
    [-2, 3, -1, 4, -5],
    [4, -5, 2, -3, 1],
    [-1, -2, 6, 5, -4],
    [3, 1, -2, -6, 2],
    [-5, 4, 3, -1, -3],
  ];
  Matrix square(int n) => Matrix.fromInts([
    for (final row in negative.take(n)) row.take(n).toList(),
  ]);

  test('Every solver brackets negative operands', () {
    final solutions = <String, StepSolution>{
      for (var n = 1; n <= 5; n++) ...{
        'rref $n': GaussJordanSolver.solve(square(n)),
        'ref $n': GaussJordanSolver.solve(
          square(n),
          const EliminationOptions(toRref: false),
        ),
        'det $n': DeterminantSolver.solve(square(n)),
        'inverse $n': InverseSolver.solve(square(n)),
        'lu $n': LUDecompositionSolver.solve(square(n)),
        'rank $n': RankNullitySolver.solve(square(n)),
        'add $n': MatrixArithmeticSolver.add(square(n), square(n)),
        'multiply $n': MatrixArithmeticSolver.multiply(square(n), square(n)),
      },
      'eigen 2': EigenSolver.solve(
        Matrix.fromInts([
          [1, -2],
          [3, -4],
        ]),
      ),
      'system': LinearSystemsSolver.solve(
        Matrix.fromInts([
          [-2, 3, -1],
          [4, -5, 2],
        ]),
      ),
    };
    for (final MapEntry(key: name, value: solution) in solutions.entries) {
      for (final formula in formulas(solution)) {
        expect(
          unbracketed.hasMatch(formula),
          isFalse,
          reason: '$name: $formula',
        );
      }
    }
  });

  test('2×2 diagonal products bracket negative factors', () {
    final steps = DeterminantSolver.solve(
      Matrix.fromInts([
        [-3, -2],
        [-5, -4],
      ]),
    ).steps;
    // The template writes "{a} · {d}", so each factor is an operand.
    expect(steps[0].explanationParams, containsPair('a', '(-3)'));
    expect(steps[0].explanationParams, containsPair('d', '(-4)'));
    expect(steps[1].explanationParams, containsPair('b', '(-2)'));
    expect(steps[1].explanationParams, containsPair('c', '(-5)'));
  });

  test('Characteristic equations omit zero and unit coefficients', () {
    String poly(List<List<int>> rows) =>
        EigenSolver.solve(Matrix.fromInts(rows)).steps
                .expand((step) => step.explanationParams.entries)
                .firstWhere((entry) => entry.key == 'poly')
                .value
            as String;
    expect(
      poly([
        [0, 1],
        [-1, 0],
      ]),
      r'\lambda^2 + 1 = 0',
    );
    expect(
      poly([
        [1, 0],
        [0, 0],
      ]),
      r'\lambda^2 - \lambda = 0',
    );
    expect(
      poly([
        [5, 2],
        [2, 2],
      ]),
      r'\lambda^2 - 7 \lambda + 6 = 0',
    );
    expect(
      poly([
        [-1, 1],
        [0, 0],
      ]),
      r'\lambda^2 + \lambda = 0',
    );
    expect(
      poly([
        [2, 0, 0],
        [0, 3, 0],
        [0, 0, 4],
      ]),
      r'-\lambda^3 + 9 \lambda^2 - 26 \lambda + 24 = 0',
    );
    expect(
      poly([
        [0, 1, 0],
        [0, 0, 1],
        [1, 0, 0],
      ]),
      r'-\lambda^3 + 1 = 0',
    );
    expect(
      poly([
        [1, 2, 0],
        [2, 1, 0],
        [0, 0, 0],
      ]),
      r'-\lambda^3 + 2 \lambda^2 + 3 \lambda = 0',
    );
  });
}
