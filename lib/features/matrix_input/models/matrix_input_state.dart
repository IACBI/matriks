import 'package:matrix_engine/matrix_engine.dart';

import '../../topics/models/topic_item.dart';

class MatrixInputState {
  final TopicItem topic;
  final int rowsA;
  final int colsA;
  final List<List<String>> dataA;

  final int rowsB;
  final int colsB;
  final List<List<String>> dataB;

  final int activeMatrix; // 0 for A, 1 for B
  final int focusedRow;
  final int focusedCol;
  final String? errorMessage;

  const MatrixInputState({
    required this.topic,
    required this.rowsA,
    required this.colsA,
    required this.dataA,
    required this.rowsB,
    required this.colsB,
    required this.dataB,
    this.activeMatrix = 0,
    this.focusedRow = 0,
    this.focusedCol = 0,
    this.errorMessage,
  });

  Matrix toMatrixA() {
    final values = List.generate(
      rowsA,
      (r) => List.generate(colsA, (c) => Rational.parse(dataA[r][c])),
    );
    return Matrix(values);
  }

  Matrix toMatrixB() {
    final values = List.generate(
      rowsB,
      (r) => List.generate(colsB, (c) => Rational.parse(dataB[r][c])),
    );
    return Matrix(values);
  }

  MatrixInputState copyWith({
    TopicItem? topic,
    int? rowsA,
    int? colsA,
    List<List<String>>? dataA,
    int? rowsB,
    int? colsB,
    List<List<String>>? dataB,
    int? activeMatrix,
    int? focusedRow,
    int? focusedCol,
    String? Function()? errorMessage,
  }) {
    return MatrixInputState(
      topic: topic ?? this.topic,
      rowsA: rowsA ?? this.rowsA,
      colsA: colsA ?? this.colsA,
      dataA: dataA ?? this.dataA,
      rowsB: rowsB ?? this.rowsB,
      colsB: colsB ?? this.colsB,
      dataB: dataB ?? this.dataB,
      activeMatrix: activeMatrix ?? this.activeMatrix,
      focusedRow: focusedRow ?? this.focusedRow,
      focusedCol: focusedCol ?? this.focusedCol,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
