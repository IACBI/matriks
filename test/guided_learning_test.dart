import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/features/step_player/widgets/instruction_lesson.dart';
import 'package:matriks/features/step_player/widgets/instruction_timeline.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/features/step_player/cubit/player_cubit.dart';
import 'package:matriks/features/topics/views/topics_screen.dart';
import 'package:matriks/features/practice/views/practice_screen.dart';
import 'package:matriks/features/practice/models/quiz_question.dart';

import 'product_accessibility_test.dart' show host;

void main() {
  test(
    'Worked calculations preserve solver signs and both determinant products',
    () {
      final solution = GaussJordanSolver.solve(
        Matrix.fromInts([
          [1, 2],
          [2, 5],
        ]),
      );
      final step = solution.steps.firstWhere(
        (s) => s.transformation is RowEliminationTransformation,
      );
      final lesson = InstructionLesson.forStep(
        transformation: step.transformation,
        before: step.matrixBefore,
        after: step.matrixAfter,
      );
      expect(lesson.calculations.first, r'2 - 2 \cdot 1 = 0');
      expect(lesson.rationale, contains('Target 2 ÷ pivot 1 = 2'));
      expect(lesson.operation, startsWith('Subtract 2'));
      final determinant = DeterminantSolver.solve(
        Matrix.fromInts([
          [2, 3],
          [1, 4],
        ]),
      ).steps.last;
      final detLesson = InstructionLesson.forStep(
        transformation: determinant.transformation,
        before: determinant.matrixBefore,
        after: determinant.matrixAfter,
      );
      expect(detLesson.markers, ['+', '−']);
      expect(detLesson.calculations, [
        r'2 \cdot 4 = 8',
        r'3 \cdot 1 = 3',
        '8 - 3 = 5',
      ]);
    },
  );

  test('Sarrus keeps six exact contributions and a separate signed sum', () {
    final step = DeterminantSolver.solve(
      Matrix.fromInts([
        [1, 2, 3],
        [0, 1, 4],
        [5, 6, 0],
      ]),
    ).steps.last;
    final lesson = InstructionLesson.forStep(
      transformation: step.transformation,
      before: step.matrixBefore,
      after: step.matrixAfter,
    );
    expect(lesson.calculations.length, 7);
    expect(lesson.calculations[1], r'2 \cdot 4 \cdot 5 = 40');
    expect(lesson.calculations[4], r'1 \cdot 4 \cdot 6 = 24');
    expect(lesson.calculations.last, '40 - 39 = 1');
    // The last step recaps the six products and only animates the
    // subtraction; the products themselves were traced in steps 1 and 2.
    expect(lesson.revealedAtStart, 6);
    expect(lesson.progressiveCount, 1);
    final solution = DeterminantSolver.solve(
      Matrix.fromInts([
        [1, 2, 3],
        [0, 1, 4],
        [5, 6, 0],
      ]),
    );
    final positive = InstructionTimeline.forTransformation(
      solution.steps.first.transformation,
    );
    expect(positive.operationMs ~/ 3, greaterThanOrEqualTo(1200));
  });

  test('Every quiz option has bilingual misconception feedback', () {
    for (final language in ['tr', 'en']) {
      final bank = QuizBank.getQuestions(language: language);
      for (final question in bank) {
        expect(question.optionFeedback.length, question.optionsLatex.length);
        expect(
          question.optionFeedback.every((text) => text.trim().isNotEmpty),
          true,
        );
      }
      expect(
        bank[1].optionFeedback[0],
        contains(language == 'tr' ? 'de sıfır olmayan' : 'would also'),
      );
    }
  });

  testWidgets('Recommended start opens a nontrivial worked lesson', (
    tester,
  ) async {
    await tester.pumpWidget(host(const TopicsScreen()));
    await tester.pumpAndSettle();
    // The starter lessons are listed without expanding anything first.
    expect(find.text('New to matrices?'), findsOneWidget);
    final start = find.text('1 · Create zeros');
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pumpAndSettle();
    expect(find.byType(StepPlayerScreen), findsOneWidget);
    final cubit = tester
        .element(find.byType(MatrixDisplayGrid))
        .read<PlayerCubit>();
    expect(cubit.state.totalSteps, greaterThan(2));
    expect(
      cubit.state.solution.steps.any(
        (s) => s.transformation is RowEliminationTransformation,
      ),
      true,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Step list and operation inspection pause autoplay without losing place',
    (tester) async {
      final solution = DeterminantSolver.solve(
        Matrix.fromInts([
          [2, 3],
          [1, 4],
        ]),
      );
      await tester.pumpWidget(
        host(StepPlayerScreen(solution: solution, topicTitle: 'Determinant')),
      );
      await tester.pumpAndSettle();
      final cubit = tester
          .element(find.byType(MatrixDisplayGrid))
          .read<PlayerCubit>();
      expect(find.byType(Slider), findsNothing);
      cubit.play();
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('choose-lesson-step')));
      await tester.pumpAndSettle();
      expect(cubit.state.isPlaying, false);
      final tiles = find.byType(ListTile);
      await tester.tap(tiles.last);
      await tester.pumpAndSettle();
      expect(cubit.state.currentStepIndex, solution.steps.length - 1);
      expect(cubit.state.isPlaying, false);
      final inspector = find.byKey(const ValueKey('operation-inspector'));
      await tester.ensureVisible(inspector);
      await tester.tap(inspector);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('instruction-progress')),
        findsOneWidget,
      );
      expect(cubit.state.isAnimating, false);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Wrong answer explains the selected misconception', (
    tester,
  ) async {
    await tester.pumpWidget(host(const PracticeScreen(), language: 'tr'));
    await tester.pumpAndSettle();
    final option = find.text('B');
    await tester.ensureVisible(option);
    await tester.tap(option);
    await tester.pumpAndSettle();
    expect(
      find.text(QuizBank.getQuestions().first.optionFeedback[1]),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('answer-feedback')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Quiz choices expose button, enabled, and selected states', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(host(const PracticeScreen(), language: 'tr'));
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel('Satır 1, sütun 1, değer 1'),
        findsOneWidget,
      );
      final choice = find.byKey(const ValueKey('quiz-option-B'));
      await tester.ensureVisible(choice);
      await tester.pumpAndSettle();
      var flags = tester
          .getSemantics(choice)
          .getSemanticsData()
          .flagsCollection;
      expect(flags.isButton, true);
      expect(flags.isEnabled.toBoolOrNull(), true);
      expect(flags.isSelected.toBoolOrNull(), false);
      await tester.tap(choice);
      await tester.pumpAndSettle();
      flags = tester.getSemantics(choice).getSemanticsData().flagsCollection;
      expect(flags.isButton, true);
      expect(flags.isEnabled.toBoolOrNull(), false);
      expect(flags.isSelected.toBoolOrNull(), true);
    } finally {
      semantics.dispose();
    }
  });
}
