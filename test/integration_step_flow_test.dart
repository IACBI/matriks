import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/app.dart';

import 'helpers/player_flow.dart';

void main() {
  testWidgets(
    'Full flow: select Determinant, enter matrix input, solve, and navigate steps',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MatrixEducatorApp());
      await tester.pumpAndSettle();

      // 1. Find and tap Determinant topic
      final detCard = find.text('Determinant');
      await tester.scrollUntilVisible(
        detCard,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(detCard, findsOneWidget);
      await tester.tap(detCard);
      await tester.pumpAndSettle();

      // 2. We should now be in MatrixInputScreen
      expect(find.text('Solve'), findsOneWidget);
      expect(find.text('Size: '), findsOneWidget);

      // Tap Random preset to populate with random values
      final randomBtn = find.byIcon(Icons.casino_outlined);
      expect(randomBtn, findsOneWidget);
      await tester.tap(randomBtn);
      await tester.pumpAndSettle();

      // 3. Tap Solve
      final solveBtn = find.text('Solve');
      await tester.tap(solveBtn);
      // Allow real background isolate to finish
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 400));
      });
      await pauseInitialPlayback(tester);

      expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);

      // 5. Navigate to Step 2
      final nextBtn = find.byIcon(Icons.skip_next_rounded);
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();
      expect(find.textContaining('Step 2 of'), findsOneWidget);

      // 6. Navigate back to Step 1
      final prevBtn = find.byIcon(Icons.skip_previous_rounded);
      await tester.tap(prevBtn);
      await tester.pumpAndSettle();
      expect(find.textContaining('Step 1 of'), findsOneWidget);
    },
  );
}
