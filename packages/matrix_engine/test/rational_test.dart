import 'package:matrix_engine/src/rational/rational.dart';
import 'package:test/test.dart';

void main() {
  group('Rational Arithmetic', () {
    test('Basic creation and simplification', () {
      final r1 = Rational(4, 8);
      expect(r1.num, equals(BigInt.from(1)));
      expect(r1.den, equals(BigInt.from(2)));
      expect(r1.toString(), equals('1/2'));

      final r2 = Rational(-6, 9);
      expect(r2.num, equals(BigInt.from(-2)));
      expect(r2.den, equals(BigInt.from(3)));

      final r3 = Rational(6, -9);
      expect(r3.num, equals(BigInt.from(-2)));
      expect(r3.den, equals(BigInt.from(3)));

      final r4 = Rational(-6, -9);
      expect(r4.num, equals(BigInt.from(2)));
      expect(r4.den, equals(BigInt.from(3)));

      final rZero = Rational(0, 5);
      expect(rZero.isZero, isTrue);
      expect(rZero.num, equals(BigInt.zero));
      expect(rZero.den, equals(BigInt.one));
    });

    test('Division by zero throws exception', () {
      expect(() => Rational(1, 0), throwsA(isA<DivisionByZeroException>()));
      expect(
        () => Rational(1, 2) / Rational.zero,
        throwsA(isA<DivisionByZeroException>()),
      );
    });

    test('Addition & Subtraction', () {
      final a = Rational(1, 3);
      final b = Rational(1, 6);
      expect(a + b, equals(Rational(1, 2)));
      expect(a - b, equals(Rational(1, 6)));
      expect(b - a, equals(Rational(-1, 6)));
    });

    test('Multiplication & Division', () {
      final a = Rational(2, 3);
      final b = Rational(3, 4);
      expect(a * b, equals(Rational(1, 2)));
      expect(a / b, equals(Rational(8, 9)));
    });

    test('String parsing', () {
      expect(Rational.parse('5'), equals(Rational(5, 1)));
      expect(Rational.parse('-7'), equals(Rational(-7, 1)));
      expect(Rational.parse('3/4'), equals(Rational(3, 4)));
      expect(Rational.parse('-15/20'), equals(Rational(-3, 4)));
      expect(Rational.parse('0.75'), equals(Rational(3, 4)));
      expect(Rational.parse('-0.5'), equals(Rational(-1, 2)));
      expect(Rational.tryParse('invalid'), isNull);
    });

    test('LaTeX formatting', () {
      expect(Rational(5, 1).toLatex(), equals('5'));
      expect(Rational(3, 4).toLatex(), equals(r'\frac{3}{4}'));
      expect(Rational(-3, 4).toLatex(), equals(r'-\frac{3}{4}'));
    });

    test('Comparison', () {
      expect(Rational(1, 3) < Rational(1, 2), isTrue);
      expect(Rational(2, 4) == Rational(1, 2), isTrue);
      expect(Rational(-1, 2) < Rational.zero, isTrue);
    });

    test('Decimal text rounds exactly, even beyond the double range', () {
      expect(Rational(1, 3).toDecimalString(4), '0.3333');
      expect(Rational(2, 3).toDecimalString(4), '0.6667');
      expect(Rational(-1, 8).toDecimalString(2), '-0.13');
      expect(Rational(-1, 1000).toDecimalString(2), '0.00');
      expect(Rational(7).toDecimalString(0), '7');
      final huge = Rational.parse('1${'0' * 400}') / Rational(3);
      expect(huge.toDouble().isFinite, isFalse);
      expect(huge.toDecimalString(1), '${'3' * 400}.3');
      expect(Rational(3, 8).terminatesWithin(3), isTrue);
      expect(Rational(3, 8).terminatesWithin(2), isFalse);
      expect(Rational(1, 3).terminatesWithin(12), isFalse);
    });
  });
}
