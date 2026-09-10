import 'dart:math';

import 'package:matrix_engine/matrix_engine.dart';
import 'package:test/test.dart';

// Independent cofactor expansion, unlike the production elimination algorithm.
Rational determinant(Matrix a) {
  if (a.rows == 1) return a.get(0, 0);
  var sum = Rational.zero;
  for (var c = 0; c < a.cols; c++) {
    sum +=
        Rational(c.isEven ? 1 : -1) *
        a.get(0, c) *
        determinant(a.submatrix(0, c));
  }
  return sum;
}

Matrix product(Matrix a, Matrix b) => Matrix(
  List.generate(
    a.rows,
    (r) => List.generate(b.cols, (c) {
      var value = Rational.zero;
      for (var k = 0; k < a.cols; k++) {
        value += a.get(r, k) * b.get(k, c);
      }
      return value;
    }),
  ),
);
void checkSteps(StepSolution solution) {
  for (final step in solution.steps) {
    final before = Matrix(step.matrixBefore.values);
    final t = step.transformation;
    final Matrix? expected = switch (t) {
      RowSwapTransformation() => before.swapRows(t.rowA, t.rowB),
      RowScaleTransformation() => before.scaleRow(t.row, t.scalar),
      RowEliminationTransformation() => before.addRowMultiple(
        t.targetRow,
        t.sourceRow,
        t.factor,
      ),
      _ => null,
    };
    if (expected != null) expect(Matrix(step.matrixAfter.values), expected);
  }
}

List<List<int>> subsets(int length, int count) {
  if (count == 0) return [[]];
  return [
    for (var last = count - 1; last < length; last++)
      for (final prefix in subsets(last, count - 1)) [...prefix, last],
  ];
}

int rankByMinors(Matrix a) {
  for (var n = min(a.rows, a.cols); n > 0; n--) {
    for (final rows in subsets(a.rows, n)) {
      for (final cols in subsets(a.cols, n)) {
        if (!determinant(
          Matrix(
            rows.map((r) => cols.map((c) => a.get(r, c)).toList()).toList(),
          ),
        ).isZero) {
          return n;
        }
      }
    }
  }
  return 0;
}

