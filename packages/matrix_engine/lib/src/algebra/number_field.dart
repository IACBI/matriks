import '../rational/rational.dart';
import 'polynomial.dart';

/// The number field Q[x]/(m) for a monic irreducible polynomial m.
///
/// The class of x is a root of m, so arithmetic here is exact arithmetic with
/// that root: for m = x² - 5, [generator] behaves as √5 (or, equally, -√5,
/// since nothing in the field tells the two apart). A result proved here, such
/// as A·v = x·v, therefore holds for every root of m at once.
///
/// Irreducibility is the caller's promise; [NumberFieldElement.inverse] throws
/// when it finds a zero divisor, which only a reducible modulus can have.
class NumberField {
  /// The monic irreducible polynomial that the generator satisfies.
  final RationalPolynomial modulus;

  /// A field for [modulus], which must be monic with degree at least 1.
  NumberField(this.modulus) {
    if (modulus.degree < 1 || !modulus.isMonic) {
      throw ArgumentError.value(
        modulus,
        'modulus',
        'must be monic with degree at least 1',
      );
    }
  }

  /// The field Q itself, as Q[x]/(x - [value]); its generator is [value].
  factory NumberField.rational(Rational value) =>
      NumberField(RationalPolynomial.linear(value));

  /// The degree of the field over Q, the degree of [modulus].
  int get degree => modulus.degree;

  /// The element represented by [polynomial], reduced modulo [modulus].
  NumberFieldElement element(RationalPolynomial polynomial) =>
      NumberFieldElement._(this, polynomial % modulus);

  /// The rational number [value] as an element.
  NumberFieldElement rational(Rational value) =>
      element(RationalPolynomial.constant(value));

  NumberFieldElement get zero => element(RationalPolynomial.zero);

  NumberFieldElement get one => rational(Rational.one);

  /// The class of x: a root of [modulus].
  NumberFieldElement get generator => element(RationalPolynomial.x);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumberField && other.modulus == modulus;

  @override
  int get hashCode => modulus.hashCode;

  @override
  String toString() => 'Q[x]/(${modulus.toString()})';
}

/// An element of a [NumberField]: a polynomial in the generator of degree
/// below the field's degree. Immutable; equality is exact.
class NumberFieldElement {
  final NumberField field;

  /// The reduced representative, of degree below `field.degree`.
  final RationalPolynomial polynomial;

  const NumberFieldElement._(this.field, this.polynomial);

  bool get isZero => polynomial.isZero;

  /// Whether the element is a rational number.
  bool get isRational => polynomial.degree <= 0;

  /// The coefficient of generator^[power] in the reduced representative.
  Rational operator [](int power) => polynomial[power];

  void _check(NumberFieldElement other) {
    if (other.field != field) {
      throw ArgumentError('Elements of different number fields.');
    }
  }

  NumberFieldElement operator +(NumberFieldElement other) {
    _check(other);
    return NumberFieldElement._(field, polynomial + other.polynomial);
  }

  NumberFieldElement operator -(NumberFieldElement other) {
    _check(other);
    return NumberFieldElement._(field, polynomial - other.polynomial);
  }

  NumberFieldElement operator -() => NumberFieldElement._(field, -polynomial);

  NumberFieldElement operator *(NumberFieldElement other) {
    _check(other);
    return field.element(polynomial * other.polynomial);
  }

  /// This element times the rational [factor].
  NumberFieldElement scale(Rational factor) =>
      NumberFieldElement._(field, polynomial.scale(factor));

  /// The multiplicative inverse, by the extended Euclidean algorithm.
  /// Throws [DivisionByZeroException] for zero.
  NumberFieldElement inverse() {
    if (isZero) throw const DivisionByZeroException();
    // Invariant: r_i ≡ s_i · this (mod modulus).
    var r0 = field.modulus;
    var r1 = polynomial;
    var s0 = RationalPolynomial.zero;
    var s1 = RationalPolynomial.one;
    while (!r1.isZero) {
      final step = r0.divMod(r1);
      (r0, r1) = (r1, step.remainder);
      (s0, s1) = (s1, s0 - step.quotient * s1);
    }
    if (r0.degree != 0) {
      throw ArgumentError(
        'The modulus is reducible: $polynomial has no inverse',
      );
    }
    return field.element(s0.scale(r0[0].inverse()));
  }

  NumberFieldElement operator /(NumberFieldElement other) {
    _check(other);
    return this * other.inverse();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumberFieldElement &&
          other.field == field &&
          other.polynomial == polynomial;

  @override
  int get hashCode => Object.hash(field, polynomial);

  @override
  String toString() => polynomial.toString();
}
