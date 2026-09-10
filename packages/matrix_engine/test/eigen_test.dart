import 'package:matrix_engine/src/algorithms/eigen.dart';
import 'package:matrix_engine/src/model/matrix.dart';
import 'package:matrix_engine/src/rational/rational.dart';
import 'package:test/test.dart';

void main() {
  group('EigenSolver (Realistic Linear Algebra Problems)', () {
    test('Problem 1: Distinct real eigenvalues and eigenvectors for 2x2', () {
      // Matrix:
      // [ 4  1 ]
      // [ 2  3 ]
      // tr = 7, det = 12 - 2 = 10
      // p(λ) = λ² - 7λ + 10 = (λ - 5)(λ - 2) = 0
      // Eigenvalues: λ1 = 5, λ2 = 2
      final m = Matrix.fromInts([
        [4, 1],
        [2, 3],
      ]);

      final sol = EigenSolver.solve(m);
      expect(sol.isSuccess, isTrue);

      final result = sol.result as EigenResult;
      expect(result.hasComplexEigenvalues, isFalse);
      expect(result.realEigenpairs.length, equals(2));

      final eValues = result.realEigenpairs.map((p) => p.eigenvalue).toList();
      expect(eValues, contains(Rational.fromInt(5)));
      expect(eValues, contains(Rational.fromInt(2)));

      // Verify A*v = λ*v for each eigenpair
      for (final pair in result.realEigenpairs) {
        final v = pair.eigenvector;
        final lambda = pair.eigenvalue;
        // A * v
        final av0 = (m.get(0, 0) * v[0]) + (m.get(0, 1) * v[1]);
        final av1 = (m.get(1, 0) * v[0]) + (m.get(1, 1) * v[1]);
        // λ * v
        final lv0 = lambda * v[0];
        final lv1 = lambda * v[1];
        expect(av0, equals(lv0));
        expect(av1, equals(lv1));
      }
    });

    test('Problem 2: 90 degree rotation matrix has complex eigenvalues', () {
      // [ 0 -1 ]
      // [ 1  0 ]
      // p(λ) = λ² + 1 = 0 => λ = ±i
      final m = Matrix.fromInts([
        [0, -1],
        [1, 0],
      ]);

      final sol = EigenSolver.solve(m);
      expect(sol.isSuccess, isTrue);

      final result = sol.result as EigenResult;
      expect(result.hasComplexEigenvalues, isTrue);
      expect(result.realEigenpairs.isEmpty, isTrue);
    });

    test('Problem 3: 3x3 Diagonal matrix eigenvalues are diagonal entries', () {
      // [ 3 0 0 ]
      // [ 0 5 0 ]
      // [ 0 0 -2 ]
      final m = Matrix.fromInts([
        [3, 0, 0],
        [0, 5, 0],
        [0, 0, -2],
      ]);

      final sol = EigenSolver.solve(m);
      expect(sol.isSuccess, isTrue);

      final result = sol.result as EigenResult;
      final eValues = result.realEigenpairs.map((p) => p.eigenvalue).toList();
      expect(eValues, contains(Rational.fromInt(3)));
      expect(eValues, contains(Rational.fromInt(5)));
      expect(eValues, contains(Rational.fromInt(-2)));
    });
  });
}
