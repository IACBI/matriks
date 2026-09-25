import 'dart:math';

import 'package:matrix_engine/matrix_engine.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'quiz_question.dart';

/// Fresh practice rounds computed from random small matrices. Every wrong
/// option is the result of one named misconception, and its feedback says
/// which, so a wrong answer still teaches. The same seed always gives the
/// same round, so a language change can rebuild it in the new language.
class QuizGenerator {
  static const roundLength = 5;

  static List<QuizQuestion> generate(int seed, AppLocalizations l) {
    final rng = Random(seed);
    final builders = <QuizQuestion Function(Random, AppLocalizations, int)>[
      _determinant,
      _multiplier,
      _productEntry,
      _inverse,
    ];
    // Every kind once, then one more of a random kind, in random order.
    final kinds = [...builders, builders[rng.nextInt(builders.length)]]
      ..shuffle(rng);
    return [for (var i = 0; i < roundLength; i++) kinds[i](rng, l, i)];
  }

  static int _small(Random rng, int limit, {bool nonZero = false}) {
    while (true) {
      final v = rng.nextInt(2 * limit + 1) - limit;
      if (!nonZero || v != 0) return v;
    }
  }

  /// A factor in running prose: negative numbers in parentheses.
  static String _f(int v) => v < 0 ? '($v)' : '$v';

  static String _pmatrix(int a, int b, int c, int d) =>
      '\\begin{pmatrix} $a & $b \\\\ $c & $d \\end{pmatrix}';

  /// Shuffles the options and their feedback together; the correct option
  /// is the first entry of [options] before shuffling.
  static QuizQuestion _question({
    required Random rng,
    required String id,
    required String title,
    required String prompt,
    required Matrix matrix,
    required List<String> options,
    required List<String> feedback,
    required String explanation,
    required String hint,
  }) {
    final order = [for (var i = 0; i < options.length; i++) i]..shuffle(rng);
    return QuizQuestion(
      id: id,
      questionTitle: title,
      prompt: prompt,
      matrix: matrix,
      optionsLatex: [for (final i in order) options[i]],
      correctIndex: order.indexOf(0),
      explanation: explanation,
      hint: hint,
      optionFeedback: [for (final i in order) feedback[i]],
    );
  }

  static QuizQuestion _determinant(Random rng, AppLocalizations l, int n) {
    while (true) {
      final a = _small(rng, 5), b = _small(rng, 5, nonZero: true);
      final c = _small(rng, 5, nonZero: true), d = _small(rng, 5);
      final answers = [
        a * d - b * c,
        a * d + b * c,
        a * b - c * d,
        b * c - a * d,
      ];
      if (answers.toSet().length < answers.length) continue;
      return _question(
        rng: rng,
        id: 'g$n-det',
        title: l.genDetTitle,
        prompt: l.genDetPrompt,
        matrix: Matrix.fromInts([
          [a, b],
          [c, d],
        ]),
        options: [for (final v in answers) '$v'],
        feedback: [
          l.genDetExplanation(_f(a), _f(b), _f(c), _f(d), '${answers[0]}'),
          l.genDetFeedbackSign,
          l.genDetFeedbackRows,
          l.genDetFeedbackOrder,
        ],
        explanation: l.genDetExplanation(
          _f(a),
          _f(b),
          _f(c),
          _f(d),
          '${answers[0]}',
        ),
        hint: l.genDetHint,
      );
    }
  }

  static QuizQuestion _multiplier(Random rng, AppLocalizations l, int n) {
    final pivot = [1, -1, 2, -2, 3, -3][rng.nextInt(6)];
    // |k| >= 2, so the upside-down ratio 1/k is a different answer.
    final k = [2, -2, 3, -3][rng.nextInt(4)];
    final entry = k * pivot;
    final other = _small(rng, 5);
    final last = _small(rng, 5);
    String op(String target, String source, String factor, bool negative) =>
        '$target \\leftarrow $target ${negative ? '+' : '-'} $factor$source';
    final size = '${k.abs()}';
    final ratio = '\\frac{1}{${k.abs()}}';
    return _question(
      rng: rng,
      id: 'g$n-multiplier',
      title: l.genElimTitle,
      prompt: l.genElimPrompt,
      matrix: Matrix.fromInts([
        [pivot, other],
        [entry, last],
      ]),
      options: [
        op('R_2', 'R_1', size, k < 0),
        op('R_2', 'R_1', size, k > 0),
        op('R_2', 'R_1', ratio, k < 0),
        op('R_1', 'R_2', size, k < 0),
      ],
      feedback: [
        l.genElimExplanation('$entry', _f(pivot), '$k'),
        l.genElimFeedbackSign,
        l.genElimFeedbackRatio,
        l.genElimFeedbackRow,
      ],
      explanation: l.genElimExplanation('$entry', _f(pivot), '$k'),
      hint: l.genElimHint,
    );
  }

  static QuizQuestion _productEntry(Random rng, AppLocalizations l, int n) {
    while (true) {
      final a = _small(rng, 4), b = _small(rng, 4, nonZero: true);
      final c = _small(rng, 4), d = _small(rng, 4);
      // Entry (1, 2) of A·A: row 1 (a, b) with column 2 (b, d).
      final answers = [a * b + b * d, b * b, a * c + b * d, a * b + c * d];
      if (answers.toSet().length < answers.length) continue;
      final explanation = l.genProductExplanation(
        _f(a),
        _f(b),
        _f(b),
        _f(d),
        '${answers[0]}',
      );
      return _question(
        rng: rng,
        id: 'g$n-product',
        title: l.genProductTitle,
        prompt: l.genProductPrompt,
        matrix: Matrix.fromInts([
          [a, b],
          [c, d],
        ]),
        options: [for (final v in answers) '$v'],
        feedback: [
          explanation,
          l.genProductFeedbackSquare,
          l.genProductFeedbackRows,
          l.genProductFeedbackColumns,
        ],
        explanation: explanation,
        hint: l.genProductHint,
      );
    }
  }

  static QuizQuestion _inverse(Random rng, AppLocalizations l, int n) {
    while (true) {
      final a = _small(rng, 4), b = _small(rng, 4, nonZero: true);
      final c = _small(rng, 4, nonZero: true), d = _small(rng, 4);
      final det = a * d - b * c;
      // a != d keeps "signs changed but not swapped" a distinct answer.
      if (det == 0 || a == d) continue;
      final scale = '\\frac{1}{$det}';
      final explanation = l.genInverseExplanation(_f(det));
      return _question(
        rng: rng,
        id: 'g$n-inverse',
        title: l.genInverseTitle,
        prompt: l.genInversePrompt,
        matrix: Matrix.fromInts([
          [a, b],
          [c, d],
        ]),
        options: [
          '$scale ${_pmatrix(d, -b, -c, a)}',
          '$scale ${_pmatrix(d, b, c, a)}',
          '$scale ${_pmatrix(a, -b, -c, d)}',
          '$scale ${_pmatrix(-d, b, c, -a)}',
        ],
        feedback: [
          explanation,
          l.genInverseFeedbackSigns,
          l.genInverseFeedbackSwap,
          l.genInverseFeedbackNegated,
        ],
        explanation: explanation,
        hint: l.genInverseHint,
      );
    }
  }
}
