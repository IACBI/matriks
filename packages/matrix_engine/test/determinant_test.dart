import 'package:matrix_engine/src/algorithms/determinant.dart';
import 'package:matrix_engine/src/model/matrix.dart';
import 'package:matrix_engine/src/rational/rational.dart';
import 'package:test/test.dart';

void main() {
  group('DeterminantSolver', () {
    test('2x2 Determinant', () {
      // [ 4  6 ]
      // [ 3  8 ]
      // det = 4*8 - 6*3 = 32 - 18 = 14
      final m = Matrix.fromInts([
        [4, 6],
        [3, 8],
      ]);

      final sol = DeterminantSolver.solve(m);
      expect(sol.isSuccess, isTrue);
      expect(sol.result, equals(Rational.fromInt(14)));
      expect(sol.steps.length, equals(3));
    });

    test('3x3 Determinant (Sarrus)', () {
      // [ 1  2  3 ]
      // [ 0  1  4 ]
      // [ 5  6  0 ]
      // det = 1*(0 - 24) - 2*(0 - 20) + 3*(0 - 5) = -24 + 40 - 15 = 1
      final m = Matrix.fromInts([
        [1, 2, 3],
        [0, 1, 4],
        [5, 6, 0],
      ]);

      final sol = DeterminantSolver.solve(m, method: DeterminantMethod.sarrus);
      expect(sol.isSuccess, isTrue);
      expect(sol.result, equals(Rational.fromInt(1)));
    });

    test('4x4 Determinant (Triangularization)', () {
      // Identity 4x4 -> det = 1
      final id4 = Matrix.identity(4);
      final sol = DeterminantSolver.solve(id4, method: DeterminantMethod.triangular);
      expect(sol.result, equals(Rational.one));

      // 4x4 upper triangular
      final ut = Matrix.fromInts([
        [2, 3, 1, 5],
        [0, 3, 4, 1],
        [0, 0, 4, 2],
        [0, 0, 0, 5],
      ]);
      // det = 2 * 3 * 4 * 5 = 120
      final solUt = DeterminantSolver.solve(ut, method: DeterminantMethod.triangular);
      expect(solUt.result, equals(Rational.fromInt(120)));
    });
  });
}
