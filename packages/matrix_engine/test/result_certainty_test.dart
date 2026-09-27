import 'package:matrix_engine/matrix_engine.dart';
import 'package:test/test.dart';

/// A·v = λ·v for every basis vector of every eigenpair, in Q(λ).
void _expectExactEigenpairs(Matrix matrix, EigenResult result) {
  for (final pair in result.eigenpairs) {
    final field = pair.eigenvalue.field;
    for (final v in pair.eigenspaceBasis) {
      expect(v.any((e) => !e.isZero), isTrue);
      for (var r = 0; r < matrix.rows; r++) {
        var sum = field.zero;
        for (var c = 0; c < matrix.cols; c++) {
          sum += field.rational(matrix.get(r, c)) * v[c];
        }
        expect(sum, field.generator * v[r]);
      }
    }
  }
}

void main() {
  test('Irrational 2x2 roots are exact square roots with exact vectors', () {
    final matrix = Matrix.fromInts([
      [0, 2],
      [1, 0],
    ]);
    final solution = EigenSolver.solve(matrix);
    expect(solution.accuracy, ResultAccuracy.exact);
    expect(solution.decimalPlaces, isNull);
    expect(solution.completeness, ResultCompleteness.complete);
    expect(solution.resultLatex, isNot(contains(r'\approx')));
    expect(solution.resultLatex, contains(r'\sqrt{2}'));
    expect(solution.steps.last.explanationKey, 'eigen_vector_surd_desc');
    final result = solution.result as EigenResult;
    expect(result.realEigenpairs, isEmpty);
    expect(result.eigenpairs.map((p) => p.eigenvalue.latex), [
      r'\sqrt{2}',
      r'-\sqrt{2}',
    ]);
    for (final pair in result.eigenpairs) {
      expect(pair.algebraicMultiplicity, 1);
    }
    _expectExactEigenpairs(matrix, result);
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
  test('A rational root deflates to an exact irrational quadratic pair', () {
    final matrix = Matrix.fromInts([
      [3, 0, 0],
      [0, 0, 2],
      [0, 1, 0],
    ]);
    final solution = EigenSolver.solve(matrix);
    expect(solution.accuracy, ResultAccuracy.exact);
    expect(solution.decimalPlaces, isNull);
    expect(solution.completeness, ResultCompleteness.complete);
    final result = solution.result as EigenResult;
    expect(result.realEigenpairs.map((p) => p.eigenvalue), [Rational(3)]);
    expect(result.eigenpairs.map((p) => p.eigenvalue.latex), [
      r'-\sqrt{2}',
      r'\sqrt{2}',
      '3',
    ]);
    expect(solution.steps[1].explanationKey, 'eigen_roots_factored_desc');
    _expectExactEigenpairs(matrix, result);
  });
  test('An irreducible cubic with three real roots is exact in cosines', () {
    // λ³ - 3λ - 1 has three irrational real roots, 2cos(π/9 - 2πk/3).
    final matrix = Matrix.fromInts([
      [0, 1, 0],
      [0, 0, 1],
      [1, 3, 0],
    ]);
    final solution = EigenSolver.solve(matrix);
    expect(solution.accuracy, ResultAccuracy.exact);
    expect(solution.completeness, ResultCompleteness.complete);
    final result = solution.result as EigenResult;
    expect(result.realEigenpairs, isEmpty);
    // Angles in [0, π]: 7π/9 rather than the equal 11π/9.
    expect(result.eigenpairs.map((p) => p.eigenvalue.latex), [
      r'2\cos\left(\frac{7\pi}{9}\right)',
      r'2\cos\left(\frac{5\pi}{9}\right)',
      r'2\cos\left(\frac{\pi}{9}\right)',
    ]);
    expect(result.eigenpairs.map((p) => p.eigenvalue.approximate), [
      closeTo(-1.532, 1e-3),
      closeTo(-0.347, 1e-3),
      closeTo(1.879, 1e-3),
    ]);
    expect(solution.steps[1].explanationKey, 'eigen_roots_trig_desc');
    for (final step in solution.steps.skip(2)) {
      expect(step.explanationKey, 'eigen_vector_cubic_desc');
    }
    _expectExactEigenpairs(matrix, result);
  });
  test('One real root with a complex pair is complete and exact', () {
    final matrix = Matrix.fromInts([
      [2, 0, 0],
      [0, 0, -1],
      [0, 1, 0],
    ]);
    final solution = EigenSolver.solve(matrix);
    final result = solution.result as EigenResult;
    expect(result.hasComplexEigenvalues, isTrue);
    expect(result.realEigenpairs.single.eigenvalue, Rational(2));
    expect(solution.completeness, ResultCompleteness.complete);
    expect(solution.accuracy, ResultAccuracy.exact);
    expect(solution.resultLatex, contains(r'\lambda = i \implies'));
    expect(solution.resultLatex, contains(r'\lambda = -i \implies'));
    expect(solution.steps[1].explanationKey, 'eigen_roots_factored_desc');
    _expectExactEigenpairs(matrix, result);
  });
  test('Coefficients far beyond floating point are still solved exactly', () {
    final big = Rational.parse('1000000000000000000000000000000');
    final matrix = Matrix([
      [big, Rational.one, Rational.zero],
      [Rational.zero, -big, Rational.one],
      [Rational.one, Rational.zero, Rational(7)],
    ]);
    final solution = EigenSolver.solve(matrix);
    expect(solution.completeness, ResultCompleteness.complete);
    expect(solution.accuracy, ResultAccuracy.exact);
    final result = solution.result as EigenResult;
    expect(result.eigenpairs.fold(0, (n, p) => n + p.algebraicMultiplicity), 3);
    _expectExactEigenpairs(matrix, result);
  });
  test('Repeated roots carry their full eigenspace and multiplicity', () {
    for (final size in [2, 3]) {
      final solution = EigenSolver.solve(Matrix.identity(size));
      expect(solution.completeness, ResultCompleteness.complete);
      final result = solution.result as EigenResult;
      expect(result.realEigenpairs.single.algebraicMultiplicity, size);
      final pair = result.eigenpairs.single;
      expect(pair.algebraicMultiplicity, size);
      expect(pair.geometricMultiplicity, size);
      expect(pair.isDefective, isFalse);
      expect(result.isDiagonalizable, isTrue);
    }
  });
  test('Complex eigenvalues have exact complex eigenvectors; other sizes are '
      'unsupported', () {
    final matrix = Matrix.fromInts([
      [0, -1],
      [1, 0],
    ]);
    final complex = EigenSolver.solve(matrix);
    expect(complex.completeness, ResultCompleteness.complete);
    expect(complex.accuracy, ResultAccuracy.exact);
    expect(complex.decimalPlaces, isNull);
    final result = complex.result as EigenResult;
    expect(result.hasComplexEigenvalues, true);
    expect(result.eigenpairs.map((p) => p.eigenvalue.latex), ['i', '-i']);
    _expectExactEigenpairs(matrix, result);
    final four = EigenSolver.solve(Matrix.identity(4));
    expect(four.isSuccess, false);
    expect(four.completeness, ResultCompleteness.unsupported);
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
