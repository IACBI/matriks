import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/core/widgets/custom_numpad.dart';
import 'package:matriks/features/matrix_input/views/matrix_input_screen.dart';
import 'package:matriks/features/step_player/widgets/solution_summary.dart';
import 'package:matriks/features/topics/models/topic_item.dart';

import 'product_accessibility_test.dart' show host;

void main() {
  for (final width in [600.0, 1440.0]) {
    testWidgets('Solve lines up with the keypad keys at $width px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        host(MatrixInputScreen(topic: TopicItem.allTopics.first)),
      );
      await tester.pumpAndSettle();
      final solve = tester.getRect(
        find.widgetWithText(ElevatedButton, 'Solve'),
      );
      final keys = tester.getRect(
        find
            .descendant(
              of: find.byType(CustomNumpad),
              matching: find.byType(Column),
            )
            .first,
      );
      expect(keys.width, CustomNumpad.keysMaxWidth);
      expect(solve.center.dx, moreOrLessEquals(keys.center.dx, epsilon: 1));
      expect(solve.width, lessThanOrEqualTo(keys.width));
    });
  }

  testWidgets('The result sits in the centred stage column on a wide window', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final solution = InverseSolver.solve(
      Matrix.fromInts([
        [1, 2, 3],
        [0, 1, 4],
        [5, 6, 0],
      ]),
    );
    await tester.pumpWidget(
      host(
        Scaffold(
          body: SolutionSummary(
            solution: solution,
            decimal: false,
            onViewSteps: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final checks = tester.getRect(find.byType(ResultChecks));
    expect(checks.width, lessThanOrEqualTo(880));
    expect(checks.center.dx, moreOrLessEquals(720, epsilon: 1));
    expect(
      tester.getRect(find.text('Result:')).left,
      moreOrLessEquals(checks.left, epsilon: 1),
    );
  });
}
