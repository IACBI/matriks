import 'package:intl/intl.dart';
import 'package:matrix_engine/matrix_engine.dart';

/// Decimal places shown by the decimal view.
const decimalViewPlaces = 4;

/// TeX for the decimal view of an exact value.
///
/// A value whose expansion ends within [decimalViewPlaces] digits is shown
/// exactly, without trailing zeros. Anything else is rounded and marked with
/// ≈, so a rounded number never reads as exact. A nonzero value too small to
/// survive rounding switches to scientific notation rather than showing a zero
/// that could be mistaken for a pivot that vanished.
String decimalLatex(Rational value) {
  final rounded = value.toDecimalString(decimalViewPlaces);
  if (value.terminatesWithin(decimalViewPlaces)) return _trimZeros(rounded);
  if (RegExp(r'^-?0\.0+$').hasMatch(rounded)) {
    return '\\approx ${_scientific(value)}';
  }
  return '\\approx $rounded';
}

/// Number of characters a decimal cell needs, for layout estimates.
int decimalWidth(Rational value) =>
    decimalLatex(value).replaceAll(r'\approx ', '~').length;

String _trimZeros(String text) {
  if (!text.contains('.')) return text;
  return text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

String _scientific(Rational value) {
  final ten = Rational.fromInt(10);
  var exponent = 0;
  var scaled = value.abs();
  while (scaled < Rational.one) {
    scaled = scaled * ten;
    exponent--;
  }
  var mantissa = scaled.toDecimalString(2);
  if (mantissa == '10.00') {
    mantissa = '1.00';
    exponent++;
  }
  final sign = value.isNegative ? '-' : '';
  return '$sign$mantissa \\times 10^{$exponent}';
}

/// Playback speed such as "1.25×" in the reader's locale ("1,25×" in Turkish).
String formatSpeed(double speed, String locale) =>
    '${NumberFormat('0.##', locale).format(speed)}×';
