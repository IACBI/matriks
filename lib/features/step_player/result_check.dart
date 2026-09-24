import 'package:matrix_engine/matrix_engine.dart';

import '../../l10n/generated/app_localizations.dart';

/// One way to confirm a result independently of the steps that produced it,
/// computed in exact arithmetic: A·A⁻¹ = I, L·U = P·A, Ax = b, Av = λv.
class ResultCheck {
  final String description;
  final String latex;
  final bool holds;

  const ResultCheck({
    required this.description,
    required this.latex,
    required this.holds,
  });
}

Matrix _product(Matrix a, Matrix b) => Matrix([
  for (var r = 0; r < a.rows; r++)
    [
      for (var c = 0; c < b.cols; c++)
        [for (var k = 0; k < a.cols; k++) a.get(r, k) * b.get(k, c)]
            .fold(Rational.zero, (sum, v) => sum + v),
    ],
]);

/// Cofactor expansion along the first row: a different method from the
/// row reduction the determinant lessons use for larger matrices.
Rational _cofactorDeterminant(Matrix m) {
  if (m.rows == 1) return m.get(0, 0);
  var sum = Rational.zero;
  for (var c = 0; c < m.cols; c++) {
    if (m.get(0, c).isZero) continue;
    final term = m.get(0, c) * _cofactorDeterminant(m.submatrix(0, c));
    sum = c.isEven ? sum + term : sum - term;
  }
  return sum;
}

Matrix _column(List<Rational> values) => Matrix([
  for (final v in values) [v],
]);

/// Checks for [solution]; empty when the operation has no independent
/// check worth showing (a sum, a product, an echelon form) or failed.
List<ResultCheck> resultChecks(StepSolution solution, AppLocalizations l) {
  if (!solution.isSuccess) return const [];
  final a = solution.initialMatrix;
  final result = solution.result;
  switch (solution.operationKey) {
    case 'op_inverse' when result is Matrix:
      final product = _product(a, result);
      return [
        ResultCheck(
          description: l.checkInverse,
          latex: 'A \\cdot A^{-1} = ${product.toLatex()} = I',
          holds: product == Matrix.identity(a.rows),
        ),
      ];
    case 'op_determinant' when result is Rational:
      // Small matrices are taught with a formula, larger ones by row
      // reduction; each is checked with the other kind of method.
      final other = a.rows <= 3
          ? DeterminantSolver.solve(
                  a,
                  method: DeterminantMethod.triangular,
                ).result
                as Rational
          : _cofactorDeterminant(a);
      return [
        ResultCheck(
          description: a.rows <= 3 ? l.checkDetRows : l.checkDetCofactor,
          latex: '\\det(A) = ${other.toLatex()}',
          holds: other == result,
        ),
      ];
    case 'op_lu' when result is LUResult:
      final lu = _product(result.lMatrix, result.uMatrix);
      final permuted = result.pMatrix == null
          ? a
          : _product(result.pMatrix!, a);
      return [
        ResultCheck(
          description: l.checkLu,
          latex:
              '${result.isPermuted ? 'L U = P A' : 'L U = A'} = ${lu.toLatex()}',
          holds: lu == permuted,
        ),
      ];
    case 'op_linear_systems'
        when result is LinearSystemResult &&
            result.type == LinearSystemType.unique:
      final coefficients = Matrix([
        for (var r = 0; r < a.rows; r++)
          [for (var c = 0; c < a.cols - 1; c++) a.get(r, c)],
      ]);
      final b = _column([
        for (var r = 0; r < a.rows; r++) a.get(r, a.cols - 1),
      ]);
      final ax = _product(coefficients, _column(result.uniqueSolution!));
      return [
        ResultCheck(
          description: l.checkSystem,
          latex: 'A\\mathbf{x} = ${ax.toLatex()} = \\mathbf{b}',
          holds: ax == b,
        ),
      ];
    case 'op_rank_nullity' when result is RankNullityResult:
      return [
        ResultCheck(
          description: l.checkRank,
          latex:
              '${result.rank} + ${result.nullity} = ${result.rank + result.nullity} = n',
          holds: result.rank + result.nullity == a.cols,
        ),
      ];
    case 'op_eigen' when result is EigenResult:
      // Only exact pairs: a rounded eigenvalue gives Av ≈ λv by design.
      return [
        for (final (index, pair) in result.realEigenpairs.indexed)
          if (solution.accuracy == ResultAccuracy.exact ||
              _isExactRoot(a, pair.eigenvalue))
            () {
              final v = _column(pair.eigenvector);
              final av = _product(a, v);
              final lv = _column([
                for (final e in pair.eigenvector) e * pair.eigenvalue,
              ]);
              // λv written as mathematicians do: v, -v, 3v.
              final lambda = pair.eigenvalue == Rational.one
                  ? ''
                  : pair.eigenvalue == Rational.minusOne
                  ? '-'
                  : '${pair.eigenvalue.toLatex()}\\,';
              return ResultCheck(
                description: l.checkEigen,
                latex:
                    'A\\mathbf{v}_{${index + 1}} = ${av.toLatex()} = $lambda\\mathbf{v}_{${index + 1}}',
                holds: av == lv,
              );
            }(),
      ];
  }
  return const [];
}

bool _isExactRoot(Matrix a, Rational lambda) => _cofactorDeterminant(
  Matrix([
    for (var r = 0; r < a.rows; r++)
      [
        for (var c = 0; c < a.cols; c++)
          r == c ? a.get(r, c) - lambda : a.get(r, c),
      ],
  ]),
).isZero;
