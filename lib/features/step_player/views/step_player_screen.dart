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

class StepPlayerScreen extends StatelessWidget {
  final StepSolution solution;
  final String topicTitle;
  final bool workedExample;

  const StepPlayerScreen({
    super.key,
    required this.solution,
    required this.topicTitle,
    this.workedExample = false,
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
      ),
    );
  }
}

class _StepPlayerView extends StatefulWidget {
  final String topicTitle;
  final bool workedExample;

  const _StepPlayerView({
    required this.topicTitle,
    required this.workedExample,
  });

  @override
  State<_StepPlayerView> createState() => _StepPlayerViewState();
}

class _StepPlayerViewState extends State<_StepPlayerView>
    with WidgetsBindingObserver {
  final _matrixKey = GlobalKey();
  final Set<int> _predicted = {};
  int? _pendingPrediction;
  String get topicTitle => widget.topicTitle;

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
    final l10n = AppLocalizations.of(context);
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
                state.solution.errorMessageKey != null
                    ? _resolveKey(l10n, state.solution.errorMessageKey!)
                    : (l10n?.solveFallbackError ??
                          'No solution steps generated.'),
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
        final title = _resolveString(
          l10n,
          currentStep.titleKey,
          currentStep.titleParams,
        );
        final description = _resolveString(
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

        final matrixGridWidget = MatrixDisplayGrid(
          key: _matrixKey,
          sceneFormula:
              currentStep.transformation is InformationalStepTransformation
              ? (currentStep.explanationParams['vector'] ??
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
          subCalculations: currentStep.subCalculations,
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
        );

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
                  tooltip: l10n!.showResult,
                  onPressed: playerCubit.showResult,
                  icon: const Icon(Icons.last_page_rounded),
                ),
                PopupMenuButton<SolutionMode>(
                  tooltip: l10n.solutionModeLabel,
                  icon: const Icon(Icons.tune_rounded),
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
                            ? AppTheme.accentCyan
                            : (isDark ? const Color(0xFF475569) : Colors.grey),
                      ),
                    ),
                    child: Text(
                      settingsState.isDecimalView ? '0.0' : 'a/b',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: settingsState.isDecimalView
                            ? AppTheme.accentCyan
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
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryBlue,
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
                                          child: Text(
                                            title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall,
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
                                  child: StepCard(
                                    showTitle: false,
                                    explanationLevel:
                                        settingsState.explanationLevel,
                                    step: currentStep,
                                    localizedTitle: title,
                                    localizedDescription: description,
                                    rationale: InstructionLesson.forStep(
                                      transformation:
                                          currentStep.transformation,
                                      before: currentStep.matrixBefore,
                                      after: currentStep.matrixAfter,
                                      l10n: l10n,
                                    ).rationale,
                                    onExpandCalculations: playerCubit.pause,
                                    onSubCalculationTap: (sub) =>
                                        playerCubit.inspectCell(
                                          sub.targetRow,
                                          sub.targetCol,
                                        ),
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
                                StepCard(
                                  showTitle: false,
                                  explanationLevel:
                                      settingsState.explanationLevel,
                                  step: currentStep,
                                  localizedTitle: title,
                                  localizedDescription: description,
                                  rationale: InstructionLesson.forStep(
                                    transformation: currentStep.transformation,
                                    before: currentStep.matrixBefore,
                                    after: currentStep.matrixAfter,
                                    l10n: l10n,
                                  ).rationale,
                                  onExpandCalculations: playerCubit.pause,
                                  onSubCalculationTap: (sub) =>
                                      playerCubit.inspectCell(
                                        sub.targetRow,
                                        sub.targetCol,
                                      ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  // Bottom Player Controls
                  PlayerControlBar(
                    animationEnabled:
                        state.mode == SolutionMode.guided && !prediction,
                    currentStepIndex: state.currentStepIndex,
                    totalSteps: state.totalSteps,
                    stepTitles: state.solution.steps
                        .map(
                          (step) => readableMathProse(
                            _resolveString(
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

  String _resolveKey(AppLocalizations? l10n, String key) {
    if (l10n == null) return key;
    switch (key) {
      case 'stepAlreadyReducedTitle':
        return l10n.stepAlreadyReducedTitle;
      case 'stepAlreadyReducedDesc':
        return l10n.stepAlreadyReducedDesc;
      case 'error_matrix_is_singular':
        return l10n.error_matrix_is_singular;
      case 'error_inverse_not_square':
        return l10n.error_inverse_not_square;
      case 'error_dimension_mismatch_add':
        return l10n.error_dimension_mismatch_add;
      case 'error_dimension_mismatch_multiply':
        return l10n.error_dimension_mismatch_multiply;
      default:
        return key;
    }
  }

  String _resolveString(
    AppLocalizations? l10n,
    String key,
    Map<String, dynamic> params,
  ) {
    if (l10n == null) return key;
    try {
      switch (key) {
        case 'stepAlreadyReducedTitle':
          return l10n.stepAlreadyReducedTitle;
        case 'stepAlreadyReducedDesc':
          return l10n.stepAlreadyReducedDesc;
        case 'step_row_swap_title':
          return l10n.step_row_swap_title(
            params['rowA'] ?? 0,
            params['rowB'] ?? 0,
          );
        case 'step_row_swap_desc':
          return l10n.step_row_swap_desc(
            params['col'] ?? 0,
            params['pivot']?.toString() ?? '',
            params['rowA'] ?? 0,
            params['rowB'] ?? 0,
          );
        case 'step_row_scale_title':
          return l10n.step_row_scale_title(params['row'] ?? 0);
        case 'step_row_scale_desc':
          return l10n.step_row_scale_desc(
            params['factor']?.toString() ?? '',
            params['row'] ?? 0,
          );
        case 'step_row_elimination_title':
          return l10n.step_row_elimination_title(params['target'] ?? 0);
        case 'step_row_elimination_desc':
          return l10n.step_row_elimination_desc(
            params['col'] ?? 0,
            params['multiplier']?.toString() ?? '',
            params['source'] ?? 0,
            params['target'] ?? 0,
          );

        // Determinant keys
        case 'det_1x1_title':
          return l10n.det_1x1_title;
        case 'det_1x1_desc':
          return l10n.det_1x1_desc(params['val']?.toString() ?? '');
        case 'det_2x2_main_diagonal_title':
          return l10n.det_2x2_main_diagonal_title;
        case 'det_2x2_main_diagonal_desc':
          return l10n.det_2x2_main_diagonal_desc(
            params['a']?.toString() ?? '',
            params['d']?.toString() ?? '',
            params['product']?.toString() ?? '',
          );
        case 'det_2x2_anti_diagonal_title':
          return l10n.det_2x2_anti_diagonal_title;
        case 'det_2x2_anti_diagonal_desc':
          return l10n.det_2x2_anti_diagonal_desc(
            params['b']?.toString() ?? '',
            params['c']?.toString() ?? '',
            params['product']?.toString() ?? '',
          );
        case 'det_2x2_final_title':
          return l10n.det_2x2_final_title;
        case 'det_2x2_final_desc':
          return l10n.det_2x2_final_desc(
            params['anti']?.toString() ?? '',
            params['det']?.toString() ?? '',
            params['main']?.toString() ?? '',
          );
        case 'det_sarrus_pos_title':
          return l10n.det_sarrus_pos_title;
        case 'det_sarrus_pos_desc':
          return l10n.det_sarrus_pos_desc(
            params['p1']?.toString() ?? '',
            params['p2']?.toString() ?? '',
            params['p3']?.toString() ?? '',
            params['total']?.toString() ?? '',
          );
        case 'det_sarrus_neg_title':
          return l10n.det_sarrus_neg_title;
        case 'det_sarrus_neg_desc':
          return l10n.det_sarrus_neg_desc(
            params['n1']?.toString() ?? '',
            params['n2']?.toString() ?? '',
            params['n3']?.toString() ?? '',
            params['total']?.toString() ?? '',
          );
        case 'det_sarrus_final_title':
          return l10n.det_sarrus_final_title;
        case 'det_sarrus_final_desc':
          return l10n.det_sarrus_final_desc(
            params['det']?.toString() ?? '',
            params['neg']?.toString() ?? '',
            params['pos']?.toString() ?? '',
          );
        case 'det_singular_column_title':
          return l10n.det_singular_column_title;
        case 'det_singular_column_desc':
          return l10n.det_singular_column_desc(params['col'] ?? 0);
        case 'det_row_swap_title':
          return l10n.det_row_swap_title;
        case 'det_row_swap_desc':
          return l10n.det_row_swap_desc(
            params['rowA'] ?? 0,
            params['rowB'] ?? 0,
          );
        case 'det_diagonal_product_title':
          return l10n.det_diagonal_product_title;
        case 'det_diagonal_product_desc':
          return l10n.det_diagonal_product_desc(
            params['det']?.toString() ?? '',
            params['diagonals']?.toString() ?? '',
            params['sign']?.toString() ?? '',
          );

        // Inverse keys
        case 'inverse_singular_title':
          return l10n.inverse_singular_title;
        case 'inverse_singular_desc':
          return l10n.inverse_singular_desc;
        case 'inverse_2x2_det_title':
          return l10n.inverse_2x2_det_title;
        case 'inverse_2x2_det_desc':
          return l10n.inverse_2x2_det_desc(
            params['det']?.toString() ?? '',
            params['formula']?.toString() ?? '',
          );
        case 'inverse_2x2_adjoint_title':
          return l10n.inverse_2x2_adjoint_title;
        case 'inverse_2x2_adjoint_desc':
          return l10n.inverse_2x2_adjoint_desc;
        case 'inverse_2x2_scale_title':
          return l10n.inverse_2x2_scale_title;
        case 'inverse_2x2_scale_desc':
          return l10n.inverse_2x2_scale_desc(
            params['factor']?.toString() ?? '',
          );
        case 'inverse_block_init_title':
          return l10n.inverse_block_init_title;
        case 'inverse_block_init_desc':
          return l10n.inverse_block_init_desc(params['n'] ?? 0);
        case 'inverse_block_extract_title':
          return l10n.inverse_block_extract_title;
        case 'inverse_block_extract_desc':
          return l10n.inverse_block_extract_desc;

        // Arithmetic keys
        case 'arithmetic_add_cell_title':
          return l10n.arithmetic_add_cell_title(
            params['col'] ?? 0,
            params['row'] ?? 0,
          );
        case 'arithmetic_add_cell_desc':
          return l10n.arithmetic_add_cell_desc(
            params['formula']?.toString() ?? '',
          );
        case 'arithmetic_mult_cell_title':
          return l10n.arithmetic_mult_cell_title(
            params['col'] ?? 0,
            params['row'] ?? 0,
          );
        case 'arithmetic_mult_cell_desc':
          return l10n.arithmetic_mult_cell_desc(
            params['col'] ?? 0,
            params['formula']?.toString() ?? '',
            params['row'] ?? 0,
          );

        // Linear systems
        case 'system_inconsistent_title':
          return l10n.system_inconsistent_title(params['row'] ?? 0);
        case 'system_inconsistent_desc':
          return l10n.system_inconsistent_desc(
            params['row'] ?? 0,
            params['val']?.toString() ?? '',
          );
        case 'system_unique_title':
          return l10n.system_unique_title;
        case 'system_unique_desc':
          return l10n.system_unique_desc(params['solution']?.toString() ?? '');
        case 'system_infinite_title':
          return l10n.system_infinite_title(params['count'] ?? 0);
        case 'system_infinite_desc':
          return l10n.system_infinite_desc(
            params['freeVars']?.toString() ?? '',
            params['params']?.toString() ?? '',
          );

        // Rank-nullity
        case 'rank_nullity_title':
          return l10n.rank_nullity_title(
            params['nullity'] ?? 0,
            params['rank'] ?? 0,
          );
        case 'rank_nullity_desc':
          return l10n.rank_nullity_desc(
            params['cols'] ?? 0,
            params['nullity'] ?? 0,
            params['rank'] ?? 0,
          );

        case 'eigen_vector_approx_title':
          return l10n.eigen_vector_approx_title(
            params['index'].toString(),
            params['lambda'].toString(),
          );
        case 'eigen_vector_approx_desc':
          return l10n.eigen_vector_approx_desc(
            params['lambda'].toString(),
            params['vector'].toString(),
          );
        // Eigen
        case 'eigen_char_poly_title':
          return l10n.eigen_char_poly_title;
        case 'eigen_trace_det_desc':
          return l10n.eigen_trace_det_desc(
            params['det']?.toString() ?? '',
            params['trace']?.toString() ?? '',
          );
        case 'eigen_complex_title':
          return l10n.eigen_complex_title;
        case 'eigen_complex_desc':
          return l10n.eigen_complex_desc(
            params['poly']?.toString() ?? '',
            params['roots']?.toString() ?? '',
          );
        case 'eigen_roots_title':
          return l10n.eigen_roots_title;
        case 'eigen_roots_approx_desc':
          return l10n.eigen_roots_approx_desc(
            params['poly']?.toString() ?? '',
            params['roots']?.toString() ?? '',
          );
        case 'eigen_roots_desc':
          return l10n.eigen_roots_desc(
            params['poly']?.toString() ?? '',
            params['roots']?.toString() ?? '',
          );
        case 'eigen_vector_title':
          return l10n.eigen_vector_title(
            params['index'] ?? 0,
            params['lambda']?.toString() ?? '',
          );
        case 'eigen_vector_desc':
          return l10n.eigen_vector_desc(
            params['lambda']?.toString() ?? '',
            params['vector']?.toString() ?? '',
          );
        case 'eigen_3x3_poly_desc':
          return l10n.eigen_3x3_poly_desc(
            params['det']?.toString() ?? '',
            params['poly']?.toString() ?? '',
            params['trace']?.toString() ?? '',
          );
        case 'eigen_irrational_desc':
          return l10n.eigen_irrational_desc(params['poly']?.toString() ?? '');

        // LU Decomposition
        case 'lu_init_title':
          return l10n.lu_init_title;
        case 'lu_init_desc':
          return l10n.lu_init_desc;
        case 'lu_swap_desc':
          return l10n.lu_swap_desc(params['rowA'] ?? 0, params['rowB'] ?? 0);
        case 'lu_elim_title':
          return l10n.lu_elim_title(
            params['source'] ?? 0,
            params['target'] ?? 0,
          );
        case 'lu_elim_desc':
          return l10n.lu_elim_desc(
            params['multiplier']?.toString() ?? '',
            params['source'] ?? 0,
            params['target'] ?? 0,
          );
        case 'lu_final_title':
          return l10n.lu_final_title;
        case 'lu_final_desc':
          return l10n.lu_final_desc;

        default:
          return key;
      }
    } catch (_) {
      return key;
    }
  }
}
