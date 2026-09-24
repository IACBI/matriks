import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum SolutionMode { guided, steps, result }

enum ExplanationLevel { short, detailed, hidden }

enum AccentPalette { blue, teal, purple }

enum PlayerAction { play, previous, next, replay, result }

class SettingsState {
  static const languages = ['en', 'tr', 'zh', 'es', 'ru'];
  static final defaultShortcuts = Map<PlayerAction, int>.unmodifiable({
    PlayerAction.play: LogicalKeyboardKey.space.keyId,
    PlayerAction.previous: LogicalKeyboardKey.arrowLeft.keyId,
    PlayerAction.next: LogicalKeyboardKey.arrowRight.keyId,
    PlayerAction.replay: LogicalKeyboardKey.keyR.keyId,
    PlayerAction.result: LogicalKeyboardKey.keyS.keyId,
  });
  final ThemeMode themeMode;
  final Locale? locale;
  final bool isDecimalView;
  final double defaultPlaybackSpeed;
  final SolutionMode solutionMode;
  final ExplanationLevel explanationLevel;
  final AccentPalette accentPalette;
  final bool reduceMotion;
  final bool predictions;
  final bool compact;
  final Map<PlayerAction, int> shortcutOverrides;
  final bool storageError;
  Map<PlayerAction, int> get shortcuts =>
      Map.unmodifiable({...defaultShortcuts, ...shortcutOverrides});

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.isDecimalView = false,
    this.defaultPlaybackSpeed = 1,
    this.solutionMode = SolutionMode.guided,
    this.explanationLevel = ExplanationLevel.short,
    this.accentPalette = AccentPalette.blue,
    this.reduceMotion = false,
    this.predictions = true,
    this.compact = false,
    this.shortcutOverrides = const {},
    this.storageError = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? Function()? locale,
    bool? isDecimalView,
    double? defaultPlaybackSpeed,
    SolutionMode? solutionMode,
    ExplanationLevel? explanationLevel,
    AccentPalette? accentPalette,
    bool? reduceMotion,
    bool? predictions,
    bool? compact,
    Map<PlayerAction, int>? shortcuts,
    bool? storageError,
  }) => SettingsState(
    themeMode: themeMode ?? this.themeMode,
    locale: locale != null ? locale() : this.locale,
    isDecimalView: isDecimalView ?? this.isDecimalView,
    defaultPlaybackSpeed: defaultPlaybackSpeed ?? this.defaultPlaybackSpeed,
    solutionMode: solutionMode ?? this.solutionMode,
    explanationLevel: explanationLevel ?? this.explanationLevel,
    accentPalette: accentPalette ?? this.accentPalette,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    predictions: predictions ?? this.predictions,
    compact: compact ?? this.compact,
    shortcutOverrides: shortcuts == null
        ? shortcutOverrides
        : Map.unmodifiable(shortcuts),
    storageError: storageError ?? this.storageError,
  );

  // Value equality lets the cubit skip emitting an unchanged state, which
  // rebuilt the whole MaterialApp (and both themes) after every save.
  @override
  bool operator ==(Object other) =>
      other is SettingsState &&
      other.themeMode == themeMode &&
      other.locale == locale &&
      other.isDecimalView == isDecimalView &&
      other.defaultPlaybackSpeed == defaultPlaybackSpeed &&
      other.solutionMode == solutionMode &&
      other.explanationLevel == explanationLevel &&
      other.accentPalette == accentPalette &&
      other.reduceMotion == reduceMotion &&
      other.predictions == predictions &&
      other.compact == compact &&
      mapEquals(other.shortcuts, shortcuts) &&
      other.storageError == storageError;

  @override
  int get hashCode => Object.hash(
    themeMode,
    locale,
    isDecimalView,
    defaultPlaybackSpeed,
    solutionMode,
    explanationLevel,
    accentPalette,
    reduceMotion,
    predictions,
    compact,
    Object.hashAllUnordered(
      shortcuts.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    storageError,
  );

  Map<String, Object?> toJson() => {
    'version': 1,
    'theme': themeMode.name,
    'locale': locale?.languageCode,
    'decimal': isDecimalView,
    'speed': defaultPlaybackSpeed,
    'mode': solutionMode.name,
    'explanation': explanationLevel.name,
    'accent': accentPalette.name,
    'reduceMotion': reduceMotion,
    'predictions': predictions,
    'compact': compact,
    'shortcuts': shortcuts.map((key, value) => MapEntry(key.name, value)),
  };

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1) throw const FormatException('Settings version');
    T choice<T extends Enum>(List<T> values, String key, T fallback) =>
        values.where((v) => v.name == json[key]).firstOrNull ?? fallback;
    final speed = json['speed'];
    final locale = json['locale'];
    final bindings = Map<PlayerAction, int>.of(defaultShortcuts);
    final saved = json['shortcuts'];
    if (saved is Map) {
      final candidate = <PlayerAction, int>{};
      for (final action in PlayerAction.values) {
        final id = saved[action.name];
        if (id is int && isAssignableKey(LogicalKeyboardKey(id))) {
          candidate[action] = id;
        }
      }
      if (candidate.length == PlayerAction.values.length &&
          candidate.values.toSet().length == candidate.length) {
        bindings.addAll(candidate);
      }
    }
    return SettingsState(
      themeMode: choice(ThemeMode.values, 'theme', ThemeMode.system),
      locale: locale is String && languages.contains(locale)
          ? Locale(locale)
          : null,
      isDecimalView: json['decimal'] == true,
      defaultPlaybackSpeed: speed is num && speed.isFinite && speed > 0
          ? speed.toDouble().clamp(.25, 4)
          : 1,
      solutionMode: choice(SolutionMode.values, 'mode', SolutionMode.guided),
      explanationLevel: choice(
        ExplanationLevel.values,
        'explanation',
        ExplanationLevel.short,
      ),
      accentPalette: choice(AccentPalette.values, 'accent', AccentPalette.blue),
      reduceMotion: json['reduceMotion'] == true,
      predictions: json['predictions'] != false,
      compact: json['compact'] == true,
      shortcutOverrides: Map.unmodifiable(bindings),
    );
  }

  // Reserve navigation and text editing keys outside the player.
  static bool isAssignableKey(LogicalKeyboardKey key) =>
      key == LogicalKeyboardKey.space ||
      key == LogicalKeyboardKey.arrowLeft ||
      key == LogicalKeyboardKey.arrowRight ||
      (key.keyId >= LogicalKeyboardKey.keyA.keyId &&
          key.keyId <= LogicalKeyboardKey.keyZ.keyId);
}
