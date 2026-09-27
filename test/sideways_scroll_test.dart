import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matriks/core/widgets/math_text.dart';
import 'package:matriks/features/matrix_input/views/matrix_input_screen.dart';
import 'package:matriks/features/practice/views/practice_screen.dart';
import 'package:matriks/features/settings/cubit/settings_state.dart';
import 'package:matriks/features/step_player/cubit/player_cubit.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/features/step_player/widgets/matrix_cell_widget.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/features/step_player/widgets/solution_summary.dart';
import 'package:matriks/features/topics/models/topic_item.dart';

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

  // Above the matrix the player shows the operation (L during LU, a row
  // operation), the scene formula, the entries being added and the row of A
  // with the column of B. On a phone at large text these overflow; each must
  // say so. A cell's own formula shrinks and then scrolls inside the cell,
  // where a bar would cover the value, so cells are left out.
  final big = Matrix.fromInts([
    [-4817, 2093, -7561, 3348, -1229],
    [6402, -3915, 1187, -8836, 5071],
    [-2254, 7718, -4409, 1963, -6632],
    [8145, -1376, 5920, -2781, 3304],
    [-3593, 6047, -8218, 4456, -1985],
  ]);
  for (final (name, make) in [
    ('LU', () => LUDecompositionSolver.solve(big)),
    ('RREF', () => GaussJordanSolver.solve(big)),
    ('addition', () => MatrixArithmeticSolver.add(big, big)),
    ('multiplication', () => MatrixArithmeticSolver.multiply(big, big)),
  ]) {
    testWidgets('Every overflowing formula in the $name player shows its bar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final solution = make();
      await tester.pumpWidget(
        host(StepPlayerScreen(solution: solution, topicTitle: name), scale: 2),
      );
      await tester.pumpAndSettle();
      final cubit = tester
          .element(find.byType(MatrixDisplayGrid))
          .read<PlayerCubit>();
      cubit.setMode(SolutionMode.steps);
      var overflowing = 0;
      for (var i = 0; i < solution.steps.length; i++) {
        cubit.jumpToStep(i);
        await tester.pumpAndSettle();
        overflowing += expectBarsOnOverflow(
          find.byType(MatrixDisplayGrid),
          'step ${i + 1}',
        );
      }
      // The matrix is wide at this size, and so is at least one formula.
      expect(overflowing, greaterThan(solution.steps.length));
    });
  }

  testWidgets('A 5×5 editor on a narrow phone shows that it scrolls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(MatrixInputScreen(topic: TopicItem.allTopics.first)),
    );
    await tester.pumpAndSettle();
    for (final label in ['Add a row', 'Add a column']) {
      for (var i = 0; i < 2; i++) {
        final add = find.byTooltip(label).first;
        await tester.ensureVisible(add);
        await tester.pumpAndSettle();
        await tester.tap(add);
        await tester.pumpAndSettle();
      }
    }
    expect(find.byType(MatrixInputScreen), findsOneWidget);
    expect(
      expectBarsOnOverflow(find.byType(MatrixInputScreen), 'editor'),
      greaterThan(0),
    );
  });

  testWidgets(
    'Practice at 200% text wraps its options and shows every scroll',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        host(PracticeScreen(onReturnTopics: () {}), scale: 2),
      );
      await tester.pumpAndSettle();
      // R₂ ← R₂ − 2R₁ breaks after its arrow term instead of scrolling.
      final option = find.byWidgetPredicate(
        (widget) =>
            widget is MathText && widget.latex == r'R_2 \leftarrow R_2 - 2R_1',
      );
      expect(option, findsOneWidget);
      expect(
        find.descendant(of: option, matching: find.byType(Wrap)),
        findsOneWidget,
      );
      expect(expectBarsOnOverflow(option, 'option'), 0);
      // The question's matrix is wider than the phone at this size.
      expect(
        expectBarsOnOverflow(find.byType(PracticeScreen), 'practice'),
        greaterThan(0),
      );
    },
  );

  testWidgets('On a narrow phone the column of B sits under the row of A', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(
        StepPlayerScreen(
          solution: MatrixArithmeticSolver.multiply(big, big),
          topicTitle: 'AB',
        ),
      ),
    );
    await tester.pumpAndSettle();
    final cubit = tester
        .element(find.byType(MatrixDisplayGrid))
        .read<PlayerCubit>();
    cubit.setMode(SolutionMode.steps);
    cubit.jumpToStep(0);
    await tester.pumpAndSettle();
    final column = tester.getRect(find.text('B · column 1'));
    final row = tester.getRect(find.text('A · row 1'));
    expect(column.left, greaterThanOrEqualTo(0));
    expect(column.right, lessThanOrEqualTo(320));
    expect(column.top, greaterThan(row.bottom));
  });
}

/// Checks that every horizontal scroll view under [root] that overflows,
/// outside matrix cells, shows an always-visible scrollbar driving it, and
/// returns how many overflowed. A cell's own value shrinks and then scrolls
/// inside the cell, where a bar would cover it.
int expectBarsOnOverflow(Finder root, String where) {
  var overflowing = 0;
  for (final element
      in find
          .descendant(of: root, matching: find.byType(Scrollable))
          .evaluate()) {
    final position =
        ((element as StatefulElement).state as ScrollableState).position;
    if (position.axis != Axis.horizontal ||
        position.maxScrollExtent <= 0 ||
        element.findAncestorWidgetOfExactType<MatrixCellWidget>() != null) {
      continue;
    }
    overflowing++;
    final bar = element.findAncestorWidgetOfExactType<Scrollbar>();
    expect(bar?.thumbVisibility, isTrue, reason: where);
    expect(bar!.controller!.position, same(position), reason: where);
  }
  return overflowing;
}
