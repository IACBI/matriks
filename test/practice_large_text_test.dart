import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/features/practice/views/practice_screen.dart';

import 'product_accessibility_test.dart' show host;

void main() {
  testWidgets('At 200% text on a phone, option letters stay inside their '
      'circles and the answer feedback wraps', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(const PracticeScreen(), scale: 2));
    await tester.pumpAndSettle();

    for (final letter in ['A', 'B', 'C', 'D']) {
      final text = find.text(letter);
      final circle = find.ancestor(of: text, matching: find.byType(Container));
      final badge = tester.getRect(circle.first);
      final glyph = tester.getRect(text);
      expect(badge.width, 56);
      expect(badge.contains(glyph.topLeft), isTrue, reason: letter);
      expect(badge.contains(glyph.bottomRight - const Offset(1, 1)), isTrue);
    }

    final option = find.bySemanticsLabel(RegExp(r'^A: '));
    await tester.ensureVisible(option);
    await tester.pumpAndSettle();
    await tester.tap(option);
    await tester.pumpAndSettle();
    // A title that cannot wrap overflows its row and fails the test here.
    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
  });
}
