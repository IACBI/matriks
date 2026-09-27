import 'dart:math' as math;

import '../algebra/number_field.dart';
import '../algebra/polynomial.dart';
import '../rational/rational.dart';

/// One exact eigenvalue: a root of an irreducible factor of the
/// characteristic polynomial.
///
/// The value itself is algebraic: [minimalPolynomial] determines it up to its
/// conjugates, and [latex] names which conjugate this is by a closed form
/// (a fraction, a square root, Cardano's formula with real cube roots, or the
/// trigonometric form of three real cubic roots). Everything computed with it
/// (eigenvectors, checks) uses exact arithmetic in [field], where this value
/// is the generator.
///
/// [approximate] and [approximateImaginary] are evaluated in floating point
/// from the same closed form. They exist for plotting and tests only, and are
/// never a result: display [latex] or [text].
class ExactEigenvalue {
  /// The monic irreducible polynomial over Q with this value as a root; x - r
  /// for a rational r.
  final RationalPolynomial minimalPolynomial;

  /// How often this value is a root of the characteristic polynomial.
  final int algebraicMultiplicity;

  /// Whether the value is real; exact, not read from [approximateImaginary].
  final bool isReal;

  /// Exact closed form in LaTeX, e.g. `\frac{1}{2} + \frac{\sqrt{5}}{2}`.
  final String latex;

  /// The same closed form as plain text with Unicode symbols, e.g.
  /// `1/2 + √5/2`, for prose that is not typeset.
  final String text;

  /// Floating-point real part, from the closed form. Not a result.
  final double approximate;

  /// Floating-point imaginary part (0 for a real value). Not a result.
  final double approximateImaginary;

  final Rational? _rational;
  final _Quadratic? _quadratic;
  final _Expr? _pair;

  /// Position among the conjugates: 0 for the larger of two real conjugates
  /// or the one with positive imaginary part; for three real cubic roots,
  /// 0 is the smallest.
  final int _conjugate;

  ExactEigenvalue._({
    required this.minimalPolynomial,
    required this.algebraicMultiplicity,
    required this.isReal,
    required this.latex,
    required this.text,
    required this.approximate,
    this.approximateImaginary = 0,
    this._rational,
    this._quadratic,
    this._pair,
    this._conjugate = 0,
  });

  factory ExactEigenvalue._fromRational(Rational value, int multiplicity) =>
      ExactEigenvalue._(
        minimalPolynomial: RationalPolynomial.linear(value),
        algebraicMultiplicity: multiplicity,
        isReal: true,
        latex: value.toLatex(),
        text: value.toString(),
        approximate: approximateRational(value),
        rational: value,
      );

  /// Degree of [minimalPolynomial]: 1 rational, 2 quadratic, 3 cubic.
  int get degree => minimalPolynomial.degree;

  bool get isRational => degree == 1;

  /// The value when it is rational, otherwise null.
  Rational? get rationalValue => _rational;

  /// Q(λ) = Q[x]/(minimal polynomial), in which λ is the generator.
  NumberField get field => NumberField(minimalPolynomial);

  /// [element] of [field] written in terms of this value.
  ///
  /// A quadratic value is substituted, so the result reads a + b√k (times i
  /// when complex). A cubic value stays symbolic: the element is written as a
  /// polynomial in [symbol], valid for each of the three conjugate roots.
  String elementLatex(
    NumberFieldElement element, {
    String symbol = r'\lambda',
  }) {
    _checkField(element);
    final rational = _rational;
    final quadratic = _quadratic;
    if (rational != null) {
      return element.polynomial.evaluate(rational).toLatex();
    }
    if (quadratic != null) return quadratic.substitute(element).latex;
    return element.polynomial.toLatex(symbol);
  }

  /// [elementLatex] as plain text: `-1 + √5`, `λ² - 3λ + 1`.
  String elementText(NumberFieldElement element, {String symbol = 'λ'}) {
    _checkField(element);
    final rational = _rational;
    final quadratic = _quadratic;
    if (rational != null) {
      return element.polynomial.evaluate(rational).toString();
    }
    if (quadratic != null) return quadratic.substitute(element).text;
    return polynomialText(element.polynomial, symbol);
  }

  void _checkField(NumberFieldElement element) {
    if (element.field.modulus != minimalPolynomial) {
      throw ArgumentError('The element is not in the field of this value.');
    }
  }

  @override
  String toString() => text;
}

/// An exact eigenvalue with a basis of its eigenspace.
///
/// Each basis vector has entries in the eigenvalue's field Q(λ); for a
/// rational eigenvalue they are rational constants. The basis spans the null
/// space of A - λI, so [geometricMultiplicity] is its dimension.
class ExactEigenpair {
  final ExactEigenvalue eigenvalue;

  /// Basis of the eigenspace; every vector is nonzero and they are linearly
  /// independent.
  final List<List<NumberFieldElement>> eigenspaceBasis;

  ExactEigenpair({
    required this.eigenvalue,
    required List<List<NumberFieldElement>> eigenspaceBasis,
  }) : eigenspaceBasis = List.unmodifiable([
         for (final v in eigenspaceBasis)
           List<NumberFieldElement>.unmodifiable(v),
       ]);

  int get algebraicMultiplicity => eigenvalue.algebraicMultiplicity;

  /// Dimension of the eigenspace.
  int get geometricMultiplicity => eigenspaceBasis.length;

  /// Whether the eigenspace is smaller than the multiplicity of the root, so
  /// the matrix is not diagonalizable. A fact about the matrix, not a gap in
  /// the calculation.
  bool get isDefective => geometricMultiplicity < algebraicMultiplicity;

