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
          if (eigen.hasComplexEigenvalues)
            Text(l.complexScope)
          else if (solution.accuracy == ResultAccuracy.approximate)
            Text(l.eigenPrecision),
          if (solution.initialMatrix.rows == 3) Text(l.eigenScope),
          // Distinct eigenvalues have one-dimensional eigenspaces, so the
          // vector shown is already a basis; only a repeated one may not be.
          if (eigen.realEigenpairs.any((p) => p.algebraicMultiplicity > 1))
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
              if (solution.resultLatex != null && solution.result is! Matrix)
                Wrap(
                  spacing: 32,
                  runSpacing: 12,
                  children: [
                    for (final part in solution.resultLatex!.split(r' \quad '))
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: MathText(part, fontSize: 24),
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: MathText(check.latex, fontSize: 18),
              ),
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
    final values = [
      for (var r = 0; r < 2; r++)
        for (var c = 0; c < 2; c++) a.get(r, c).toDouble(),
    ];
    if (values.any((v) => !v.isFinite || v.abs() > 1000)) return null;
    return TransformLink(
      key: const ValueKey('transform-link'),
      matrix: TransformMatrix(values[0], values[1], values[2], values[3]),
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
