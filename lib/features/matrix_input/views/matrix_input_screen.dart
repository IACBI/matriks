import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/generated/app_localizations.dart';

import 'package:matrix_engine/matrix_engine.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_numpad.dart';
import '../../../core/widgets/matrix_bracket.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../step_player/step_text.dart';
import '../../step_player/views/step_player_screen.dart';
import '../../topics/models/topic_item.dart';
import '../matrix_input_cubit.dart';
import '../models/matrix_input_state.dart';

class MatrixInputScreen extends StatelessWidget {
  final TopicItem topic;

  const MatrixInputScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MatrixInputCubit(topic),
      child: _MatrixInputView(topic: topic),
    );
  }
}

class _MatrixInputView extends StatefulWidget {
  final TopicItem topic;

  const _MatrixInputView({required this.topic});

  @override
  State<_MatrixInputView> createState() => _MatrixInputViewState();
}

class _MatrixInputViewState extends State<_MatrixInputView> {
  bool _isSolving = false;
  String? _inputError;
  (int, int, int)? _invalidCell;
  TopicItem get topic => widget.topic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<MatrixInputCubit, MatrixInputState>(
      builder: (context, state) {
        final cubit = context.read<MatrixInputCubit>();
        final isA = state.activeMatrix == 0;
        final currentRows = isA ? state.rowsA : state.rowsB;
        final currentCols = isA ? state.colsA : state.colsB;
        final currentData = isA ? state.dataA : state.dataB;
        String? visibleError;
        final invalid = _invalidCell;
        if (invalid != null) {
          final data = invalid.$1 == 0 ? state.dataA : state.dataB;
          if (invalid.$2 < data.length &&
              invalid.$3 < data[invalid.$2].length &&
              Rational.tryParse(data[invalid.$2][invalid.$3]) == null) {
            visibleError = _inputError;
          }
        }

        KeyEventResult handleKeyEvent(KeyEvent event) {
          if (event is! KeyDownEvent || _isSolving) {
            return KeyEventResult.ignored;
          }
          if (HardwareKeyboard.instance.isControlPressed ||
              HardwareKeyboard.instance.isMetaPressed) {
            return KeyEventResult.ignored;
          }
          final key = event.logicalKey;

          if (key == LogicalKeyboardKey.enter ||
              key == LogicalKeyboardKey.numpadEnter) {
            _solveAndAnimate(context, state);
          } else if (key == LogicalKeyboardKey.backspace) {
            cubit.onBackspace();
          } else if (key == LogicalKeyboardKey.delete) {
            cubit.onClear();
          } else if (key == LogicalKeyboardKey.arrowRight) {
            cubit.onNextCell();
          } else if (key == LogicalKeyboardKey.arrowLeft) {
            cubit.onPrevCell();
          } else if (key == LogicalKeyboardKey.arrowDown) {
            final nextRow = (state.focusedRow + 1) % currentRows;
            cubit.setFocus(nextRow, state.focusedCol);
          } else if (key == LogicalKeyboardKey.arrowUp) {
            final prevRow = (state.focusedRow - 1 + currentRows) % currentRows;
            cubit.setFocus(prevRow, state.focusedCol);
          } else if (event.character != null && event.character!.isNotEmpty) {
            final ch = event.character!;
            if (ch.length != 1 || !'0123456789-./'.contains(ch)) {
              return KeyEventResult.ignored;
            }
            cubit.onKeyPressed(ch);
          } else {
            return KeyEventResult.ignored;
          }
          return KeyEventResult.handled;
        }

        final minCols = topic.isAugmentedSystem ? 2 : 1;
        final canDecrementRows =
            currentRows > (topic.type == TopicType.eigen ? 2 : 1) &&
            (isA ||
                topic.type == TopicType.add ||
                topic.type != TopicType.multiply);
        final canIncrementRows =
            currentRows < (topic.type == TopicType.eigen ? 3 : 5) &&
            (isA ||
                topic.type == TopicType.add ||
                topic.type != TopicType.multiply);
        final canDecrementCols = currentCols > minCols;
        final canIncrementCols = currentCols < 5;

        // B's rows follow A's columns in a product; say why they are locked.
        final rowsLocked = !isA && topic.type == TopicType.multiply;

        Widget buildDimensionRow() {
          final row = Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 8,
            children: [
              Text(
                '${l10n.size}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildDimensionChip(
                context,
                label: '$currentRows',
                canDecrement: canDecrementRows,
                canIncrement: canIncrementRows,
                decrementTooltip: l10n.removeRow,
                incrementTooltip: l10n.addRow,
                onDecrement: () {
                  if (isA || topic.type == TopicType.add) {
                    cubit.setDimensionsA(currentRows - 1, currentCols);
                  } else {
                    cubit.setDimensionsB(currentRows - 1, currentCols);
                  }
                },
                onIncrement: () {
                  if (isA || topic.type == TopicType.add) {
                    cubit.setDimensionsA(currentRows + 1, currentCols);
                  } else {
                    cubit.setDimensionsB(currentRows + 1, currentCols);
                  }
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '×',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              _buildDimensionChip(
                context,
                label: '$currentCols',
                enabled: !topic.requiresSquare,
                canDecrement: canDecrementCols,
                canIncrement: canIncrementCols,
                decrementTooltip: l10n.removeColumn,
                incrementTooltip: l10n.addColumn,
                onDecrement: () {
                  if (isA || topic.type == TopicType.add) {
                    cubit.setDimensionsA(currentRows, currentCols - 1);
                  } else {
                    cubit.setDimensionsB(currentRows, currentCols - 1);
                  }
                },
                onIncrement: () {
                  if (isA || topic.type == TopicType.add) {
                    cubit.setDimensionsA(currentRows, currentCols + 1);
                  } else {
                    cubit.setDimensionsB(currentRows, currentCols + 1);
                  }
                },
              ),
            ],
          );
          if (!rowsLocked) return row;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              row,
              const SizedBox(height: 6),
              Text(
                l10n.multiplyRowsLocked,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          );
        }

        void applyPreset(VoidCallback preset) {
          preset();
          final messenger = ScaffoldMessenger.of(context);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(l10n.presetApplied(isA ? 'A' : 'B')),
                action: SnackBarAction(
                  label: l10n.undo,
                  onPressed: cubit.undoPreset,
                ),
              ),
            );
        }

        Widget buildMatrixCanvas() {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    visibleError ?? l10n.inputHelp,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: visibleError != null
                          ? theme.colorScheme.error
                          : null,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MatrixBracket(
                              height: currentRows * 60 - 8,
                              isLeft: true,
                            ),
                            const SizedBox(width: 4),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(currentRows, (r) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(currentCols, (c) {
                                    final isFocused =
                                        r == state.focusedRow &&
                                        c == state.focusedCol;
                                    final cellVal = currentData[r][c];
                                    final hasError =
                                        _invalidCell ==
                                            (state.activeMatrix, r, c) &&
                                        Rational.tryParse(cellVal) == null;

                                    final cellWidget = Semantics(
                                      label: l10n.inputCell(
                                        isA ? 'A' : 'B',
                                        r + 1,
                                        c + 1,
                                      ),
                                      value: cellVal,
                                      hint: hasError ? _inputError : null,
                                      excludeSemantics: true,
                                      onTap: () => cubit.setFocus(r, c),
                                      selected: isFocused,
                                      button: true,
                                      child: InkWell(
                                        onTap: () => cubit.setFocus(r, c),
                                        child: AnimatedContainer(
                                          duration: AppTheme.motion(
                                            context,
                                            150,
                                          ),
                                          width: 58,
                                          height: 52,
                                          margin: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: isFocused
                                                ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withValues(
                                                        alpha: isDark
                                                            ? 0.3
                                                            : 0.15,
                                                      )
                                                : isDark
                                                ? AppTheme.surfaceVariantDark
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              AppTheme.radiusSm,
                                            ),
                                            border: Border.all(
                                              color: hasError
                                                  ? theme.colorScheme.error
                                                  : isFocused
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                  : isDark
                                                  ? AppTheme.borderDark
                                                  : AppTheme.borderSubtleLight,
                                              width: isFocused ? 2.2 : 1.2,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Text(
                                                cellVal.isEmpty ? '0' : cellVal,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );

                                    if (topic.isAugmentedSystem &&
                                        c == currentCols - 2) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          cellWidget,
                                          Container(
                                            width: 2,
                                            height: 42,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? AppTheme.accentIndigo
                                                  : const Color(0xFF818CF8),
                                              borderRadius:
                                                  BorderRadius.circular(1),
                                            ),
                                          ),
                                        ],
                                      );
                                    }

                                    return cellWidget;
                                  }),
                                );
                              }),
                            ),
                            const SizedBox(width: 4),
                            MatrixBracket(
                              height: currentRows * 60 - 8,
                              isLeft: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        Widget buildSolveButton() {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSolving
                    ? null
                    : () => _solveAndAnimate(context, state),
                icon: _isSolving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow_rounded),
                label: Text(_isSolving ? (l10n.calculating) : (l10n.calculate)),
              ),
            ),
          );
        }

        return Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (!node.hasPrimaryFocus &&
                (event.logicalKey == LogicalKeyboardKey.enter ||
                    event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
              return KeyEventResult.ignored;
            }
            return handleKeyEvent(event);
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(topic.title(l10n)),
              actions: [
                IconButton(
                  tooltip: l10n.presetRandom,
                  icon: const Icon(Icons.casino_outlined),
                  onPressed: () => applyPreset(cubit.presetRandom),
                ),
                IconButton(
                  tooltip: l10n.presetIdentity,
                  icon: const Icon(Icons.grid_3x3),
                  onPressed: () => applyPreset(cubit.presetIdentity),
                ),
                IconButton(
                  tooltip: l10n.presetClear,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => applyPreset(cubit.presetClear),
                ),
              ],
            ),
            body: SafeArea(
              child: AbsorbPointer(
                absorbing: _isSolving,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isLandscape =
                        MediaQuery.of(context).orientation ==
                        Orientation.landscape;
                    final isWide =
                        constraints.maxWidth >= 960 &&
                        MediaQuery.textScalerOf(context).scale(1) <= 1.3;

                    if (isWide) {
                      return Row(
                        children: [
                          // Left: Dimension Selector + Matrix Canvas
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: buildMatrixCanvas(),
                            ),
                          ),
                          VerticalDivider(
                            width: 1,
                            color: isDark
                                ? AppTheme.borderDark
                                : AppTheme.borderLight,
                          ),
                          // Right: Dual matrix tabs, Solve Button & Compact CustomNumpad
                          Expanded(
                            flex: 4,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (topic.isDualMatrix) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 4.0,
                                      ),
                                      child: SegmentedButton<int>(
                                        segments: [
                                          ButtonSegment(
                                            value: 0,
                                            label: Text(l10n.matrixA),
                                          ),
                                          ButtonSegment(
                                            value: 1,
                                            label: Text(l10n.matrixB),
                                          ),
                                        ],
                                        selected: {state.activeMatrix},
                                        onSelectionChanged: (set) =>
                                            cubit.selectMatrix(set.first),
                                      ),
                                    ),
                                  ],
                                  buildDimensionRow(),
                                  const SizedBox(height: 16),
                                  buildSolveButton(),
                                  CustomNumpad(
                                    keyHeight:
                                        isLandscape &&
                                            constraints.maxHeight < 420
                                        ? 36.0
                                        : 42.0,
                                    onKeyPressed: cubit.onKeyPressed,
                                    onBackspace: cubit.onBackspace,
                                    onClear: cubit.onClear,
                                    onNextCell: cubit.onNextCell,
                                    onNextRow: cubit.onNextRow,
                                    onPrevCell: cubit.onPrevCell,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    // Portrait mode layout
                    final editorChildren = <Widget>[
                      // Top Settings: Dimension Selector & Dual Matrix Switcher
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            if (topic.isDualMatrix) ...[
                              SegmentedButton<int>(
                                segments: [
                                  ButtonSegment(
                                    value: 0,
                                    label: Text(l10n.matrixA),
                                  ),
                                  ButtonSegment(
                                    value: 1,
                                    label: Text(l10n.matrixB),
                                  ),
                                ],
                                selected: {state.activeMatrix},
                                onSelectionChanged: (set) =>
                                    cubit.selectMatrix(set.first),
                              ),
                              const SizedBox(height: 8),
                            ],
                            buildDimensionRow(),
                          ],
                        ),
                      ),

                      // Matrix Grid input canvas
                      SizedBox(
                        height:
                            currentRows * 64 +
                            110 * MediaQuery.textScalerOf(context).scale(1),
                        child: buildMatrixCanvas(),
                      ),

                      // Solve Button
                      buildSolveButton(),

                      // Compact Custom Numpad
                      CustomNumpad(
                        keyHeight: constraints.maxHeight < 620 ? 38.0 : 46.0,
                        onKeyPressed: cubit.onKeyPressed,
                        onBackspace: cubit.onBackspace,
                        onClear: cubit.onClear,
                        onNextCell: cubit.onNextCell,
                        onNextRow: cubit.onNextRow,
                        onPrevCell: cubit.onPrevCell,
                      ),
                    ];
                    return ListView(children: editorChildren);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDimensionChip(
    BuildContext context, {
    required String label,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    bool enabled = true,
    bool canDecrement = true,
    bool canIncrement = true,
    String? decrementTooltip,
    String? incrementTooltip,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceVariantDark : AppTheme.borderLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderSubtleLight,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: decrementTooltip,
            onPressed: (enabled && canDecrement) ? onDecrement : null,
            icon: const Icon(Icons.remove, size: 16),
            visualDensity: VisualDensity.standard,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          IconButton(
            tooltip: incrementTooltip,
            onPressed: (enabled && canIncrement) ? onIncrement : null,
            icon: const Icon(Icons.add, size: 16),
            visualDensity: VisualDensity.standard,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        ],
      ),
    );
  }

  void _solveAndAnimate(BuildContext context, MatrixInputState state) async {
    if (_isSolving) return;
    final l10n = AppLocalizations.of(context)!;
    for (var index = 0; index < (topic.isDualMatrix ? 2 : 1); index++) {
      final data = index == 0 ? state.dataA : state.dataB;
      for (var r = 0; r < data.length; r++) {
        for (var c = 0; c < data[r].length; c++) {
          if (Rational.tryParse(data[r][c]) == null) {
            context.read<MatrixInputCubit>().setFocus(r, c, index);
            _invalidCell = (index, r, c);
            setState(
              () => _inputError = l10n.inputInvalid(
                index == 0 ? 'A' : 'B',
                r + 1,
                c + 1,
              ),
            );
            return;
          }
        }
      }
    }
    setState(() {
      _isSolving = true;
      _inputError = null;
      _invalidCell = null;
    });
    StepSolution solution;
    try {
      final matrixA = state.toMatrixA();
      final matrixB = topic.isDualMatrix ? state.toMatrixB() : matrixA;
      switch (topic.type) {
        case TopicType.gauss:
          solution = await compute(_solveGaussTask, matrixA);
          break;
        case TopicType.rref:
          solution = await compute(_solveRrefTask, matrixA);
          break;
        case TopicType.linearSystems:
          solution = await compute(_solveLinearSystemsTask, matrixA);
          break;
        case TopicType.determinant:
          solution = await compute(_solveDeterminantTask, matrixA);
          break;
        case TopicType.inverse:
          solution = await compute(_solveInverseTask, matrixA);
          break;
        case TopicType.rankNullity:
          solution = await compute(_solveRankNullityTask, matrixA);
          break;
        case TopicType.eigen:
          solution = await compute(_solveEigenTask, matrixA);
          break;
        case TopicType.lu:
          solution = await compute(_solveLuTask, matrixA);
          break;
        case TopicType.transform2d:
        case TopicType.practice:
          return;
        case TopicType.add:
          solution = await compute(_solveAddTask, (matrixA, matrixB));
          break;
        case TopicType.multiply:
          solution = await compute(_solveMultiplyTask, (matrixA, matrixB));
          break;
      }
    } catch (error, stack) {
      // An exception text is for developers; the learner gets a plain message.
      debugPrint('Solve failed: $error\n$stack');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.solveFallbackError)));
      return;
    } finally {
      if (mounted) setState(() => _isSolving = false);
    }

    if (!context.mounted) return;
    // A preset's undo notice belongs to the editor; left open it would sit
    // over the player's controls on the next page.
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    if (!solution.isSuccess && solution.steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            solution.errorMessageKey != null
                ? localizedSolverError(l10n, solution.errorMessageKey!)
                : l10n.solveFallbackError,
          ),
        ),
      );
      return;
    }

    final settings = context.read<SettingsCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StepPlayerScreen(
          solution: solution,
          topicTitle: topic.title(l10n),
          onOwnMatrix: () => Navigator.of(context).pop(),
          onLessonComplete: () => settings.completeTopic(topic.type.name),
        ),
      ),
    );
  }
}

// Background isolate top-level runner functions
StepSolution _solveGaussTask(Matrix m) =>
    GaussJordanSolver.solve(m, const EliminationOptions(toRref: false));

StepSolution _solveRrefTask(Matrix m) =>
    GaussJordanSolver.solve(m, const EliminationOptions(toRref: true));

StepSolution _solveLinearSystemsTask(Matrix m) => LinearSystemsSolver.solve(m);

StepSolution _solveDeterminantTask(Matrix m) => DeterminantSolver.solve(m);

StepSolution _solveInverseTask(Matrix m) => InverseSolver.solve(m);

StepSolution _solveRankNullityTask(Matrix m) => RankNullitySolver.solve(m);

StepSolution _solveEigenTask(Matrix m) => EigenSolver.solve(m);

StepSolution _solveLuTask(Matrix m) => LUDecompositionSolver.solve(m);

StepSolution _solveAddTask((Matrix, Matrix) pair) =>
    MatrixArithmeticSolver.add(pair.$1, pair.$2);

StepSolution _solveMultiplyTask((Matrix, Matrix) pair) =>
    MatrixArithmeticSolver.multiply(pair.$1, pair.$2);