  /// [vector] as a LaTeX column, entries per [ExactEigenvalue.elementLatex].
  String vectorLatex(
    List<NumberFieldElement> vector, {
    String symbol = r'\lambda',
  }) {
    final entries = vector
        .map((e) => eigenvalue.elementLatex(e, symbol: symbol))
        .join(r' \\ ');
    return '\\begin{pmatrix}$entries\\end{pmatrix}';
  }

  /// [vector] as plain text, `(2, -1 + √5)`.
  String vectorText(List<NumberFieldElement> vector, {String symbol = 'λ'}) =>
      '(${vector.map((e) => eigenvalue.elementText(e, symbol: symbol)).join(', ')})';
}

/// The exact roots of a monic polynomial of degree 2 or 3 with rational
/// coefficients, and its factorization into irreducible factors over Q.
///
/// Repeated roots come from gcd(p, p′) and are rational at these degrees.
/// Rational roots are found completely by [_rationalRoots]; what remains is
/// irreducible and is solved in closed form. The roots are listed factor by
/// factor; order them with [compareRealEigenvalues].
({
  List<ExactEigenvalue> roots,
  List<({RationalPolynomial factor, int multiplicity})> factors,
})
exactSpectrum(RationalPolynomial polynomial) {
  if (polynomial.degree < 1 || polynomial.degree > 3) {
    throw ArgumentError.value(polynomial, 'polynomial', 'degree must be 1–3');
  }
  final p = polynomial.monic();
  final squareFree = p ~/ p.gcd(p.derivative());
  final rationals = [..._rationalRoots(squareFree)]..sort();
  final roots = <ExactEigenvalue>[];
  final factors = <({RationalPolynomial factor, int multiplicity})>[];
  var rest = p;
  for (final r in rationals) {
    final linear = RationalPolynomial.linear(r);
    var multiplicity = 0;
    while (rest.degree >= 1) {
      final step = rest.divMod(linear);
      if (!step.remainder.isZero) break;
      rest = step.quotient;
      multiplicity++;
    }
    factors.add((factor: linear, multiplicity: multiplicity));
    roots.add(ExactEigenvalue._fromRational(r, multiplicity));
  }
  switch (rest.degree) {
    case 0:
      break;
    case 2:
      factors.add((factor: rest, multiplicity: 1));
      roots.addAll(_quadraticRoots(rest));
    case 3:
      factors.add((factor: rest, multiplicity: 1));
      roots.addAll(_cubicRoots(rest));
    default:
      throw StateError('A rational root of $rest was missed.');
  }
  return (roots: roots, factors: factors);
}

/// Exact order of two real eigenvalues from the same characteristic
/// polynomial of degree at most 3. Only the unordered pair of complex roots,
/// never compared with reals, is left to [ExactEigenvalue.approximate].
int compareRealEigenvalues(ExactEigenvalue a, ExactEigenvalue b) {
  final ra = a._rational;
  final rb = b._rational;
  if (ra != null && rb != null) return ra.compareTo(rb);
  final qa = a._quadratic;
  final qb = b._quadratic;
  if (ra != null && qb != null) return -qb.compareTo(ra);
  if (qa != null && rb != null) return qa.compareTo(rb);
  if (qa != null && qb != null && a.minimalPolynomial == b.minimalPolynomial) {
    return qa.coefficient.compareTo(qb.coefficient);
  }
  if (a.minimalPolynomial == b.minimalPolynomial && a.degree == 3) {
    return a._conjugate.compareTo(b._conjugate);
  }
  return a.approximate.compareTo(b.approximate);
}

/// Whether [a] is listed before its conjugate [b]: + before -.
int compareConjugates(ExactEigenvalue a, ExactEigenvalue b) =>
    a._conjugate.compareTo(b._conjugate);

/// A basis vector of an eigenspace rescaled by a rational factor so that its
/// written entries have integer coefficients without a common factor, and
/// the first nonzero entry is positive (for a complex entry: its real part,
/// or its imaginary part when the real part is zero; for a cubic value: the
/// leading coefficient of the polynomial in λ).
List<NumberFieldElement> normalizeEigenvector(
  ExactEigenvalue value,
  List<NumberFieldElement> vector,
) {
  final coefficients = [
    for (final e in vector) ..._writtenCoefficients(value, e),
  ].where((c) => !c.isZero).toList();
  if (coefficients.isEmpty) return vector;
  var lcm = BigInt.one;
  var gcd = BigInt.zero;
  for (final c in coefficients) {
    lcm = lcm ~/ lcm.gcd(c.den) * c.den;
  }
  for (final c in coefficients) {
    gcd = gcd.gcd((c * Rational(lcm)).num.abs());
  }
  var factor = Rational(lcm, gcd);
  final first = vector.firstWhere((e) => !e.isZero);
  if (_writtenSign(value, first) < 0) factor = -factor;
  return [for (final e in vector) e.scale(factor)];
}

/// Bits needed to write [vector]'s entries: smaller is simpler.
int writtenSize(ExactEigenvalue value, List<NumberFieldElement> vector) {
  var bits = 0;
  for (final e in vector) {
    for (final c in _writtenCoefficients(value, e)) {
      bits += c.num.bitLength + c.den.bitLength;
    }
  }
  return bits;
}

