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
}
