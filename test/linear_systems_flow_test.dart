import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/app.dart';

import 'helpers/player_flow.dart';

void main() {
  testWidgets(
    'Linear Systems flow: select topic, solve augmented system, navigate steps',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MatrixEducatorApp());
      await tester.pumpAndSettle();

      // 1. Find and tap Linear Systems topic
      final topicFinder = find.text('Linear Systems (Ax = b)');
      await tester.scrollUntilVisible(
        topicFinder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(topicFinder, findsOneWidget);
      await tester.tap(topicFinder);
      await tester.pumpAndSettle();

      // 2. MatrixInputScreen opens for augmented system [A | b]
      expect(find.text('Solve'), findsOneWidget);
      // Augmented matrix default is 3x4
      expect(find.text('3'), findsWidgets);
      expect(find.text('4'), findsWidgets);

      // 3. Fill with random values using the Random preset button
      final randomBtn = find.byIcon(Icons.casino_outlined);
      expect(randomBtn, findsOneWidget);
      await tester.tap(randomBtn);
      await tester.pumpAndSettle();

      // 4. Tap Solve
      final solveBtn = find.text('Solve');
      await tester.tap(solveBtn);

      // Allow real isolate to process
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 500));
      });
      await pauseInitialPlayback(tester);

      // 5. We should be on StepPlayerScreen
      expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.textContaining('Step 1 of'), findsOneWidget);

      // Navigate to step 2
      await tester.tap(find.byIcon(Icons.skip_next_rounded));
      await tester.pumpAndSettle();
      expect(find.textContaining('Step 2 of'), findsOneWidget);

      // Navigate back to step 1
      await tester.tap(find.byIcon(Icons.skip_previous_rounded));
      await tester.pumpAndSettle();
      expect(find.textContaining('Step 1 of'), findsOneWidget);
    },
  );
}
