import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/app.dart';

import 'helpers/player_flow.dart';

void main() {
  testWidgets(
    'Eigenvalues flow: select topic, solve 2x2 matrix, view eigenspace steps',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MatrixEducatorApp());
      await tester.pumpAndSettle();

      // 1. Scroll and find Eigenvalues & Eigenvectors topic
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();
      final topicFinder = find.text('Eigenvalues & Eigenvectors');
      await tester.scrollUntilVisible(
        topicFinder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(topicFinder, findsOneWidget);
      await tester.tap(topicFinder);
      await tester.pumpAndSettle();

      // 2. We should be on MatrixInputScreen for square matrix
      expect(find.text('Solve'), findsOneWidget);

      // Populate with Random preset
      final randomBtn = find.byIcon(Icons.casino_outlined);
      expect(randomBtn, findsOneWidget);
      await tester.tap(randomBtn);
      await tester.pumpAndSettle();

      // 3. Tap Solve
      final solveBtn = find.text('Solve');
      await tester.tap(solveBtn);

      // Allow background isolate to finish
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 500));
      });
      await pauseInitialPlayback(tester);

      // 4. We should be in StepPlayerScreen with steps
      expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
      expect(find.textContaining('Step 1 of'), findsOneWidget);
    },
  );
}
