import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:matrix_engine/matrix_engine.dart';

import '../../../core/number_format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/math_text.dart';
import '../../../core/widgets/matrix_bracket.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'determinant_lines_painter.dart';
import 'matrix_cell_widget.dart';
import 'multiplication_sources.dart';
import 'row_swap_brackets_painter.dart';
import 'instruction_timeline.dart';
import 'instruction_lesson.dart';

/// Geometry that must stay the same for every step of one solution.
///
/// Without it each step sizes itself: a swap is narrower than an elimination
/// that reserves room for its cell expression, so the matrix jumps between
/// steps. The player measures the whole solution once and passes this.
class MatrixLayoutHint {
  /// Widest numerator, denominator or decimal text in any step.
  final int minimumDigits;

  /// Some step shows an arithmetic expression inside a cell.
  final bool reserveOperationWidth;

  /// Some step swaps rows and draws its connector beside the matrix.
  final bool reserveSwapLane;

  const MatrixLayoutHint({
    this.minimumDigits = 1,
    this.reserveOperationWidth = false,
    this.reserveSwapLane = false,
  });

  factory MatrixLayoutHint.forSolution(
    StepSolution solution, {
    required bool decimal,
  }) {
    var digits = 1;
    var operation = false;
    var swap = false;
    for (final step in solution.steps) {
      for (final snapshot in [step.matrixBefore, step.matrixAfter]) {
        digits = math.max(digits, _widestEntry(snapshot, decimal));
      }
      final t = step.transformation;
      operation =
          operation ||
          t is RowEliminationTransformation ||
          t is RowScaleTransformation ||
          t is MatrixElementAdditionTransformation ||
          t is MatrixElementMultiplicationTransformation ||
          t is AdjugateTransformation ||
          t is MatrixScaleTransformation;
      swap = swap || t is RowSwapTransformation;
    }
    return MatrixLayoutHint(
      minimumDigits: digits,
      reserveOperationWidth: operation,
      reserveSwapLane: swap,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MatrixLayoutHint &&
      other.minimumDigits == minimumDigits &&
      other.reserveOperationWidth == reserveOperationWidth &&
      other.reserveSwapLane == reserveSwapLane;

  @override
  int get hashCode =>
      Object.hash(minimumDigits, reserveOperationWidth, reserveSwapLane);
}

int _widestEntry(MatrixSnapshot snapshot, bool decimal) {
  var digits = 1;
  for (var r = 0; r < snapshot.rows; r++) {
    for (var c = 0; c < snapshot.cols; c++) {
      final value = snapshot.get(r, c);
      digits = math.max(
        digits,
        decimal
            ? decimalWidth(value)
            : math.max(
                value.num.toString().length,
                value.den.toString().length,
              ),
      );
    }
  }
  return digits;
}

class MatrixDisplayGrid extends StatefulWidget {
  final String? sceneFormula;
  final bool staticStep;
  final bool showExplanation;
  final MatrixSnapshot snapshot;
  final MatrixSnapshot? snapshotBefore;
  final List<CellHighlight> highlights;
  final List<SubCalculation> subCalculations;
  final StepTransformation? transformation;
  final bool isDecimalView;
  final double playbackSpeed;
  final int? stepIndex;
  final bool? isAnimating;
  final int animationRevision;
  final ValueChanged<int>? onAnimationCompleted;
  final VoidCallback? onScrubStart;
  final VoidCallback? onReplay;
  final void Function(int row, int col)? onCellTap;
  final MatrixLayoutHint? layoutHint;

  const MatrixDisplayGrid({
    this.sceneFormula,
    this.staticStep = false,
    this.showExplanation = true,
    super.key,
    required this.snapshot,
    this.snapshotBefore,
    required this.highlights,
    this.subCalculations = const [],
    this.transformation,
    this.isDecimalView = false,
    this.playbackSpeed = 1.0,
    this.stepIndex,
    this.isAnimating,
    this.animationRevision = 0,
    this.onAnimationCompleted,
    this.onScrubStart,
    this.onReplay,
    this.onCellTap,
    this.layoutHint,
  });

  @override
  State<MatrixDisplayGrid> createState() => _MatrixDisplayGridState();
}

class _MatrixDisplayGridState extends State<MatrixDisplayGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late InstructionTimeline _timeline;
  final Map<(InstructionPhase, int, bool), Widget> _explanationCache = {};
  final Map<int, Widget> _sourceCache = {};
  bool _scrubbing = false;
  bool _completionSent = false;
  final Map<Object, Widget> _cellCache = {};
  final Map<int, ({List<Widget> cells, Widget row})> _rowCache = {};
  final Map<(int, int, bool), List<Widget>> _stageRows = {};
  final ScrollController _matrixScroll = ScrollController();
  (int, int)? _followedColumn;

  double _cellWidth = 88;
  double _cellHeight = 64;
  double _fontSize = 20;
  double get cellWidth => _cellWidth;
  double get cellHeight => _cellHeight;

  InstructionTimeline _timelineFor(MatrixDisplayGrid grid) =>
      InstructionTimeline.forTransformation(
        grid.transformation,
        columns: changingColumns(
          grid.transformation,
          grid.snapshotBefore,
          grid.snapshot.cols,
        ).length,
        cells: grid.snapshot.rows * grid.snapshot.cols,
      );

  bool get _reserveSwapLane =>
      widget.transformation is RowSwapTransformation ||
      (widget.layoutHint?.reserveSwapLane ?? false);

  /// Shown in every mode, including the recap step, so the Sarrus diagonals
  /// stay straight and the matrix keeps its width across the three steps.
  bool get _showSarrusCopies =>
      widget.transformation is DeterminantSarrusTransformation &&
      widget.snapshot.rows == 3 &&
      widget.snapshot.cols == 3;

  /// Horizontal space between the last real column and the first copied
  /// column of a Sarrus scene: bracket margin, bracket and a gap.
  static const _sarrusGap = 4.0 + 10 + 8;

  double _measureCellWidth() {
    var digits = widget.layoutHint?.minimumDigits ?? 1;
    for (final snapshot in [widget.snapshot, widget.snapshotBefore]) {
      if (snapshot == null) continue;
      digits = math.max(digits, _widestEntry(snapshot, widget.isDecimalView));
    }
    return (32.0 + digits * _fontSize * .65).clamp(52.0, 400.0) *
        MediaQuery.textScalerOf(context).scale(1);
  }

  bool get _running => !widget.staticStep && (widget.isAnimating ?? true);

  @override
  void initState() {
    super.initState();
    _timeline = _timelineFor(widget);
    _animController = AnimationController(
      vsync: this,
      animationBehavior: AnimationBehavior.preserve,
      duration: _timeline.duration(widget.playbackSpeed),
    )..addStatusListener(_statusChanged);
    _scheduleStart();
  }

  void _statusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed || _scrubbing || _completionSent) {
      return;
    }
    _completionSent = true;
    final revision = widget.animationRevision;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.animationRevision == revision && !_scrubbing) {
        widget.onAnimationCompleted?.call(revision);
      }
    });
  }

  void _scheduleStart() {
    final revision = widget.animationRevision;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.animationRevision != revision) return;
      _completionSent = false;
      _animController.value = widget.staticStep ? 1 : 0;
      if (_running) _animController.forward();
    });
  }

  @override
  void didUpdateWidget(covariant MatrixDisplayGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    _timeline = _timelineFor(widget);
    _cellCache.clear();
    _rowCache.clear();
    _explanationCache.clear();
    _sourceCache.clear();
    _stageRows.clear();
    _followedColumn = null;
    _animController.duration = _timeline.duration(widget.playbackSpeed);
    if (widget.staticStep != oldWidget.staticStep ||
        widget.animationRevision != oldWidget.animationRevision ||
        widget.snapshot != oldWidget.snapshot ||
        widget.stepIndex != oldWidget.stepIndex) {
      _scrubbing = false;
      _animController.stop();
      _scheduleStart();
      return;
    }
    if (widget.playbackSpeed != oldWidget.playbackSpeed) {
      _animController.duration = _timeline.duration(widget.playbackSpeed);
      if (_animController.isAnimating) _animController.forward();
    }
    if (_running && !(oldWidget.isAnimating ?? true)) {
      _scrubbing = false;
      _completionSent = false;
      if (_animController.value == 1) _animController.value = 0;
      _animController.forward();
    } else if (!_running) {
      _animController.stop();
    }
  }

  void _onScrub(double value) {
    _scrubbing = true;
    _animController.stop();
    widget.onScrubStart?.call();
    _animController.value = value.clamp(0.0, 1.0);
  }

  void _replay() {
    if (widget.onReplay != null) {
      widget.onReplay!();
      return;
    }
    _scrubbing = false;
    _completionSent = false;
    _animController.forward(from: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cellCache.clear();
    _rowCache.clear();
    _explanationCache.clear();
    _sourceCache.clear();
    _stageRows.clear();
    _followedColumn = null;
  }

  @override
  void dispose() {
    _matrixScroll.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: _buildLayout);

  Widget _buildLayout(BuildContext context, BoxConstraints constraints) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final available = constraints.maxWidth;
    final extras =
        64 * scale +
        (_reserveSwapLane ? 20 : 0) +
        (widget.snapshot.augmentedColIndex != null ? 10 : 0);
    final previousGeometry = (_cellWidth, _cellHeight, _fontSize);
    _fontSize = 22;
    var naturalWidth = _measureCellWidth();
    if (naturalWidth * widget.snapshot.cols + extras > available) {
      _fontSize = 18;
      naturalWidth = _measureCellWidth();
    }
    final preferredWidth = available.isFinite
        ? ((available - extras) / widget.snapshot.cols).clamp(
            52 * scale,
            96 * scale,
          )
        : 88 * scale;
    _cellWidth = math.max(naturalWidth, preferredWidth);
    final transformation = widget.transformation;
    final hasCellCalculation =
        transformation is RowEliminationTransformation ||
        transformation is RowScaleTransformation ||
        transformation is MatrixElementAdditionTransformation ||
        transformation is MatrixElementMultiplicationTransformation ||
        transformation is AdjugateTransformation ||
        transformation is MatrixScaleTransformation;
    final reserveOperation =
        widget.layoutHint?.reserveOperationWidth ?? hasCellCalculation;
    if (reserveOperation &&
        !widget.staticStep &&
        !MediaQuery.disableAnimationsOf(context)) {
      // Reserve space for a readable operation and keep geometry stable through its result.
      _cellWidth = math.max(_cellWidth, 120 * scale);
    }
    _cellHeight = 64 * scale;
    if (previousGeometry != (_cellWidth, _cellHeight, _fontSize)) {
      _cellCache.clear();
      _rowCache.clear();
      _stageRows.clear();
    }
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final dividerCol = widget.snapshot.augmentedColIndex;
    final gridHeight = widget.snapshot.rows * cellHeight;
    final bracketHeight = (widget.snapshot.rows * cellHeight) - 8.0;
    final gridWidth = widget.snapshot.cols * cellWidth;
    final reduceMotion =
        widget.staticStep || MediaQuery.disableAnimationsOf(context);
    final sarrusCopies = _showSarrusCopies;
    final trans = widget.transformation;
    final rowLabels = List.generate(
      widget.snapshot.rows,
      (r) => _buildRowLabel(r, isDark),
    );
    final lesson = InstructionLesson.forStep(
      transformation: trans,
      after: widget.snapshot,
      before: widget.snapshotBefore,
      l10n: l10n,
    );
    final termCount = trans is MatrixElementMultiplicationTransformation
        ? trans.rowElements.length
        : lesson.progressiveCount;
    final changing = changingColumns(
      trans,
      widget.snapshotBefore,
      widget.snapshot.cols,
    );
    final cellCount = widget.snapshot.rows * widget.snapshot.cols;
    // How many discrete moments the operation has; cells only change there.
    final stageCount =
        trans is RowEliminationTransformation || trans is RowScaleTransformation
        ? changing.length
        : trans is MatrixScaleTransformation
        ? cellCount
        : widget.snapshot.cols;
    final drawsDiagonals =
        (trans is DeterminantCrossProductTransformation && !trans.recap) ||
        (trans is DeterminantSarrusTransformation && !trans.recap);
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.sceneFormula != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: MathText(widget.sceneFormula!, fontSize: 20),
              ),
            ),
          if (trans is MatrixElementAdditionTransformation)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  MathText(
                    'A_{${trans.row + 1},${trans.col + 1}} = ${trans.left.toLatex()}',
                    fontSize: 20,
                  ),
                  MathText(
                    'B_{${trans.row + 1},${trans.col + 1}} = ${trans.right.toLatex()}',
                    fontSize: 20,
                  ),
                ],
              ),
            ),
          if (trans is MatrixElementMultiplicationTransformation)
            AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                final phase = _timeline.phase(_animController.value);
                final active =
                    !reduceMotion && phase == InstructionPhase.operation
                    ? (_timeline.operationProgress(_animController.value) *
                              trans.rowElements.length)
                          .floor()
                          .clamp(0, trans.rowElements.length - 1)
                    : -1;
                return _sourceCache.putIfAbsent(
                  active,
                  () => MultiplicationSources(
                    transformation: trans,
                    activeTerm: active,
                  ),
                );
              },
            ),
          if (trans is MatrixElementMultiplicationTransformation)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                l10n!.multiplicationOutput,
                style: theme.textTheme.labelLarge,
              ),
            ),
          if (trans != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildOperationBadge(trans, isDark),
              ),
            ),
          _buildMatrixViewport(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                final progress = reduceMotion
                    ? 1.0
                    : _timeline.operationProgress(_animController.value);
                // Numeric cells change at column boundaries, not on every frame.
                final stage = (progress * stageCount).floor();
                _followActiveColumn(trans, progress, reduceMotion, changing);
                final term = trans is MatrixElementMultiplicationTransformation
                    ? (progress * trans.rowElements.length).floor()
                    : 0;
                final rows = _stageRows.putIfAbsent(
                  (stage, term, progress > 0 && progress < 1),
                  () {
                    return List.generate(widget.snapshot.rows, (r) {
                      final cells = List.generate(
                        widget.snapshot.cols,
                        (c) => _buildCellAt(
                          r,
                          c,
                          trans,
                          progress,
                          isDark,
                          dividerCol,
                          reduceMotion,
                          changing,
                        ),
                      );
                      final previous = _rowCache[r];
                      final row =
                          previous != null && listEquals(previous.cells, cells)
                          ? previous.row
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: cells,
                            );
                      _rowCache[r] = (cells: cells, row: row);
                      return row;
                    });
                  },
                );
                return
                // Main Matrix Grid with Side Brackets and Animated Overlays
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Row Index Headers (R1, R2, ...) on the left (fixed grid coordinates)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(widget.snapshot.rows, (r) {
                        return SizedBox(
                          height: cellHeight,
                          child: Center(child: rowLabels[r]),
                        );
                      }),
                    ),
                    const SizedBox(width: 6),

                    // Left Swap Brackets Painter (for Row Swap)
                    if (trans is RowSwapTransformation)
                      CustomPaint(
                        size: Size(20, gridHeight),
                        painter: RowSwapBracketsPainter(
                          rowA: trans.rowA,
                          rowB: trans.rowB,
                          cellHeight: cellHeight,
                        ),
                      )
                    else if (_reserveSwapLane)
                      const SizedBox(width: 20),

                    // Left Matrix Bracket [
                    MatrixBracket(height: bracketHeight, isLeft: true),
                    const SizedBox(width: 4),

                    // Matrix Grid Cells with CustomPainter Overlay
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Base Cells Column
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(widget.snapshot.rows, (
                                r,
                              ) {
                                final rowOffset = _computeRowOffset(
                                  r,
                                  trans,
                                  progress,
                                  reduceMotion,
                                );
                                final rowWidget = rows[r];
                                if (trans is AdjugateTransformation &&
                                    !reduceMotion &&
                                    progress < 1) {
                                  return _adjugateRow(r, rowWidget, progress);
                                }

                                if (trans is! RowSwapTransformation ||
                                    reduceMotion) {
                                  return rowWidget;
                                }
                                return Transform.translate(
                                  offset: rowOffset,
                                  child: rowWidget,
                                );
                              }),
                            ),
                            // Sarrus: the first two columns written again to
                            // the right of the matrix, so every product runs
                            // along a straight diagonal.
                            if (sarrusCopies) ...[
                              const SizedBox(width: 4),
                              MatrixBracket(
                                height: bracketHeight,
                                isLeft: false,
                              ),
                              const SizedBox(width: 8),
                              _buildSarrusCopies(isDark),
                            ],
                          ],
                        ),

                        // Ghost Row Projection (Phase 1 of Row Elimination: R_t <- R_t - c*R_s)
                        if (trans is RowEliminationTransformation &&
                            !reduceMotion &&
                            progress < 0.45) ...[
                          _buildGhostRowOverlay(trans, progress, isDark),
                        ],

                        // Determinant Lines Overlay (2x2 and 3x3 Sarrus)
                        // Reduced motion and static steps draw every product
                        // of the step at once instead of tracing them.
                        if (drawsDiagonals) ...[
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                size: Size(gridWidth, gridHeight),
                                painter: DeterminantLinesPainter(
                                  rows: widget.snapshot.rows,
                                  cols: widget.snapshot.cols,
                                  cellWidth: cellWidth,
                                  cellHeight: cellHeight,
                                  transformation: trans!,
                                  progress: progress,
                                  showAll: reduceMotion,
                                  copiedColumnsGap: sarrusCopies
                                      ? _sarrusGap
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (!sarrusCopies) ...[
                      const SizedBox(width: 4),
                      // Right Matrix Bracket ]
                      MatrixBracket(height: bracketHeight, isLeft: false),
                    ],
                  ],
                );
              },
            ),
          ),
          // Steps without step-specific teaching text rely on the solver's
          // description; three placeholder phases would add nothing.
          if (widget.showExplanation && !lesson.generic)
            const SizedBox(height: 24),
          if (widget.showExplanation && !lesson.generic)
            AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                final phase = reduceMotion
                    ? InstructionPhase.result
                    : _timeline.phase(_animController.value);
                final progress = _timeline.operationProgress(
                  _animController.value,
                );
                final active = termCount <= 0
                    ? -1
                    : (progress * termCount).floor().clamp(0, termCount - 1);
                // Announcing every phase while the lesson plays would talk over
                // itself; the step title announces progress instead.
                final announce = !_running;
                return _explanationCache.putIfAbsent(
                  (phase, active, announce),
                  () => InstructionExplanation(
                    lesson: lesson,
                    phase: phase,
                    activeCalculation: active,
                    showAllPhases: reduceMotion,
                    announce: announce,
                  ),
                );
              },
            ),
          const SizedBox(height: 8),
          if (!widget.staticStep)
            ExpansionTile(
              key: const ValueKey('operation-inspector'),
              maintainState: true,
              tilePadding: EdgeInsets.zero,
              title: Text(
                l10n?.inspectOperation ?? 'Inspect this operation',
                style: theme.textTheme.labelLarge,
              ),
              onExpansionChanged: (open) {
                if (open) widget.onScrubStart?.call();
              },
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _animController,
                        builder: (context, _) => Slider(
                          key: const ValueKey('instruction-progress'),
                          semanticFormatterCallback: (value) =>
                              '${l10n?.instructionProgress ?? 'This operation'} ${(value * 100).round()}%',
                          value: _animController.value,
                          onChanged: _onScrub,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n?.replayAnimation ?? 'Replay animation',
                      onPressed: _replay,
                      icon: const Icon(Icons.replay_rounded),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMatrixViewport({required Widget child}) {
    return NotificationListener<ScrollStartNotification>(
      onNotification: (notification) {
        if (notification.dragDetails != null) widget.onScrubStart?.call();
        return false;
      },
      child: Scrollbar(
        controller: _matrixScroll,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _matrixScroll,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: 10),
          child: child,
        ),
      ),
    );
  }

  void _followActiveColumn(
    StepTransformation? transformation,
    double progress,
    bool reduced,
    List<int> changing,
  ) {
    if (!_running || _scrubbing) return;
    final column = switch (transformation) {
      MatrixElementMultiplicationTransformation t => t.targetCol,
      MatrixElementAdditionTransformation t => t.col,
      RowEliminationTransformation() || RowScaleTransformation() =>
        changing[(progress * changing.length).floor().clamp(
          0,
          changing.length - 1,
        )],
      MatrixScaleTransformation() =>
        ((progress * widget.snapshot.rows * widget.snapshot.cols).floor() %
                widget.snapshot.cols)
            .clamp(0, widget.snapshot.cols - 1),
      _ => 0,
    };
    final token = (widget.animationRevision, column);
    if (_followedColumn == token) return;
    _followedColumn = token;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _followedColumn != token ||
          !_running ||
          !_matrixScroll.hasClients) {
        return;
      }
      final position = _matrixScroll.position;
      final divider = widget.snapshot.augmentedColIndex;
      final left =
          64 * MediaQuery.textScalerOf(context).scale(1) +
          (_reserveSwapLane ? 20 : 0) +
          column * cellWidth +
          (divider != null && column >= divider ? 10 : 0);
      final right = left + cellWidth;
      var offset = position.pixels;
      if (left < offset) offset = left;
      if (right > offset + position.viewportDimension) {
        offset = right - position.viewportDimension;
      }
      offset = offset.clamp(0.0, position.maxScrollExtent);
      if ((offset - position.pixels).abs() < 1) return;
      if (reduced) {
        _matrixScroll.jumpTo(offset);
      } else {
        _matrixScroll.animateTo(
          offset,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// Calculates physical curved vertical translation for Row Swap
  Offset _computeRowOffset(
    int r,
    StepTransformation? trans,
    double progress,
    bool reduceMotion,
  ) {
    if (reduceMotion || trans is! RowSwapTransformation) return Offset.zero;

    final topRow = math.min(trans.rowA, trans.rowB);
    final bottomRow = math.max(trans.rowA, trans.rowB);

    if (r != topRow && r != bottomRow) return Offset.zero;

    final curved = Curves.easeInOutCubic.transform(progress);
    final deltaY = (bottomRow - topRow) * cellHeight;

    if (r == topRow) {
      // Row slot topRow contains matrixAfter.row(topRow) which came from bottomRow.
      // At progress = 0: offset is +deltaY (physically located at bottomRow).
      // At progress = 1: offset is 0.0 (snapped into topRow).
      final dy = deltaY * (1.0 - curved);
      // Curve to the right during transit
      final dx = 26.0 * math.sin(curved * math.pi);
      return Offset(dx, dy);
    } else {
      // Row slot bottomRow contains matrixAfter.row(bottomRow) which came from topRow.
      // At progress = 0: offset is -deltaY (physically located at topRow).
      // At progress = 1: offset is 0.0 (snapped into bottomRow).
      final dy = -deltaY * (1.0 - curved);
      // Curve to the left during transit
      final dx = -26.0 * math.sin(curved * math.pi);
      return Offset(dx, dy);
    }
  }

  /// Builds a single cell widget with appropriate instructional state
  Widget _buildCellAt(
    int r,
    int c,
    StepTransformation? trans,
    double progress,
    bool isDark,
    int? dividerCol,
    bool reduceMotion,
    List<int> changing,
  ) {
    // A row operation reaches its changing columns one after another; a
    // column it cannot change (source entry 0) is finished from the start.
    bool columnDone(int column) {
      final index = changing.indexOf(column);
      return index < 0 || progress >= (index + 1) / changing.length;
    }

    CellHighlight? matchHighlight;
    for (final h in widget.highlights) {
      if (h.row == r && h.col == c) {
        matchHighlight = h;
        break;
      }
    }

    bool hasSub = false;
    for (final sub in widget.subCalculations) {
      if (sub.targetRow == r && sub.targetCol == c) {
        hasSub = true;
        break;
      }
    }

    Rational? valBefore;
    if (widget.snapshotBefore != null &&
        r < widget.snapshotBefore!.rows &&
        c < widget.snapshotBefore!.cols) {
      valBefore = widget.snapshotBefore!.get(r, c);
    }

    final valAfter = widget.snapshot.get(r, c);

    // Dynamic display value transitioning from before to after
    Rational displayVal = valAfter;
    if (!reduceMotion && valBefore != null && trans is! RowSwapTransformation) {
      if (trans is RowEliminationTransformation && trans.targetRow == r) {
        if (!columnDone(c)) displayVal = valBefore;
      } else if (trans is RowScaleTransformation && trans.row == r) {
        if (!columnDone(c)) displayVal = valBefore;
      } else if (trans is RowEliminationTransformation ||
          trans is RowScaleTransformation) {
        // Other rows are untouched.
      } else if (trans is MatrixScaleTransformation) {
        final order = r * widget.snapshot.cols + c;
        final count = widget.snapshot.rows * widget.snapshot.cols;
        if (progress < (order + 1) / count) displayVal = valBefore;
      } else if (trans is AdjugateTransformation && r == c) {
        // The diagonal entries move into place instead of changing value.
      } else if (trans is MatrixElementMultiplicationTransformation) {
        if (progress < 1) displayVal = valBefore;
      } else {
        if (progress < 1) {
          displayVal = valBefore;
        }
      }
    }

    if (!reduceMotion &&
        matchHighlight?.type == HighlightType.zeroed &&
        !columnDone(c)) {
      matchHighlight = CellHighlight(
        row: r,
        col: c,
        type: HighlightType.target,
      );
    }

    if (!reduceMotion && progress < 1 && matchHighlight != null) {
      matchHighlight = CellHighlight(row: r, col: c, type: matchHighlight.type);
    }

    // The full calculation lives in the stable explanation area below the matrix.
    final isZeroResult =
        trans is RowEliminationTransformation &&
        trans.targetRow == r &&
        valAfter == Rational.zero &&
        (reduceMotion || columnDone(c));

    final calculation = !reduceMotion && progress > 0 && progress < 1
        ? _calculationAt(r, c, trans, progress, changing)
        : null;
    // Addition and multiplication fill the output one entry at a time in row
    // order; entries after the current one hold a placeholder zero.
    final order = r * widget.snapshot.cols + c;
    final current = switch (trans) {
      MatrixElementMultiplicationTransformation t =>
        t.targetRow * widget.snapshot.cols + t.targetCol,
      MatrixElementAdditionTransformation t =>
        t.row * widget.snapshot.cols + t.col,
      _ => null,
    };
    final pending =
        current != null &&
        (order > current || (order == current && !reduceMotion && progress < 1));
    final cacheKey = (
      r,
      c,
      displayVal,
      calculation,
      isZeroResult,
      matchHighlight?.type,
      matchHighlight?.badgeText,
      pending,
    );
    final l10n = AppLocalizations.of(context);
    return _cellCache.putIfAbsent(cacheKey, () {
      final cell = SizedBox(
        width: cellWidth,
        height: cellHeight,
        child: MatrixCellWidget(
          calculationLatex: calculation,
          value: displayVal,
          fontSize: _fontSize,
          valueBefore: valBefore,
          highlight: matchHighlight,
          isDecimalView: widget.isDecimalView,
          hasSubCalculation: hasSub,
          isZeroResult: isZeroResult,
          pending: pending,
          // Tests host bare grids without localizations; keep a fallback.
          semanticLabel: pending
              ? (l10n?.matrixCellPendingLabel(r + 1, c + 1) ??
                    'Row ${r + 1}, column ${c + 1}, not calculated yet')
              : (l10n?.matrixCellLabel(r + 1, c + 1, '$displayVal') ??
                    'Row ${r + 1}, column ${c + 1}, $displayVal'),
          onTap: hasSub && widget.onCellTap != null
              ? () => widget.onCellTap!(r, c)
              : null,
        ),
      );

      // Augmented separator vertical divider line
      if (dividerCol != null && c == dividerCol - 1) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            cell,
            Container(
              width: 2,
              height: 42,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.accentIndigo : const Color(0xFF818CF8),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        );
      }

      return cell;
    });
  }

  String? _calculationAt(
    int row,
    int col,
    StepTransformation? trans,
    double progress,
    List<int> changing,
  ) {
    String factor(Rational value) =>
        value.isNegative ? '(${value.toLatex()})' : value.toLatex();
    final before = widget.snapshotBefore;
    final activeColumn =
        changing[(progress * changing.length).floor().clamp(
          0,
          changing.length - 1,
        )];
    if (before != null &&
        row < before.rows &&
        col < before.cols &&
        col == activeColumn) {
      final value = before.get(row, col);
      if (trans is RowEliminationTransformation && row == trans.targetRow) {
        final sign = trans.factor.isNegative ? '-' : '+';
        return '${factor(value)} $sign ${factor(trans.factor.abs())} \\cdot ${factor(before.get(trans.sourceRow, col))}';
      }
      if (trans is RowScaleTransformation && row == trans.row) {
        return '${factor(trans.scalar)} \\cdot ${factor(value)}';
      }
    }
    if (trans is MatrixElementAdditionTransformation &&
        row == trans.row &&
        col == trans.col) {
      return '${factor(trans.left)} + ${factor(trans.right)}';
    }
    if (before != null && row < before.rows && col < before.cols) {
      if (trans is AdjugateTransformation && row != col) {
        return '-${factor(before.get(row, col))}';
      }
      if (trans is MatrixScaleTransformation) {
        final count = widget.snapshot.rows * widget.snapshot.cols;
        final active = (progress * count).floor().clamp(0, count - 1);
        if (row * widget.snapshot.cols + col == active) {
          return '${factor(before.get(row, col))} \\cdot ${factor(trans.scalar)}';
        }
      }
    }
    if (trans is MatrixElementMultiplicationTransformation &&
        row == trans.targetRow &&
        col == trans.targetCol) {
      final count = ((progress * trans.rowElements.length).floor() + 1).clamp(
        1,
        trans.rowElements.length,
      );
      return List.generate(
        count,
        (index) =>
            '${factor(trans.rowElements[index])} \\cdot ${factor(trans.colElements[index])}',
      ).join(' + ');
    }
    return null;
  }

  /// Adjugate motion: the two diagonal entries travel along the diagonal to
  /// each other's place, bending apart so they never cover each other.
  Widget _adjugateRow(int r, Widget row, double progress) {
    final cells = _rowCache[r]?.cells;
    if (cells == null || r >= cells.length) return row;
    final eased = Curves.easeInOutCubic.transform(progress);
    final direction = r == 0 ? 1.0 : -1.0;
    final travel = Offset(cellWidth, cellHeight) * direction * (1 - eased);
    final bend = Offset(18, -18) * direction * math.sin(eased * math.pi);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var c = 0; c < cells.length; c++)
          c == r
              ? Transform.translate(offset: travel + bend, child: cells[c])
              : cells[c],
      ],
    );
  }

  /// L as it stands after this LU step. The entry just written is framed;
  /// entries below the diagonal that later steps will fill show a dot, not a
  /// zero that would read as a result.
  Widget _buildLowerMatrix(LUEliminationTransformation trans) {
    final lower = trans.lower;
    final theme = Theme.of(context);
    final muted = theme.brightness == Brightness.dark
        ? AppTheme.textMutedDark
        : AppTheme.textMutedLight;
    bool pending(int r, int c) =>
        r > c &&
        (c > trans.lowerCol || (c == trans.lowerCol && r > trans.lowerRow));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const MathText('L =', fontSize: 18),
        const SizedBox(width: 8),
        MatrixBracket(
          height: lower.rows * 40.0 * MediaQuery.textScalerOf(context).scale(1),
          isLeft: true,
          width: 6,
          thickness: 2,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var r = 0; r < lower.rows; r++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var c = 0; c < lower.cols; c++)
                    Container(
                      constraints: BoxConstraints(
                        minWidth: 44 * MediaQuery.textScalerOf(context).scale(1),
                        minHeight: 40 * MediaQuery.textScalerOf(context).scale(1),
                      ),
                      margin: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: r == trans.lowerRow && c == trans.lowerCol
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: MathText(
                        pending(r, c)
                            ? r'\cdot'
                            : widget.isDecimalView
                            ? decimalLatex(lower.get(r, c))
                            : lower.get(r, c).toLatex(),
                        fontSize: 16,
                        color: pending(r, c) ? muted : null,
                      ),
                    ),
                ],
              ),
          ],
        ),
        MatrixBracket(
          height: lower.rows * 40.0 * MediaQuery.textScalerOf(context).scale(1),
          isLeft: false,
          width: 6,
          thickness: 2,
        ),
      ],
    );
  }

  /// A lightweight outline links the source and target without covering numbers.
  Widget _buildGhostRowOverlay(
    RowEliminationTransformation trans,
    double progress,
    bool isDark,
  ) {
    final movement = (progress / .4).clamp(0.0, 1.0);
    final eased = Curves.easeInOutCubic.transform(movement);
    return Positioned(
      top:
          (trans.sourceRow + (trans.targetRow - trans.sourceRow) * eased) *
          cellHeight,
      left: 0,
      child: IgnorePointer(
        child: Opacity(
          opacity: (1 - movement) * .7,
          child: Container(
            width: widget.snapshot.cols * cellWidth,
            height: cellHeight,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.accentPurple, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperationBadge(StepTransformation trans, bool isDark) {
    if (trans is LUDecompositionTransformation) {
      return MathText(
        'L = ${trans.lSnapshot.toMatrix().toLatex()}',
        fontSize: 20,
      );
    }
    if (trans is LinearSystemTransformation) {
      return MathText(trans.summaryLatex, fontSize: 20);
    }
    if (trans is EigenTransformation) {
      return MathText(trans.polynomialLatex, fontSize: 20);
    }
    if (trans is RankNullityTransformation) {
      return MathText(
        '${trans.rank} + ${trans.nullity} = ${trans.totalCols}',
        fontSize: 20,
      );
    }
    if (trans is RowSwapTransformation) {
      return Text(
        'R${trans.rowA + 1} ↔ R${trans.rowB + 1}',
        style: Theme.of(context).textTheme.titleLarge,
      );
    }
    if (trans is RowEliminationTransformation) {
      final sign = trans.factor.isNegative ? '-' : '+';
      final factor = trans.factor.abs() == Rational.one
          ? ''
          : '(${trans.factor.abs().toLatex()})';
      final operation = MathText(
        'R_{${trans.targetRow + 1}} \\leftarrow R_{${trans.targetRow + 1}} $sign $factor R_{${trans.sourceRow + 1}}',
        fontSize: 20,
      );
      if (trans is! LUEliminationTransformation) return operation;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [operation, const SizedBox(height: 12), _buildLowerMatrix(trans)],
      );
    }
    if (trans is AdjugateTransformation) {
      return const MathText(
        r'\begin{pmatrix} a & b \\ c & d \end{pmatrix} \rightarrow \begin{pmatrix} d & -b \\ -c & a \end{pmatrix}',
        fontSize: 18,
      );
    }
    if (trans is MatrixScaleTransformation) {
      return MathText(
        'A^{-1} = ${trans.scalar.toLatex()} \\cdot \\text{adj}(A)',
        fontSize: 20,
      );
    }
    if (trans is RowScaleTransformation) {
      return MathText(
        'R_{${trans.row + 1}} \\leftarrow (${trans.scalar.toLatex()}) R_{${trans.row + 1}}',
        fontSize: 20,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildRowLabel(int r, bool isDark) {
    Color? activeColor;
    for (final h in widget.highlights) {
      if (h.row == r) {
        if (h.type == HighlightType.pivot) {
          activeColor = AppTheme.accentAmber;
        } else if (h.type == HighlightType.target && activeColor == null) {
          activeColor = AppTheme.accentCyan;
        } else if (h.type == HighlightType.source && activeColor == null) {
          activeColor = AppTheme.accentPurple;
        }
      }
    }

    final isHighlighted = activeColor != null;
    return AnimatedContainer(
      duration: AppTheme.motion(context, 180),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isHighlighted
            ? activeColor.withValues(alpha: isDark ? 0.25 : 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isHighlighted
            ? Border.all(color: activeColor.withValues(alpha: 0.6))
            : null,
      ),
      child: Text(
        'R${r + 1}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w500,
          color: isHighlighted
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSarrusCopies(bool isDark) {
    final color = isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var c = 0; c < 2; c++)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var r = 0; r < 3; r++)
                  SizedBox(
                    width: cellWidth,
                    height: cellHeight,
                    child: Center(
                      child: MathText(
                        widget.isDecimalView
                            ? decimalLatex(widget.snapshot.get(r, c))
                            : widget.snapshot.get(r, c).toLatex(),
                        fontSize: _fontSize,
                        color: color,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
