import 'package:matrix_engine/src/algorithms/inverse.dart';
import 'package:matrix_engine/src/model/matrix.dart';
import 'package:matrix_engine/src/rational/rational.dart';
import 'package:test/test.dart';

void main() {
  group('InverseSolver', () {
    test('2x2 Inversion', () {
      // [ 4  7 ]
      // [ 2  6 ]
      // det = 24 - 14 = 10
      // inv = (1/10) * [ 6 -7 ; -2 4 ] = [ 3/5, -7/10 ; -1/5, 2/5 ]
      final m = Matrix.fromInts([
        [4, 7],
        [2, 6],
      ]);

      final sol = InverseSolver.solve(m);
      expect(sol.isSuccess, isTrue);
      final inv = sol.result as Matrix;
      expect(inv.get(0, 0), equals(Rational(3, 5)));
      expect(inv.get(0, 1), equals(Rational(-7, 10)));
      expect(inv.get(1, 0), equals(Rational(-1, 5)));
      expect(inv.get(1, 1), equals(Rational(2, 5)));
    });

    test('3x3 Inversion via [A|I] Gauss-Jordan', () {
      // Invertible matrix:
      // [ 1  2  3 ]
      // [ 0  1  4 ]
      // [ 5  6  0 ]
      final m = Matrix.fromInts([
        [1, 2, 3],
        [0, 1, 4],
        [5, 6, 0],
      ]);

      final sol = InverseSolver.solve(m);
      expect(sol.isSuccess, isTrue);
      final inv = sol.result as Matrix;

      // Verify A * A^-1 == I
      // Let's check a few known entries:
      // inv = [ -24, 18, 5 ; 20, -15, -4 ; -5, 4, 1 ]
      expect(inv.get(0, 0), equals(Rational.fromInt(-24)));
      expect(inv.get(0, 1), equals(Rational.fromInt(18)));
      expect(inv.get(0, 2), equals(Rational.fromInt(5)));
      expect(inv.get(1, 0), equals(Rational.fromInt(20)));
    });

    test('Rejects singular matrix with clear error', () {
      final singular = Matrix.fromInts([
        [1, 2],
        [2, 4],
      ]);

      final sol = InverseSolver.solve(singular);
      expect(sol.isSuccess, isFalse);
      expect(sol.errorMessageKey, equals('error_matrix_is_singular'));
    });
  });
}
