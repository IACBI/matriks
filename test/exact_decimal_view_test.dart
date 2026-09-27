import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/core/number_format.dart';
import 'package:matriks/core/widgets/math_text.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

/// Reads a decimal-view string back into the exact value it denotes.
Rational parseDecimalView(String latex) {
  final fraction = RegExp(r'^(-?)\\frac\{(\d+)\}\{(\d+)\}$').firstMatch(latex);
  if (fraction != null) {
    final value = Rational(
      BigInt.parse(fraction[2]!),
      BigInt.parse(fraction[3]!),
    );
    return fraction[1]!.isEmpty ? value : -value;
  }
  final match = RegExp(r'^(-?)(\d+)(?:\.(\d*)(?:\\overline\{(\d+)\})?)?$')
      .firstMatch(latex);
  expect(match, isNotNull, reason: latex);
  final fixed = match![3] ?? '';
  final repetend = match[4] ?? '';
  final shift = BigInt.from(10).pow(fixed.length);
  var value =
      Rational(BigInt.parse(match[2]!)) +
      Rational(BigInt.parse(fixed.isEmpty ? '0' : fixed), shift);
  if (repetend.isNotEmpty) {
    final period = BigInt.from(10).pow(repetend.length) - BigInt.one;
    value = value + Rational(BigInt.parse(repetend), period * shift);
  }
  return match[1]!.isEmpty ? value : -value;
}

/// Characters a reader sees: the bar adds no width.
int shownLength(String latex) =>
    latex.replaceAll(r'\overline{', '').replaceAll('}', '').length;

void main() {
  group('Exact decimal view', () {
    test('repeating expansions put a bar over the repetend', () {
      expect(decimalLatex(Rational(1, 3)), r'0.\overline{3}');
      expect(decimalLatex(Rational(1, 6)), r'0.1\overline{6}');
      expect(decimalLatex(Rational(22, 7)), r'3.\overline{142857}');
      expect(decimalLatex(Rational(-1, 12)), r'-0.08\overline{3}');
      expect(decimalLatex(Rational(-7, 3)), r'-2.\overline{3}');
      expect(decimalLatex(Rational(1, 17)), r'0.\overline{0588235294117647}');
    });

    test('terminating expansions show every digit', () {
      expect(decimalLatex(Rational.zero), '0');
      expect(decimalLatex(Rational(42)), '42');
      expect(decimalLatex(Rational(-3)), '-3');
      expect(decimalLatex(Rational(1, 8)), '0.125');
      expect(decimalLatex(Rational(-1, 16)), '-0.0625');
      expect(decimalLatex(Rational(12345, 1024)), '12.0556640625');
      expect(
        decimalLatex(Rational(BigInt.one, BigInt.two.pow(24))),
        '0.000000059604644775390625',
      );
    });

    test('longer expansions fall back to the exact fraction', () {
      // 25 terminating digits.
      expect(
        decimalLatex(Rational(BigInt.one, BigInt.two.pow(25))),
        r'\frac{1}{33554432}',
      );
      // 23 digits before a one-digit repetend is 24; one more is too long.
      final threes = BigInt.from(3);
      final longest = Rational(BigInt.one, threes * BigInt.two.pow(23));
      expect(decimalLatex(longest), r'0.00000003973642985026041\overline{6}');
      expect(parseDecimalView(decimalLatex(longest)), longest);
      expect(
        decimalLatex(Rational(BigInt.one, threes * BigInt.two.pow(24))),
        r'\frac{1}{50331648}',
      );
      // Period 22 fits, period 28 does not.
      expect(decimalLatex(Rational(1, 23)), contains(r'\overline'));
      expect(decimalLatex(Rational(-1, 29)), r'-\frac{1}{29}');
      expect(decimalLatex(Rational(100, 97)), r'\frac{100}{97}');
    });

    test('huge denominators fall back without long division', () {
      final den = BigInt.from(10).pow(2000) + BigInt.one;
      final value = Rational(BigInt.from(7), den);
      final watch = Stopwatch()..start();
      for (var i = 0; i < 1000; i++) {
        decimalLatex(value);
      }
      watch.stop();
      expect(decimalLatex(value), value.toLatex());
      expect(watch.elapsedMilliseconds, lessThan(2000));
    });

    test('every shown decimal is exactly the value', () {
      final random = math.Random(7);
      for (var i = 0; i < 3000; i++) {
        final den = random.nextInt(2000) + 1;
        final num = random.nextInt(200001) - 100000;
        final value = Rational(num, den);
        final latex = decimalLatex(value);
        expect(latex, isNot(contains('approx')));
        expect(parseDecimalView(latex), value, reason: '$value → $latex');
      }
    });

    test('decimalWidth counts the characters shown', () {
      final random = math.Random(11);
      for (var i = 0; i < 2000; i++) {
        final value = Rational(
          random.nextInt(2000001) - 1000000,
          random.nextInt(5000) + 1,
        );
        final latex = decimalLatex(value);
        expect(
          decimalWidth(value),
          latex.contains(r'\frac') ? fractionWidth(value) : shownLength(latex),
          reason: latex,
        );
      }
    });
  });

  group('Repeating decimals for screen readers', () {
    test('the bar is read as a word, not dropped or leaked', () {
      expect(mathSemanticsLabel(r'0.1\overline{6}'), '0.1 repeating 6');
      expect(mathSemanticsLabel(r'-0.08\overline{3}'), '-0.08 repeating 3');
      expect(mathSemanticsLabel(r'3.\overline{142857}'), '3. repeating 142857');
      expect(readableMathProse(r'x = 0.1\overline{6}'), 'x = 0.1 repeating 6');
      expect(
        mathSemanticsLabel(r'0.\overline{3}', repeating: 'devirli'),
        '0. devirli 3',
      );
    });

    testWidgets('flutter_math renders the bar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: MathText(r'0.1\overline{6}'))),
        ),
      );
      final math = tester.widget<Math>(find.byType(Math));
      expect(math.parseError, isNull);
      expect(find.text(r'0.1\overline{6}'), findsNothing);
      expect(tester.takeException(), isNull);
      // The bar sits above the digits, so the formula is taller than the
      // same digits without it.
      final barred = tester.getSize(find.byType(Math));
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: MathText('0.16'))),
        ),
      );
      final plain = tester.getSize(find.byType(Math));
      expect(barred.height, greaterThan(plain.height));
      expect(barred.width, moreOrLessEquals(plain.width, epsilon: 1));
    });
  });

  testWidgets('The repeating word follows the interface language', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: MathText(r'0.1\overline{6}')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('0.1 devirli 6'), findsOneWidget);
    handle.dispose();
  });
}
