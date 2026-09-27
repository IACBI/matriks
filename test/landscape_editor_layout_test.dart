import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/core/widgets/custom_numpad.dart';
import 'package:matriks/features/matrix_input/views/matrix_input_screen.dart';
import 'package:matriks/features/topics/models/topic_item.dart';

import 'product_accessibility_test.dart' show host;

Future<void> openEditor(
  WidgetTester tester,
  Size size, {
  TopicType topic = TopicType.rref,
  double scale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    host(MatrixInputScreen(topic: TopicItem.of(topic)), scale: scale),
  );
  await tester.pumpAndSettle();
}

final solveButton = find.widgetWithText(ElevatedButton, 'Solve');
final firstCell = find.bySemanticsLabel('Matrix A, row 1, column 1');

void expectOnScreen(WidgetTester tester, Finder finder, Size size) {
  final rect = tester.getRect(finder);
  expect(rect.top, greaterThanOrEqualTo(0), reason: '$rect');
  expect(rect.left, greaterThanOrEqualTo(0), reason: '$rect');
  expect(rect.bottom, lessThanOrEqualTo(size.height), reason: '$rect');
  expect(rect.right, lessThanOrEqualTo(size.width), reason: '$rect');
  expect(finder.hitTestable(), findsOneWidget);
}

void main() {
  const phones = [Size(844, 390), Size(667, 375), Size(932, 430)];

  for (final size in phones) {
    for (final topic in [TopicType.rref, TopicType.multiply]) {
      testWidgets(
        'A ${size.width.toInt()}x${size.height.toInt()} phone on its side '
        'shows the ${topic.name} matrix beside Solve',
        (tester) async {
          await openEditor(tester, size, topic: topic);
          expect(tester.takeException(), isNull);
          expectOnScreen(tester, solveButton, size);
          expectOnScreen(tester, firstCell, size);
          expect(find.byType(VerticalDivider), findsOneWidget);
          expect(
            tester.getRect(firstCell).right,
            lessThan(tester.getRect(solveButton).left),
          );
          // Keypad keys keep their 44 px touch targets.
          final seven = find.descendant(
            of: find.byType(CustomNumpad),
            matching: find.bySemanticsLabel('7'),
          );
          final key = tester.getSize(seven);
          expect(key.width, greaterThanOrEqualTo(44));
          expect(key.height, greaterThanOrEqualTo(44));
          if (topic == TopicType.rref) {
            // With one matrix the whole keypad fits under Solve.
            expectOnScreen(
              tester,
              find.descendant(
                of: find.byType(CustomNumpad),
                matching: find.bySemanticsLabel('Clear cell'),
              ),
              size,
            );
          }
        },
      );
    }
  }

  testWidgets('Typing on the keypad leaves the cells in view', (tester) async {
    const size = Size(667, 375);
    await openEditor(tester, size);
    final cellTop = tester.getRect(firstCell).top;
    for (final digit in ['1', '2', '3', '0']) {
      await tester.tap(
        find.descendant(
          of: find.byType(CustomNumpad),
          matching: find.text(digit),
        ),
      );
      await tester.pumpAndSettle();
    }
    expect(tester.getRect(firstCell).top, cellTop);
    expectOnScreen(tester, firstCell, size);
    expectOnScreen(tester, solveButton, size);
  });

  testWidgets('At 200% text the landscape panes scroll without overflow', (
    tester,
  ) async {
    const size = Size(844, 390);
    await openEditor(tester, size, scale: 2);
    expect(tester.takeException(), isNull);
    expect(find.byType(VerticalDivider), findsOneWidget);
    await tester.scrollUntilVisible(
      solveButton,
      100,
      scrollable: find
          .ancestor(of: solveButton, matching: find.byType(Scrollable))
          .first,
    );
    expectOnScreen(tester, solveButton, size);
  });

  testWidgets('A portrait phone keeps the stacked editor', (tester) async {
    await openEditor(tester, const Size(390, 844));
    expect(tester.takeException(), isNull);
    expect(find.byType(VerticalDivider), findsNothing);
    expect(
      tester.getRect(solveButton).top,
      greaterThan(tester.getRect(firstCell).bottom),
    );
  });

  testWidgets('A wide window keeps its five-to-four split', (tester) async {
    await openEditor(tester, const Size(1280, 800));
    expect(tester.takeException(), isNull);
    final divider = tester.getRect(find.byType(VerticalDivider));
    expect(divider.center.dx, moreOrLessEquals((1280 - 1) * 5 / 9, epsilon: 1));
    expect(
      tester.getRect(firstCell).right,
      lessThan(tester.getRect(solveButton).left),
    );
  });
}
