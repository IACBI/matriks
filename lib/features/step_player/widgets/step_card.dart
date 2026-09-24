import 'package:flutter/material.dart';
import 'package:matrix_engine/matrix_engine.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/math_text.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/cubit/settings_state.dart';

class StepCard extends StatelessWidget {
  final ExplanationLevel explanationLevel;
  final MatrixStep step;
  final bool showTitle;
  final String? rationale;
  final VoidCallback? onExpandCalculations;
  final String localizedTitle;
  final String localizedDescription;
  final void Function(SubCalculation)? onSubCalculationTap;

  /// The solver's description, when the phase explanation does not already
  /// say the same thing.
  final bool showDescription;

  /// The step's cell formulas, when the explanation has no calculations of
  /// its own; otherwise the same formulas would be listed twice.
  final bool showCellCalculations;

  const StepCard({
    this.explanationLevel = ExplanationLevel.detailed,
    super.key,
    required this.step,
    this.showTitle = true,
    this.rationale,
    this.onExpandCalculations,
    required this.localizedTitle,
    required this.localizedDescription,
    this.onSubCalculationTap,
    this.showDescription = true,
    this.showCellCalculations = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visible = explanationLevel != ExplanationLevel.hidden;
    final description = visible && showDescription;
    final hasRationale = visible && rationale != null;
    final calculations =
        showCellCalculations && step.subCalculations.isNotEmpty;
    final roles = {
      for (final h in step.highlights)
        if (h.type == HighlightType.pivot ||
            h.type == HighlightType.source ||
            h.type == HighlightType.target ||
            h.type == HighlightType.zeroed)
          h.type,
    };
    if (!description &&
        !hasRationale &&
        !calculations &&
        roles.isEmpty &&
        !showTitle) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            Semantics(
              header: true,
              child: Text(
                readableMathProse(localizedTitle),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
          if (description) ...[
            if (showTitle) const SizedBox(height: 10),
            Text(
              l10n?.explanation ?? 'Explanation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              readableMathProse(localizedDescription),
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
          if (hasRationale)
            ExpansionTile(
              key: ValueKey('${step.stepIndex}-${explanationLevel.name}'),
              tilePadding: EdgeInsets.zero,
              initiallyExpanded: explanationLevel == ExplanationLevel.detailed,
              title: Text(l10n!.stepExplanation),
              onExpansionChanged: (open) {
                if (open) onExpandCalculations?.call();
              },
              children: [
                Text(
                  readableMathProse(rationale!),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          if (calculations) ...[
            const SizedBox(height: 12),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                '${l10n?.cellCalculations ?? 'Cell calculations'} (${step.subCalculations.length})',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              onExpansionChanged: (open) {
                if (open) onExpandCalculations?.call();
              },
              children: step.subCalculations
                  .map(
                    (sub) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: MathText(sub.formulaLatex, fontSize: 16),
                      ),
                      trailing: const Icon(
                        Icons.open_in_full_rounded,
                        size: 16,
                      ),
                      onTap: onSubCalculationTap == null
                          ? null
                          : () => onSubCalculationTap!(sub),
                    ),
                  )
                  .toList(),
            ),
          ],

          if (roles.isNotEmpty) const SizedBox(height: 12),
          // Semantic color legend for the step
          if (roles.isNotEmpty)
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              if (step.highlights.any((h) => h.type == HighlightType.pivot))
                _buildLegendDot(
                  AppTheme.accentAmber,
                  l10n?.legendPivot ?? 'Pivot',
                  isDark,
                ),
              if (step.highlights.any((h) => h.type == HighlightType.source))
                _buildLegendDot(
                  AppTheme.accentPurple,
                  l10n?.legendSource ?? 'Source',
                  isDark,
                ),
              if (step.highlights.any((h) => h.type == HighlightType.target))
                _buildLegendDot(
                  AppTheme.accentCyan,
                  l10n?.legendTarget ?? 'Target',
                  isDark,
                ),
              if (step.highlights.any((h) => h.type == HighlightType.zeroed))
                _buildLegendDot(
                  AppTheme.accentGreen,
                  l10n?.legendZeroResult ?? '0-Result',
                  isDark,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
