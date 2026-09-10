import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:matrix_engine/matrix_engine.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/math_text.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'determinant_lines_painter.dart';
import 'matrix_cell_widget.dart';
import 'multiplication_sources.dart';
import 'row_swap_brackets_painter.dart';
import 'instruction_timeline.dart';
import 'instruction_lesson.dart';

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
  });

  @override
  State<MatrixDisplayGrid> createState() => _MatrixDisplayGridState();
}

class _MatrixDisplayGridState extends State<MatrixDisplayGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late InstructionTimeline _timeline;
  final Map<(InstructionPhase, int), Widget> _explanationCache = {};
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

  double _measureCellWidth() {
    var digits = 1;
    for (final snapshot in [widget.snapshot, widget.snapshotBefore]) {
      if (snapshot == null) continue;
      for (var r = 0; r < snapshot.rows; r++) {
        for (var c = 0; c < snapshot.cols; c++) {
          final value = snapshot.get(r, c);
          final length = widget.isDecimalView
              ? value.toDisplayString(asDecimal: true).length
              : math.max(
                  value.num.toString().length,
                  value.den.toString().length,
                );
          digits = math.max(digits, length);
        }
      }
    }
    return (32.0 + digits * _fontSize * .65).clamp(52.0, 400.0) *
        MediaQuery.textScalerOf(context).scale(1);
  }

  bool get _running => !widget.staticStep && (widget.isAnimating ?? true);

  @override
  void initState() {
    super.initState();
    _timeline = InstructionTimeline.forTransformation(widget.transformation);
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
    _timeline = InstructionTimeline.forTransformation(widget.transformation);
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
        (widget.transformation is RowSwapTransformation ? 20 : 0) +
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
        transformation is MatrixElementMultiplicationTransformation;
    if (hasCellCalculation &&
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
    final bracketColor = isDark
        ? const Color(0xFF64748B)
        : const Color(0xFF475569);
    final dividerCol = widget.snapshot.augmentedColIndex;
    final gridHeight = widget.snapshot.rows * cellHeight;
    final bracketHeight = (widget.snapshot.rows * cellHeight) - 8.0;
    final gridWidth = widget.snapshot.cols * cellWidth;
    final reduceMotion =
        widget.staticStep || MediaQuery.of(context).disableAnimations;
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
        : (trans is DeterminantCrossProductTransformation &&
                  trans.phase == 3) ||
              (trans is DeterminantSarrusTransformation && trans.phase == 3)
        ? lesson.calculations.length - 1
        : lesson.calculations.length;
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
                final stage = (progress * widget.snapshot.cols).floor();
                _followActiveColumn(trans, progress, reduceMotion);
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
                    if (trans is RowSwapTransformation) ...[
                      CustomPaint(
                        size: Size(20, gridHeight),
                        painter: RowSwapBracketsPainter(
                          rowA: trans.rowA,
                          rowB: trans.rowB,
                          cellHeight: cellHeight,
                          progress: progress,
                          isDark: isDark,
                        ),
                      ),
                    ],

                    // Left Matrix Bracket [
                    _buildBracket(
                      bracketColor,
                      height: bracketHeight,
                      isLeft: true,
                    ),
                    const SizedBox(width: 4),

                    // Matrix Grid Cells with CustomPainter Overlay
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Base Cells Column
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(widget.snapshot.rows, (r) {
                            final rowOffset = _computeRowOffset(
                              r,
                              trans,
                              progress,
                              reduceMotion,
                            );
                            final rowWidget = rows[r];

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

                        // Ghost Row Projection (Phase 1 of Row Elimination: R_t <- R_t - c*R_s)
                        if (trans is RowEliminationTransformation &&
                            !reduceMotion &&
                            progress < 0.45) ...[
                          _buildGhostRowOverlay(trans, progress, isDark),
                        ],

                        // Determinant Lines Overlay (2x2 and 3x3 Sarrus)
                        if ((trans is DeterminantCrossProductTransformation ||
                                trans is DeterminantSarrusTransformation) &&
                            !reduceMotion) ...[
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
                                  isDark: isDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(width: 4),
                    // Right Matrix Bracket ]
                    _buildBracket(
                      bracketColor,
                      height: bracketHeight,
                      isLeft: false,
                    ),
                  ],
                );
              },
            ),
          ),
          if (widget.showExplanation) const SizedBox(height: 24),
          if (widget.showExplanation)
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
                return _explanationCache.putIfAbsent(
                  (phase, active),
                  () => InstructionExplanation(
                    lesson: lesson,
                    phase: phase,
                    activeCalculation: active,
                    showAllPhases: reduceMotion,
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
  ) {
    if (!_running || _scrubbing) return;
    final column = switch (transformation) {
      MatrixElementMultiplicationTransformation t => t.targetCol,
      MatrixElementAdditionTransformation t => t.col,
      RowEliminationTransformation() || RowScaleTransformation() =>
        (progress * widget.snapshot.cols).floor().clamp(
          0,
          widget.snapshot.cols - 1,
        ),
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
  ) {
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
        if (progress < (c + 1) / widget.snapshot.cols) {
          displayVal = valBefore;
        }
      } else if (trans is RowScaleTransformation && trans.row == r) {
        if (progress < (c + 1) / widget.snapshot.cols) {
          displayVal = valBefore;
        }
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
        progress < (c + 1) / widget.snapshot.cols) {
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
        (reduceMotion || progress >= (c + 1) / widget.snapshot.cols);

    final calculation = !reduceMotion && progress > 0 && progress < 1
        ? _calculationAt(r, c, trans, progress)
        : null;
    final cacheKey = (
      r,
      c,
      displayVal,
      calculation,
      isZeroResult,
      matchHighlight?.type,
      matchHighlight?.badgeText,
    );
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
          semanticLabel:
              (AppLocalizations.of(context)
                  ?.matrixCellLabel(r + 1, c + 1, displayVal.toString()) ??
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
  ) {
    String factor(Rational value) =>
        value.isNegative ? '(${value.toLatex()})' : value.toLatex();
    final before = widget.snapshotBefore;
    final activeColumn = (progress * widget.snapshot.cols).floor();
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
    if (trans is DeterminantCofactorTransformation) {
      return MathText(
        '${trans.sign.toLatex()} \\cdot (${trans.element.toLatex()}) \\cdot \\det ${trans.minorMatrix.toMatrix().toLatex()}',
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
      return MathText(
        'R_{${trans.targetRow + 1}} \\leftarrow R_{${trans.targetRow + 1}} $sign $factor R_{${trans.sourceRow + 1}}',
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

  Widget _buildBracket(
    Color color, {
    required double height,
    required bool isLeft,
  }) {
    return Container(
      width: 10,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: color, width: 2.5),
          bottom: BorderSide(color: color, width: 2.5),
          left: isLeft ? BorderSide(color: color, width: 2.5) : BorderSide.none,
          right: !isLeft
              ? BorderSide(color: color, width: 2.5)
              : BorderSide.none,
        ),
      ),
    );
  }
}
