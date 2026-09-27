# Matrix engine

A pure Dart linear algebra engine used by Matriks. It provides immutable matrices, BigInt rational arithmetic, and worked-step solutions without Flutter dependencies.

## Capabilities

Gaussian/Gauss–Jordan elimination, determinant, inverse, matrix addition and multiplication, linear systems, rank/nullity, LU decomposition and exact eigen analysis of 2×2 and 3×3 matrices. Public exports are in `lib/matrix_engine.dart`. Solutions carry before/after snapshots and instructional transformations used by the application.

## Example

```dart
import 'package:matrix_engine/matrix_engine.dart';

void main() {
  final matrix = Matrix.fromInts([
    [1, 2],
    [3, 4],
  ]);
  final solution = DeterminantSolver.solve(matrix);
  print(solution.result); // -2
  print(solution.totalSteps);
}
```

Run `dart run example/matrix_engine_example.dart` from this directory. Resolve dependencies with `dart pub get`; validate with `dart analyze` and `dart test`. SDK constraints are defined in `pubspec.yaml`.

## Numerical boundaries

Rational arithmetic is exact; geometric animation belongs to the Flutter app. `Rational.tryParse` accepts integers, decimal strings and fractions written in decimal digits and returns null for anything else, including hexadecimal, or a zero denominator. `Rational.parse` throws on invalid input. The library retains arbitrary precision; callers accepting untrusted input must bound dimensions and input length. The Matriks editor limits dimensions to 1–5 and cells to 32 characters, with tighter eigen dimensions.

Eigen analysis supports only 2×2 and 3×3 inputs, and within that scope it is exact: nothing is rounded and no root is left out. `StepSolution.accuracy` is always `exact` and `completeness` is `complete`.

- Repeated roots come from gcd(p, p′); at degree 2 and 3 they are rational.
- Rational roots are found completely, with no size limit. The characteristic polynomial is scaled to a primitive integer polynomial aₙxⁿ + … + a₀; each real root is isolated by a Sturm sequence and bisected at dyadic points until its interval is narrower than 1/(2aₙ²), and the fraction with the smallest denominator in that interval is kept only if the polynomial vanishes there exactly. A polynomial with no root modulo some small prime not dividing aₙ has no rational root, which settles most irreducible cases at once. No floating point is involved.
- What remains is irreducible and solved in closed form: `-b/2 ± √D` for a quadratic (square factors below 10⁵ are pulled out of the radicand; a larger one may stay inside, which is still exact), Cardano's formula with real cube roots for a cubic with one real root, and the trigonometric form for a cubic with three real roots. Complex roots are written `a ± b√k i`. In these closed forms ∛x of a real x is the real cube root (∛−8 = −2), as in Cardano's formula, and cosine angles are written in [0, π].
- Eigenvectors are computed by exact elimination in the number field Q(λ) = Q[x]/(m), where m is the eigenvalue's minimal polynomial (`NumberField`, `NumberFieldElement`, `RationalPolynomial`). A repeated rational eigenvalue gets a basis of its whole eigenspace; when that is smaller than the multiplicity, the matrix is reported as defective, which is a fact about the matrix. A vector for a cubic eigenvalue is written as a polynomial in λ, valid for each of its three roots.
- `EigenResult.eigenpairs` lists every eigenvalue as an `ExactEigenpair`; `realEigenpairs` keeps only the rational ones as `Rational` vectors. `ExactEigenvalue.approximate` is a floating-point value of the closed form for plotting and tests; it is never a result.

A 3×3 matrix of 15-digit fractions takes about 50–100 ms on the Dart VM and 0.2–0.7 s compiled to JavaScript, depending on the machine and its load. `Rational.toDecimalString` rounds with integer arithmetic and never produces NaN or Infinity. Do not advertise this package as a general numerical eigensolver: larger matrices are not supported.

## Maintenance

Preserve exact values, snapshots and result contracts. Add mathematical regression tests for behavior changes. See the root [agent guide](../../AGENTS.md) and [review index](../../docs/README.md). This is an internal path dependency; version 1.0.0 is package metadata, not evidence of a published release.
