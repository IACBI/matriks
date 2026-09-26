import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_engine/matrix_engine.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/math_text.dart';
import '../../../core/widgets/matrix_bracket.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../settings/widgets/language_menu.dart';
import '../../step_player/widgets/matrix_cell_widget.dart';
import '../models/quiz_generator.dart';
import '../models/quiz_question.dart';

class PracticeScreen extends StatefulWidget {
  final VoidCallback? onReturnTopics;
  const PracticeScreen({super.key, this.onReturnTopics});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late String _language;
  late List<QuizQuestion> _questions;

  /// Null for the curated first round; otherwise the seed of a generated
  /// round, kept so a language change rebuilds the same questions.
  int? _seed;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _hasAnswered = false;
  bool _showHint = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _language = Localizations.localeOf(context).languageCode;
    _questions = _buildQuestions();
  }

  List<QuizQuestion> _buildQuestions() {
    final seed = _seed;
    return seed == null
        ? QuizBank.getQuestions(language: _language)
        : QuizGenerator.generate(
            seed,
            lookupAppLocalizations(Locale(_language)),
          );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  QuizQuestion get _currentQuestion => _questions[_currentIndex];

  void _selectOption(int index) {
    if (_hasAnswered) return;
    setState(() {
      _selectedOptionIndex = index;
      _hasAnswered = true;
      if (index == _currentQuestion.correctIndex) {
        _score += 10;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _hasAnswered = false;
        _showHint = false;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _restartQuiz({bool fresh = false}) {
    setState(() {
      if (fresh) {
        _seed = Random().nextInt(1 << 31);
        _questions = _buildQuestions();
      }
      _currentIndex = 0;
      _score = 0;
      _selectedOptionIndex = null;
      _hasAnswered = false;
      _showHint = false;
    });
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    if (!_hasAnswered) {
      if (key == LogicalKeyboardKey.keyA ||
          key == LogicalKeyboardKey.digit1 ||
          key == LogicalKeyboardKey.numpad1) {
        _selectOption(0);
      } else if (key == LogicalKeyboardKey.keyB ||
          key == LogicalKeyboardKey.digit2 ||
          key == LogicalKeyboardKey.numpad2) {
        if (_currentQuestion.optionsLatex.length > 1) _selectOption(1);
      } else if (key == LogicalKeyboardKey.keyC ||
          key == LogicalKeyboardKey.digit3 ||
          key == LogicalKeyboardKey.numpad3) {
        if (_currentQuestion.optionsLatex.length > 2) _selectOption(2);
      } else if (key == LogicalKeyboardKey.keyD ||
          key == LogicalKeyboardKey.digit4 ||
          key == LogicalKeyboardKey.numpad4) {
        if (_currentQuestion.optionsLatex.length > 3) _selectOption(3);
      } else if (key == LogicalKeyboardKey.keyH) {
        setState(() => _showHint = !_showHint);
      } else {
        return KeyEventResult.ignored;
      }
    } else {
      if (key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.numpadEnter ||
          key == LogicalKeyboardKey.space) {
        _nextQuestion();
      } else {
        return KeyEventResult.ignored;
      }
    }
    return KeyEventResult.handled;
  }

  void _showCompletionDialog() {
    // Finishing a round completes the practice topic on the learning path.
    context.read<SettingsCubit?>()?.completeTopic('practice');
    final l10n = lookupAppLocalizations(Locale(_language));
    final title = l10n.practiceCompleted;
    final scoreText = l10n.practiceTotalScore(_score, _questions.length * 10);
    final praiseText = _score == _questions.length * 10
        ? l10n.practicePerfectScore
        : l10n.practiceGoodEffort;
    final returnText = l10n.practiceReturnTopics;
    final restartText = l10n.practiceRestart;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: AppTheme.accentAmber,
              size: 28,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              scoreText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(praiseText),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (widget.onReturnTopics != null) {
                widget.onReturnTopics!();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(returnText),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _restartQuiz();
            },
            child: Text(restartText),
          ),
          FilledButton(
            key: const ValueKey('quiz-new-round'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _restartQuiz(fresh: true);
            },
            child: Text(l10n.newQuestions),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = lookupAppLocalizations(Locale(_language));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final q = _currentQuestion;
    final isCorrect = _selectedOptionIndex == q.correctIndex;

    final screenTitle = l10n.practiceTitle;
    final scoreLabel = l10n.practiceScore(_score);
    final questionProgressLabel = l10n.practiceQuestionProgress(
      _currentIndex + 1,
      _questions.length,
    );
    final hintLabel = _showHint ? l10n.practiceHideHint : l10n.practiceHint;
    final feedbackTitle = isCorrect
        ? l10n.practiceCorrect
        : l10n.practiceIncorrect;
    final nextButtonLabel = _currentIndex < _questions.length - 1
        ? l10n.practiceNext
        : l10n.practiceResults;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (!node.hasPrimaryFocus) return KeyEventResult.ignored;
        return _handleKeyEvent(event);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            screenTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [const LanguageMenu()],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Linear Progress Indicator
              ExcludeSemantics(
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  backgroundColor: isDark
                      ? AppTheme.surfaceVariantDark
                      : AppTheme.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 4,
                ),
              ),

              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Score Badge, sized to its content rather than the
                          // full column width.
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentAmber.withValues(
                                  alpha: isDark ? 0.25 : 0.15,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd,
                                ),
                                border: Border.all(
                                  color: AppTheme.accentAmber.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppTheme.accentAmber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      scoreLabel,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppTheme.accentAmber
                                            : const Color(0xFFB45309),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Question Header & Tag
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary
                                      .withValues(alpha: isDark ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusSm,
                                  ),
                                ),
                                child: Text(
                                  questionProgressLabel,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showHint = !_showHint;
                                  });
                                },
                                icon: const Icon(
                                  Icons.lightbulb_outline_rounded,
                                  size: 16,
                                ),
                                label: Text(hintLabel),
                              ),
                            ],
                          ),

                          if (_showHint) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.accentAmber.withValues(
                                  alpha: isDark ? 0.15 : 0.08,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd,
                                ),
                                border: Border.all(
                                  color: AppTheme.accentAmber.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    color: AppTheme.accentAmber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      readableMathProse(q.hint),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? const Color(0xFFFDE68A)
                                            : const Color(0xFF92400E),
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),

                          // Question Title & Prompt
                          Text(
                            q.questionTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            readableMathProse(q.prompt),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Matrix Visual Display Card
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.surfaceDark
                                    : AppTheme.scaffoldLight,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusLg,
                                ),
                                border: Border.all(
                                  color: isDark
                                      ? AppTheme.borderDark
                                      : AppTheme.borderLight,
                                ),
                              ),
                              child: _buildMatrixPreview(q.matrix, isDark),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 4 Interactive Options
                          ...List.generate(q.optionsLatex.length, (i) {
                            final optionLatex = q.optionsLatex[i];
                            return _buildOptionButton(
                              i,
                              optionLatex,
                              q.correctIndex,
                              isDark,
                            );
                          }),

                          // Feedback & Explanation Card
                          if (_hasAnswered) ...[
                            const SizedBox(height: 16),
                            TweenAnimationBuilder<double>(
                              key: ValueKey('feedback-$_currentIndex'),
                              tween: Tween(begin: 0, end: 1),
                              duration: AppTheme.motion(
                                context,
                                AppTheme.panelMs,
                              ),
                              builder: (context, value, child) =>
                                  Opacity(opacity: value, child: child),
                              child: Semantics(
                                liveRegion: true,
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isCorrect
                                        ? AppTheme.accentGreen.withValues(
                                            alpha: isDark ? 0.2 : 0.1,
                                          )
                                        : AppTheme.accentRed.withValues(
                                            alpha: isDark ? 0.2 : 0.1,
                                          ),
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMd,
                                    ),
                                    border: Border.all(
                                      color: isCorrect
                                          ? AppTheme.accentGreen
                                          : AppTheme.accentRed,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            isCorrect
                                                ? Icons.check_circle_rounded
                                                : Icons.cancel_rounded,
                                            color: isCorrect
                                                ? AppTheme.accentGreen
                                                : AppTheme.accentRed,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          // Wraps on a phone at large text
                                          // instead of running off the card.
                                          Expanded(
                                            child: Text(
                                              feedbackTitle,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (!isCorrect &&
                                          _selectedOptionIndex != null &&
                                          q.optionFeedback.length >
                                              _selectedOptionIndex!) ...[
                                        const SizedBox(height: 10),
                                        Text(
                                          q.optionFeedback[_selectedOptionIndex!],
                                          key: const ValueKey(
                                            'answer-feedback',
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Text(
                                        readableMathProse(q.explanation),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark
                                              ? AppTheme.textPrimaryDark
                                              : AppTheme.textPrimaryLight,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _nextQuestion,
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: Text(nextButtonLabel),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatrixPreview(Matrix m, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MatrixBracket(
            width: 8,
            thickness: 2.2,
            height:
                (m.rows * 64.0 * MediaQuery.textScalerOf(context).scale(1)) -
                8.0,
            isLeft: true,
          ),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(m.rows, (r) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(m.cols, (c) {
                  return SizedBox(
                    width: 80 * MediaQuery.textScalerOf(context).scale(1),
                    height: 64 * MediaQuery.textScalerOf(context).scale(1),
                    child: MatrixCellWidget(
                      value: m.get(r, c),
                      semanticLabel: lookupAppLocalizations(
                        Locale(_language),
                      ).matrixCellLabel(r + 1, c + 1, m.get(r, c).toString()),
                    ),
                  );
                }),
              );
            }),
          ),
          const SizedBox(width: 4),
          MatrixBracket(
            width: 8,
            thickness: 2.2,
            height:
                (m.rows * 64.0 * MediaQuery.textScalerOf(context).scale(1)) -
                8.0,
            isLeft: false,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    int index,
    String optionLatex,
    int correctIndex,
    bool isDark,
  ) {
    final isSelected = _selectedOptionIndex == index;
    final isCorrectOption = index == correctIndex;

    Color bgColor = isDark ? AppTheme.surfaceVariantDark : Colors.white;
    Color borderColor = isDark
        ? AppTheme.borderSubtleDark
        : AppTheme.borderSubtleLight;

    if (_hasAnswered) {
      if (isCorrectOption) {
        bgColor = AppTheme.accentGreen.withValues(alpha: isDark ? 0.28 : 0.15);
        borderColor = AppTheme.accentGreen;
      } else if (isSelected && !isCorrectOption) {
        bgColor = AppTheme.accentRed.withValues(alpha: isDark ? 0.28 : 0.15);
        borderColor = AppTheme.accentRed;
      }
    } else if (isSelected) {
      borderColor = Theme.of(context).colorScheme.primary;
    }

    final optionLetters = ['A', 'B', 'C', 'D'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Semantics(
        key: ValueKey('quiz-option-${optionLetters[index]}'),
        container: true,
        button: true,
        enabled: !_hasAnswered,
        selected: isSelected,
        // The formula sits in a horizontal scroll view, which would keep it
        // out of the button's label: the option was read as just "A".
        label: '${optionLetters[index]}: ${mathSemanticsLabel(optionLatex)}',
        excludeSemantics: true,
        child: InkWell(
          onTap: _hasAnswered ? null : () => _selectOption(index),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: AnimatedContainer(
            duration: AppTheme.motion(context),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                // Grows with the letter, which follows the text size.
                Container(
                  width: MediaQuery.textScalerOf(context).scale(28),
                  height: MediaQuery.textScalerOf(context).scale(28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? AppTheme.scaffoldDark
                        : AppTheme.surfaceVariantLight,
                    border: Border.all(color: borderColor),
                  ),
                  child: Center(
                    child: Text(
                      optionLetters[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark
                            ? Colors.white
                            : AppTheme.textPrimaryLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: MathText(optionLatex, fontSize: 15),
                    ),
                  ),
                ),
                if (_hasAnswered && isCorrectOption)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.accentGreen,
                    size: 20,
                  )
                else if (_hasAnswered && isSelected && !isCorrectOption)
                  const Icon(
                    Icons.cancel_rounded,
                    color: AppTheme.accentRed,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
