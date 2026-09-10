import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../topics/models/topic_item.dart';
import 'models/matrix_input_state.dart';

class MatrixInputCubit extends Cubit<MatrixInputState> {
  final Random _random = Random();

  MatrixInputCubit(TopicItem topic)
    : super(
        MatrixInputState(
          topic: topic,
          rowsA: 3,
          colsA: topic.isAugmentedSystem ? 4 : 3,
          dataA: _createDefaultData(3, topic.isAugmentedSystem ? 4 : 3),
          rowsB: 3,
          colsB: 3,
          dataB: _createDefaultData(3, 3),
        ),
      ) {
    if (topic.requiresSquare) {
      setDimensionsA(3, 3);
    } else if (topic.isAugmentedSystem) {
      setDimensionsA(3, 4);
    }
  }

  static List<List<String>> _createDefaultData(int rows, int cols) {
    return List.generate(
      rows,
      (r) => List.generate(cols, (c) => r == c ? '1' : '0'),
    );
  }

  void selectMatrix(int index) {
    if (index < 0 || index > (state.topic.isDualMatrix ? 1 : 0)) return;
    emit(state.copyWith(activeMatrix: index, focusedRow: 0, focusedCol: 0));
  }

  void setFocus(int row, int col, [int? matrixIndex]) {
    final index = matrixIndex ?? state.activeMatrix;
    if (index < 0 || index > (state.topic.isDualMatrix ? 1 : 0)) return;
    final rows = index == 0 ? state.rowsA : state.rowsB;
    final cols = index == 0 ? state.colsA : state.colsB;
    emit(
      state.copyWith(
        focusedRow: row.clamp(0, rows - 1),
        focusedCol: col.clamp(0, cols - 1),
        activeMatrix: index,
      ),
    );
  }

  void setDimensionsA(int rows, int cols) {
    final isEigen = state.topic.type == TopicType.eigen;
    final clampedRows = rows.clamp(isEigen ? 2 : 1, isEigen ? 3 : 5);
    final minCols = state.topic.isAugmentedSystem ? 2 : 1;
    final clampedCols = (state.topic.requiresSquare ? clampedRows : cols).clamp(
      minCols,
      5,
    );

    final newDataA = List.generate(
      clampedRows,
      (r) => List.generate(clampedCols, (c) {
        if (r < state.rowsA && c < state.colsA) {
          return state.dataA[r][c];
        }
        return r == c ? '1' : '0';
      }),
    );

    var rowsB = state.rowsB;
    var colsB = state.colsB;
    var newDataB = state.dataB;

    if (state.topic.type == TopicType.multiply) {
      // B.rows must equal A.cols
      rowsB = clampedCols;
      newDataB = List.generate(
        rowsB,
        (r) => List.generate(
          colsB,
          (c) => (r < state.rowsB && c < state.colsB) ? state.dataB[r][c] : '0',
        ),
      );
    } else if (state.topic.type == TopicType.add) {
      // Both must match
      rowsB = clampedRows;
      colsB = clampedCols;
      newDataB = List.generate(
        rowsB,
        (r) => List.generate(
          colsB,
          (c) => (r < state.rowsB && c < state.colsB) ? state.dataB[r][c] : '0',
        ),
      );
    }

    emit(
      state.copyWith(
        rowsA: clampedRows,
        colsA: clampedCols,
        dataA: newDataA,
        rowsB: rowsB,
        colsB: colsB,
        dataB: newDataB,
        focusedRow: state.focusedRow.clamp(
          0,
          (state.activeMatrix == 0 ? clampedRows : rowsB) - 1,
        ),
        focusedCol: state.focusedCol.clamp(
          0,
          (state.activeMatrix == 0 ? clampedCols : colsB) - 1,
        ),
      ),
    );
  }

  void setDimensionsB(int rows, int cols) {
    if (state.topic.type == TopicType.add) {
      setDimensionsA(rows, cols);
      return;
    }

    final clampedRows =
        (state.topic.type == TopicType.multiply ? state.colsA : rows).clamp(
          1,
          5,
        );
    final clampedCols = cols.clamp(1, 5);

    final newDataB = List.generate(
      clampedRows,
      (r) => List.generate(clampedCols, (c) {
        if (r < state.rowsB && c < state.colsB) {
          return state.dataB[r][c];
        }
        return '0';
      }),
    );

    emit(
      state.copyWith(
        rowsB: clampedRows,
        colsB: clampedCols,
        dataB: newDataB,
        focusedRow: state.activeMatrix == 1
            ? state.focusedRow.clamp(0, clampedRows - 1)
            : state.focusedRow,
        focusedCol: state.activeMatrix == 1
            ? state.focusedCol.clamp(0, clampedCols - 1)
            : state.focusedCol,
      ),
    );
  }

