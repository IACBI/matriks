import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/features/step_player/widgets/instruction_lesson.dart';
import 'package:matriks/features/practice/models/quiz_question.dart';
import 'package:matriks/features/transform_visualizer/models/transform_matrix.dart';

void main() {
  test('Triangular determinant lesson retains the row permutation sign', () {
    final solution = DeterminantSolver.solve(
      Matrix.fromInts([
        [0, 1, 0, 0],
        [1, 0, 0, 0],
        [0, 0, 2, 0],
        [0, 0, 0, 3],
      ]),
    );
    expect(solution.result, Rational(-6));
    final step = solution.steps.last;
    final lesson = InstructionLesson.forStep(
      transformation: step.transformation,
      before: step.matrixBefore,
      after: step.matrixAfter,
    );
    expect(lesson.calculations.last, endsWith('= -6'));
    expect(lesson.calculations.last, contains('(-1)'));
  });
  test('All five quiz answer keys agree with their matrix operations in every language', () {
    for (final locale in ['en', 'tr', 'zh', 'es', 'ru']) {
      final questions = QuizBank.getQuestions(language: locale);
      expect(questions.map((q) => q.correctIndex), [0, 2, 3, 1, 2]);
      expect(
        questions[0].matrix.addRowMultiple(1, 0, Rational(-2)).get(1, 0),
        Rational.zero,
      );
      expect(questions[1].matrix.swapRows(0, 1).get(0, 0).isZero, false);
      expect(
        questions[2].matrix.scaleRow(1, Rational(-1, 3)).get(1, 1),
        Rational.one,
      );
      expect(
        (RankNullitySolver.solve(questions[3].matrix).result
                as RankNullityResult)
            .rank,
        2,
      );
      expect(DeterminantSolver.solve(questions[4].matrix).result, Rational(24));
      for (final question in questions) {
        expect(question.optionFeedback.length, question.optionsLatex.length);
      }
    }
  });
  test(
    'Geometric presets match projection, rotation, reflection, scale and shear',
    () {
      final projection = TransformMatrix.preset('projection');
      expect(
        projection.a * projection.a + projection.b * projection.c,
        projection.a,
      );
      expect(
        projection.a * projection.b + projection.b * projection.d,
        projection.b,
      );
      expect(
        projection.c * projection.a + projection.d * projection.c,
        projection.c,
      );
      expect(
        projection.c * projection.b + projection.d * projection.d,
        projection.d,
      );
      final rotation = TransformMatrix.preset('rotation');
      for (var i = 0; i <= 20; i++) {
        final m = TransformMatrix.identity.interpolate(rotation, i / 20);
        final x = m.a * 3 + m.b * 4;
        final y = m.c * 3 + m.d * 4;
        expect(x * x + y * y, closeTo(25, 1e-10));
        expect(m.determinant, closeTo(1, 1e-10));
      }
      expect(TransformMatrix.preset('reflection').determinant, -1);
      expect(TransformMatrix.preset('scale').determinant, 2.25);
      expect(TransformMatrix.preset('shear').determinant, 1);
    },
  );
}