List<Rational> _writtenCoefficients(
  ExactEigenvalue value,
  NumberFieldElement e,
) {
  final rational = value._rational;
  final quadratic = value._quadratic;
  if (rational != null) return [e.polynomial.evaluate(rational)];
  if (quadratic != null) {
    final surd = quadratic.parts(e);
    return [surd.a, surd.b];
  }
  return [for (var i = 0; i < value.degree; i++) e[i]];
}

int _writtenSign(ExactEigenvalue value, NumberFieldElement e) {
  final rational = value._rational;
  final quadratic = value._quadratic;
  if (rational != null) return e.polynomial.evaluate(rational).num.sign;
  if (quadratic != null) {
    final surd = quadratic.parts(e);
    if (quadratic.imaginary) {
      return surd.a.isZero ? surd.b.num.sign : surd.a.num.sign;
    }
    return _surdSign(surd.a, surd.b, quadratic.radicand);
  }
  return e.polynomial.leadingCoefficient.num.sign;
}

/// Floating-point value of [value] without overflowing to NaN for large
/// numerators and denominators.
double approximateRational(Rational value) {
  if (value.isZero) return 0;
  final n = value.num.abs();
  final d = value.den;
  final shift = 62 - (n.bitLength - d.bitLength);
  final scaled = shift >= 0 ? (n << shift) ~/ d : n ~/ (d << -shift);
  final half = -shift ~/ 2;
  final result =
      scaled.toDouble() *
      math.pow(2.0, half).toDouble() *
      math.pow(2.0, -shift - half).toDouble();
  return value.isNegative ? -result : result;
}

/// [polynomial] as plain text in [symbol], highest power first: `λ² - 3λ + 1`.
String polynomialText(RationalPolynomial polynomial, [String symbol = 'λ']) {
  const superscripts = '⁰¹²³⁴⁵⁶⁷⁸⁹';
  if (polynomial.isZero) return '0';
  final buffer = StringBuffer();
  for (var power = polynomial.degree; power >= 0; power--) {
    final c = polynomial[power];
    if (c.isZero) continue;
    if (buffer.isEmpty) {
      if (c.isNegative) buffer.write('-');
    } else {
      buffer.write(c.isNegative ? ' - ' : ' + ');
    }
    final size = c.abs();
    final exponent = power < 2
        ? ''
        : power
              .toString()
              .split('')
              .map((d) => superscripts[int.parse(d)])
              .join();
    final base = power == 0 ? '' : '$symbol$exponent';
    if (power == 0) {
      buffer.write(size.toString());
    } else if (size.isOne) {
      buffer.write(base);
    } else if (size.isInteger) {
      buffer.write('$size$base');
    } else {
      buffer.write('($size)$base');
    }
  }
  return buffer.toString();
}

// ---------------------------------------------------------------------------
// Rational roots

/// Every rational root of the square-free [f], exactly and without a size
/// limit.
///
/// f is scaled to a primitive integer polynomial a_n xⁿ + … + a_0. A rational
/// root u/v in lowest terms has v | a_n, and two distinct fractions with
/// denominators at most |a_n| differ by at least 1/a_n². Each real root is
/// isolated by a Sturm sequence between the Cauchy bounds ±2^e and bisected at
/// dyadic points until its interval is narrower than 1/(2a_n²). The fraction
/// with the smallest denominator in that interval is then the only candidate:
/// if the root is rational it is that fraction, which is kept only when f
/// vanishes there exactly. No floating point is involved.
List<Rational> _rationalRoots(RationalPolynomial f) {
  if (f.degree < 1) return const [];
  if (f.degree == 1) return [-f[0] / f[1]];
  final p = _integerCoefficients(f);
  final lead = p.last.abs();
  if (_rootlessModuloSomePrime(p, lead)) return const [];
  final sturm = _sturmSequence(f).map(_integerCoefficients).toList();

  int variations(_Dyadic x) {
    var count = 0;
    var previous = 0;
    for (final s in sturm) {
      final sign = _signAt(s, x);
      if (sign == 0) continue;
      if (previous != 0 && sign != previous) count++;
      previous = sign;
    }
    return count;
  }

  var largest = BigInt.zero;
  for (final c in p) {
    if (c.abs() > largest) largest = c.abs();
  }
  // |root| < 1 + max|a_i|/|a_n| ≤ 2^e.
  final e = math.max(1, largest.bitLength - lead.bitLength + 2);
  final found = <Rational>{};
  final pending = <(_Dyadic, _Dyadic)>[
    (_Dyadic(-(BigInt.one << e), 0), _Dyadic(BigInt.one << e, 0)),
  ];
  while (pending.isNotEmpty) {
    final (lo, hi) = pending.removeLast();
    final count = variations(lo) - variations(hi);
    if (count == 0) continue;
    if (count == 1) {
      final root = _refine(p, lead, lo, hi);
      if (root != null) found.add(root);
      continue;
    }
    // Split at a point that is not itself a root; a root met on the way is
    // found again inside one of the halves.
    var split = _Dyadic.mid(lo, hi);
    while (_signAt(p, split) == 0) {
      found.add(split.toRational());
      split = _Dyadic.mid(split, hi);
    }
    pending
      ..add((lo, split))
      ..add((split, hi));
  }
  return found.toList();
}

