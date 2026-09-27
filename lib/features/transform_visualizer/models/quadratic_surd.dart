import 'dart:math' as math;

import 'package:matrix_engine/matrix_engine.dart';

/// An exact number `a + b√2` with rational `a` and `b`.
///
/// These numbers form a field, so sums, differences, products and quotients
/// stay exact. It is just large enough to hold the 45° rotation (±√2/2)
/// alongside every rational coefficient a learner can type.
class QuadraticSurd implements Comparable<QuadraticSurd> {
  /// The rational part `a`.
  final Rational rational;

  /// The coefficient `b` of √2.
  final Rational root;

  QuadraticSurd(this.rational, [Rational? root]) : root = root ?? Rational.zero;

  factory QuadraticSurd.fromInt(int value) =>
      QuadraticSurd(Rational.fromInt(value));

  /// The shortest decimal that reads back as [value], which is what a
  /// literal such as `0.5` or `1.5` in source code means.
  factory QuadraticSurd.fromDouble(double value) {
    if (!value.isFinite) {
      throw ArgumentError.value(value, 'value', 'must be finite');
    }
    final text = value.toString();
    final e = text.indexOf('e');
    if (e < 0) return QuadraticSurd(Rational.parse(text));
    final mantissa = Rational.parse(text.substring(0, e));
    final exponent = int.parse(text.substring(e + 1));
    final scale = Rational(BigInt.from(10).pow(exponent.abs()));
    return QuadraticSurd(exponent < 0 ? mantissa / scale : mantissa * scale);
  }

  static final zero = QuadraticSurd(Rational.zero);
  static final one = QuadraticSurd(Rational.one);

  /// √2/2, the cosine and sine of 45°.
  static final halfRootTwo = QuadraticSurd(Rational.zero, Rational(1, 2));

  bool get isZero => rational.isZero && root.isZero;
  bool get isRational => root.isZero;

  QuadraticSurd operator +(QuadraticSurd other) =>
      QuadraticSurd(rational + other.rational, root + other.root);

  QuadraticSurd operator -(QuadraticSurd other) =>
      QuadraticSurd(rational - other.rational, root - other.root);

  QuadraticSurd operator -() => QuadraticSurd(-rational, -root);

  QuadraticSurd operator *(QuadraticSurd other) => QuadraticSurd(
    rational * other.rational + Rational(2) * root * other.root,
    rational * other.root + root * other.rational,
  );

  QuadraticSurd operator /(QuadraticSurd other) {
    if (other.isZero) throw const DivisionByZeroException();
    // Multiply by the conjugate; the norm c² − 2d² is nonzero because √2 is
    // irrational.
    final norm =
        other.rational * other.rational - Rational(2) * other.root * other.root;
    return QuadraticSurd(
      (rational * other.rational - Rational(2) * root * other.root) / norm,
      (root * other.rational - rational * other.root) / norm,
    );
  }

  /// −1, 0 or 1, decided exactly.
  int get sign {
    final a = _signOf(rational);
    final b = _signOf(root);
    if (b == 0 || a == b) return a == 0 ? b : a;
    if (a == 0) return b;
    // Opposite signs: the larger of |a| and |b|√2 wins, compared squared.
    return (rational * rational).compareTo(Rational(2) * root * root) > 0
        ? a
        : b;
  }

  static int _signOf(Rational r) => r.isNegative ? -1 : (r.isZero ? 0 : 1);

  QuadraticSurd abs() => sign < 0 ? -this : this;

  @override
  int compareTo(QuadraticSurd other) => (this - other).sign;

  bool operator <(QuadraticSurd other) => compareTo(other) < 0;
  bool operator <=(QuadraticSurd other) => compareTo(other) <= 0;
  bool operator >(QuadraticSurd other) => compareTo(other) > 0;
  bool operator >=(QuadraticSurd other) => compareTo(other) >= 0;

  /// For drawing only; never display it.
  double toDouble() => rational.toDouble() + root.toDouble() * math.sqrt2;

  /// Exact text, e.g. `2.25`, `1/3`, `−√2/2`, `0.5 + 3√2/4`. Terminating
  /// fractions are written as decimals, others as `p/q`. [tryParse] reads
  /// every form this produces.
  @override
  String toString() {
    if (root.isZero) return _formatRational(rational);
    final surd = _formatRoot(root.abs());
    if (rational.isZero) return root.isNegative ? '−$surd' : surd;
    return '${_formatRational(rational)} ${root.isNegative ? '−' : '+'} $surd';
  }

  static String _formatRational(Rational value) {
    final sign = value.isNegative ? '−' : '';
    final magnitude = value.abs();
    if (magnitude.isInteger) return '$sign${magnitude.num}';
    final places = _decimalPlaces(magnitude.den);
    if (places == null) return '$sign${magnitude.num}/${magnitude.den}';
    return '$sign${magnitude.toDecimalString(places)}';
  }

  /// Digits after the point of a terminating decimal with this denominator,
  /// or null when the expansion repeats.
  static int? _decimalPlaces(BigInt den) {
    final two = BigInt.two;
    final five = BigInt.from(5);
    var rest = den;
    var twos = 0;
    var fives = 0;
    while (rest % two == BigInt.zero) {
      rest ~/= two;
      twos++;
    }
    while (rest % five == BigInt.zero) {
      rest ~/= five;
      fives++;
    }
    return rest == BigInt.one ? math.max(twos, fives) : null;
  }

  static String _formatRoot(Rational magnitude) {
    final factor = magnitude.num == BigInt.one ? '' : '${magnitude.num}';
    final divisor = magnitude.isInteger ? '' : '/${magnitude.den}';
    return '$factor√2$divisor';
  }

  static final _surdPattern = RegExp(
    r'^(?:([+-]?[0-9.]+(?:/[0-9]+)?)([+-]))?([+-]?)([0-9.]*)√2(?:/([0-9]+))?$',
  );

  /// Reads an integer, decimal or fraction (`3`, `-0.25`, `1/3`, with `,` as
  /// a decimal separator and `−` as a minus sign), or a value with √2 in
  /// the forms [toString] writes (`√2/2`, `−3√2/4`, `1 + √2`). Returns null
  /// for anything else.
  static QuadraticSurd? tryParse(String input) {
    final text = input
        .replaceAll(RegExp(r'\s'), '')
        .replaceAll('−', '-')
        .replaceAll(',', '.');
    if (!text.contains('√')) {
      final value = Rational.tryParse(text);
      return value == null ? null : QuadraticSurd(value);
    }
    final match = _surdPattern.firstMatch(text);
    if (match == null) return null;
    var rational = Rational.zero;
    var negativeRoot = match.group(3) == '-';
    if (match.group(1) != null) {
      final parsed = Rational.tryParse(match.group(1)!);
      if (parsed == null) return null;
      rational = parsed;
      if (match.group(2) == '-') negativeRoot = !negativeRoot;
    }
    final factorText = match.group(4)!;
    final factor = factorText.isEmpty
        ? Rational.one
        : Rational.tryParse(factorText);
    if (factor == null) return null;
    var root = factor;
    final divisorText = match.group(5);
    if (divisorText != null) {
      final divisor = Rational.tryParse(divisorText);
      if (divisor == null || divisor.isZero) return null;
      root = root / divisor;
    }
    return QuadraticSurd(rational, negativeRoot ? -root : root);
  }

  @override
  bool operator ==(Object other) =>
      other is QuadraticSurd &&
      rational == other.rational &&
      root == other.root;

  @override
  int get hashCode => Object.hash(rational, root);
}
