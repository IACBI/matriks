import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                  choice(l.accentLabel, s.accentPalette, {
                    AccentPalette.blue: l.blue,
                    AccentPalette.teal: l.teal,
                    AccentPalette.purple: l.purple,
                  }, (v) => cubit.update(s.copyWith(accentPalette: v))),
                  choice(l.densityLabel, s.compact, {
                    false: l.comfortable,
                    true: l.compact,
                  }, (v) => cubit.update(s.copyWith(compact: v))),
                ]),
                const SizedBox(height: 16),
                section(l.learning, [
                  choice(l.solutionModeLabel, s.solutionMode, {
                    SolutionMode.guided: l.guidedMode,
                    SolutionMode.steps: l.stepsMode,
                    SolutionMode.result: l.resultMode,
                  }, (v) => cubit.update(s.copyWith(solutionMode: v))),
                  Text(
                    l.playbackSpeed(s.defaultPlaybackSpeed.toStringAsFixed(2)),
                  ),
                  Slider(
                    value: s.defaultPlaybackSpeed,
                    min: .25,
                    max: 4,
                    divisions: 15,
                    label: '${s.defaultPlaybackSpeed}×',
                    semanticFormatterCallback: (v) =>
                        '${v.toStringAsFixed(2)}×',
                    onChanged: cubit.setDefaultSpeed,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.motionLabel),
                    subtitle: Text(l.motionHelp),
                    value: s.reduceMotion,
                    onChanged: (v) => cubit.update(s.copyWith(reduceMotion: v)),
                  ),
                  choice(l.explanation, s.explanationLevel, {
                    ExplanationLevel.short: l.shortExplanation,
                    ExplanationLevel.detailed: l.detailedExplanation,
                    ExplanationLevel.hidden: l.hiddenExplanation,
                  }, (v) => cubit.update(s.copyWith(explanationLevel: v))),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.predictionLabel),
                    subtitle: Text(l.predictionHelp),
                    value: s.predictions,
                    onChanged: (v) => cubit.update(s.copyWith(predictions: v)),
                  ),
                  choice(l.numberView, s.isDecimalView, {
                    false: l.fractionView,
                    true: l.decimalView,
                  }, (v) => cubit.update(s.copyWith(isDecimalView: v))),
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
                        child: Text(
                          s.shortcuts[e.key] == LogicalKeyboardKey.space.keyId
                              ? l.spaceKey
                              : LogicalKeyboardKey(s.shortcuts[e.key]!)
                                    .keyLabel,
                        ),
                      ),
                    ),
                ]),
                const SizedBox(height: 20),
                Text(l.localPreferences),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: cubit.reset,
                    icon: const Icon(Icons.restore),
                    label: Text(l.resetSettings),
                  ),
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
              setState(() => error = l.shortcutConflict);
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
}
