import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

import 'package:matrix_engine/matrix_engine.dart';

class QuizQuestion {
  final String id;
  final String questionTitle;
  final String prompt;
  final Matrix matrix;
  final List<String> optionsLatex;
  final int correctIndex;
  final String explanation;
  final String hint;
  final List<String> optionFeedback;

  const QuizQuestion({
    required this.id,
    required this.questionTitle,
    required this.prompt,
    required this.matrix,
    required this.optionsLatex,
    required this.correctIndex,
    required this.explanation,
    required this.hint,
    this.optionFeedback = const [],
  });
}

class QuizBank {
  static List<QuizQuestion> get questions => getQuestions(language: 'tr');
  static List<QuizQuestion> getQuestions({String language = 'tr'}) {
    final l = lookupAppLocalizations(
      Locale(
        ['en', 'tr', 'es', 'ru', 'zh'].contains(language) ? language : 'en',
      ),
    );
    return [
      QuizQuestion(
        id: 'q1',
        questionTitle: l.quizQ1QuestionTitle,
        prompt: l.quizQ1Prompt,
        matrix: Matrix.fromInts([
          [1, 3],
          [2, 5],
        ]),
        optionsLatex: [
          r'R_2 \leftarrow R_2 - 2R_1',
          r'R_2 \leftarrow R_2 + 2R_1',
          r'R_1 \leftrightarrow R_2',
          r'R_2 \leftarrow \frac{1}{2} R_2',
        ],
        correctIndex: 0,
        explanation: l.quizQ1Explanation,
        hint: l.quizQ1Hint,
        optionFeedback: [
          l.quizQ1Feedback0,
          l.quizQ1Feedback1,
          l.quizQ1Feedback2,
          l.quizQ1Feedback3,
        ],
      ),
      QuizQuestion(
        id: 'q2',
        questionTitle: l.quizQ2QuestionTitle,
        prompt: l.quizQ2Prompt,
        matrix: Matrix.fromInts([
          [0, 2, 4],
          [3, 1, -1],
          [1, 5, 2],
        ]),
        optionsLatex: [
          r'R_1 \leftarrow R_1 + R_2',
          r'R_1 \leftrightarrow R_2',
          r'R_2 \leftarrow R_2 - 3R_3',
          r'R_3 \leftarrow \frac{1}{2} R_3',
        ],
        correctIndex: 1,
        explanation: l.quizQ2Explanation,
        hint: l.quizQ2Hint,
        optionFeedback: [
          l.quizQ2Feedback0,
          l.quizQ2Feedback1,
          l.quizQ2Feedback2,
          l.quizQ2Feedback3,
        ],
      ),
      QuizQuestion(
        id: 'q3',
        questionTitle: l.quizQ3QuestionTitle,
        prompt: l.quizQ3Prompt,
        matrix: Matrix.fromInts([
          [1, 2, 3],
          [0, -3, 6],
          [0, 0, 4],
        ]),
        optionsLatex: [
          r'R_2 \leftarrow R_2 + 4R_1',
          r'R_2 \leftarrow -\frac{1}{3} R_2',
          r'R_2 \leftarrow 3 R_2',
          r'R_2 \leftrightarrow R_3',
        ],
        correctIndex: 1,
        explanation: l.quizQ3Explanation,
        hint: l.quizQ3Hint,
        optionFeedback: [
          l.quizQ3Feedback0,
          l.quizQ3Feedback1,
          l.quizQ3Feedback2,
          l.quizQ3Feedback3,
        ],
      ),
      QuizQuestion(
        id: 'q4',
        questionTitle: l.quizQ4QuestionTitle,
        prompt: l.quizQ4Prompt,
        matrix: Matrix.fromInts([
          [1, 2, 0],
          [0, 1, 4],
          [0, 0, 0],
        ]),
        optionsLatex: [
          r'\text{rank}(A) = 3',
          r'\text{rank}(A) = 2',
          r'\text{rank}(A) = 1',
          r'\text{rank}(A) = 0',
        ],
        correctIndex: 1,
        explanation: l.quizQ4Explanation,
        hint: l.quizQ4Hint,
        optionFeedback: [
          l.quizQ4Feedback0,
          l.quizQ4Feedback1,
          l.quizQ4Feedback2,
          l.quizQ4Feedback3,
        ],
      ),
      QuizQuestion(
        id: 'q5',
        questionTitle: l.quizQ5QuestionTitle,
        prompt: l.quizQ5Prompt,
        matrix: Matrix.fromInts([
          [2, 5, 7],
          [0, 3, -1],
          [0, 0, 4],
        ]),
        optionsLatex: [
          r'\det(A) = 2 + 3 + 4 = 9',
          r'\det(A) = 2 \cdot 3 \cdot 4 = 24',
          r'\det(A) = 0',
          r'\det(A) = -24',
        ],
        correctIndex: 1,
        explanation: l.quizQ5Explanation,
        hint: l.quizQ5Hint,
        optionFeedback: [
          l.quizQ5Feedback0,
          l.quizQ5Feedback1,
          l.quizQ5Feedback2,
          l.quizQ5Feedback3,
        ],
      ),
    ];
  }
}
