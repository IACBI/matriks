import '../rational/rational.dart';

/// Immutable 2D Matrix of [Rational] numbers.
class Matrix {
  final int rows;
  final int cols;
  final List<List<Rational>> _data;

  Matrix(List<List<Rational>> data)
      : rows = data.length,
        cols = data.isEmpty ? 0 : data.first.length,
        _data = List.unmodifiable(
          data.map((row) => List<Rational>.unmodifiable(row)).toList(),
        ) {
    if (rows == 0 || cols == 0) {
      throw ArgumentError('Matrix dimensions must be greater than zero.');
    }
    for (int r = 1; r < rows; r++) {
      if (data[r].length != cols) {
        throw ArgumentError('All rows in a Matrix must have the same column length.');
      }
    }
  }

  factory Matrix.fromInts(List<List<int>> data) {
    return Matrix(
      data.map((row) => row.map((val) => Rational.fromInt(val)).toList()).toList(),
    );
  }

  factory Matrix.fromDoubles(List<List<double>> data) {
    return Matrix(
      data
          .map((row) => row.map((val) => Rational.parse(val.toString())).toList())
          .toList(),
    );
  }

  factory Matrix.identity(int n) {
    if (n <= 0) throw ArgumentError('Identity matrix dimension must be > 0');
    final data = List.generate(
      n,
      (r) => List.generate(n, (c) => r == c ? Rational.one : Rational.zero),
    );
    return Matrix(data);
  }

  factory Matrix.zero(int rows, int cols) {
    final data = List.generate(
      rows,
      (_) => List.generate(cols, (_) => Rational.zero),
    );
    return Matrix(data);
  }

  factory Matrix.fill(int rows, int cols, Rational value) {
    final data = List.generate(
      rows,
      (_) => List.generate(cols, (_) => value),
    );
    return Matrix(data);
  }

  Rational get(int r, int c) {
    if (r < 0 || r >= rows || c < 0 || c >= cols) {
      throw RangeError('Index ($r, $c) out of bounds for matrix ${rows}x$cols');
    }
    return _data[r][c];
  }

  List<Rational> getRow(int r) => _data[r];

  List<Rational> getCol(int c) {
    if (c < 0 || c >= cols) throw RangeError('Column $c out of bounds');
    return List.generate(rows, (r) => _data[r][c]);
  }

  bool get isSquare => rows == cols;

  /// Creates a new matrix swapping rows [r1] and [r2]
  Matrix swapRows(int r1, int r2) {
    if (r1 == r2) return this;
    final mutable = _toMutable();
    final temp = mutable[r1];
    mutable[r1] = mutable[r2];
    mutable[r2] = temp;
    return Matrix(mutable);
  }

  /// Creates a new matrix with row [r] scaled by [scalar]
  Matrix scaleRow(int r, Rational scalar) {
    if (scalar == Rational.one) return this;
    final mutable = _toMutable();
    mutable[r] = mutable[r].map((x) => x * scalar).toList();
    return Matrix(mutable);
  }

  /// Creates a new matrix where targetRow = targetRow + (factor * sourceRow)
  Matrix addRowMultiple(int targetRow, int sourceRow, Rational factor) {
    if (factor.isZero) return this;
    final mutable = _toMutable();
    for (int c = 0; c < cols; c++) {
      mutable[targetRow][c] = mutable[targetRow][c] + (factor * mutable[sourceRow][c]);
    }
    return Matrix(mutable);
  }

  /// Matrix transpose $A^T$
  Matrix transpose() {
    final data = List.generate(
      cols,
      (c) => List.generate(rows, (r) => _data[r][c]),
    );
    return Matrix(data);
  }

  /// Horizontally augments this matrix with [other] -> [this | other]
  Matrix augment(Matrix other) {
    if (rows != other.rows) {
      throw ArgumentError('Cannot augment matrices with different row counts: $rows vs ${other.rows}');
    }
    final data = List.generate(
      rows,
      (r) => [..._data[r], ...other._data[r]],
    );
    return Matrix(data);
  }

  /// Splits this matrix at column index [colSplit] -> (Left, Right)
  (Matrix, Matrix) split(int colSplit) {
    if (colSplit <= 0 || colSplit >= cols) {
      throw RangeError('Split column $colSplit is out of range (1..${cols - 1})');
    }
    final leftData = List.generate(
      rows,
      (r) => _data[r].sublist(0, colSplit),
    );
    final rightData = List.generate(
      rows,
      (r) => _data[r].sublist(colSplit),
    );
    return (Matrix(leftData), Matrix(rightData));
  }

  /// Creates a new matrix with entry at (r, c) updated to [val]
  Matrix setEntry(int r, int c, Rational val) {
    final mutable = _toMutable();
    mutable[r][c] = val;
    return Matrix(mutable);
  }

  /// Returns submatrix omitting [excludeRow] and [excludeCol]
  Matrix submatrix(int excludeRow, int excludeCol) {
    if (rows <= 1 || cols <= 1) {
      throw StateError('Cannot create submatrix of 1x1 or smaller matrix.');
    }
    final data = <List<Rational>>[];
    for (int r = 0; r < rows; r++) {
      if (r == excludeRow) continue;
      final rowList = <Rational>[];
      for (int c = 0; c < cols; c++) {
        if (c == excludeCol) continue;
        rowList.add(_data[r][c]);
      }
      data.add(rowList);
    }
    return Matrix(data);
  }

  List<List<Rational>> _toMutable() {
    return _data.map((row) => List<Rational>.from(row)).toList();
  }

  List<List<Rational>> toList() => _toMutable();

  String toLatex() {
    final buffer = StringBuffer(r'\begin{pmatrix}' '\n');
    for (int r = 0; r < rows; r++) {
      buffer.write('  ');
      for (int c = 0; c < cols; c++) {
        buffer.write(_data[r][c].toLatex());
        if (c < cols - 1) buffer.write(' & ');
      }
      if (r < rows - 1) buffer.write(r' \\');
      buffer.write('\n');
    }
    buffer.write(r'\end{pmatrix}');
    return buffer.toString();
  }

  String toAscii() {
    final buffer = StringBuffer();
    for (int r = 0; r < rows; r++) {
      buffer.write('[ ');
      for (int c = 0; c < cols; c++) {
        buffer.write(_data[r][c].toString().padLeft(6));
        if (c < cols - 1) buffer.write(', ');
      }
      buffer.writeln(' ]');
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Matrix || other.rows != rows || other.cols != cols) return false;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (_data[r][c] != other._data[r][c]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    int hash = Object.hash(rows, cols);
    for (final row in _data) {
      for (final cell in row) {
        hash = Object.hash(hash, cell);
      }
    }
    return hash;
  }

  @override
  String toString() => toAscii();
}
