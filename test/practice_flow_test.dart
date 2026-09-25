import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/app.dart';

void main() {
  testWidgets(
    'Practice flow: launch quiz, answer correctly, verify score and navigation',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MatrixEducatorApp());
      await tester.pumpAndSettle();

      // 1. Scroll down and find the Practice Topic
      final practiceTopicFinder = find.text('Self-Test & Practice Quiz');
      await tester.scrollUntilVisible(
        practiceTopicFinder,
        300.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(practiceTopicFinder, findsOneWidget);

      // 2. Tap to open PracticeScreen
      await tester.tap(practiceTopicFinder);
      await tester.pumpAndSettle();

      // 3. Verify Practice Screen elements
      expect(find.text('Self-Test (Practice Mode)'), findsOneWidget);
      expect(find.text('0 Points'), findsOneWidget);
      expect(find.text('Question 1 / 5'), findsOneWidget);
      expect(
        find.text('Gaussian Elimination: Pivot & Elimination'),
        findsOneWidget,
      );

      // 4. Tap the first option (Option A - correct answer)
      final optionAFinder = find.text('A');
      expect(optionAFinder, findsOneWidget);
      await tester.tap(optionAFinder);
      await tester.pumpAndSettle();

      // 5. Verify feedback and score update
      expect(find.text('Congratulations, Correct Answer!'), findsOneWidget);
      expect(find.text('10 Points'), findsOneWidget);

      // 6. Tap Next Question
      final nextBtn = find.text('Next Question');
      expect(nextBtn, findsOneWidget);
      await tester.ensureVisible(nextBtn);
      await tester.pumpAndSettle();
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      // 7. Verify Question 2 is loaded
      expect(find.text('Question 2 / 5'), findsOneWidget);
      expect(find.text('Row Swap (Permutation) Requirement'), findsOneWidget);
    },
  );
}
