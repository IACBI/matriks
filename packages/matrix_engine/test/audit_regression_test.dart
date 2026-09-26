import 'package:matrix_engine/matrix_engine.dart';
import 'package:test/test.dart';

void main() {
  test(
    '3x3 eigenvectors satisfy A v = lambda v including dependent coordinates',
    () {
      final matrix = Matrix.fromInts([
        [1, 1, 0],
        [0, 2, 1],
        [0, 0, 3],
      ]);
      final result = EigenSolver.solve(matrix).result as EigenResult;
      expect(result.realEigenpairs.length, 3);
      for (final pair in result.realEigenpairs) {
        expect(pair.eigenvector.any((v) => !v.isZero), isTrue);
        for (var row = 0; row < 3; row++) {
          var product = Rational.zero;
          for (var col = 0; col < 3; col++) {
            product += matrix.get(row, col) * pair.eigenvector[col];
          }
          expect(product, pair.eigenvalue * pair.eigenvector[row]);
        }
      }
    },
  );

  test('LU transformations accurately reproduce each recorded matrix', () {
    final solution = LUDecompositionSolver.solve(
      Matrix.fromInts([
        [0, 2, 1],
        [2, 1, 0],
        [1, 3, 2],
      ]),
    );
    for (final step in solution.steps) {
      final before = Matrix(
        List.generate(
          step.matrixBefore.rows,
          (r) => List.generate(
            step.matrixBefore.cols,
            (c) => step.matrixBefore.get(r, c),
          ),
        ),
      );
      final transformation = step.transformation;
      Matrix? expected;
      if (transformation is RowSwapTransformation) {
        expected = before.swapRows(transformation.rowA, transformation.rowB);
      } else if (transformation is RowEliminationTransformation) {
        expected = before.addRowMultiple(
          transformation.targetRow,
          transformation.sourceRow,
          transformation.factor,
        );
      }
      if (expected != null) {
        for (var r = 0; r < expected.rows; r++) {
          for (var c = 0; c < expected.cols; c++) {
            expect(step.matrixAfter.get(r, c), expected.get(r, c));
          }
        }
      }
    }
  });

  test('Already-reduced matrices retain a viewable result step', () {
    for (final matrix in [Matrix.identity(3), Matrix.zero(2, 3)]) {
      final solution = GaussJordanSolver.solve(matrix);
      expect(solution.steps, isNotEmpty);
      expect(solution.finalMatrix, matrix);
    }
  });

  test('Decimal fractional part cannot contain a sign', () {
    expect(Rational.tryParse('1.-2'), isNull);
    expect(Rational.tryParse('1.+2'), isNull);
    expect(Rational.parse('-0.25'), Rational(-1, 4));
  });

  test('Matrix.fromDoubles reads exponent-form doubles exactly', () {
    final m = Matrix.fromDoubles([
      [0.5, 0.1, 1e-7],
      [1.5e21, -2.5e-8, 100.0],
    ]);
    expect(m.get(0, 0), Rational(1, 2));
    expect(m.get(0, 1), Rational(1, 10));
    expect(m.get(0, 2), Rational(1, 10000000));
    expect(m.get(1, 0), Rational(BigInt.parse('1500000000000000000000')));
    expect(m.get(1, 1), Rational(-1, 40000000));
    expect(m.get(1, 2), Rational(100));
    for (final bad in [double.nan, double.infinity, double.negativeInfinity]) {
      expect(
        () => Matrix.fromDoubles([
          [bad],
        ]),
        throwsArgumentError,
      );
    }
  });
}
