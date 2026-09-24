import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/generated/app_localizations.dart';

import 'package:matrix_engine/matrix_engine.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/math_text.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../cubit/player_cubit.dart';
import '../cubit/player_state.dart';
import '../widgets/cell_calculation_sheet.dart';
import '../widgets/matrix_display_grid.dart';
import '../widgets/player_control_bar.dart';
import '../widgets/step_card.dart';
import '../widgets/instruction_lesson.dart';
import '../widgets/solution_summary.dart';
import '../widgets/prediction_card.dart';
import '../../settings/cubit/settings_state.dart';
import '../step_text.dart';

class StepPlayerScreen extends StatelessWidget {
  final StepSolution solution;
  final String topicTitle;
  final bool workedExample;

  /// Offered when the lesson ends: a worked example opens the editor for the
  /// same topic, a solved input returns to its matrix.
  final VoidCallback? onOwnMatrix;

  const StepPlayerScreen({
    super.key,
    required this.solution,
    required this.topicTitle,
    this.workedExample = false,
    this.onOwnMatrix,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final speed = context.read<SettingsCubit>().state.defaultPlaybackSpeed;
        return PlayerCubit(
          solution,
          initialSpeed: speed,
          mode: context.read<SettingsCubit>().state.solutionMode,
        );
      },
      child: _StepPlayerView(
        topicTitle: topicTitle,
        workedExample: workedExample,
        onOwnMatrix: onOwnMatrix,
      ),
    );
  }
}

class _StepPlayerView extends StatefulWidget {
  final String topicTitle;
  final bool workedExample;
  final VoidCallback? onOwnMatrix;

  const _StepPlayerView({
    required this.topicTitle,
    required this.workedExample,
    this.onOwnMatrix,
  });

  @override
  State<_StepPlayerView> createState() => _StepPlayerViewState();
}