/// Whether the integer polynomial [p] has no root modulo some prime ℓ ∤
/// [lead] below 400, which proves that it has no rational root: a root u/v in
/// lowest terms has v | lead, so u·v⁻¹ would be a root modulo ℓ. A quick,
/// exact certificate for the common irreducible case; when every prime
/// tried has a root, the search in [_rationalRoots] decides.
bool _rootlessModuloSomePrime(List<BigInt> p, BigInt lead) {
  for (final prime in _primes) {
    final l = prime.toInt();
    if (l > 400) break;
    if (lead % prime == BigInt.zero) continue;
    final residues = [for (final c in p) (c % prime).toInt()];
    var rootless = true;
    for (var x = 0; x < l && rootless; x++) {
      var acc = 0;
      for (var i = residues.length - 1; i >= 0; i--) {
        acc = (acc * x + residues[i]) % l;
      }
      if (acc == 0) rootless = false;
    }
    if (rootless) return true;
  }
  return false;
}

/// The rational root in (lo, hi), which holds exactly one simple root of p
/// and has no root at either end, or null when that root is irrational.
Rational? _refine(List<BigInt> p, BigInt lead, _Dyadic lo, _Dyadic hi) {
  final shift = math.max(lo.shift, hi.shift);
  var a = lo.num << (shift - lo.shift);
  var b = hi.num << (shift - hi.shift);
  var s = shift;
  final signA = _signAt(p, _Dyadic(a, s));
  final bound = BigInt.two * lead * lead;
  // Width (b - a)/2^s must fall below 1/(2 lead²).
  while ((b - a) * bound >= BigInt.one << s) {
    final mid = a + b;
    a <<= 1;
    b <<= 1;
    s++;
    final sign = _signAt(p, _Dyadic(mid, s));
    if (sign == 0) return _Dyadic(mid, s).toRational();
    if (sign == signA) {
      a = mid;
    } else {
      b = mid;
    }
  }
  final candidate = _simplest(
    _Dyadic(a, s).toRational(),
    _Dyadic(b, s).toRational(),
  );
  return _vanishesAt(p, candidate) ? candidate : null;
}

/// The fraction with the smallest denominator in the closed interval [x, y].
Rational _simplest(Rational x, Rational y) {
  if (!x.isPositive && !y.isNegative) return Rational.zero;
  if (y.isNegative) return -_simplest(-y, -x);
  // Continued-fraction descent: 0 < x ≤ y.
  final terms = <BigInt>[];
  var lo = x;
  var hi = y;
  while (true) {
    final whole = lo.num ~/ lo.den;
    if (lo.isInteger) {
      terms.add(whole);
      break;
    }
    if (Rational(whole + BigInt.one) <= hi) {
      terms.add(whole + BigInt.one);
      break;
    }
    terms.add(whole);
    final w = Rational(whole);
    (lo, hi) = ((hi - w).inverse(), (lo - w).inverse());
  }
  var result = Rational(terms.last);
  for (var i = terms.length - 2; i >= 0; i--) {
    result = Rational(terms[i]) + result.inverse();
  }
  return result;
}

bool _vanishesAt(List<BigInt> p, Rational x) {
  final n = p.length - 1;
  var acc = p[n];
  var power = BigInt.one;
  for (var i = n - 1; i >= 0; i--) {
    power *= x.den;
    acc = acc * x.num + p[i] * power;
  }
  return acc == BigInt.zero;
}

/// Sturm sequence of [f]: f, f′, then negated remainders.
List<RationalPolynomial> _sturmSequence(RationalPolynomial f) {
  final sequence = [f, f.derivative()];
  while (true) {
    final r = -(sequence[sequence.length - 2] % sequence.last);
    if (r.isZero) break;
    sequence.add(r);
  }
  return sequence;
}

/// [f] times a positive rational, with coprime integer coefficients. The
/// sign of every value is kept.
List<BigInt> _integerCoefficients(RationalPolynomial f) {
  var lcm = BigInt.one;
  for (final c in f.coefficients) {
    lcm = lcm ~/ lcm.gcd(c.den) * c.den;
  }
  final scaled = [for (final c in f.coefficients) c.num * (lcm ~/ c.den)];
  var gcd = BigInt.zero;
  for (final c in scaled) {
    gcd = gcd.gcd(c);
  }
  return [for (final c in scaled) c ~/ gcd];
}

/// Sign of the integer polynomial [c] (constant term first) at [x], from
/// 2^(shift·n)·c(x) evaluated in integers.
int _signAt(List<BigInt> c, _Dyadic x) {
  final n = c.length - 1;
  var acc = c[n];
  for (var i = n - 1; i >= 0; i--) {
    acc = acc * x.num + (c[i] << (x.shift * (n - i)));
  }
  return acc.sign;
}

/// num / 2^shift.
class _Dyadic {
  final BigInt num;
  final int shift;
  const _Dyadic(this.num, this.shift);

  factory _Dyadic.mid(_Dyadic a, _Dyadic b) {
    final s = math.max(a.shift, b.shift);
    return _Dyadic((a.num << (s - a.shift)) + (b.num << (s - b.shift)), s + 1);
  }

  Rational toRational() => Rational(num, BigInt.one << shift);
}

// ---------------------------------------------------------------------------
// Radicals

/// Primes below 10⁵, the trial divisors for square and cube factors.
final List<BigInt> _primes = () {
  const limit = 100000;
  final composite = List.filled(limit + 1, false);
  final primes = <BigInt>[];
  for (var i = 2; i <= limit; i++) {
    if (composite[i]) continue;
    primes.add(BigInt.from(i));
    for (var j = i * i; j <= limit; j += i) {
      composite[j] = true;
    }
  }
  return primes;
}();

final List<int> _smallPrimes = [for (final p in _primes) p.toInt()];

