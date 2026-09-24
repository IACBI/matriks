import 'package:matrix_engine/matrix_engine.dart';
import 'package:test/test.dart';

void main() {
  test('Irrational 2x2 roots disclose rounding and approximate vectors', () {
    final solution = EigenSolver.solve(
      Matrix.fromInts([
        [0, 2],
        [1, 0],
      ]),
    );
    expect(solution.accuracy, ResultAccuracy.approximate);
    expect(solution.decimalPlaces, 3);
    expect(solution.resultLatex, contains(r'\approx'));
    expect(solution.steps.last.explanationKey, 'eigen_vector_approx_desc');
    final pair = (solution.result as EigenResult).realEigenpairs.first;
    expect(pair.eigenvalue.toDouble().abs(), closeTo(1.414, .00001));
    expect(pair.algebraicMultiplicity, 1);
  });
  test('3x3 roots outside the old integer window are found exactly', () {
    for (final diagonal in [
      [1, 30, 40],
      [25, 30, 40],
    ]) {
      final solution = EigenSolver.solve(
        Matrix.fromInts([
          [diagonal[0], 0, 0],
          [0, diagonal[1], 0],
          [0, 0, diagonal[2]],
        ]),
      );
      expect(solution.completeness, ResultCompleteness.complete);
      expect(solution.accuracy, ResultAccuracy.exact);
      expect(
        (solution.result as EigenResult).realEigenpairs.map(
          (p) => p.eigenvalue,
        ),
        diagonal.map(Rational.fromInt),
      );
    }
  });
  test('Fractional 3x3 roots are exact and satisfy A v = lambda v', () {
    final matrix = Matrix([
      [Rational(1, 2), Rational.zero, Rational.zero],
      [Rational.zero, Rational(7, 3), Rational.zero],
      [Rational.one, Rational.zero, Rational(-5, 4)],
    ]);
    final solution = EigenSolver.solve(matrix);
    expect(solution.completeness, ResultCompleteness.complete);
    expect(solution.accuracy, ResultAccuracy.exact);
    for (final pair in (solution.result as EigenResult).realEigenpairs) {
      for (var r = 0; r < 3; r++) {
        var sum = Rational.zero;
        for (var c = 0; c < 3; c++) {
          sum += matrix.get(r, c) * pair.eigenvector[c];
        }
        expect(sum, pair.eigenvalue * pair.eigenvector[r]);
      }
    }
  });
  test('A rational root deflates to an irrational quadratic pair', () {
    final solution = EigenSolver.solve(
      Matrix.fromInts([
        [3, 0, 0],
        [0, 0, 2],
        [0, 1, 0],
      ]),
    );
    expect(solution.accuracy, ResultAccuracy.approximate);
    expect(solution.decimalPlaces, 3);
    expect(solution.completeness, ResultCompleteness.complete);
    expect(
      (solution.result as EigenResult).realEigenpairs.map((p) => p.eigenvalue),
      [Rational.parse('-1.414'), Rational.parse('1.414'), Rational(3)],
    );
    expect(solution.steps[1].explanationKey, 'eigen_roots_approx_desc');
  });
  test('An irreducible cubic is rounded from exact rational brackets', () {
    // λ³ - 3λ - 1 has three irrational real roots.
    final solution = EigenSolver.solve(
      Matrix.fromInts([
        [0, 1, 0],
        [0, 0, 1],
        [1, 3, 0],
      ]),
    );
    expect(solution.accuracy, ResultAccuracy.approximate);
    expect(solution.completeness, ResultCompleteness.complete);
    final pairs = (solution.result as EigenResult).realEigenpairs;
    expect(pairs.map((p) => p.eigenvalue), [
      Rational.parse('-1.532'),
      Rational.parse('-0.347'),
      Rational.parse('1.879'),
    ]);
    for (final pair in pairs) {
      expect(pair.eigenvector.any((v) => !v.isZero), isTrue);
      expect(solution.steps.last.explanationKey, 'eigen_vector_approx_desc');
    }
  });
  test('One real root with a complex pair is partial, never complete', () {
    final solution = EigenSolver.solve(
      Matrix.fromInts([
        [2, 0, 0],
        [0, 0, -1],
        [0, 1, 0],
      ]),
    );
    final result = solution.result as EigenResult;
    expect(result.hasComplexEigenvalues, isTrue);
    expect(result.realEigenpairs.single.eigenvalue, Rational(2));
    expect(solution.completeness, ResultCompleteness.partial);
    expect(solution.resultLatex, contains(r'\pm 1.00i'));
    expect(solution.steps[1].explanationKey, 'eigen_cubic_complex_desc');
  });
  test('Coefficients too large to estimate are reported as unsupported', () {
    final big = Rational.parse('1000000000000000000000000000000');
    final solution = EigenSolver.solve(
      Matrix([
        [big, Rational.one, Rational.zero],
        [Rational.zero, -big, Rational.one],
        [Rational.one, Rational.zero, Rational(7)],
      ]),
    );
    expect(solution.completeness, ResultCompleteness.unsupported);
    expect(solution.steps.last.explanationKey, 'eigen_irrational_desc');
  });
  test(
    'Repeated roots disclose representative basis and correct multiplicity',
    () {
      for (final size in [2, 3]) {
        final solution = EigenSolver.solve(Matrix.identity(size));
        expect(solution.completeness, ResultCompleteness.partial);
        expect(
          (solution.result as EigenResult)
              .realEigenpairs
              .single
              .algebraicMultiplicity,
          size,
        );
      }
    },
  );
  test('Complex eigenvectors and unsupported dimensions disclose limits', () {
    final complex = EigenSolver.solve(
      Matrix.fromInts([
        [0, -1],
        [1, 0],
      ]),
    );
    expect(complex.completeness, ResultCompleteness.unsupported);
    expect(complex.decimalPlaces, 2);
    expect((complex.result as EigenResult).hasComplexEigenvalues, true);
    expect(EigenSolver.solve(Matrix.identity(4)).isSuccess, false);
  });
  test('Exact distinct roots retain zero residual and complete status', () {
    final matrix = Matrix.fromInts([
      [1, 0, 0],
      [0, 2, 0],
      [0, 0, 3],
    ]);
    final solution = EigenSolver.solve(matrix);
    expect(solution.accuracy, ResultAccuracy.exact);
    expect(solution.completeness, ResultCompleteness.complete);
    for (final pair in (solution.result as EigenResult).realEigenpairs) {
      for (var r = 0; r < 3; r++) {
        var sum = Rational.zero;
        for (var c = 0; c < 3; c++) {
          sum += matrix.get(r, c) * pair.eigenvector[c];
        }
        expect(sum, pair.eigenvalue * pair.eigenvector[r]);
      }
    }
  });
}
