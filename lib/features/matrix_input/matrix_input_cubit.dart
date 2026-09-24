import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_engine/matrix_engine.dart';

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
      // Toggling the sign of a lone minus returns to zero, never to an empty
      // cell that reads as a value.
      newVal = currentVal == '-'
          ? '0'
          : currentVal.startsWith('-')
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

  /// Moves down one row in the same column, wrapping to the top.
  void onNextRow() {
    final rows = state.activeMatrix == 0 ? state.rowsA : state.rowsB;
    emit(state.copyWith(focusedRow: (state.focusedRow + 1) % rows));
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

  MatrixInputState? _beforePreset;

  /// Restores the matrix replaced by the last preset.
  void undoPreset() {
    final previous = _beforePreset;
    if (previous == null) return;
    _beforePreset = null;
    emit(
      state.copyWith(
        dataA: previous.dataA,
        dataB: previous.dataB,
        rowsA: previous.rowsA,
        colsA: previous.colsA,
        rowsB: previous.rowsB,
        colsB: previous.colsB,
      ),
    );
  }

  void _applyPreset(List<List<String>> data) {
    _beforePreset = state;
    emit(
      state.activeMatrix == 0
          ? state.copyWith(dataA: data)
          : state.copyWith(dataB: data),
    );
  }

  /// Random entries suited to the topic: eigen examples get integer
  /// eigenvalues and inverse examples are invertible, so a random matrix is
  /// a useful lesson rather than an approximation or an error.
  void presetRandom() {
    final isA = state.activeMatrix == 0;
    final rows = isA ? state.rowsA : state.rowsB;
    final cols = isA ? state.colsA : state.colsB;
    final type = state.topic.type;

    List<List<int>> generate() =>
        List.generate(rows, (_) => List.generate(cols, (_) => _random.nextInt(11) - 3));

    List<List<int>> data;
    if (isA && type == TopicType.eigen) {
      data = _integerSpectrum(rows);
    } else if (isA &&
        (type == TopicType.inverse || type == TopicType.lu) &&
        rows == cols) {
      data = generate();
      for (var attempt = 0; attempt < 20; attempt++) {
        if (!_integerDeterminant(data).isZero) break;
        data = generate();
      }
    } else {
      data = generate();
    }
    _applyPreset([
      for (final row in data) [for (final value in row) '$value'],
    ]);
  }

  /// P D P⁻¹ with a random diagonal D and a unimodular integer P, so the
  /// entries stay integers and the eigenvalues are the diagonal of D.
  List<List<int>> _integerSpectrum(int n) {
    final d = List.generate(n, (_) => _random.nextInt(9) - 4);
    var p = _elementary(n, 0, 0, 0);
    var pInv = p;
    for (var step = 0; step < 2; step++) {
      final i = _random.nextInt(n);
      final j = (i + 1 + _random.nextInt(n - 1)) % n;
      final k = _random.nextBool() ? 1 : -1;
      // P ← P·E and P⁻¹ ← E⁻¹·P⁻¹, where E = I + k·e(i,j), E⁻¹ = I − k·e(i,j).
      p = _multiply(p, _elementary(n, i, j, k));
      pInv = _multiply(_elementary(n, i, j, -k), pInv);
    }
    final diagonal = List.generate(
      n,
      (r) => List.generate(n, (c) => r == c ? d[r] : 0),
    );
    return _multiply(_multiply(p, diagonal), pInv);
  }

  /// The identity plus [k] at (i, j); with k = 0 it is the identity.
  static List<List<int>> _elementary(int n, int i, int j, int k) =>
      List.generate(
        n,
        (r) => List.generate(
          n,
          (c) => (r == c ? 1 : 0) + (r == i && c == j && i != j ? k : 0),
        ),
      );

  static List<List<int>> _multiply(List<List<int>> a, List<List<int>> b) =>
      List.generate(
        a.length,
        (r) => List.generate(b.first.length, (c) {
          var sum = 0;
          for (var m = 0; m < b.length; m++) {
            sum += a[r][m] * b[m][c];
          }
          return sum;
        }),
      );

  static Rational _integerDeterminant(List<List<int>> data) {
    var matrix = Matrix.fromInts(data);
    var det = Rational.one;
    for (var c = 0; c < matrix.cols; c++) {
      var pivot = -1;
      for (var r = c; r < matrix.rows; r++) {
        if (!matrix.get(r, c).isZero) {
          pivot = r;
          break;
        }
      }
      if (pivot < 0) return Rational.zero;
      if (pivot != c) {
        matrix = matrix.swapRows(pivot, c);
        det = -det;
      }
      det = det * matrix.get(c, c);
      for (var r = c + 1; r < matrix.rows; r++) {
        matrix = matrix.addRowMultiple(
          r,
          c,
          -(matrix.get(r, c) / matrix.get(c, c)),
        );
      }
    }
    return det;
  }

  void presetIdentity() {
    final isA = state.activeMatrix == 0;
    final rows = isA ? state.rowsA : state.rowsB;
    final cols = isA ? state.colsA : state.colsB;
    _applyPreset(
      List.generate(rows, (r) => List.generate(cols, (c) => r == c ? '1' : '0')),
    );
  }

  void presetClear() {
    final isA = state.activeMatrix == 0;
    final rows = isA ? state.rowsA : state.rowsB;
    final cols = isA ? state.colsA : state.colsB;
    _applyPreset(List.generate(rows, (_) => List.generate(cols, (_) => '0')));
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
