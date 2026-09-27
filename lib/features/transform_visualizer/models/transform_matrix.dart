import 'dart:math' as math;

import 'package:matrix_engine/matrix_engine.dart';

import 'quadratic_surd.dart';

/// Small presentation model for geometric interpolation, independent of solvers.
///
/// [a], [b], [c] and [d] are doubles for drawing and interpolation only.
/// Anything shown to the learner comes from the exact entries ([exactA] …),
/// which are held exactly when the matrix is built with [TransformMatrix.exact]
/// or [TransformMatrix.fromRationals].
class TransformMatrix {
  final double a, b, c, d;
  final QuadraticSurd? _exactA, _exactB, _exactC, _exactD;

  const TransformMatrix(this.a, this.b, this.c, this.d)
    : _exactA = null,
      _exactB = null,
      _exactC = null,
      _exactD = null;

  TransformMatrix.exact(
    QuadraticSurd exactA,
    QuadraticSurd exactB,
    QuadraticSurd exactC,
    QuadraticSurd exactD,
  ) : a = exactA.toDouble(),
      b = exactB.toDouble(),
      c = exactC.toDouble(),
      d = exactD.toDouble(),
      _exactA = exactA,
      _exactB = exactB,
      _exactC = exactC,
      _exactD = exactD;

  factory TransformMatrix.fromRationals(
    Rational a,
    Rational b,
    Rational c,
    Rational d,
  ) => TransformMatrix.exact(
    QuadraticSurd(a),
    QuadraticSurd(b),
    QuadraticSurd(c),
    QuadraticSurd(d),
  );

  static const identity = TransformMatrix(1, 0, 0, 1);

  /// Exact entries. A matrix built from doubles reads each as the shortest
  /// decimal that round-trips to it (see [QuadraticSurd.fromDouble]).
  QuadraticSurd get exactA => _exactA ?? QuadraticSurd.fromDouble(a);
  QuadraticSurd get exactB => _exactB ?? QuadraticSurd.fromDouble(b);
  QuadraticSurd get exactC => _exactC ?? QuadraticSurd.fromDouble(c);
  QuadraticSurd get exactD => _exactD ?? QuadraticSurd.fromDouble(d);

  /// This matrix with its entries held exactly.
  TransformMatrix toExact() => _exactA != null
      ? this
      : TransformMatrix.exact(exactA, exactB, exactC, exactD);

  /// Drawing approximation of [exactDeterminant].
  double get determinant => a * d - b * c;

  QuadraticSurd get exactDeterminant => exactA * exactD - exactB * exactC;

  bool get isRotation =>
      (a - d).abs() < 1e-10 &&
      (b + c).abs() < 1e-10 &&
      (determinant - 1).abs() < 1e-10;

  TransformMatrix interpolate(TransformMatrix target, double t) {
    if (t <= 0) return this;
    if (t >= 1) return target;
    // Preserve lengths when moving between rotations, including identity.
    if (isRotation && target.isRotation) {
      final start = math.atan2(c, a);
      final end = math.atan2(target.c, target.a);
      final delta = math.atan2(math.sin(end - start), math.cos(end - start));
      final angle = start + delta * t;
      return TransformMatrix(
        math.cos(angle),
        -math.sin(angle),
        math.sin(angle),
        math.cos(angle),
      );
    }
    return TransformMatrix(
      a + (target.a - a) * t,
      b + (target.b - b) * t,
      c + (target.c - c) * t,
      d + (target.d - d) * t,
    );
  }

  static TransformMatrix preset(String name) {
    QuadraticSurd q(int n, [int den = 1]) => QuadraticSurd(Rational(n, den));
    final zero = q(0);
    final one = q(1);
    final half = QuadraticSurd.halfRootTwo;
    return switch (name) {
      'shear' => TransformMatrix.exact(one, one, zero, one),
      'rotation' => TransformMatrix.exact(half, -half, half, half),
      'reflection' => TransformMatrix.exact(one, zero, zero, q(-1)),
      'projection' => TransformMatrix.exact(q(1, 2), q(1, 2), q(1, 2), q(1, 2)),
      'scale' => TransformMatrix.exact(q(3, 2), zero, zero, q(3, 2)),
      _ => TransformMatrix.exact(one, zero, zero, one),
    };
  }
}
