import 'package:flutter/material.dart';
import 'package:matrix_engine/matrix_engine.dart';

import '../../../core/widgets/math_text.dart';
import '../../../l10n/generated/app_localizations.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            if (solution.isSuccess)
              Chip(
                avatar: const Icon(Icons.verified_outlined, size: 18),
                label: Text(
                  solution.accuracy == ResultAccuracy.exact
                      ? l.resultExact
                      : l.resultApproximate,
                ),
              ),
            if (solution.isSuccess ||
                solution.completeness == ResultCompleteness.unsupported)
              Chip(
                label: Text(switch (solution.completeness) {
                  ResultCompleteness.complete => l.resultComplete,
                  ResultCompleteness.partial => l.resultPartial,
                  ResultCompleteness.unsupported => l.resultUnsupported,
                }),
              ),
          ],
        ),
        if (eigen != null) ...[
          if (eigen.hasComplexEigenvalues)
            Text(l.complexScope)
          else if (solution.accuracy == ResultAccuracy.approximate)
            Text(l.eigenPrecision),
          if (solution.initialMatrix.rows == 3) Text(l.eigenScope),
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
    final error = switch (solution.errorMessageKey) {
      'error_matrix_is_singular' => l.error_matrix_is_singular,
      'error_inverse_not_square' => l.error_inverse_not_square,
      'error_dimension_mismatch_add' => l.error_dimension_mismatch_add,
      'error_dimension_mismatch_multiply' =>
        l.error_dimension_mismatch_multiply,
      _ => l.solveFallbackError,
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
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
          if (solution.resultLatex != null)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: MathText(solution.resultLatex!, fontSize: 24),
            ),
          const SizedBox(height: 24),
          if (solution.isSuccess)
            MatrixDisplayGrid(
              snapshot: MatrixSnapshot.fromMatrix(solution.finalMatrix),
              highlights: const [],
              staticStep: true,
              showExplanation: false,
              isDecimalView: decimal,
            ),
          const SizedBox(height: 24),
          if (solution.steps.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: onViewSteps,
                icon: const Icon(Icons.layers_outlined),
                label: Text(l.viewSteps),
              ),
            ),
        ],
      ),
    );
  }
}
