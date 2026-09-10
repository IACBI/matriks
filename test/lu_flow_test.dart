import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/app.dart';

import 'helpers/player_flow.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/features/step_player/cubit/player_cubit.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';

void main() {
  testWidgets(
    'LU Decomposition flow: select LU topic, solve 3x3 matrix, verify steps',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MatrixEducatorApp());
      await tester.pumpAndSettle();

      // 1. Scroll and select LU Decomposition
      final luFinder = find.text('LU Decomposition (A = LU)');
      await tester.scrollUntilVisible(
        luFinder,
        300.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(luFinder, findsOneWidget);
      await tester.tap(luFinder);
      await tester.pumpAndSettle();

      // 2. MatrixInputScreen is shown
      expect(find.text('Solve'), findsOneWidget);

      // 3. Solve with background isolate
      await tester.tap(find.text('Solve'));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 300));
      });
      await pauseInitialPlayback(tester);

      // 4. Verify StepPlayerScreen opens with LU Factorization steps
      expect(find.textContaining('Step 1 of'), findsWidgets);
      final cubit = tester
          .element(find.byType(MatrixDisplayGrid))
          .read<PlayerCubit>();
      expect(
        cubit.state.currentStep!.transformation,
        isA<LUDecompositionTransformation>(),
      );
    },
  );
}