/// [n] ≥ 0 in base 2²⁴, most significant digit first.
List<int> _limbs(BigInt n) {
  final mask = BigInt.from(0xFFFFFF);
  return [
    for (var shift = n.bitLength ~/ 24 * 24; shift >= 0; shift -= 24)
      ((n >> shift) & mask).toInt(),
  ];
}

/// n mod [p] from [_limbs]; every intermediate stays below 2⁴¹, so int
/// arithmetic is exact in JavaScript too, where BigInt division is slow.
int _remainder(List<int> limbs, int p) {
  var r = 0;
  for (final limb in limbs) {
    r = (r * 0x1000000 + limb) % p;
  }
  return r;
}

/// n = outside^power · inside, with every prime below 10⁵ appearing in
/// inside fewer than [power] times. A larger prime factor repeated [power]
/// times may stay inside, which is still exact; only when all of inside is
/// such a power is it pulled out as well.
({BigInt outside, BigInt inside}) _extractPower(BigInt n, int power) {
  var rest = n;
  var outside = BigInt.one;
  var kept = BigInt.one;
  var limbs = _limbs(rest);
  for (final small in _smallPrimes) {
    if (rest == BigInt.one) break;
    if (_remainder(limbs, small) != 0) continue;
    final p = BigInt.from(small);
    var count = 0;
    while (rest % p == BigInt.zero) {
      rest ~/= p;
      count++;
    }
    outside *= p.pow(count ~/ power);
    kept *= p.pow(count % power);
    limbs = _limbs(rest);
  }
  final root = _integerRoot(rest, power);
  if (root.pow(power) == rest) {
    outside *= root;
    rest = BigInt.one;
  }
  return (outside: outside, inside: kept * rest);
}

/// ⌊n^(1/power)⌋ for n ≥ 0.
BigInt _integerRoot(BigInt n, int power) {
  if (n < BigInt.two) return n;
  // Newton's iteration from above decreases monotonically to the floor.
  final k = BigInt.from(power);
  final k1 = BigInt.from(power - 1);
  var x = BigInt.one << (n.bitLength ~/ power + 1);
  while (true) {
    final next = (k1 * x + n ~/ x.pow(power - 1)) ~/ k;
    if (next >= x) return x;
    x = next;
  }
}

/// √r = coefficient · √radicand for r ≥ 0; radicand 1 when √r is rational.
({Rational coefficient, BigInt radicand}) _sqrt(Rational r) {
  if (r.isZero) return (coefficient: Rational.zero, radicand: BigInt.one);
  final top = _extractPower(r.num, 2);
  final bottom = _extractPower(r.den, 2);
  // √(N/M) = sN√kN / (sM√kM) = sN√(kN·kM) / (sM·kM).
  return (
    coefficient: Rational(top.outside, bottom.outside * bottom.inside),
    radicand: top.inside * bottom.inside,
  );
}

/// ∛r = coefficient · ∛radicand (real cube root, sign in the coefficient).
({Rational coefficient, BigInt radicand}) _cbrt(Rational r) {
  if (r.isZero) return (coefficient: Rational.zero, radicand: BigInt.one);
  // ∛(N/M) = ∛(N·M²) / M.
  final extracted = _extractPower(r.num.abs() * r.den * r.den, 3);
  final coefficient = Rational(extracted.outside, r.den);
  return (
    coefficient: r.isNegative ? -coefficient : coefficient,
    radicand: extracted.inside,
  );
}

/// Sign of a + b√k, exactly.
int _surdSign(Rational a, Rational b, BigInt k) {
  final sa = a.num.sign;
  final sb = b.num.sign;
  if (sb == 0 || k == BigInt.one) return (a + b * Rational(k)).num.sign;
  if (sa == 0 || sa == sb) return sb;
  // Opposite signs: the larger of a² and b²k wins.
  return (a * a).compareTo(b * b * Rational(k)) > 0 ? sa : sb;
}

// ---------------------------------------------------------------------------
// Closed forms

/// A LaTeX formula and the same expression as plain text.
class _Expr {
  final String latex;
  final String text;
  const _Expr(this.latex, this.text);
}

/// A signed summand; [body] is written without its sign.
class _Term {
  final bool negative;
  final _Expr body;
  const _Term(this.negative, this.body);
}

_Expr _join(List<_Term> terms) {
  if (terms.isEmpty) return const _Expr('0', '0');
  final latex = StringBuffer();
  final text = StringBuffer();
  for (final (i, term) in terms.indexed) {
    final sign = term.negative ? '-' : '+';
    if (i == 0) {
      if (term.negative) {
        latex.write('-');
        text.write('-');
      }
    } else {
      latex.write(' $sign ');
      text.write(' $sign ');
    }
    latex.write(term.body.latex);
    text.write(term.body.text);
  }
  return _Expr(latex.toString(), text.toString());
}

_Term? _rationalTerm(Rational r) {
  if (r.isZero) return null;
  final size = r.abs();
  return _Term(r.isNegative, _Expr(size.toLatex(), size.toString()));
}

/// size · radical for a positive rational size: 2√5, √5/2, 3∛2/4.
_Expr _scaled(Rational size, _Expr radical) {
  final n = size.num;
  final d = size.den;
  final latexTop = n == BigInt.one ? radical.latex : '$n${radical.latex}';
  final textTop = n == BigInt.one ? radical.text : '$n${radical.text}';
  if (d == BigInt.one) return _Expr(latexTop, textTop);
  return _Expr('\\frac{$latexTop}{$d}', '$textTop/$d');
}

_Expr _squareRoot(BigInt k) => _Expr('\\sqrt{$k}', '√$k');

