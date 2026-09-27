import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/core/widgets/math_text.dart';
import 'package:matriks/features/step_player/widgets/solution_summary.dart';

import 'product_accessibility_test.dart' show host;

void main() {
  // L and U of this matrix hold fractions such as -1509/652: far wider than
  // a phone.
  final wide = LUDecompositionSolver.solve(
    Matrix.fromInts([
      [7, 3, 5, 2, 9],
      [3, 8, 1, 6, 4],
      [5, 2, 9, 3, 7],
      [2, 6, 4, 8, 1],
      [9, 4, 7, 1, 6],
    ]),
  );
  final small = LUDecompositionSolver.solve(
    Matrix.fromInts([
      [2, 1],
      [4, 3],
    ]),
  );

  Future<void> show(WidgetTester tester, StepSolution solution, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    return tester.pumpWidget(
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
  }

  Finder formula(String start) => find.byWidgetPredicate(
    (widget) => widget is MathText && widget.latex.startsWith(start),
  );

  ScrollPosition positionOf(WidgetTester tester, Finder formula) => tester
      .state<ScrollableState>(
        find.ancestor(of: formula, matching: find.byType(Scrollable)).first,
      )
      .position;

  testWidgets('A result wider than a phone shows a scrollbar that scrolls it', (
    tester,
  ) async {
    await show(tester, wide, const Size(390, 844));
    await tester.pumpAndSettle();
    final l = formula('L =');
    expect(l, findsOneWidget);
    final position = positionOf(tester, l);
    expect(position.maxScrollExtent, greaterThan(0));
    expect(position.pixels, 0);

    // The thumb sits along the bottom edge of the formula's viewport; a
    // mouse moves the formula only by dragging it.
    final viewport = tester.getRect(
      find.ancestor(of: l, matching: find.byType(Scrollable)).first,
    );
    await tester.dragFrom(
      Offset(viewport.left + 12, viewport.bottom - 4),
      const Offset(120, 0),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();
    expect(position.pixels, greaterThan(0));
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('The check under the result scrolls the same way', (
    tester,
  ) async {
    // L·U = A repeats A, so only large entries make the check itself wide.
    final large = LUDecompositionSolver.solve(
      Matrix.fromInts([
        [-4817, 2093, -7561, 3348, -1229],
        [6402, -3915, 1187, -8836, 5071],
        [-2254, 7718, -4409, 1963, -6632],
        [8145, -1376, 5920, -2781, 3304],
        [-3593, 6047, -8218, 4456, -1985],
      ]),
    );
    await show(tester, large, const Size(390, 844));
    await tester.pumpAndSettle();
    final check = formula('L U =');
    expect(check, findsOneWidget);
    final position = positionOf(tester, check);
    expect(position.maxScrollExtent, greaterThan(0));
    final bar = tester.widget<Scrollbar>(
      find.ancestor(of: check, matching: find.byType(Scrollbar)).first,
    );
    expect(bar.thumbVisibility, isTrue);
    expect(bar.controller!.position, same(position));
  });

  testWidgets('A result that fits keeps its spacing and shows no thumb', (
    tester,
  ) async {
    await show(tester, small, const Size(1280, 900));
    await tester.pumpAndSettle();
    final l = formula('L =');
    expect(positionOf(tester, l).maxScrollExtent, 0);
    final view = tester.widget<SingleChildScrollView>(
      find.ancestor(of: l, matching: find.byType(SingleChildScrollView)).first,
    );
    expect(view.padding, EdgeInsets.zero);
  });

  testWidgets('Room for the thumb is made only while a formula overflows', (
    tester,
  ) async {
    await show(tester, wide, const Size(390, 844));
    await tester.pumpAndSettle();
    final l = formula('L =');
    SingleChildScrollView view() => tester.widget<SingleChildScrollView>(
      find.ancestor(of: l, matching: find.byType(SingleChildScrollView)).first,
    );
    expect(view().padding, const EdgeInsets.only(bottom: 10));

    // On a window wide enough for it the room goes again.
    tester.view.physicalSize = const Size(1280, 900);
    await tester.pumpAndSettle();
    expect(positionOf(tester, l).maxScrollExtent, 0);
    expect(view().padding, EdgeInsets.zero);
  });
}
