import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/settings/cubit/settings_state.dart';
import 'package:matriks/features/settings/data/preferences_repository.dart';
import 'package:matriks/features/practice/models/quiz_question.dart';
import 'package:matriks/features/step_player/cubit/player_cubit.dart';
import 'package:matrix_engine/matrix_engine.dart';

class MemoryPreferences implements PreferencesRepository {
  SettingsState? saved;
  bool fail = false;
  Completer<SettingsState?>? delayedRead;
  @override
  Future<SettingsState?> load() async {
    if (fail) throw StateError('unavailable');
    return delayedRead == null ? saved : delayedRead!.future;
  }

  @override
  Future<void> save(SettingsState settings) async {
    await Future<void>.delayed(Duration.zero);
    if (fail) throw StateError('unavailable');
    saved = SettingsState.fromJson(
      jsonDecode(jsonEncode(settings.toJson())) as Map<String, dynamic>,
    );
  }
}

void main() {
  test(
    'All preferences survive restart and reset without storing matrices',
    () async {
      final repository = MemoryPreferences();
      final cubit = SettingsCubit(repository: repository);
      cubit.update(
        cubit.state.copyWith(
          themeMode: ThemeMode.dark,
          locale: () => const Locale('zh'),
          isDecimalView: true,
          defaultPlaybackSpeed: 2.5,
          solutionMode: SolutionMode.result,
          explanationLevel: ExplanationLevel.hidden,
          reduceMotion: true,
          predictions: false,
          compact: true,
          lastTopic: () => 'eigen',
          completedTopics: {'rref', 'gauss'},
        ),
      );
      expect(
        cubit.setShortcut(PlayerAction.result, LogicalKeyboardKey.keyX),
        true,
      );
      await cubit.flushed;
      final restored = SettingsCubit(repository: repository);
      await restored.restore();
      expect(restored.state.toJson(), cubit.state.toJson());
      expect(repository.saved!.toJson().keys, isNot(contains('matrix')));
      expect(restored.state.completedTopics, {'rref', 'gauss'});
      restored.reset();
      await restored.flushed;
      // Resetting preferences keeps what the learner has done.
      expect(
        repository.saved!.toJson(),
        const SettingsState(
          lastTopic: 'eigen',
          completedTopics: {'gauss', 'rref'},
        ).toJson(),
      );
      restored.resetProgress();
      await restored.flushed;
      expect(repository.saved!.toJson(), const SettingsState().toJson());
      await cubit.close();
      await restored.close();
    },
  );
  test(
    'Rapid writes, failed storage and stale load preserve newest changes',
    () async {
      final repository = MemoryPreferences()
        ..delayedRead = Completer<SettingsState?>();
      final cubit = SettingsCubit(repository: repository);
      final loading = cubit.restore();
      cubit.setDefaultSpeed(2);
      cubit.setDefaultSpeed(3);
      repository.delayedRead!.complete(const SettingsState());
      await loading;
      await cubit.flushed;
      expect(cubit.state.defaultPlaybackSpeed, 3);
      expect(repository.saved!.defaultPlaybackSpeed, 3);
      repository.fail = true;
      cubit.setLocale(const Locale('es'));
      await cubit.flushed;
      expect(cubit.state.locale!.languageCode, 'es');
      expect(cubit.state.storageError, true);
      repository.fail = false;
      cubit.setDefaultSpeed(1);
      await cubit.flushed;
      expect(cubit.state.storageError, false);
      await cubit.close();
    },
  );
  test(
    'Untrusted preferences and shortcut collisions recover safely',
    () async {
      final s = SettingsState.fromJson({
        'version': 1,
        'speed': double.nan,
        'locale': 'xx',
        'theme': 'bad',
        'shortcuts': {'play': 32},
      });
      expect(s.defaultPlaybackSpeed, 1);
      expect(s.locale, isNull);
      expect(s.shortcuts, SettingsState.defaultShortcuts);
      expect(
        () => SettingsState.fromJson({'version': 2}),
        throwsFormatException,
      );
      final c = SettingsCubit();
      expect(
        c.setShortcut(PlayerAction.result, LogicalKeyboardKey.space),
        false,
      );
      expect(c.setShortcut(PlayerAction.result, LogicalKeyboardKey.tab), false);
      c.setDefaultSpeed(double.infinity);
      expect(c.state.defaultPlaybackSpeed, 1);
      c.setLocale(const Locale('xx'));
      expect(c.state.locale, isNull);
      await c.close();
    },
  );
  test(
    'Instant result rejects stale completion and static steps never animate',
    () async {
      final solution = GaussJordanSolver.solve(
        Matrix.fromInts([
          [1, 2],
          [2, 5],
        ]),
      );
      final player = PlayerCubit(solution);
      player.play();
      final revision = player.state.animationRevision;
      player.showResult();
      player.animationCompleted(revision);
      expect(player.state.mode, SolutionMode.result);
      expect(player.state.isAnimating, false);
      expect(player.state.currentStepIndex, 0);
      player.setMode(SolutionMode.steps);
      player.nextStep();
      player.play();
      expect(player.state.currentStepIndex, 1);
      expect(player.state.isAnimating, false);
      player.setMode(SolutionMode.guided);
      expect(player.state.isAnimating, true);
      player.animationCompleted(revision);
      expect(player.state.currentStepIndex, 1);
      await player.close();
    },
  );
  test(
    'All five ARBs have equal keys/placeholders and equivalent quiz identities',
    () {
      Map<String, dynamic> read(String code) =>
          jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
              as Map<String, dynamic>;
      final english = read('en');
      final keys = english.keys.where((k) => !k.startsWith('@')).toSet();
      final pattern = RegExp(r'\{([A-Za-z][A-Za-z0-9_]*)\}');
      final baseline = QuizBank.getQuestions(language: 'en');
      for (final code in SettingsState.languages) {
        final translated = read(code);
        expect(
          translated.keys.where((k) => !k.startsWith('@')).toSet(),
          keys,
          reason: code,
        );
        for (final key in keys) {
          expect((translated[key] as String).trim(), isNotEmpty);
          expect(
            pattern
                .allMatches(translated[key] as String)
                .map((m) => m[1])
                .toSet(),
            pattern.allMatches(english[key] as String).map((m) => m[1]).toSet(),
            reason: '$code:$key',
          );
        }
        final questions = QuizBank.getQuestions(language: code);
        for (var i = 0; i < questions.length; i++) {
          expect(questions[i].id, baseline[i].id);
          expect(questions[i].optionsLatex, baseline[i].optionsLatex);
          expect(questions[i].correctIndex, baseline[i].correctIndex);
          expect(questions[i].optionFeedback.length, 4);
        }
      }
    },
  );
}