/// |b|√k, or |b|√k·i when [imaginary]; k = 1 drops the root.
_Expr _surdMagnitude(Rational b, BigInt k, bool imaginary) {
  final size = b.abs();
  if (!imaginary) {
    return k == BigInt.one
        ? _Expr(size.toLatex(), size.toString())
        : _scaled(size, _squareRoot(k));
  }
  if (k == BigInt.one) {
    if (size.isOne) return const _Expr('i', 'i');
    if (size.isInteger) return _Expr('${size}i', '${size}i');
    return _Expr('${size.toLatex()}i', '($size)i');
  }
  final real = _scaled(size, _squareRoot(k));
  if (size.isInteger) return _Expr('${real.latex}\\,i', '${real.text} i');
  return _Expr('${real.latex}i', '(${real.text})i');
}

/// a + b√k (times i on the root when [imaginary]).
_Expr _surd(Rational a, Rational b, BigInt k, {bool imaginary = false}) =>
    _join([
      ?_rationalTerm(a),
      if (!b.isZero) _Term(b.isNegative, _surdMagnitude(b, k, imaginary)),
    ]);

/// a ± |b|√k: both conjugates in one formula.
_Expr _surdPair(Rational a, Rational b, BigInt k, {bool imaginary = false}) {
  final size = _surdMagnitude(b, k, imaginary);
  if (a.isZero) return _Expr('\\pm ${size.latex}', '±${size.text}');
  return _Expr('${a.toLatex()} \\pm ${size.latex}', '$a ± ${size.text}');
}

/// Root center + coefficient·√radicand (·i) of an irreducible quadratic.
class _Quadratic {
  final Rational center;
  final Rational coefficient;
  final BigInt radicand;
  final bool imaginary;

  const _Quadratic(
    this.center,
    this.coefficient,
    this.radicand,
    this.imaginary,
  );

  /// e0 + e1·λ = (e0 + e1·center) + e1·coefficient·√radicand.
  ({Rational a, Rational b}) parts(NumberFieldElement e) =>
      (a: e[0] + e[1] * center, b: e[1] * coefficient);

  _Expr substitute(NumberFieldElement e) {
    final p = parts(e);
    return _surd(p.a, p.b, radicand, imaginary: imaginary);
  }

  /// Order against a rational, for real roots.
  int compareTo(Rational r) => _surdSign(center - r, coefficient, radicand);
}

List<ExactEigenvalue> _quadraticRoots(RationalPolynomial q) {
  // x² + bx + c = 0 ⟺ x = -b/2 ± √D, D = b²/4 - c.
  final b = q[1];
  final c = q[0];
  final center = -b / Rational(2);
  final discriminant = b * b / Rational(4) - c;
  final imaginary = discriminant.isNegative;
  final root = _sqrt(discriminant.abs());
  final pair = _surdPair(
    center,
    root.coefficient,
    root.radicand,
    imaginary: imaginary,
  );
  final centerValue = approximateRational(center);
  // |coefficient|·√radicand = √|D|, evaluated from the written parts.
  final offset = math.sqrt(
    approximateRational(
      root.coefficient * root.coefficient * Rational(root.radicand),
    ),
  );
  return [
    for (final sign in [1, -1])
      () {
        final coefficient = sign > 0 ? root.coefficient : -root.coefficient;
        final value = _surd(
          center,
          coefficient,
          root.radicand,
          imaginary: imaginary,
        );
        return ExactEigenvalue._(
          minimalPolynomial: q,
          algebraicMultiplicity: 1,
          isReal: !imaginary,
          latex: value.latex,
          text: value.text,
          approximate: imaginary ? centerValue : centerValue + sign * offset,
          approximateImaginary: imaginary ? sign * offset : 0,
          quadratic: _Quadratic(center, coefficient, root.radicand, imaginary),
          pair: pair,
          conjugate: sign > 0 ? 0 : 1,
        );
      }(),
  ];
}

/// Both non-real or irrational conjugates of [value] as one ± formula, e.g.
/// `\frac{1}{2} \pm \frac{\sqrt{5}}{2}`; null for a rational value or a
/// real cubic root.
({String latex, String text})? conjugatePair(ExactEigenvalue value) {
  final pair = value._pair;
  return pair == null ? null : (latex: pair.latex, text: pair.text);
}

List<ExactEigenvalue> _cubicRoots(RationalPolynomial q) {
  // x = t - a/3 turns x³ + ax² + bx + c into t³ + pt + s.
  final a = q[2];
  final b = q[1];
  final c = q[0];
  final shift = -a / Rational(3);
  final p = b - a * a / Rational(3);
  final s = Rational(2) * a * a * a / Rational(27) - a * b / Rational(3) + c;
  // Discriminant -(4p³ + 27s²), nonzero because q is irreducible.
  final discriminant = -(Rational(4) * p * p * p + Rational(27) * s * s);
  return discriminant.isNegative
      ? _cardano(q, shift, p, s)
      : _trigonometric(q, shift, p, s);
}

