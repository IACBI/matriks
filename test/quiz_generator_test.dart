import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/features/practice/models/quiz_generator.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

void main() {
  test('Generated rounds are well formed in every language', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final l = lookupAppLocalizations(locale);
      for (var seed = 0; seed < 40; seed++) {
        final round = QuizGenerator.generate(seed, l);
        expect(round, hasLength(QuizGenerator.roundLength));
        // Every kind of question appears in each round.
        expect(
          round.map((q) => q.id.split('-').last).toSet(),
          containsAll(['det', 'multiplier', 'product', 'inverse']),
        );
        for (final q in round) {
          expect(q.optionsLatex.toSet(), hasLength(q.optionsLatex.length));
          expect(q.optionFeedback, hasLength(q.optionsLatex.length));
          expect(q.correctIndex, inInclusiveRange(0, 3));
          expect(q.explanation, isNot(contains('{')));
        }
      }
    }
  });

  test('The marked answer is the mathematically correct one', () {
    final l = lookupAppLocalizations(const Locale('en'));
    for (var seed = 0; seed < 200; seed++) {
      for (final q in QuizGenerator.generate(seed, l)) {
        final m = q.matrix;
        final answer = q.optionsLatex[q.correctIndex];
        final a = m.get(0, 0), b = m.get(0, 1);
        final c = m.get(1, 0), d = m.get(1, 1);
        switch (q.id.split('-').last) {
          case 'det':
            expect(
              answer,
              (DeterminantSolver.solve(m).result as Rational).toString(),
            );
          case 'product':
            expect(answer, (a * b + b * d).toString());
            final product =
                MatrixArithmeticSolver.multiply(m, m).result as Matrix;
            expect(answer, product.get(0, 1).toString());
          case 'multiplier':
            // R2 <- R2 - k R1 with k = c / a zeroes the entry below the pivot.
            final k = c / a;
            final expected = k.isNegative
                ? 'R_2 \\leftarrow R_2 + ${(-k).toString()}R_1'
                : 'R_2 \\leftarrow R_2 - ${k.toString()}R_1';
            expect(answer, expected);
            expect(c - k * a, Rational.zero);
          case 'inverse':
            final det = a * d - b * c;
            expect(
              answer,
              '\\frac{1}{$det} \\begin{pmatrix} $d & ${-b} \\\\ ${-c} & $a \\end{pmatrix}',
            );
            final inverse = InverseSolver.solve(m).result as Matrix;
            expect(inverse.get(0, 1), -b / det);
          default:
            fail('unknown question ${q.id}');
        }
      }
    }
  });
}
