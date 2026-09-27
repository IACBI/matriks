import 'package:intl/intl.dart';
import 'package:matrix_engine/matrix_engine.dart';

/// Most digits the decimal view writes after the point, repetend included.
///
/// A sign, a few integer digits, the point and 24 digits stay under the
/// roughly 32 characters at which a matrix cell stops growing, and a longer
/// repetend is more than a reader can check digit by digit. 1/17, 1/19 and
/// 1/23 (periods 16, 18 and 22) are written out; 1/29 (period 28) and longer
/// are shown as fractions.
const decimalViewMaxDigits = 24;

// An expansion with p digits before the repetend and k in it has a
// denominator dividing 10^p·(10^k − 1), so it is at most 10^(p+k). A larger
// denominator cannot fit and needs no division at all.
final _maxDenominator = BigInt.from(10).pow(decimalViewMaxDigits);
final _ten = BigInt.from(10);

/// Exact decimal expansion of |value|, or null when it has more than
/// [decimalViewMaxDigits] digits after the point.
({BigInt whole, String fixed, String repetend})? _expand(Rational value) {
  final den = value.den;
  if (den > _maxDenominator) return null;
  final numerator = value.num.abs();
  var remainder = numerator % den;
  final seen = <BigInt, int>{};
  final digits = StringBuffer();
  while (remainder != BigInt.zero) {
    final start = seen[remainder];
    if (start != null) {
      final text = digits.toString();
      return (
        whole: numerator ~/ den,
        fixed: text.substring(0, start),
        repetend: text.substring(start),
      );
    }
    if (seen.length == decimalViewMaxDigits) return null;
    seen[remainder] = seen.length;
    remainder *= _ten;
    digits.write(remainder ~/ den);
    remainder = remainder % den;
  }
  return (whole: numerator ~/ den, fixed: digits.toString(), repetend: '');
}

/// TeX for the decimal view of an exact value. Nothing is rounded.
///
/// A terminating expansion is written in full and a repeating one carries a
/// bar over its repetend: 1/6 is `0.1\overline{6}`. An expansion longer than
/// [decimalViewMaxDigits] after the point is shown as the exact fraction.
String decimalLatex(Rational value) {
  final expansion = _expand(value);
  if (expansion == null) return value.toLatex();
  final (:whole, :fixed, :repetend) = expansion;
  final sign = value.isNegative ? '-' : '';
  if (fixed.isEmpty && repetend.isEmpty) return '$sign$whole';
  final bar = repetend.isEmpty ? '' : '\\overline{$repetend}';
  return '$sign$whole.$fixed$bar';
}

/// Number of characters a decimal cell needs, for layout estimates: the
/// characters [decimalLatex] displays, or [fractionWidth] when it falls back
/// to a fraction.
int decimalWidth(Rational value) {
  final expansion = _expand(value);
  if (expansion == null) return fractionWidth(value);
  final (:whole, :fixed, :repetend) = expansion;
  final decimals = fixed.length + repetend.length;
  return (value.isNegative ? 1 : 0) +
      layoutLength(whole) +
      (decimals == 0 ? 0 : decimals + 1);
}

/// Number of characters a fraction cell needs, for layout estimates: the
/// longer of its numerator (with sign) and denominator.
int fractionWidth(Rational value) {
  final numerator = layoutLength(value.num);
  final denominator = layoutLength(value.den);
  return numerator > denominator ? numerator : denominator;
}

/// `n.toString().length`, exact up to 130 bits (39 digits) and a lower bound
/// beyond that.
///
/// Cell width stops growing at about 32 characters, so the exact length of a
/// larger number cannot change the layout. Converting it to text can:
/// a 357-digit BigInt takes long enough in JavaScript that thousands of them
/// block the web interface. Every number of 131 bits or more has at least 40
/// digits, and so does the bound.
int layoutLength(BigInt n) {
  final bits = n.abs().bitLength;
  if (bits <= 130) return n.toString().length;
  // 2^(bits-1) ≤ |n|; the constant sits just under log10(2) so rounding can
  // only lower the bound.
  return (n.isNegative ? 1 : 0) + ((bits - 1) * 0.30102).floor() + 1;
}

/// Playback speed such as "1.25×" in the reader's locale ("1,25×" in Turkish).
String formatSpeed(double speed, String locale) =>
    '${NumberFormat('0.##', locale).format(speed)}×';
