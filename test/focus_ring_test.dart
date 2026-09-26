import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/app.dart';
import 'package:matriks/core/widgets/focus_ring.dart';

void main() {
  Finder ring() => find
      .descendant(
        of: find.byType(FocusRing),
        matching: find.byType(CustomPaint),
      )
      .last;

  Future<void> pumpApp(WidgetTester tester, FocusHighlightStrategy s) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    FocusManager.instance.highlightStrategy = s;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    await tester.pumpWidget(const MatrixEducatorApp());
    await tester.pumpAndSettle();
  }

  testWidgets('Keyboard focus is outlined around the focused control', (
    tester,
  ) async {
    await pumpApp(tester, FocusHighlightStrategy.alwaysTraditional);
    final primary = Theme.of(tester.element(find.byType(FocusRing)))
        .colorScheme
        .primary;
    for (var i = 0; i < 3; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
    }
    final focused = FocusManager.instance.primaryFocus!;
    expect(
      focused.context!.findAncestorWidgetOfExactType<EditableText>(),
      isNull,
    );
    expect(
      ring(),
      paints..rrect(
        rrect: RRect.fromRectAndRadius(
          focused.rect.inflate(2),
          const Radius.circular(10),
        ),
        color: primary,
        strokeWidth: 2,
      ),
    );
  });

  testWidgets('Touch use draws no ring', (tester) async {
    await pumpApp(tester, FocusHighlightStrategy.alwaysTouch);
    for (var i = 0; i < 3; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
    }
    expect(FocusManager.instance.primaryFocus, isNotNull);
    expect(ring(), isNot(paints..rrect()));
  });

  testWidgets('A focused text field keeps its own border instead', (
    tester,
  ) async {
    await pumpApp(tester, FocusHighlightStrategy.alwaysTraditional);
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(
      FocusManager.instance.primaryFocus!.context!
          .findAncestorWidgetOfExactType<EditableText>(),
      isNotNull,
    );
    expect(ring(), isNot(paints..rrect()));
  });

  testWidgets('The ring follows a control that layout moves', (tester) async {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    final gap = ValueNotifier<double>(10);
    final button = FocusNode();
    addTearDown(button.dispose);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => FocusRing(child: child!),
        home: Scaffold(
          body: Column(
            children: [
              ValueListenableBuilder(
                valueListenable: gap,
                builder: (_, h, _) => SizedBox(height: h),
              ),
              TextButton(
                focusNode: button,
                onPressed: () {},
                child: const Text('Details'),
              ),
            ],
          ),
        ),
      ),
    );
    button.requestFocus();
    await tester.pumpAndSettle();
    RRect ringAt(Rect r) =>
        RRect.fromRectAndRadius(r.inflate(2), const Radius.circular(10));
    expect(ring(), paints..rrect(rrect: ringAt(button.rect)));
    // Content growing above pushes the button down with no scroll and no
    // focus change.
    gap.value = 120;
    await tester.pump();
    await tester.pump();
    expect(ring(), paints..rrect(rrect: ringAt(button.rect)));
    expect(button.rect.top, greaterThan(110));
  });
}
