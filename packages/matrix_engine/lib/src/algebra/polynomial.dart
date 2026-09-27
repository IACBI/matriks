import '../rational/rational.dart';

/// Polynomial in one variable with exact [Rational] coefficients.
///
/// Immutable. [coefficients] run from the constant term upwards and never end
/// in a zero, so the zero polynomial has no coefficients and degree -1.
class RationalPolynomial {
  /// Coefficients from the constant term upwards, without trailing zeros.
  final List<Rational> coefficients;

  /// A polynomial whose coefficient of x^i is `coefficients[i]`.
  RationalPolynomial(List<Rational> coefficients)
    : coefficients = List.unmodifiable(_trim(coefficients));

  const RationalPolynomial._(this.coefficients);

  /// The constant polynomial [value].
  factory RationalPolynomial.constant(Rational value) =>
      RationalPolynomial([value]);

  /// A polynomial from integer coefficients, constant term first.
  factory RationalPolynomial.fromInts(List<int> coefficients) =>
      RationalPolynomial([for (final c in coefficients) Rational.fromInt(c)]);

  /// The monic polynomial x - [root].
  factory RationalPolynomial.linear(Rational root) =>
      RationalPolynomial([-root, Rational.one]);

  /// The zero polynomial.
  static const RationalPolynomial zero = RationalPolynomial._([]);

  /// The constant polynomial 1.
  static final RationalPolynomial one = RationalPolynomial([Rational.one]);

  /// The polynomial x.
  static final RationalPolynomial x = RationalPolynomial([
    Rational.zero,
    Rational.one,
  ]);

  static List<Rational> _trim(List<Rational> values) {
    var end = values.length;
    while (end > 0 && values[end - 1].isZero) {
      end--;
    }
    return values.sublist(0, end);
  }

  /// Degree; -1 for the zero polynomial.
  int get degree => coefficients.length - 1;

  bool get isZero => coefficients.isEmpty;

  /// Whether the leading coefficient is 1.
  bool get isMonic => !isZero && coefficients.last.isOne;

  /// The coefficient of the highest power; zero for the zero polynomial.
  Rational get leadingCoefficient => isZero ? Rational.zero : coefficients.last;

  /// The coefficient of x^[power]; zero beyond the degree.
  Rational operator [](int power) => power >= 0 && power < coefficients.length
      ? coefficients[power]
      : Rational.zero;

  RationalPolynomial operator +(RationalPolynomial other) {
    final length = coefficients.length > other.coefficients.length
        ? coefficients.length
        : other.coefficients.length;
    return RationalPolynomial([
      for (var i = 0; i < length; i++) this[i] + other[i],
    ]);
  }

  RationalPolynomial operator -(RationalPolynomial other) => this + (-other);

  RationalPolynomial operator -() => RationalPolynomial._(
    List.unmodifiable([for (final c in coefficients) -c]),
  );

  RationalPolynomial operator *(RationalPolynomial other) {
    if (isZero || other.isZero) return zero;
    final product = List.filled(
      coefficients.length + other.coefficients.length - 1,
      Rational.zero,
    );
    for (var i = 0; i < coefficients.length; i++) {
      if (coefficients[i].isZero) continue;
      for (var j = 0; j < other.coefficients.length; j++) {
        product[i + j] += coefficients[i] * other.coefficients[j];
      }
    }
    return RationalPolynomial(product);
  }

  /// Every coefficient multiplied by [factor].
  RationalPolynomial scale(Rational factor) =>
      RationalPolynomial([for (final c in coefficients) c * factor]);

  /// This polynomial divided by its leading coefficient. Throws for zero.
  RationalPolynomial monic() {
    if (isZero) throw const DivisionByZeroException();
    return isMonic ? this : scale(leadingCoefficient.inverse());
  }

  /// Polynomial long division: `this == quotient * divisor + remainder` with
  /// `remainder.degree < divisor.degree`. Throws for a zero [divisor].
  ({RationalPolynomial quotient, RationalPolynomial remainder}) divMod(
    RationalPolynomial divisor,
  ) {
    if (divisor.isZero) throw const DivisionByZeroException();
    if (degree < divisor.degree) return (quotient: zero, remainder: this);
    final rest = [...coefficients];
    final quotient = List.filled(degree - divisor.degree + 1, Rational.zero);
    final lead = divisor.leadingCoefficient;
    for (var shift = degree - divisor.degree; shift >= 0; shift--) {
      final top = rest[shift + divisor.degree];
      if (top.isZero) continue;
      final factor = top / lead;
      quotient[shift] = factor;
      for (var i = 0; i <= divisor.degree; i++) {
        rest[shift + i] -= factor * divisor.coefficients[i];
      }
    }
    return (
      quotient: RationalPolynomial(quotient),
      remainder: RationalPolynomial(rest.sublist(0, divisor.degree)),
    );
  }

  /// The quotient of [divMod].
  RationalPolynomial operator ~/(RationalPolynomial divisor) =>
      divMod(divisor).quotient;

  /// The remainder of [divMod].
  RationalPolynomial operator %(RationalPolynomial divisor) =>
      divMod(divisor).remainder;

  /// Monic greatest common divisor; zero only when both are zero.
  RationalPolynomial gcd(RationalPolynomial other) {
    var a = this;
    var b = other;
    while (!b.isZero) {
      final r = a % b;
      a = b;
      b = r;
    }
    return a.isZero ? zero : a.monic();
  }

  RationalPolynomial derivative() => RationalPolynomial([
    for (var i = 1; i < coefficients.length; i++)
      coefficients[i] * Rational.fromInt(i),
  ]);

  /// The value at [x], by Horner's rule in exact arithmetic.
  Rational evaluate(Rational x) {
    var result = Rational.zero;
    for (var i = coefficients.length - 1; i >= 0; i--) {
      result = result * x + coefficients[i];
    }
    return result;
  }

  /// LaTeX with the highest power first, e.g. `\lambda^2 - 3\lambda + 1`.
  ///
  /// [variable] is inserted verbatim, so a subscripted symbol such as
  /// `\lambda_{2}` works too.
  String toLatex([String variable = r'\lambda']) {
    if (isZero) return '0';
    final buffer = StringBuffer();
    for (var power = degree; power >= 0; power--) {
      final c = coefficients[power];
      if (c.isZero) continue;
      final negative = c.isNegative;
      final size = c.abs();
      if (buffer.isEmpty) {
        if (negative) buffer.write('-');
      } else {
        buffer.write(negative ? ' - ' : ' + ');
      }
      final base = power == 0
          ? ''
          : power == 1
          ? variable
          : '$variable^{$power}';
      if (power == 0) {
        buffer.write(size.toLatex());
      } else if (!size.isOne) {
        buffer.write('${size.toLatex()}$base');
      } else {
        buffer.write(base);
      }
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RationalPolynomial ||
        other.coefficients.length != coefficients.length) {
      return false;
    }
    for (var i = 0; i < coefficients.length; i++) {
      if (coefficients[i] != other.coefficients[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(coefficients);

  @override
  String toString() => toLatex('x');
}
