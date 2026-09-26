import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';

class CustomNumpad extends StatelessWidget {
  /// Widest the keys grow; controls laid out with the keypad match it.
  static const keysMaxWidth = 480.0;

  final void Function(String text) onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onNextCell;
  final VoidCallback onPrevCell;

  /// Moves down a row in the same column. Falls back to [onNextCell].
  final VoidCallback? onNextRow;
  final double keyHeight;

  const CustomNumpad({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    required this.onClear,
    required this.onNextCell,
    required this.onPrevCell,
    this.onNextRow,
    this.keyHeight = 46.0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final keyBg = isDark
        ? AppTheme.surfaceVariantDark
        : AppTheme.surfaceVariantLight;
    final keyFg = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final controlBg = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    Widget buildKey(
      String label, {
      VoidCallback? onTap,
      Color? color,
      Color? textColor,
      Widget? child,
      String? semanticLabel,
      int flex = 1,
    }) {
      void activate() {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap();
        } else {
          onKeyPressed(label);
        }
      }

      return Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.all(2.5),
          child: Semantics(
            label: semanticLabel ?? label,
            button: true,
            excludeSemantics: true,
            onTap: activate,
            child: Material(
              color: color ?? keyBg,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                onTap: activate,
                child: SizedBox(
                  height: keyHeight.clamp(44.0, 80.0),
                  child: Center(
                    child:
                        child ??
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: textColor ?? keyFg,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
          constraints: const BoxConstraints(maxWidth: keysMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Every key has one job: the cell moves are previous cell, next
              // row and next cell (tab); the sign key toggles the sign.
              // Row 1: 1, 2, 3, Previous cell, Next row
              Row(
                children: [
                  buildKey('1'),
                  buildKey('2'),
                  buildKey('3'),
                  buildKey(
                    'prev',
                    onTap: onPrevCell,
                    color: controlBg,
                    semanticLabel: l10n?.keyPreviousCell ?? 'Previous cell',
                    child: const Icon(Icons.arrow_back_rounded, size: 20),
                  ),
                  buildKey(
                    'down',
                    onTap: onNextRow ?? onNextCell,
                    color: controlBg,
                    semanticLabel: l10n?.keyNextRow ?? 'Next row',
                    child: const Icon(Icons.arrow_downward_rounded, size: 20),
                  ),
                ],
              ),
              // Row 2: 4, 5, 6, Sign, Fraction
              Row(
                children: [
                  buildKey('4'),
                  buildKey('5'),
                  buildKey('6'),
                  buildKey(
                    '±',
                    onTap: () => onKeyPressed('-'),
                    textColor: theme.colorScheme.primary,
                    semanticLabel: l10n?.keySign ?? 'Toggle sign',
                  ),
                  buildKey(
                    '/',
                    textColor: theme.colorScheme.primary,
                    semanticLabel: l10n?.keyFraction ?? 'Fraction slash',
                  ),
                ],
              ),
              // Row 3: 7, 8, 9, Backspace (wide flex: 2)
              Row(
                children: [
                  buildKey('7'),
                  buildKey('8'),
                  buildKey('9'),
                  buildKey(
                    'backspace',
                    onTap: onBackspace,
                    color: controlBg,
                    flex: 2,
                    semanticLabel: l10n?.keyBackspace ?? 'Backspace',
                    child: const Icon(Icons.backspace_outlined, size: 19),
                  ),
                ],
              ),
              // Row 4: Clear (C), Zero (0, wide), Dot (.), Tab (⇥)
              Row(
                children: [
                  buildKey(
                    'C',
                    onTap: onClear,
                    color: isDark
                        ? const Color(0xFF450A0A)
                        : const Color(0xFFFEE2E2),
                    textColor: isDark
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFFDC2626),
                    semanticLabel: l10n?.keyClear ?? 'Clear cell',
                  ),
                  buildKey('0', semanticLabel: '0', flex: 2),
                  buildKey(
                    '.',
                    semanticLabel: l10n?.keyDecimal ?? 'Decimal point',
                  ),
                  buildKey(
                    'tab',
                    onTap: onNextCell,
                    color: controlBg,
                    semanticLabel: l10n?.keyNextCell ?? 'Next cell tab',
                    child: const Icon(Icons.keyboard_tab_rounded, size: 20),
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
