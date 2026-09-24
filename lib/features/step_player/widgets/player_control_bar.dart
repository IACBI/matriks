import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';

class PlayerControlBar extends StatelessWidget {
  /// Whether the play/pause and speed controls exist at all. Static steps and
  /// direct results have nothing to play.
  final bool showPlayback;
  final bool animationEnabled;
  final int currentStepIndex;
  final int totalSteps;
  final bool isPlaying;
  final List<String> stepTitles;
  final VoidCallback? onOpenSteps;
  final double playbackSpeed;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onNextStep;
  final VoidCallback onPrevStep;
  final void Function(int stepIndex) onSeek;
  final void Function(double speed) onSpeedChanged;

  const PlayerControlBar({
    this.showPlayback = true,
    this.animationEnabled = true,
    super.key,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.isPlaying,
    this.stepTitles = const [],
    this.onOpenSteps,
    required this.playbackSpeed,
    required this.onTogglePlayPause,
    required this.onNextStep,
    required this.onPrevStep,
    required this.onSeek,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    String speedText(double speed) => formatSpeed(speed, locale);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Playback Buttons & Speed Selector
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const ValueKey('choose-lesson-step'),
                    icon: const Icon(Icons.list_rounded, size: 18),
                    label: Text(
                      l10n?.stepOf(currentStepIndex + 1, totalSteps) ??
                          '${currentStepIndex + 1} / $totalSteps',
                    ),
                    onPressed: totalSteps == 0
                        ? null
                        : () {
                            onOpenSteps?.call();
                            showModalBottomSheet<void>(
                              context: context,
                              useSafeArea: true,
                              isScrollControlled: true,
                              builder: (sheetContext) => FractionallySizedBox(
                                heightFactor: .7,
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        l10n?.chooseStep ?? 'Choose a step',
                                        style: theme.textTheme.titleLarge,
                                      ),
                                      trailing: IconButton(
                                        tooltip: MaterialLocalizations.of(
                                          context,
                                        ).closeButtonTooltip,
                                        icon: const Icon(Icons.close),
                                        onPressed: () =>
                                            Navigator.pop(sheetContext),
                                      ),
                                    ),
                                    const Divider(height: 1),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: totalSteps,
                                        itemBuilder: (_, index) => ListTile(
                                          selected: index == currentStepIndex,
                                          leading: Text('${index + 1}'),
                                          title: Text(
                                            index < stepTitles.length
                                                ? stepTitles[index]
                                                : (l10n?.stepOf(
                                                        index + 1,
                                                        totalSteps,
                                                      ) ??
                                                      '${index + 1} / $totalSteps'),
                                          ),
                                          trailing: index == currentStepIndex
                                              ? const Icon(Icons.check_rounded)
                                              : null,
                                          onTap: () {
                                            Navigator.pop(sheetContext);
                                            onSeek(index);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                  ),
                  // Speed Selector
                  if (showPlayback && animationEnabled)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          key: const ValueKey('decrease-playback-speed'),
                          tooltip:
                              l10n?.decreasePlaybackSpeed ?? 'Decrease speed',
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          onPressed: playbackSpeed > .25
                              ? () => onSpeedChanged(
                                  (playbackSpeed - .25).clamp(.25, 4.0),
                                )
                              : null,
                          icon: const Icon(Icons.remove_rounded),
                        ),
                        PopupMenuButton<double>(
                          initialValue: playbackSpeed,
                          tooltip:
                              l10n?.playbackSpeed(speedText(playbackSpeed)) ??
                              'Speed: ${speedText(playbackSpeed)}',
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: onSpeedChanged,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.borderDark
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  speedText(playbackSpeed),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_drop_down, size: 16),
                              ],
                            ),
                          ),
                          itemBuilder: (context) => [
                            for (final speed in [
                              .25,
                              .5,
                              .75,
                              1.0,
                              1.25,
                              1.5,
                              2.0,
                              3.0,
                              4.0,
                            ])
                              PopupMenuItem(
                                value: speed,
                                child: Text(
                                  l10n?.playbackSpeed(speedText(speed)) ??
                                      speedText(speed),
                                ),
                              ),
                          ],
                        ),
                        IconButton(
                          key: const ValueKey('increase-playback-speed'),
                          tooltip:
                              l10n?.increasePlaybackSpeed ?? 'Increase speed',
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          onPressed: playbackSpeed < 4
                              ? () => onSpeedChanged(
                                  (playbackSpeed + .25).clamp(.25, 4.0),
                                )
                              : null,
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),

                  // Controls: Prev, Play/Pause, Next
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: l10n?.prevStep ?? 'Previous',
                        onPressed: currentStepIndex > 0 ? onPrevStep : null,
                        icon: const Icon(Icons.skip_previous_rounded, size: 28),
                      ),
                      if (showPlayback) ...[
                      const SizedBox(width: 4),
                      FloatingActionButton.small(
                        heroTag: 'play_pause_btn',
                        tooltip: isPlaying
                            ? (l10n?.pause ?? 'Pause')
                            : (l10n?.play ?? 'Play'),
                        onPressed: animationEnabled ? onTogglePlayPause : null,
                        backgroundColor: animationEnabled
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        foregroundColor: animationEnabled
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface.withValues(
                                alpha: .38,
                              ),
                        elevation: animationEnabled ? 1 : 0,
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 26,
                        ),
                      ),
                      ],
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: l10n?.nextStep ?? 'Next',
                        onPressed: currentStepIndex < totalSteps - 1
                            ? onNextStep
                            : null,
                        icon: const Icon(Icons.skip_next_rounded, size: 28),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
