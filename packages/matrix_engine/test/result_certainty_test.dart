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
  test('Out-of-range and missing roots never imply a complete spectrum', () {
    final partial = EigenSolver.solve(
      Matrix.fromInts([
        [1, 0, 0],
        [0, 30, 0],
        [0, 0, 40],
      ]),
    );
    expect(partial.completeness, ResultCompleteness.partial);
    expect((partial.result as EigenResult).realEigenpairs.length, 1);
    final missing = EigenSolver.solve(
      Matrix.fromInts([
        [25, 0, 0],
        [0, 30, 0],
        [0, 0, 40],
      ]),
    );
    expect(missing.completeness, ResultCompleteness.unsupported);
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
