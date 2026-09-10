import 'package:matrix_engine/src/algorithms/arithmetic.dart';
import 'package:matrix_engine/src/model/matrix.dart';
import 'package:matrix_engine/src/rational/rational.dart';
import 'package:test/test.dart';

void main() {
  group('MatrixArithmeticSolver', () {
    test('Matrix Addition 2x2', () {
      final a = Matrix.fromInts([
        [1, 2],
        [3, 4],
      ]);
      final b = Matrix.fromInts([
        [5, 6],
        [7, 8],
      ]);

      final sol = MatrixArithmeticSolver.add(a, b);
      expect(sol.isSuccess, isTrue);
      expect(sol.finalMatrix.get(0, 0), equals(Rational.fromInt(6)));
      expect(sol.finalMatrix.get(1, 1), equals(Rational.fromInt(12)));
      expect(sol.steps.length, equals(4));
    });

    test('Matrix Multiplication 2x3 * 3x2', () {
      // [ 1 2 3 ] * [ 7  8 ] = [ 1*7+2*9+3*11 , 1*8+2*10+3*12 ] = [ 58 , 64 ]
      // [ 4 5 6 ]   [ 9 10 ]   [ 4*7+5*9+6*11 , 4*8+5*10+6*12 ]   [ 139, 154 ]
      //             [ 11 12 ]
      final a = Matrix.fromInts([
        [1, 2, 3],
        [4, 5, 6],
      ]);
      final b = Matrix.fromInts([
        [7, 8],
        [9, 10],
        [11, 12],
      ]);

      final sol = MatrixArithmeticSolver.multiply(a, b);
      expect(sol.isSuccess, isTrue);
      expect(sol.finalMatrix.rows, equals(2));
      expect(sol.finalMatrix.cols, equals(2));
      expect(sol.finalMatrix.get(0, 0), equals(Rational.fromInt(58)));
      expect(sol.finalMatrix.get(0, 1), equals(Rational.fromInt(64)));
      expect(sol.finalMatrix.get(1, 0), equals(Rational.fromInt(139)));
      expect(sol.finalMatrix.get(1, 1), equals(Rational.fromInt(154)));
      expect(sol.steps.length, equals(4));
    });

    test('Multiplication dimension mismatch rejection', () {
      final a = Matrix.fromInts([
        [1, 2],
      ]);
      final b = Matrix.fromInts([
        [1, 2],
      ]);
      final sol = MatrixArithmeticSolver.multiply(a, b);
      expect(sol.isSuccess, isFalse);
      expect(sol.errorMessageKey, equals('error_dimension_mismatch_multiply'));
    });
  });
}
