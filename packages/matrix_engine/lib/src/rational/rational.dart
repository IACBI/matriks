/// Exact rational number (fraction) implementation for deterministic linear algebra.
/// Avoids floating-point precision drift by storing numbers as [BigInt] numerator and denominator.
class Rational implements Comparable<Rational> {
  final BigInt num;
  final BigInt den;

  static final Rational zero = Rational(BigInt.zero);
  static final Rational one = Rational(BigInt.one);
  static final Rational minusOne = Rational(-BigInt.one);

  factory Rational(dynamic numerator, [dynamic denominator]) {
    BigInt n;
    if (numerator is BigInt) {
      n = numerator;
    } else if (numerator is int) {
      n = BigInt.from(numerator);
    } else if (numerator is String) {
      n = BigInt.parse(numerator);
    } else {
      throw ArgumentError('Invalid numerator type: ${numerator.runtimeType}');
    }

    BigInt d;
    if (denominator == null) {
      d = BigInt.one;
    } else if (denominator is BigInt) {
      d = denominator;
    } else if (denominator is int) {
      d = BigInt.from(denominator);
    } else if (denominator is String) {
      d = BigInt.parse(denominator);
    } else {
      throw ArgumentError(
        'Invalid denominator type: ${denominator.runtimeType}',
      );
    }

    if (d == BigInt.zero) {
      throw const DivisionByZeroException();
    }

    // Normalize signs: denominator must be positive
    if (d < BigInt.zero) {
      n = -n;
      d = -d;
    }

    if (n == BigInt.zero) {
      return Rational._internal(BigInt.zero, BigInt.one);
    }

    final gcdVal = _gcd(n.abs(), d);
    return Rational._internal(n ~/ gcdVal, d ~/ gcdVal);
  }

  const Rational._internal(this.num, this.den);

  factory Rational.fromInt(int n) => Rational(BigInt.from(n), BigInt.one);

  /// Parse strings like "3", "-5", "3/4", "-12/7", "0.25", "-1.5"
  static Rational? tryParse(String input) {
    final s = input.trim();
    if (s.isEmpty) return null;

    if (s.contains('/')) {
      final parts = s.split('/');
      if (parts.length != 2) return null;
      final n = BigInt.tryParse(parts[0].trim());
      final d = BigInt.tryParse(parts[1].trim());
      if (n == null || d == null || d == BigInt.zero) return null;
      return Rational(n, d);
    }

    if (s.contains('.')) {
      final parts = s.split('.');
      if (parts.length != 2) return null;
      final whole = BigInt.tryParse(parts[0].trim());
      final decStr = parts[1].trim();
      if (!RegExp(r'^\d+$').hasMatch(decStr)) return null;
      final dec = BigInt.tryParse(decStr);
      if (whole == null || dec == null) return null;

      final isNegative = parts[0].trim().startsWith('-');
      final factor = BigInt.from(10).pow(decStr.length);
      final totalNum = (whole.abs() * factor) + dec;
      final signedNum = isNegative ? -totalNum : totalNum;
      return Rational(signedNum, factor);
    }

    final n = BigInt.tryParse(s);
    if (n != null) {
      return Rational(n, BigInt.one);
    }

    return null;
  }

  static Rational parse(String input) {
    final r = tryParse(input);
    if (r == null) {
      throw FormatException('Cannot parse "$input" as a Rational');
    }
    return r;
  }

  static BigInt _gcd(BigInt a, BigInt b) {
    while (b != BigInt.zero) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  bool get isZero => num == BigInt.zero;
  bool get isOne => num == BigInt.one && den == BigInt.one;
  bool get isNegative => num < BigInt.zero;
  bool get isPositive => num > BigInt.zero;
  bool get isInteger => den == BigInt.one;

  Rational operator +(Rational other) {
    final newNum = (num * other.den) + (other.num * den);
    final newDen = den * other.den;
    return Rational(newNum, newDen);
  }

  Rational operator -(Rational other) {
    final newNum = (num * other.den) - (other.num * den);
    final newDen = den * other.den;
    return Rational(newNum, newDen);
  }

  Rational operator *(Rational other) {
    final newNum = num * other.num;
    final newDen = den * other.den;
    return Rational(newNum, newDen);
  }

  Rational operator /(Rational other) {
    if (other.num == BigInt.zero) {
      throw const DivisionByZeroException();
    }
    final newNum = num * other.den;
    final newDen = den * other.num;
    return Rational(newNum, newDen);
  }

  Rational operator -() => Rational(-num, den);

  Rational abs() => isNegative ? -this : this;

  Rational inverse() {
    if (isZero) throw const DivisionByZeroException();
    return Rational(den, num);
  }

  Rational pow(int exponent) {
    if (exponent == 0) return Rational.one;
    if (exponent > 0) {
      return Rational(num.pow(exponent), den.pow(exponent));
    }
    return Rational(den.pow(-exponent), num.pow(-exponent));
  }

  double toDouble() => num.toDouble() / den.toDouble();

  /// Formatted LaTeX string, e.g. "0", "5", "-\frac{3}{4}"
  String toLatex() {
    if (den == BigInt.one) return num.toString();
    if (num < BigInt.zero) {
      return '-\\frac{${(-num)}}{$den}';
    }
    return '\\frac{$num}{$den}';
  }

  /// Compact text format: "0", "3", "-5/7"
  @override
  String toString() {
    if (den == BigInt.one) return num.toString();
    return '$num/$den';
  }

  /// Human friendly display, with optional decimal rounding.
  String toDisplayString({bool asDecimal = false, int decimalPlaces = 2}) {
    if (asDecimal) return toDecimalString(decimalPlaces);
    return toString();
  }

  /// Rounds half away from zero to [places] decimals with exact integer
  /// arithmetic. Unlike [toDouble], values beyond the double range never turn
  /// into `NaN` or `Infinity`.
  String toDecimalString([int places = 4]) {
    if (places < 0) throw RangeError.value(places, 'places');
    final factor = BigInt.from(10).pow(places);
    final scaled = num.abs() * factor;
    var rounded = scaled ~/ den;
    if ((scaled % den) * BigInt.two >= den) rounded += BigInt.one;
    final sign = isNegative && rounded != BigInt.zero ? '-' : '';
    if (places == 0) return '$sign$rounded';
    final digits = rounded.toString().padLeft(places + 1, '0');
    final split = digits.length - places;
    return '$sign${digits.substring(0, split)}.${digits.substring(split)}';
  }

  /// Whether the decimal expansion ends within [places] digits, so that
  /// [toDecimalString] with that many places is exact rather than rounded.
  bool terminatesWithin(int places) =>
      BigInt.from(10).pow(places) % den == BigInt.zero;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rational &&
          runtimeType == other.runtimeType &&
          num == other.num &&
          den == other.den;

  @override
  int get hashCode => Object.hash(num, den);

  @override
  int compareTo(Rational other) {
    final diff = (num * other.den) - (other.num * den);
    if (diff > BigInt.zero) return 1;
    if (diff < BigInt.zero) return -1;
    return 0;
  }

  bool operator <(Rational other) => compareTo(other) < 0;
  bool operator <=(Rational other) => compareTo(other) <= 0;
  bool operator >(Rational other) => compareTo(other) > 0;
  bool operator >=(Rational other) => compareTo(other) >= 0;
}

class DivisionByZeroException implements Exception {
  final String message;
  const DivisionByZeroException([
    this.message = 'Division by zero is undefined.',
  ]);

  @override
  String toString() => 'DivisionByZeroException: $message';
}
