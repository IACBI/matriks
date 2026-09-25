import 'package:matrix_engine/src/algorithms/linear_systems.dart';
import 'package:matrix_engine/src/model/matrix.dart';
import 'package:matrix_engine/src/model/step.dart';
import 'package:matrix_engine/src/rational/rational.dart';
import 'package:test/test.dart';

void main() {
  group('LinearSystemsSolver (Realistic Linear Algebra Problems)', () {
    test('Problem 1: Unique solution 3x3 system', () {
      // Equations:
      //  x +  y +  z =  6
      //       2y + 5z = -4
      // 2x + 5y -  z = 27
      // Augmented matrix:
      // [ 1  1  1 |  6 ]
      // [ 0  2  5 | -4 ]
      // [ 2  5 -1 | 27 ]
      // Exact solution: x = 5, y = 3, z = -2
      final augmented = Matrix.fromInts([
        [1, 1, 1, 6],
        [0, 2, 5, -4],
        [2, 5, -1, 27],
      ]);

      final sol = LinearSystemsSolver.solve(augmented);
      expect(sol.isSuccess, isTrue);

      final result = sol.result as LinearSystemResult;
      expect(result.type, equals(LinearSystemType.unique));
      expect(result.uniqueSolution, isNotNull);
      expect(result.uniqueSolution![0], equals(Rational.fromInt(5)));
      expect(result.uniqueSolution![1], equals(Rational.fromInt(3)));
      expect(result.uniqueSolution![2], equals(Rational.fromInt(-2)));
    });

    test(
      'Problem 2: Inconsistent system (No solution due to parallel planes)',
      () {
        // Equations:
        //  x +  y = 2
        // 2x + 2y = 5
        // Augmented matrix:
        // [ 1  1 | 2 ]
        // [ 2  2 | 5 ]
        final augmented = Matrix.fromInts([
          [1, 1, 2],
          [2, 2, 5],
        ]);

        final sol = LinearSystemsSolver.solve(augmented);
        expect(sol.isSuccess, isTrue);

        final result = sol.result as LinearSystemResult;
        expect(result.type, equals(LinearSystemType.inconsistent));
      },
    );

    test('Problem 3: Underdetermined system with infinite solutions', () {
      // Equations:
      //  x1 - 2x2 + x3 = 0
      //        2x2 - 8x3 = 8
      // Augmented matrix:
      // [ 1 -2  1 | 0 ]
      // [ 0  2 -8 | 8 ]
      final augmented = Matrix.fromInts([
        [1, -2, 1, 0],
        [0, 2, -8, 8],
      ]);

      final sol = LinearSystemsSolver.solve(augmented);
      expect(sol.isSuccess, isTrue);

      final result = sol.result as LinearSystemResult;
      expect(result.type, equals(LinearSystemType.infinite));
      expect(result.freeVariables, contains(2)); // x3 is free variable
      expect(result.basicVariables, equals([0, 1])); // x1, x2 are basic
    });
  });
}
