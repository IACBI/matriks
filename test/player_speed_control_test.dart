import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/features/step_player/widgets/player_control_bar.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      'Speed controls fit and adjust at 200% in ${locale.languageCode}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var speed = 1.0;
        var playChanges = 0;
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(2)),
              child: child!,
            ),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => PlayerControlBar(
                  currentStepIndex: 0,
                  totalSteps: 3,
                  isPlaying: true,
                  playbackSpeed: speed,
                  onTogglePlayPause: () => playChanges++,
                  onNextStep: () {},
                  onPrevStep: () {},
                  onSeek: (_) {},
                  onSpeedChanged: (value) => setState(() => speed = value),
                ),
              ),
            ),
          ),
        );
        final increase = find.byKey(const ValueKey('increase-playback-speed'));
        final decrease = find.byKey(const ValueKey('decrease-playback-speed'));
        await tester.tap(increase);
        await tester.pump();
        expect(speed, 1.25);
        await tester.tap(decrease);
        await tester.pump();
        expect(speed, 1);
        for (var i = 0; i < 12; i++) {
          await tester.tap(increase);
          await tester.pump();
        }
        expect(speed, 4);
        expect(tester.widget<IconButton>(increase).onPressed, isNull);
        for (var i = 0; i < 15; i++) {
          await tester.tap(decrease);
          await tester.pump();
        }
        expect(speed, .25);
        expect(tester.widget<IconButton>(decrease).onPressed, isNull);
        await tester.tap(find.byType(PopupMenuButton<double>));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byWidgetPredicate(
            (widget) => widget is PopupMenuItem<double> && widget.value == 1.5,
          ),
        );
        await tester.pumpAndSettle();
        expect(speed, 1.5);
        expect(playChanges, 0);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