/// One real root u + v and the pair -(u+v)/2 ± (√3/2)(u - v)i, where
/// u = ∛U, v = ∛V with U, V = -s/2 ± √R and R = s²/4 + p³/27 > 0.
List<ExactEigenvalue> _cardano(
  RationalPolynomial q,
  Rational shift,
  Rational p,
  Rational s,
) {
  final half = Rational(1, 2);
  final r = s * s / Rational(4) + p * p * p / Rational(27);
  final root = _sqrt(r);
  final center = -s * half;

  // Written parts of u + v, -(u + v)/2 and u - v as sums of terms.
  final List<_Term> sum;
  final List<_Term> halfSum;
  final Rational rationalSum;
  _Expr? imaginary;
  List<_Term> difference;
  if (root.radicand == BigInt.one) {
    // U and V are rational: simplify each real cube root and collect like
    // radicals, radicand 1 being the rational part.
    final u = _cbrt(center + root.coefficient);
    final v = _cbrt(center - root.coefficient);
    final plus = <BigInt, Rational>{};
    final minus = <BigInt, Rational>{};
    void add(Map<BigInt, Rational> map, BigInt k, Rational coefficient) =>
        map[k] = (map[k] ?? Rational.zero) + coefficient;
    add(plus, u.radicand, u.coefficient);
    add(plus, v.radicand, v.coefficient);
    add(minus, u.radicand, u.coefficient);
    add(minus, v.radicand, -v.coefficient);
    plus.removeWhere((_, c) => c.isZero);
    minus.removeWhere((_, c) => c.isZero);
    rationalSum = plus.remove(BigInt.one) ?? Rational.zero;
    _Expr cube(BigInt k) => _Expr('\\sqrt[3]{$k}', '∛$k');
    List<_Term> terms(Map<BigInt, Rational> map, Rational factor) => [
      for (final MapEntry(key: k, value: c) in map.entries)
        k == BigInt.one
            ? _rationalTerm(c * factor)!
            : _Term(
                (c * factor).isNegative,
                _scaled((c * factor).abs(), cube(k)),
              ),
    ];
    sum = terms(plus, Rational.one);
    halfSum = terms(plus, -half);
    difference = terms(minus, Rational.one);
    if (minus.length == 1) {
      // u - v = c·∛k with c > 0 (U > V), so (√3/2)(u - v) = (c/2)·√3·∛k.
      final MapEntry(key: k, value: c) = minus.entries.single;
      final radical = k == BigInt.one
          ? _squareRoot(BigInt.from(3))
          : _Expr('\\sqrt{3}\\,\\sqrt[3]{$k}', '√3·∛$k');
      final size = _scaled(c * half, radical);
      imaginary = (c * half).isInteger
          ? _Expr('${size.latex}\\,i', '${size.text} i')
          : _Expr('${size.latex}i', '(${size.text})i');
    }
  } else {
    // U, V = (A ± C√k)/d. A perfect cube e³ dividing d leaves the roots:
    // ∛U = ∛(e³·U)/e, which clears the 27 that the shift x = t - a/3 adds.
    final d =
        center.den ~/
        center.den.gcd(root.coefficient.den) *
        root.coefficient.den;
    final e = _extractPower(d, 3).outside;
    final cube = Rational(e * e * e);
    final u = _surd(center * cube, root.coefficient * cube, root.radicand);
    final v = _surd(center * cube, -root.coefficient * cube, root.radicand);
    final cu = _Expr('\\sqrt[3]{${u.latex}}', '∛(${u.text})');
    final cv = _Expr('\\sqrt[3]{${v.latex}}', '∛(${v.text})');
    rationalSum = Rational.zero;
    _Expr over(_Expr inner, BigInt divisor) => divisor == BigInt.one
        ? inner
        : _Expr('\\frac{${inner.latex}}{$divisor}', '(${inner.text})/$divisor');
    final both = _join([_Term(false, cu), _Term(false, cv)]);
    sum = e == BigInt.one
        ? [_Term(false, cu), _Term(false, cv)]
        : [_Term(false, over(both, e))];
    halfSum = [_Term(true, over(both, BigInt.two * e))];
    difference = const [];
    final inner = _join([_Term(false, cu), _Term(true, cv)]);
    imaginary = _Expr(
      '\\frac{\\sqrt{3}}{${BigInt.two * e}}\\left(${inner.latex}\\right)i',
      '(√3/${BigInt.two * e})(${inner.text})i',
    );
  }

  final real = _join([?_rationalTerm(shift + rationalSum), ...sum]);
  final complexReal = _join([
    ?_rationalTerm(shift - rationalSum * half),
    ...halfSum,
  ]);
  if (imaginary == null) {
    final inner = _join(difference);
    imaginary = _Expr(
      '\\frac{\\sqrt{3}}{2}\\left(${inner.latex}\\right)i',
      '(√3/2)(${inner.text})i',
    );
  }

  // Floating point from the same formula. u is taken on the side of -s/2
  // with the larger magnitude and v from uv = -p/3, which is Cardano's
  // pairing of the two cube roots, so nothing cancels.
  final centerValue = approximateRational(center);
  final rootValue = math.sqrt(
    approximateRational(
      root.coefficient * root.coefficient * Rational(root.radicand),
    ),
  );
  final big = centerValue >= 0
      ? centerValue + rootValue
      : centerValue - rootValue;
  final uValue = _realCbrt(big);
  final vValue = -approximateRational(p) / (3 * uValue);
  final shiftValue = approximateRational(shift);
  final realValue = shiftValue + uValue + vValue;
  final complexRealValue = shiftValue - (uValue + vValue) / 2;
  final imaginaryValue = math.sqrt(3) / 2 * (uValue - vValue).abs();

  String join(_Expr re, String sign, _Expr im, {required bool latex}) {
    final realText = latex ? re.latex : re.text;
    final imText = latex ? im.latex : im.text;
    if (realText == '0') {
      return sign == '+' ? imText : '-$imText';
    }
    return '$realText $sign $imText';
  }

  final im = imaginary;
  final pair = complexReal.latex == '0'
      ? _Expr('\\pm ${im.latex}', '±${im.text}')
      : _Expr(
          '${complexReal.latex} \\pm ${im.latex}',
          '${complexReal.text} ± ${im.text}',
        );
  return [
    ExactEigenvalue._(
      minimalPolynomial: q,
      algebraicMultiplicity: 1,
      isReal: true,
      latex: real.latex,
      text: real.text,
      approximate: realValue,
    ),
    for (final (index, sign) in ['+', '-'].indexed)
      ExactEigenvalue._(
        minimalPolynomial: q,
        algebraicMultiplicity: 1,
        isReal: false,
        latex: join(complexReal, sign, im, latex: true),
        text: join(complexReal, sign, im, latex: false),
        approximate: complexRealValue,
        approximateImaginary: index == 0 ? imaginaryValue : -imaginaryValue,
        pair: pair,
        conjugate: index,
      ),
  ];
}

