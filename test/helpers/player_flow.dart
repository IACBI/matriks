import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/features/step_player/cubit/player_cubit.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';

/// Flow tests inspect the first step by pausing the new automatic playback.
Future<void> pauseInitialPlayback(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  final player = tester
      .element(find.byType(MatrixDisplayGrid))
      .read<PlayerCubit>();
  expect(player.state.isPlaying, isTrue);
  expect(player.state.currentStepIndex, 0);
  player.pause();
  await tester.pumpAndSettle();
}