class _StepPlayerViewState extends State<_StepPlayerView>
    with WidgetsBindingObserver {
  final _matrixKey = GlobalKey();
  final Set<int> _predicted = {};
  int? _pendingPrediction;
  (StepSolution, bool, MatrixLayoutHint)? _layout;
  String get topicTitle => widget.topicTitle;

  /// Measured once per solution and number view so the matrix keeps its size
  /// from step to step.
  MatrixLayoutHint _layoutFor(StepSolution solution, bool decimal) {
    final cached = _layout;
    if (cached != null &&
        identical(cached.$1, solution) &&
        cached.$2 == decimal) {
      return cached.$3;
    }
    final hint = MatrixLayoutHint.forSolution(solution, decimal: decimal);
    _layout = (solution, decimal, hint);
    return hint;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) context.read<PlayerCubit>().pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<PlayerCubit, PlayerState>(
      listenWhen: (previous, current) =>
          previous.inspectedCalculation != current.inspectedCalculation &&
          current.inspectedCalculation != null,
      listener: (context, state) {
        if (state.inspectedCalculation != null) {
          context.read<PlayerCubit>().pause();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => SingleChildScrollView(
              child: CellCalculationSheet(
                calculation: state.inspectedCalculation!,
                onClose: () {
                  Navigator.of(ctx).pop();
                  context.read<PlayerCubit>().closeInspection();
                },
              ),
            ),
          ).then((_) {
            if (context.mounted) {
              context.read<PlayerCubit>().closeInspection();
            }
          });
        }
      },
      builder: (context, state) {
        final playerCubit = context.read<PlayerCubit>();
        final settingsState = context.watch<SettingsCubit>().state;
        final currentStep = state.currentStep;

        if (state.mode == SolutionMode.result) {
          return Scaffold(
            appBar: AppBar(title: Text(topicTitle)),
            body: SafeArea(
              child: SolutionSummary(
                solution: state.solution,
                decimal: settingsState.isDecimalView,
                onViewSteps: () => playerCubit.setMode(SolutionMode.steps),
              ),
            ),
          );
        }
        if (currentStep == null) {
          return Scaffold(
            appBar: AppBar(title: Text(topicTitle)),
            body: Center(
              child: Text(
                localizedSolverError(l10n, state.solution.errorMessageKey),
              ),
            ),
          );
        }

        final prediction =
            widget.workedExample &&
            settingsState.predictions &&
            state.mode == SolutionMode.guided &&
            currentStep.transformation is RowEliminationTransformation &&
            !_predicted.contains(state.currentStepIndex);
        if (prediction && _pendingPrediction != state.currentStepIndex) {
          _pendingPrediction = state.currentStepIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted &&
                playerCubit.state.currentStepIndex == _pendingPrediction) {
              playerCubit.pause();
            }
          });
        }
        // Converted here rather than at each display: the heading, the card and
        // the step list all show this as prose, and a title carrying TeX reached
        // the heading unconverted when only the card was wrapped.
        final title = readableMathProse(
          localizedStepText(
            l10n,
            currentStep.titleKey,
            currentStep.titleParams,
          ),
        );
        final description = localizedStepText(
          l10n,
          currentStep.explanationKey,
          currentStep.explanationParams,
        );
        final media = MediaQuery.of(context);
        final isWideScreen =
            media.size.width >= 960 && media.textScaler.scale(1) <= 1.5;

        KeyEventResult handleKeyEvent(KeyEvent event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          final key = event.logicalKey;

          if (HardwareKeyboard.instance.isControlPressed ||
              HardwareKeyboard.instance.isAltPressed ||
              HardwareKeyboard.instance.isMetaPressed ||
              HardwareKeyboard.instance.isShiftPressed) {
            return KeyEventResult.ignored;
          }
          final action = settingsState.shortcuts.entries
              .where((e) => e.value == key.keyId)
              .firstOrNull
              ?.key;
          if (prediction &&
              (action == PlayerAction.play || action == PlayerAction.replay)) {
            return KeyEventResult.ignored;
          }
          if (action != null) {
            switch (action) {
              case PlayerAction.play:
                playerCubit.togglePlayPause();
              case PlayerAction.previous:
                playerCubit.prevStep();
              case PlayerAction.next:
                playerCubit.nextStep();
              case PlayerAction.replay:
                playerCubit.replay();
              case PlayerAction.result:
                playerCubit.showResult();
            }
          } else if (key == LogicalKeyboardKey.pageDown) {
            playerCubit.nextStep();
          } else if (key == LogicalKeyboardKey.pageUp) {
            playerCubit.prevStep();
          } else if (key == LogicalKeyboardKey.home) {
            playerCubit.jumpToStep(0);
          } else if (key == LogicalKeyboardKey.end) {
            playerCubit.jumpToStep(state.totalSteps - 1);
          } else {
            return KeyEventResult.ignored;
          }
          return KeyEventResult.handled;
        }

        final lesson = InstructionLesson.forStep(
          transformation: currentStep.transformation,
          before: currentStep.matrixBefore,
          after: currentStep.matrixAfter,
          l10n: l10n,
        );
        final transformation = currentStep.transformation;
        // Only these steps attach a formula to the cell it produces; other
        // solvers list whole-step formulas that no single cell owns.
        final cellFormulas =
            transformation is RowEliminationTransformation ||
            transformation is RowScaleTransformation ||
            transformation is MatrixElementAdditionTransformation ||
            transformation is MatrixElementMultiplicationTransformation ||
            transformation is MatrixScaleTransformation;
        final stepCard = StepCard(
          showTitle: false,
          explanationLevel: settingsState.explanationLevel,
          step: currentStep,
          localizedTitle: title,
          localizedDescription: description,
          rationale: lesson.rationale,
          showDescription: lesson.generic || !lesson.coversDescription,
          showCellCalculations: lesson.calculations.isEmpty,
          onExpandCalculations: playerCubit.pause,
          onSubCalculationTap: (sub) =>
              playerCubit.inspectCell(sub.targetRow, sub.targetCol),
        );
        final matrixGridWidget = MatrixDisplayGrid(
          key: _matrixKey,
          sceneFormula:
              currentStep.transformation is InformationalStepTransformation
              ? (currentStep.explanationParams['scene'] ??
                        currentStep.explanationParams['vector'] ??
                        currentStep.explanationParams['poly'] ??
                        currentStep.explanationParams['formula'])
                    ?.toString()
              : null,
          staticStep: state.mode == SolutionMode.steps,
          showExplanation:
              settingsState.explanationLevel != ExplanationLevel.hidden,
          snapshot: currentStep.matrixAfter,
          snapshotBefore: currentStep.matrixBefore,
          highlights: currentStep.highlights,
          subCalculations: cellFormulas
              ? currentStep.subCalculations
              : const [],
          transformation: currentStep.transformation,
          isDecimalView: settingsState.isDecimalView,
          playbackSpeed: state.playbackSpeed,
          stepIndex: state.currentStepIndex,
          isAnimating: state.isAnimating && !prediction,
          animationRevision: state.animationRevision,
          onAnimationCompleted: playerCubit.animationCompleted,
          onScrubStart: playerCubit.scrub,
          onReplay: playerCubit.replay,
          onCellTap: (r, c) => playerCubit.inspectCell(r, c),
          layoutHint: _layoutFor(state.solution, settingsState.isDecimalView),
        );
        final lessonEnd = state.isLastStep && state.hasCompletedAnimation
            ? _LessonComplete(
                onShowResult: playerCubit.showResult,
                onReplay: () {
                  playerCubit.jumpToStep(0);
                  playerCubit.play();
                },
                ownMatrixLabel: widget.onOwnMatrix == null
                    ? null
                    : widget.workedExample
                    ? l10n.tryOwnMatrix
                    : l10n.editMatrix,
                onOwnMatrix: widget.onOwnMatrix,
              )
            : null;

        return Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (!node.hasPrimaryFocus) return KeyEventResult.ignored;
            return handleKeyEvent(event);
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                topicTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              actions: [
                IconButton(
                  tooltip: l10n.showResult,
                  onPressed: playerCubit.showResult,
                  icon: const Icon(Icons.last_page_rounded),
                ),
                PopupMenuButton<SolutionMode>(
                  tooltip: l10n.solutionModeLabel,
                  icon: const Icon(Icons.slideshow_rounded),
                  initialValue: state.mode,
                  onSelected: playerCubit.setMode,
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: SolutionMode.guided,
                      child: Text(l10n.guidedMode),
                    ),
                    PopupMenuItem(
                      value: SolutionMode.steps,
                      child: Text(l10n.stepsMode),
                    ),
                    PopupMenuItem(
                      value: SolutionMode.result,
                      child: Text(l10n.resultMode),
                    ),
                  ],
                ),

                // Fraction / Decimal toggle
                IconButton(
                  tooltip: l10n.fractionToggle,
                  icon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: settingsState.isDecimalView
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Text(
                      settingsState.isDecimalView ? '0.0' : 'a/b',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: settingsState.isDecimalView
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                  ),
                  onPressed: () =>
                      context.read<SettingsCubit>().toggleDecimalView(),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Top Progress Line
                  ExcludeSemantics(
                    child: LinearProgressIndicator(
                      value: (state.currentStepIndex + 1) / state.totalSteps,
                      backgroundColor: isDark
                          ? AppTheme.surfaceVariantDark
                          : AppTheme.borderLight,
                      // Follows the accent palette and keeps its contrast on
                      // the dark surface, which the fixed light-theme blue lost.
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                      minHeight: 3,
                    ),
                  ),

                  // Main Content Canvas: Side-by-Side on wide screens, Stacked on mobile
                  Expanded(
                    child: isWideScreen
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left: Animated Matrix Canvas (scrollable to prevent overflow)
                              Expanded(
                                flex: 3,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Semantics(
                                            header: true,
                                            liveRegion: true,
                                            child: Text(
                                              title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        if (prediction)
                                          PredictionCard(
                                            key: ValueKey(
                                              currentStep.stepIndex,
                                            ),
                                            transformation:
                                                currentStep.transformation
                                                    as RowEliminationTransformation,
                                            seed: state.currentStepIndex,
                                            onContinue: () => setState(() {
                                              _predicted.add(
                                                state.currentStepIndex,
                                              );
                                              _pendingPrediction = null;
                                              playerCubit.play();
                                            }),
                                          ),
                                        matrixGridWidget,
                                        if (state.solution.result
                                            is EigenResult)
                                          SolutionStatus(
                                            solution: state.solution,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Right: StepCard
                              Expanded(
                                flex: 2,
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      stepCard,
                                      if (lessonEnd != null) ...[
                                        const SizedBox(height: 16),
                                        lessonEnd,
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Semantics(
                                  header: true,
                                  liveRegion: true,
                                  child: Text(
                                    title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                ),
                                if (prediction)
                                  PredictionCard(
                                    key: ValueKey(currentStep.stepIndex),
                                    transformation:
                                        currentStep.transformation
                                            as RowEliminationTransformation,
                                    seed: state.currentStepIndex,
                                    onContinue: () => setState(() {
                                      _predicted.add(state.currentStepIndex);
                                      _pendingPrediction = null;
                                      playerCubit.play();
                                    }),
                                  ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: matrixGridWidget,
                                ),
                                if (state.solution.result is EigenResult)
                                  SolutionStatus(solution: state.solution),
                                const SizedBox(height: 8),
                                stepCard,
                                if (lessonEnd != null) ...[
                                  const SizedBox(height: 16),
                                  lessonEnd,
                                ],
                              ],
                            ),
                          ),
                  ),

                  // Bottom Player Controls
                  PlayerControlBar(
                    // Static steps have nothing to play; only a prediction
                    // temporarily disables the control.
                    showPlayback: state.mode == SolutionMode.guided,
                    animationEnabled:
                        state.mode == SolutionMode.guided && !prediction,
                    currentStepIndex: state.currentStepIndex,
                    totalSteps: state.totalSteps,
                    stepTitles: state.solution.steps
                        .map(
                          (step) => readableMathProse(
                            localizedStepText(
                              l10n,
                              step.titleKey,
                              step.titleParams,
                            ),
                          ),
                        )
                        .toList(),
                    onOpenSteps: playerCubit.pause,
                    isPlaying: state.isAnimating,
                    playbackSpeed: state.playbackSpeed,
                    onTogglePlayPause:
                        prediction || state.mode != SolutionMode.guided
                        ? () {}
                        : playerCubit.togglePlayPause,
                    onNextStep: playerCubit.nextStep,
                    onPrevStep: playerCubit.prevStep,
                    onSeek: playerCubit.jumpToStep,
                    onSpeedChanged: playerCubit.setPlaybackSpeed,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Shown under the explanation once the last step has finished.
class _LessonComplete extends StatelessWidget {
  final VoidCallback onShowResult;
  final VoidCallback onReplay;
  final String? ownMatrixLabel;
  final VoidCallback? onOwnMatrix;

  const _LessonComplete({
    required this.onShowResult,
    required this.onReplay,
    this.ownMatrixLabel,
    this.onOwnMatrix,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      key: const ValueKey('lesson-complete'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      l10n.lessonComplete,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.lessonCompleteHint, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onShowResult,
                  icon: const Icon(Icons.last_page_rounded),
                  label: Text(l10n.showResult),
                ),
                OutlinedButton.icon(
                  onPressed: onReplay,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: Text(l10n.replayLesson),
                ),
                if (onOwnMatrix != null && ownMatrixLabel != null)
                  OutlinedButton.icon(
                    onPressed: onOwnMatrix,
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(ownMatrixLabel!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
