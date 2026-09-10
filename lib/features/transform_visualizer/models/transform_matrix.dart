import 'dart:math' as math;

/// Small presentation model for geometric interpolation, independent of solvers.
class TransformMatrix {
  final double a, b, c, d;
  const TransformMatrix(this.a, this.b, this.c, this.d);
  static const identity = TransformMatrix(1, 0, 0, 1);
  double get determinant => a * d - b * c;

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

  static TransformMatrix preset(String name) => switch (name) {
    'shear' => const TransformMatrix(1, 1, 0, 1),
    'rotation' => TransformMatrix(
      math.sqrt1_2,
      -math.sqrt1_2,
      math.sqrt1_2,
      math.sqrt1_2,
    ),
    'reflection' => const TransformMatrix(1, 0, 0, -1),
    'projection' => const TransformMatrix(.5, .5, .5, .5),
    'scale' => const TransformMatrix(1.5, 0, 0, 1.5),
    _ => identity,
  };
}

String formatCoefficient(double value) {
  if (value == 0) return '0.0';
  if (value.abs() < .000001) return value.toStringAsPrecision(4);
  return value
      .toStringAsFixed(6)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '.0');
}
