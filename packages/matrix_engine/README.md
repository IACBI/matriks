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

Rational arithmetic is exact; geometric animation belongs to the Flutter app. `Rational.tryParse` accepts integers, decimal strings and fractions and returns null for invalid input or zero denominators. `Rational.parse` throws on invalid input. The library retains arbitrary precision; callers accepting untrusted input must bound dimensions and input length. The Matriks editor limits dimensions to 1–5 and cells to 32 characters, with tighter eigen dimensions.

Eigen analysis supports only 2×2 and 3×3 inputs. Irrational 2×2 roots use three-decimal approximations represented as Rational; they are not exact eigenvalues. The 3×3 solver searches integer candidates from -20 to 20 and may return only part of the spectrum. Returned vectors do not constitute a general complete eigenspace API. Result certainty/completeness labeling is an open P0 item in the [project roadmap](../../docs/ROADMAP.md). Do not advertise this package as a general numerical eigensolver.

## Maintenance

Preserve exact values, snapshots and result contracts. Add mathematical regression tests for behavior changes. See the root [agent guide](../../AGENTS.md) and [review index](../../docs/README.md). This is an internal path dependency; version 1.0.0 is package metadata, not evidence of a published release.
