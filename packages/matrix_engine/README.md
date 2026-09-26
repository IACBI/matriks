# Matrix engine

A pure Dart linear algebra engine used by Matriks. It provides immutable matrices, BigInt rational arithmetic, and worked-step solutions without Flutter dependencies.

## Capabilities

Gaussian/Gauss–Jordan elimination, determinant, inverse, matrix addition and multiplication, linear systems, rank/nullity, LU decomposition and limited eigen analysis. Public exports are in `lib/matrix_engine.dart`. Solutions carry before/after snapshots and instructional transformations used by the application.

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

Eigen analysis supports only 2×2 and 3×3 inputs. Rational roots are exact: for 3×3 matrices floating-point estimates propose candidates whose denominators divide the coefficients' common denominator, and a candidate is accepted only if the characteristic polynomial is zero at it in rational arithmetic. One rational root deflates the cubic to a quadratic. Irrational roots are three-decimal approximations represented as Rational, bracketed exactly; they are not exact eigenvalues and their vectors are approximate directions. Complex pairs are reported to two decimals without eigenvectors. Coefficients beyond 1e12 fall back to an integer search from -20 to 20. `StepSolution.accuracy` and `completeness` state which case applies; repeated roots return representative vectors, not an eigenspace basis. `Rational.toDecimalString` rounds with integer arithmetic and never produces NaN or Infinity. Do not advertise this package as a general numerical eigensolver.

## Maintenance

Preserve exact values, snapshots and result contracts. Add mathematical regression tests for behavior changes. See the root [agent guide](../../AGENTS.md) and [review index](../../docs/README.md). This is an internal path dependency; version 1.0.0 is package metadata, not evidence of a published release.