  void onKeyPressed(String key) {
    if (key.length != 1 || !'0123456789-./'.contains(key)) return;
    final isA = state.activeMatrix == 0;
    final r = state.focusedRow;
    final c = state.focusedCol;
    final currentVal = isA ? state.dataA[r][c] : state.dataB[r][c];

    String newVal;
    if (currentVal == '0' && key != '.' && key != '/') {
      newVal = key;
    } else if (key == '-') {
      newVal = currentVal.startsWith('-')
          ? currentVal.substring(1)
          : '-$currentVal';
    } else {
      // Prevent multiple slashes or decimals
      if (key == '/' && currentVal.contains('/')) return;
      if (key == '.' && currentVal.contains('.')) return;
      newVal = currentVal + key;
    }

    // Bound user-controlled BigInt work without limiting engine precision.
    if (newVal.length > 32) return;
    _updateCell(isA, r, c, newVal);
  }

  void onBackspace() {
    final isA = state.activeMatrix == 0;
    final r = state.focusedRow;
    final c = state.focusedCol;
    final currentVal = isA ? state.dataA[r][c] : state.dataB[r][c];

    if (currentVal.length <= 1 ||
        (currentVal.length == 2 && currentVal.startsWith('-'))) {
      _updateCell(isA, r, c, '0');
    } else {
      _updateCell(isA, r, c, currentVal.substring(0, currentVal.length - 1));
    }
  }

  void onClear() {
    final isA = state.activeMatrix == 0;
    _updateCell(isA, state.focusedRow, state.focusedCol, '0');
  }

  void onNextCell() {
    final isA = state.activeMatrix == 0;
    final maxR = isA ? state.rowsA : state.rowsB;
    final maxC = isA ? state.colsA : state.colsB;

    var nextC = state.focusedCol + 1;
    var nextR = state.focusedRow;

    if (nextC >= maxC) {
      nextC = 0;
      nextR++;
      if (nextR >= maxR) {
        nextR = 0; // Wrap around
      }
    }
    emit(state.copyWith(focusedRow: nextR, focusedCol: nextC));
  }

  void onPrevCell() {
    final isA = state.activeMatrix == 0;
    final maxR = isA ? state.rowsA : state.rowsB;
    final maxC = isA ? state.colsA : state.colsB;

    var prevC = state.focusedCol - 1;
    var prevR = state.focusedRow;

    if (prevC < 0) {
      prevC = maxC - 1;
      prevR--;
      if (prevR < 0) {
        prevR = maxR - 1; // Wrap around
      }
    }
    emit(state.copyWith(focusedRow: prevR, focusedCol: prevC));
  }

  void presetRandom() {
    final isA = state.activeMatrix == 0;
    final rows = isA ? state.rowsA : state.rowsB;
    final cols = isA ? state.colsA : state.colsB;

    final newData = List.generate(
      rows,
      (_) => List.generate(cols, (_) => (_random.nextInt(11) - 3).toString()),
    );

    if (isA) {
      emit(state.copyWith(dataA: newData));
    } else {
      emit(state.copyWith(dataB: newData));
    }
  }

  void presetIdentity() {
    final isA = state.activeMatrix == 0;
    final rows = isA ? state.rowsA : state.rowsB;
    final cols = isA ? state.colsA : state.colsB;

    final newData = List.generate(
      rows,
      (r) => List.generate(cols, (c) => r == c ? '1' : '0'),
    );

    if (isA) {
      emit(state.copyWith(dataA: newData));
    } else {
      emit(state.copyWith(dataB: newData));
    }
  }

  void presetClear() {
    final isA = state.activeMatrix == 0;
    final rows = isA ? state.rowsA : state.rowsB;
    final cols = isA ? state.colsA : state.colsB;

    final newData = List.generate(rows, (_) => List.generate(cols, (_) => '0'));

    if (isA) {
      emit(state.copyWith(dataA: newData));
    } else {
      emit(state.copyWith(dataB: newData));
    }
  }

  void _updateCell(bool isA, int r, int c, String val) {
    if (isA) {
      final updated = List<List<String>>.from(
        state.dataA.map((row) => List<String>.from(row)),
      );
      updated[r][c] = val;
      emit(state.copyWith(dataA: updated));
    } else {
      final updated = List<List<String>>.from(
        state.dataB.map((row) => List<String>.from(row)),
      );
      updated[r][c] = val;
      emit(state.copyWith(dataB: updated));
    }
  }
}