double _realCbrt(double x) =>
    x < 0 ? -math.pow(-x, 1 / 3).toDouble() : math.pow(x, 1 / 3).toDouble();

/// Three real roots t_k = 2√(-p/3)·cos((1/3)·arccos((3s/2p)·√(-3/p)) - 2πk/3).
List<ExactEigenvalue> _trigonometric(
  RationalPolynomial q,
  Rational shift,
  Rational p,
  Rational s,
) {
  final amplitudeRoot = _sqrt(-p / Rational(3));
  final amplitudeSize = amplitudeRoot.coefficient * Rational(2);
  final amplitude = amplitudeRoot.radicand == BigInt.one
      ? _Expr(amplitudeSize.toLatex(), amplitudeSize.toString())
      : _scaled(amplitudeSize, _squareRoot(amplitudeRoot.radicand));
  final argumentRoot = _sqrt(-Rational(3) / p);
  final argumentCoefficient =
      Rational(3) * s / (Rational(2) * p) * argumentRoot.coefficient;
  final argument = _surd(
    Rational.zero,
    argumentCoefficient,
    argumentRoot.radicand,
  );
  final amplitudeValue = math.sqrt(
    approximateRational(
      amplitudeSize * amplitudeSize * Rational(amplitudeRoot.radicand),
    ),
  );
  final argumentValue =
      argumentCoefficient.num.sign *
      math.sqrt(
        approximateRational(
          argumentCoefficient *
              argumentCoefficient *
              Rational(argumentRoot.radicand),
        ),
      );
  // arccos of ±1/2, ±√2/2 and ±√3/2 is a rational multiple of π, which
  // turns each cosine into cos(mπ).
  final Rational? arccos = _knownArccos(
    argumentCoefficient,
    argumentRoot.radicand,
  );
  final shiftValue = approximateRational(shift);
  final shiftTerm = _rationalTerm(shift);
  return [
    for (final k in [2, 1, 0])
      () {
        final _Expr angle;
        final double angleValue;
        if (arccos != null) {
          var multiple = ((arccos - Rational(2 * k)) / Rational(3)).abs();
          // cos is even and 2π-periodic; write the angle in [0, π] as
          // textbooks do (2cos(8π/9), not 2cos(10π/9)).
          final two = Rational(2);
          while (multiple > two) {
            multiple = multiple - two;
          }
          if (multiple > Rational.one) multiple = two - multiple;
          angle = _piMultiple(multiple);
          angleValue = multiple.toDouble() * math.pi;
        } else {
          final offset = switch (k) {
            1 => const _Expr(' - \\frac{2\\pi}{3}', ' - 2π/3'),
            2 => const _Expr(' - \\frac{4\\pi}{3}', ' - 4π/3'),
            _ => const _Expr('', ''),
          };
          angle = _Expr(
            '\\frac{1}{3}\\arccos\\left(${argument.latex}\\right)${offset.latex}',
            'arccos(${argument.text})/3${offset.text}',
          );
          angleValue =
              math.acos(argumentValue.clamp(-1.0, 1.0)) / 3 -
              2 * math.pi * k / 3;
        }
        final value = _join([
          ?shiftTerm,
          _Term(
            false,
            _Expr(
              '${amplitude.latex}\\cos\\left(${angle.latex}\\right)',
              '${amplitude.text}·cos(${angle.text})',
            ),
          ),
        ]);
        return ExactEigenvalue._(
          minimalPolynomial: q,
          algebraicMultiplicity: 1,
          isReal: true,
          latex: value.latex,
          text: value.text,
          approximate: shiftValue + amplitudeValue * math.cos(angleValue),
          conjugate: 2 - k,
        );
      }(),
  ];
}

/// arccos(c·√k)/π when it is rational, for the values a cubic can meet.
Rational? _knownArccos(Rational c, BigInt k) {
  if (c.abs() != Rational(1, 2) || k > BigInt.from(3)) return null;
  final positive = c.isPositive;
  return switch (k.toInt()) {
    1 => positive ? Rational(1, 3) : Rational(2, 3),
    2 => positive ? Rational(1, 4) : Rational(3, 4),
    3 => positive ? Rational(1, 6) : Rational(5, 6),
    _ => null,
  };
}

/// m·π for a positive rational m: π, 2π/9, 10π/9.
_Expr _piMultiple(Rational m) {
  final n = m.num;
  final d = m.den;
  final top = n == BigInt.one ? r'\pi' : '$n\\pi';
  final topText = n == BigInt.one ? 'π' : '$nπ';
  if (d == BigInt.one) return _Expr(top, topText);
  return _Expr('\\frac{$top}{$d}', '$topText/$d');
}
