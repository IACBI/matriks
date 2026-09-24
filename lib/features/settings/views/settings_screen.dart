import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/number_format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../widgets/language_menu.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<SettingsCubit>();
    final s = cubit.state;
    final l = AppLocalizations.of(context)!;
    Widget choice<T>(
      String label,
      T value,
      Map<T, String> options,
      ValueChanged<T> onChanged,
    ) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in options.entries)
                ChoiceChip(
                  label: Text(e.value),
                  selected: value == e.key,
                  onSelected: (_) => onChanged(e.key),
                ),
            ],
          ),
        ],
      ),
    );
    Widget section(String title, List<Widget> children) => Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
    final actions = {
      PlayerAction.play: l.play,
      PlayerAction.previous: l.prevStep,
      PlayerAction.next: l.nextStep,
      PlayerAction.replay: l.replayAnimation,
      PlayerAction.result: l.showResult,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppTheme.contentWidth),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (s.storageError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      l.settingsStorageError,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                section(l.appearance, [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.changeLanguage),
                    subtitle: Text(
                      LanguageMenu.names[s.locale?.languageCode] ??
                          l.systemDefault,
                    ),
                    trailing: const LanguageMenu(),
                  ),
                  choice(l.themeLabel, s.themeMode, {
                    ThemeMode.system: l.systemDefault,
                    ThemeMode.light: l.lightTheme,
                    ThemeMode.dark: l.darkTheme,
                  }, cubit.setThemeMode),
                ]),
                const SizedBox(height: 16),
                // The two choices most learners need stay in view; the rest
                // keep sensible defaults and wait under "More options".
                section(l.learning, [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.predictionLabel),
                    subtitle: Text(l.predictionHelp),
                    value: s.predictions,
                    onChanged: (v) => cubit.update(s.copyWith(predictions: v)),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.motionLabel),
                    subtitle: Text(l.motionHelp),
                    value: s.reduceMotion,
                    onChanged: (v) => cubit.update(s.copyWith(reduceMotion: v)),
                  ),
                  // Its own semantics node: inside the card it was merged
                  // into the section, so screen readers heard the whole card
                  // as one control.
                  Semantics(
                    container: true,
                    child: ExpansionTile(
                      key: const ValueKey('more-settings'),
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                      title: Text(l.moreOptions),
                      children: [
                        choice(l.solutionModeLabel, s.solutionMode, {
                          SolutionMode.guided: l.guidedMode,
                          SolutionMode.steps: l.stepsMode,
                          SolutionMode.result: l.resultMode,
                        }, (v) => cubit.update(s.copyWith(solutionMode: v))),
                        _SpeedSetting(
                          value: s.defaultPlaybackSpeed,
                          onCommit: cubit.setDefaultSpeed,
                        ),
                        choice(
                          l.explanation,
                          s.explanationLevel,
                          {
                            ExplanationLevel.short: l.shortExplanation,
                            ExplanationLevel.detailed: l.detailedExplanation,
                            ExplanationLevel.hidden: l.hiddenExplanation,
                          },
                          (v) => cubit.update(s.copyWith(explanationLevel: v)),
                        ),
                        choice(l.numberView, s.isDecimalView, {
                          false: l.fractionView,
                          true: l.decimalView,
                        }, (v) => cubit.update(s.copyWith(isDecimalView: v))),
                        choice(l.densityLabel, s.compact, {
                          false: l.comfortable,
                          true: l.compact,
                        }, (v) => cubit.update(s.copyWith(compact: v))),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                section(l.shortcutsLabel, [
                  Text(l.shortcutHelp),
                  for (final e in actions.entries)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(e.value),
                      trailing: OutlinedButton(
                        onPressed: () => _capture(context, cubit, e.key),
                        child: Text(_keyName(l, s.shortcuts[e.key]!)),
                      ),
                    ),
                ]),
                const SizedBox(height: 20),
                Text(l.localPreferences),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: cubit.reset,
                      icon: const Icon(Icons.restore),
                      label: Text(l.resetSettings),
                    ),
                    if (s.completedTopics.isNotEmpty || s.lastTopic != null)
                      TextButton.icon(
                        onPressed: cubit.resetProgress,
                        icon: const Icon(Icons.flag_outlined),
                        label: Text(l.resetProgress),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _capture(
    BuildContext context,
    SettingsCubit cubit,
    PlayerAction action,
  ) async {
    final l = AppLocalizations.of(context)!;
    String? error;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => Focus(
          autofocus: true,
          onKeyEvent: (_, event) {
            if (event is! KeyDownEvent ||
                event.logicalKey == LogicalKeyboardKey.escape) {
              return KeyEventResult.ignored;
            }
            final modified =
                HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isAltPressed ||
                HardwareKeyboard.instance.isMetaPressed ||
                HardwareKeyboard.instance.isShiftPressed;
            if (!modified && cubit.setShortcut(action, event.logicalKey)) {
              Navigator.pop(dialogContext);
            } else {
              // A key outside the assignable set is not a conflict; repeat
              // which keys are allowed instead.
              final assignable =
                  !modified && SettingsState.isAssignableKey(event.logicalKey);
              setState(
                () => error = assignable ? l.shortcutConflict : l.shortcutHelp,
              );
            }
            return KeyEventResult.handled;
          },
          child: AlertDialog(
            title: Text(l.pressKey),
            content: Text(error ?? l.shortcutHelp),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Readable name of an assignable key: letters as themselves, arrows as
  /// arrows rather than the platform's English "Arrow Left".
  static String _keyName(AppLocalizations l, int keyId) {
    if (keyId == LogicalKeyboardKey.space.keyId) return l.spaceKey;
    if (keyId == LogicalKeyboardKey.arrowLeft.keyId) return '←';
    if (keyId == LogicalKeyboardKey.arrowRight.keyId) return '→';
    return LogicalKeyboardKey(keyId).keyLabel;
  }
}

/// Default playback speed. The slider moves freely and the preference is
/// saved once, when the drag ends, instead of on every intermediate value.
class _SpeedSetting extends StatefulWidget {
  final double value;
  final ValueChanged<double> onCommit;
  const _SpeedSetting({required this.value, required this.onCommit});

  @override
  State<_SpeedSetting> createState() => _SpeedSettingState();
}

class _SpeedSettingState extends State<_SpeedSetting> {
  late double _value = widget.value;

  @override
  void didUpdateWidget(_SpeedSetting oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final text = formatSpeed(_value, locale);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.playbackSpeed(text)),
        Slider(
          value: _value,
          min: .25,
          max: 4,
          divisions: 15,
          label: text,
          semanticFormatterCallback: (v) => formatSpeed(v, locale),
          onChanged: (v) => setState(() => _value = v),
          onChangeEnd: widget.onCommit,
        ),
      ],
    );
  }
}
