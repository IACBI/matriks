import 'package:flutter/material.dart';
import 'package:matrix_engine/matrix_engine.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/math_text.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../transform_visualizer/models/transform_matrix.dart';
import '../../transform_visualizer/views/transform_visualizer_screen.dart';
import '../result_check.dart';
import '../step_text.dart';
import 'matrix_display_grid.dart';

class SolutionStatus extends StatelessWidget {
  final StepSolution solution;
  const SolutionStatus({super.key, required this.solution});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final eigen = solution.result is EigenResult
        ? solution.result as EigenResult
        : null;
    // A chip reports itself as selectable (a checkbox on the web); these
    // only state a fact about the result, so they are read as plain text.
    Widget status(String text, {Widget? avatar}) => Semantics(
      container: true,
      label: text,
      excludeSemantics: true,
      child: Chip(avatar: avatar, label: Text(text)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            if (solution.isSuccess)
              status(
                solution.accuracy == ResultAccuracy.exact
                    ? l.resultExact
                    : l.resultApproximate,
                avatar: Icon(
                  solution.accuracy == ResultAccuracy.exact
                      ? Icons.verified_outlined
                      : Icons.data_usage_rounded,
                  size: 18,
                ),
              ),
            if (solution.isSuccess ||
                solution.completeness == ResultCompleteness.unsupported)
              status(switch (solution.completeness) {
                ResultCompleteness.complete => l.resultComplete,
                ResultCompleteness.partial => l.resultPartial,
                ResultCompleteness.unsupported => l.resultUnsupported,
              }),
          ],
        ),
        if (eigen != null) ...[
          if (eigen.hasComplexEigenvalues) Text(l.eigenComplexNote),
          if (eigen.eigenpairs.any((p) => p.eigenvalue.degree == 3))
            Text(l.eigenCubicNote),
          // Too few eigenvectors is a property of A, stated as such.
          if (eigen.eigenpairs.any((p) => p.isDefective))
            Text(l.eigenBasisScope),
        ],
      ],
    );
  }
}

