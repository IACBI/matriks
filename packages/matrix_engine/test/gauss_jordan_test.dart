import 'package:matrix_engine/src/algorithms/gauss_jordan.dart';
import 'package:matrix_engine/src/model/matrix.dart';
import 'package:matrix_engine/src/rational/rational.dart';
import 'package:test/test.dart';

void main() {
  group('GaussJordanSolver', () {
    test('Solves 2x2 matrix to RREF', () {
      // [ 2  4 ] -> [ 1 0 ]
      // [ 1  3 ]    [ 0 1 ]
      final m = Matrix.fromInts([
        [2, 4],
        [1, 3],
      ]);

      final solution = GaussJordanSolver.solve(m);
      expect(solution.isSuccess, isTrue);
      expect(solution.finalMatrix, equals(Matrix.identity(2)));
      expect(solution.steps.isNotEmpty, isTrue);
    });

    test('Solves 3x3 matrix to RREF', () {
      // Invertible matrix with det = 1
      // [ 1  2  3 ]
      // [ 0  1  4 ]
      // [ 5  6  0 ]
      final m = Matrix.fromInts([
        [1, 2, 3],
        [0, 1, 4],
        [5, 6, 0],
      ]);

      final solution = GaussJordanSolver.solve(m);
      expect(solution.isSuccess, isTrue);
      expect(solution.finalMatrix, equals(Matrix.identity(3)));
      expect(solution.steps.length, greaterThan(3));
    });

    test('Handles singular matrix (dependent rows)', () {
      // [ 1  2 ] -> [ 1  2 ]
      // [ 2  4 ]    [ 0  0 ]
      final m = Matrix.fromInts([
        [1, 2],
        [2, 4],
      ]);

      final solution = GaussJordanSolver.solve(m);
      expect(solution.isSuccess, isTrue);
      expect(solution.finalMatrix.get(1, 0), equals(Rational.zero));
      expect(solution.finalMatrix.get(1, 1), equals(Rational.zero));
    });
  });
}
