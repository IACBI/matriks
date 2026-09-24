import 'package:matrix_engine/src/algorithms/arithmetic.dart';
import 'package:matrix_engine/src/algorithms/lu_decomposition.dart';
import 'package:matrix_engine/src/model/matrix.dart';
import 'package:matrix_engine/src/rational/rational.dart';
import 'package:test/test.dart';

void main() {
  group('LUDecompositionSolver (Realistic Linear Algebra Problems)', () {
    test(
      'Problem 1: Classic 3x3 Doolittle LU factorization without row swaps',
      () {
        // Matrix from Gilbert Strang:
        // [  2  1  1 ]
        // [  4 -6  0 ]
        // [ -2  7  2 ]
        final a = Matrix.fromInts([
          [2, 1, 1],
          [4, -6, 0],
          [-2, 7, 2],
        ]);

        final sol = LUDecompositionSolver.solve(a);
        expect(sol.isSuccess, isTrue);

        final result = sol.result as LUResult;
        expect(result.isPermuted, isFalse);

        final l = result.lMatrix;
        final u = result.uMatrix;

        // Verify L is unit lower triangular
        expect(l.get(0, 0), equals(Rational.one));
        expect(l.get(1, 1), equals(Rational.one));
        expect(l.get(2, 2), equals(Rational.one));
        expect(l.get(0, 1), equals(Rational.zero));
        expect(l.get(0, 2), equals(Rational.zero));
        expect(l.get(1, 2), equals(Rational.zero));

        // Multipliers in L
        expect(l.get(1, 0), equals(Rational.fromInt(2)));
        expect(l.get(2, 0), equals(Rational.fromInt(-1)));
        expect(l.get(2, 1), equals(Rational.fromInt(-1)));

        // Verify U is upper triangular
        expect(u.get(1, 0), equals(Rational.zero));
        expect(u.get(2, 0), equals(Rational.zero));
        expect(u.get(2, 1), equals(Rational.zero));

        // Verify L * U == A
        final luMult = MatrixArithmeticSolver.multiply(l, u);
        expect(luMult.finalMatrix, equals(a));
      },
    );

    test('Problem 2: 2x2 LU factorization', () {
      // [ 3 1 ]
      // [ 6 5 ]
      // L = [ 1 0; 2 1 ], U = [ 3 1; 0 3 ]
      final a = Matrix.fromInts([
        [3, 1],
        [6, 5],
      ]);

      final sol = LUDecompositionSolver.solve(a);
      expect(sol.isSuccess, isTrue);

      final result = sol.result as LUResult;
      final luMult = MatrixArithmeticSolver.multiply(
        result.lMatrix,
        result.uMatrix,
      );
      expect(luMult.finalMatrix, equals(a));
    });
  });
}