class SolutionSummary extends StatelessWidget {
  final StepSolution solution;
  final bool decimal;
  final VoidCallback onViewSteps;
  const SolutionSummary({
    super.key,
    required this.solution,
    required this.decimal,
    required this.onViewSteps,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final error = localizedSolverError(l, solution.errorMessageKey);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      // The same centred column as the lesson stage, so a wide window does
      // not pull the heading and checks away from the matrix.
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.resultLabel,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              SolutionStatus(solution: solution),
              const SizedBox(height: 16),
              if (!solution.isSuccess)
                Text(
                  error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              // A matrix result is drawn below as the matrix itself; its TeX line
              // would only repeat it, with cramped fractions.
              // Separate parts (each eigenpair; P, L and U) sit side by side
              // when they fit and stack on a narrow screen.
              // The engine's result for a system with no solution is English
              // prose; the interface says it in the learner's language.
              if (solution.result case LinearSystemResult(
                type: LinearSystemType.inconsistent,
              ))
                Text(
                  l.systemNoSolution,
                  style: Theme.of(context).textTheme.titleLarge,
                )
              else if (solution.resultLatex != null &&
                  solution.result is! Matrix)
                Wrap(
                  spacing: 32,
                  runSpacing: 12,
                  children: [
                    for (final part in solution.resultLatex!.split(r' \quad '))
                      // "λ = … ⟹ v = …" breaks after the arrow when it does
                      // not fit, so a long exact λ (Cardano's formula on a
                      // phone) cannot push its vector out of sight.
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (final piece in _splitAtImplies(part))
                            SidewaysFormula(
                              child: MathText(piece, fontSize: 24),
                            ),
                        ],
                      ),
                  ],
                ),
              const SizedBox(height: 24),
              // Only a matrix result is drawn as a matrix. For a determinant,
              // LU or eigen result the final matrix would stand unlabelled under
              // the answer (U again, or A itself).
              if (solution.isSuccess && solution.result is Matrix)
                MatrixDisplayGrid(
                  snapshot: MatrixSnapshot.fromMatrix(solution.finalMatrix),
                  highlights: const [],
                  staticStep: true,
                  showExplanation: false,
                  isDecimalView: decimal,
                ),
              ResultChecks(solution: solution),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (solution.steps.isNotEmpty)
                    FilledButton.icon(
                      onPressed: onViewSteps,
                      icon: const Icon(Icons.layers_outlined),
                      label: Text(l.viewSteps),
                    ),
                  ?TransformLink.forSolution(solution),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Independent confirmations of the result (A·A⁻¹ = I, Av = λv, ...),
/// computed exactly; nothing is shown for operations without one.
class ResultChecks extends StatelessWidget {
  final StepSolution solution;
  const ResultChecks({super.key, required this.solution});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final checks = resultChecks(solution, l);
    if (checks.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Card(
      key: const ValueKey('result-checks'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.checkTitle, style: theme.textTheme.titleMedium),
            for (final (index, check) in checks.indexed) ...[
              const SizedBox(height: 12),
              // Eigenpairs share one description; say it once.
              if (index == 0 ||
                  checks[index - 1].description != check.description) ...[
                Text(check.description, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 6),
              ],
              SidewaysFormula(child: MathText(check.latex, fontSize: 18)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    check.holds
                        ? Icons.check_circle_outline_rounded
                        : Icons.error_outline_rounded,
                    size: 18,
                    color: check.holds
                        ? AppTheme.accentGreen
                        : theme.colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    check.holds ? l.checkHolds : l.checkFails,
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A formula that scrolls sideways when it is wider than the screen, with a
/// visible scrollbar.
///
/// Flutter adds no scrollbar to a horizontal scroll view by itself, and a
/// matrix cut at the edge (the L of a 5×5 LU on a phone) otherwise looks
/// complete. Room for the thumb is reserved only while the formula overflows,
/// so a formula that fits keeps its spacing.
class SidewaysFormula extends StatefulWidget {
  final Widget child;
  const SidewaysFormula({super.key, required this.child});

  @override
  State<SidewaysFormula> createState() => _SidewaysFormulaState();
}

class _SidewaysFormulaState extends State<SidewaysFormula> {
  final _controller = ScrollController();
  var _overflows = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _onMetrics(ScrollMetricsNotification notification) {
    if (notification.depth == 0) {
      final overflows =
          notification.metrics.maxScrollExtent >
          notification.metrics.minScrollExtent;
      if (overflows != _overflows) setState(() => _overflows = overflows);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _onMetrics,
      child: Scrollbar(
        controller: _controller,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(bottom: _overflows ? 10 : 0),
          child: widget.child,
        ),
      ),
    );
  }
}

/// `a \implies b` as `a \implies` and `b`; anything else unchanged.
List<String> _splitAtImplies(String latex) {
  const arrow = r' \implies ';
  final at = latex.indexOf(arrow);
  if (at < 0) return [latex];
  return [
    '${latex.substring(0, at)} \\implies',
    latex.substring(at + arrow.length),
  ];
}

/// Opens a 2×2 eigen problem in the transformation view, where the
/// eigenvectors are the directions the grid only stretches.
class TransformLink extends StatelessWidget {
  final TransformMatrix matrix;
  const TransformLink({super.key, required this.matrix});

  /// Null unless [solution] is a 2×2 eigen analysis whose entries the
  /// transformation view accepts ([-1000, 1000]).
  static TransformLink? forSolution(StepSolution solution) {
    final a = solution.initialMatrix;
    if (solution.operationKey != 'op_eigen' || a.rows != 2 || a.cols != 2) {
      return null;
    }
    final limit = Rational.fromInt(1000);
    final values = [
      for (var r = 0; r < 2; r++)
        for (var c = 0; c < 2; c++) a.get(r, c),
    ];
    if (values.any((v) => v.abs() > limit)) return null;
    return TransformLink(
      key: const ValueKey('transform-link'),
      // Exact, so 1/3 arrives as 1/3 rather than 0.3333333333333333.
      matrix: TransformMatrix.fromRationals(
        values[0],
        values[1],
        values[2],
        values[3],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TransformVisualizerScreen(initial: matrix),
        ),
      ),
      icon: const Icon(Icons.open_in_new_rounded),
      label: Text(AppLocalizations.of(context)!.seeAsTransform),
    );
  }
}