void main() {
  final random = Random(20260910);
  Matrix sample(int rows, int cols) => Matrix(
    List.generate(
      rows,
      (_) => List.generate(
        cols,
        (_) => Rational(random.nextInt(11) - 5, random.nextInt(4) + 1),
      ),
    ),
  );
  for (var n = 1; n <= 5; n++) {
    test(
      'Determinant, inverse, PA=LU and row steps: size $n, 25 fraction cases',
      () {
        for (var iteration = 0; iteration < 25; iteration++) {
          final a = iteration == 0 ? Matrix.zero(n, n) : sample(n, n);
          final det = determinant(a);
          for (final method in [
            DeterminantMethod.auto,
            DeterminantMethod.triangular,
          ]) {
            final solution = DeterminantSolver.solve(a, method: method);
            expect(solution.result, det, reason: a.toString());
            checkSteps(solution);
          }
          final inverse = InverseSolver.solve(a);
          expect(inverse.isSuccess, !det.isZero);
          if (inverse.isSuccess) {
            expect(product(a, inverse.result as Matrix), Matrix.identity(n));
            expect(product(inverse.result as Matrix, a), Matrix.identity(n));
            checkSteps(inverse);
          }
          final luSolution = LUDecompositionSolver.solve(a);
          final lu = luSolution.result as LUResult;
          expect(
            product(lu.pMatrix ?? Matrix.identity(n), a),
            product(lu.lMatrix, lu.uMatrix),
          );
          for (var r = 0; r < n; r++) {
            expect(lu.lMatrix.get(r, r), Rational.one);
            for (var c = 0; c < n; c++) {
              if (r < c) expect(lu.lMatrix.get(r, c), Rational.zero);
              if (r > c) expect(lu.uMatrix.get(r, c), Rational.zero);
            }
          }
          checkSteps(luSolution);
        }
      },
    );
  }
  test(
    'Rectangular addition, multiplication, REF, RREF, rank and systems 1–5',
    () {
      for (var rows = 1; rows <= 5; rows++) {
        for (var cols = 1; cols <= 5; cols++) {
          final a = sample(rows, cols);
          final b = sample(rows, cols);
          expect(
            MatrixArithmeticSolver.add(a, b).result,
            Matrix(
              List.generate(
                rows,
                (r) => List.generate(cols, (c) => a.get(r, c) + b.get(r, c)),
              ),
            ),
          );
          final multiplier = sample(cols, rows);
          expect(
            MatrixArithmeticSolver.multiply(a, multiplier).result,
            product(a, multiplier),
          );
          final reduced = GaussJordanSolver.solve(a);
          final ref = GaussJordanSolver.solve(
            a,
            const EliminationOptions(toRref: false),
          );
          checkSteps(reduced);
          checkSteps(ref);
          expect(
            GaussJordanSolver.solve(ref.finalMatrix).finalMatrix,
            reduced.finalMatrix,
          );
          expect(
            GaussJordanSolver.solve(reduced.finalMatrix).finalMatrix,
            reduced.finalMatrix,
          );
          var previous = -1;
          var rank = 0;
          var zeroSeen = false;
          for (var r = 0; r < rows; r++) {
            final pivot = reduced.finalMatrix
                .getRow(r)
                .indexWhere((v) => !v.isZero);
            if (pivot < 0) {
              zeroSeen = true;
              continue;
            }
            expect(zeroSeen, false);
            expect(pivot, greaterThan(previous));
            previous = pivot;
            rank++;
            for (var i = 0; i < rows; i++) {
              expect(
                reduced.finalMatrix.get(i, pivot),
                i == r ? Rational.one : Rational.zero,
              );
            }
          }
          final rn = RankNullitySolver.solve(a).result as RankNullityResult;
          expect(rn.rank, rank);
          expect(rn.rank, rankByMinors(a));
          expect(rn.rank + rn.nullity, cols);
          final x = sample(cols, 1);
          final rhs = product(a, x);
          final solved = LinearSystemsSolver.solve(a.augment(rhs));
          final result = solved.result as LinearSystemResult;
          expect(
            result.type,
            rank == cols ? LinearSystemType.unique : LinearSystemType.infinite,
          );
          if (result.uniqueSolution != null) {
            expect(
              product(
                a,
                Matrix(result.uniqueSolution!.map((v) => [v]).toList()),
              ),
              rhs,
            );
          } else {
            final particular = List.filled(cols, Rational.zero);
            for (var i = 0; i < result.basicVariables.length; i++) {
              particular[result.basicVariables[i]] = solved.finalMatrix.get(
                i,
                cols,
              );
            }
            expect(
              product(a, Matrix(particular.map((v) => [v]).toList())),
              rhs,
            );
            for (final free in result.freeVariables) {
              final v = List.filled(cols, Rational.zero);
              v[free] = Rational.one;
              for (var i = 0; i < result.basicVariables.length; i++) {
                v[result.basicVariables[i]] = -solved.finalMatrix.get(i, free);
              }
              expect(
                product(a, Matrix(v.map((v) => [v]).toList())),
                Matrix.zero(rows, 1),
              );
            }
          }
          checkSteps(solved);
        }
      }
      expect(
        (LinearSystemsSolver.solve(
                  Matrix.fromInts([
                    [0, 0, 1],
                  ]),
                ).result
                as LinearSystemResult)
            .type,
        LinearSystemType.inconsistent,
      );
    },
  );
  test('Exact eigenpairs satisfy Av=lambda v for all 625 small integer 2x2 matrices', () {
    for (var a = -2; a <= 2; a++) {
      for (var b = -2; b <= 2; b++) {
        for (var c = -2; c <= 2; c++) {
          for (var d = -2; d <= 2; d++) {
            final matrix = Matrix.fromInts([
              [a, b],
              [c, d],
            ]);
            final solution = EigenSolver.solve(matrix);
            if (solution.accuracy != ResultAccuracy.exact) {
              final discriminant = (a - d) * (a - d) + 4 * b * c;
              if (discriminant >= 0) {
                final pairs = (solution.result as EigenResult).realEigenpairs;
                expect(pairs.length, 2);
                expect(
                  pairs[0].eigenvalue.toDouble(),
                  closeTo((a + d + sqrt(discriminant)) / 2, .0005),
                );
                expect(
                  pairs[1].eigenvalue.toDouble(),
                  closeTo((a + d - sqrt(discriminant)) / 2, .0005),
                );
              }
              continue;
            }
            for (final pair
                in (solution.result as EigenResult).realEigenpairs) {
              expect(pair.eigenvector.any((v) => !v.isZero), true);
              final v = Matrix(pair.eigenvector.map((e) => [e]).toList());
              expect(
                product(matrix, v),
                Matrix(
                  pair.eigenvector.map((e) => [e * pair.eigenvalue]).toList(),
                ),
              );
            }
          }
        }
      }
    }
  });
  test('Large translated irrational eigenvalues retain decimal precision', () {
    final offset = Rational.parse('10000000000000000000000');
    final solution = EigenSolver.solve(
      Matrix([
        [offset, Rational(2)],
        [Rational.one, offset],
      ]),
    );
    final pairs = (solution.result as EigenResult).realEigenpairs;
    expect(pairs.map((p) => p.eigenvalue - offset), [
      Rational.parse('1.414'),
      Rational.parse('-1.414'),
    ]);
  });
  test('3x3 eigenpairs on 30 similar matrices retain known spectrum and zero residual', () {
    for (var i = 0; i < 30; i++) {
      var basis = Matrix.identity(3).addRowMultiple(1, 0, Rational(i - 15));
      basis = basis.addRowMultiple(2, 1, Rational(2, 3)).swapRows(0, 2);
      final diagonal = Matrix.fromInts([
        [i % 5 - 2, 0, 0],
        [0, 7, 0],
        [0, 0, -9],
      ]);
      final a = product(
        product(basis, diagonal),
        InverseSolver.solve(basis).result as Matrix,
      );
      final solution = EigenSolver.solve(a);
      expect(solution.completeness, ResultCompleteness.complete);
      final pairs = (solution.result as EigenResult).realEigenpairs;
      expect(
        pairs.map((p) => p.eigenvalue),
        unorderedEquals([Rational(i % 5 - 2), Rational(7), Rational(-9)]),
      );
      for (final pair in pairs) {
        expect(pair.eigenvector.any((v) => !v.isZero), true);
        expect(
          product(a, Matrix(pair.eigenvector.map((v) => [v]).toList())),
          Matrix(pair.eigenvector.map((v) => [v * pair.eigenvalue]).toList()),
        );
      }
    }
  });
  test(
    'Tiny distinct irrational roots are retained even when both round to zero',
    () {
      final solution = EigenSolver.solve(
        Matrix([
          [Rational.zero, Rational(2, 100000000)],
          [Rational(1, 100000000), Rational.zero],
        ]),
      );
      expect((solution.result as EigenResult).realEigenpairs.length, 2);
      expect(solution.steps[1].explanationKey, 'eigen_roots_approx_desc');
    },
  );
}
