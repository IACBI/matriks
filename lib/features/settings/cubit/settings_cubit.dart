import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/preferences_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final PreferencesRepository? repository;
  Future<void> _pending = Future.value();
  int _revision = 0;
  SettingsCubit({
    this.repository,
    SettingsState initial = const SettingsState(),
  }) : super(initial);

  Future<void> restore() async {
    final revision = _revision;
    try {
      final saved = await repository?.load();
      if (!isClosed && revision == _revision && saved != null) emit(saved);
    } catch (_) {
      if (!isClosed && revision == _revision) {
        emit(state.copyWith(storageError: true));
      }
    }
  }

  void update(SettingsState settings) {
    final revision = ++_revision;
    emit(settings);
    if (repository == null) return;
    // Serialize writes: a slow older write must never overwrite a newer setting.
    _pending = _pending.then((_) async {
      try {
        await repository!.save(settings);
        if (!isClosed && revision == _revision) {
          emit(state.copyWith(storageError: false));
        }
      } catch (_) {
        if (!isClosed && revision == _revision) {
          emit(state.copyWith(storageError: true));
        }
      }
    });
  }

  Future<void> get flushed => _pending;

  /// Restores display and playback defaults. The learner's progress is not
  /// a display preference and survives; [resetProgress] clears it.
  void reset() => update(
    SettingsState(
      lastTopic: state.lastTopic,
      completedTopics: state.completedTopics,
    ),
  );

  void openTopic(String name) {
    if (state.lastTopic != name) update(state.copyWith(lastTopic: () => name));
  }

  void completeTopic(String name) {
    if (state.completedTopics.contains(name)) return;
    update(state.copyWith(completedTopics: {...state.completedTopics, name}));
  }

  void resetProgress() =>
      update(state.copyWith(lastTopic: () => null, completedTopics: const {}));
  void toggleTheme({Brightness? currentBrightness}) {
    final dark =
        state.themeMode == ThemeMode.dark ||
        (state.themeMode == ThemeMode.system &&
            currentBrightness == Brightness.dark);
    setThemeMode(dark ? ThemeMode.light : ThemeMode.dark);
  }

  void setThemeMode(ThemeMode mode) => update(state.copyWith(themeMode: mode));
  void setLocale(Locale? locale) {
    if (locale != null &&
        !SettingsState.languages.contains(locale.languageCode)) {
      return;
    }
    update(state.copyWith(locale: () => locale));
  }

  void toggleDecimalView() =>
      update(state.copyWith(isDecimalView: !state.isDecimalView));
  void setDefaultSpeed(double speed) {
    if (!speed.isFinite || speed <= 0) return;
    update(state.copyWith(defaultPlaybackSpeed: speed.clamp(.25, 4)));
  }

  bool setShortcut(PlayerAction action, LogicalKeyboardKey key) {
    if (!SettingsState.isAssignableKey(key) ||
        state.shortcuts.entries.any(
          (e) => e.key != action && e.value == key.keyId,
        )) {
      return false;
    }
    update(state.copyWith(shortcuts: {...state.shortcuts, action: key.keyId}));
    return true;
  }
}
