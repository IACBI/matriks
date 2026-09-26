import '../rational/rational.dart';
import 'matrix.dart';

/// Semantic roles for highlighting elements in the UI
enum HighlightType {
  pivot, // The active pivot element (accent gold/amber)
  target, // The row/column/cell being modified (bright cyan/blue)
  source, // The row/column/cell used to calculate the transformation (purple/indigo)
  zeroed, // An element that has successfully become zero (emerald green)
  inactive, // Dimmed out element (grayed out)
  selected, // General selection focus
}

/// Highlight details for a specific cell or region
class CellHighlight {
  final int row;
  final int col;
  final HighlightType type;
  final String? badgeText;

  const CellHighlight({
    required this.row,
    required this.col,
    required this.type,
    this.badgeText,
  });
}

/// Breakdown of a single cell's arithmetic for the student to inspect
class SubCalculation {
  final int targetRow;
  final int targetCol;
  final String formulaLatex;
  final Rational result;

  const SubCalculation({
    required this.targetRow,
    required this.targetCol,
    required this.formulaLatex,
    required this.result,
  });
}

/// Display structure of the matrix (e.g. augmented for equations or inverse)
enum MatrixStructureType {
  standard, // Regular A matrix
  augmented, // [A | b] for linear systems
  block, // [A | I] for matrix inversion
}

/// Snapshot of the matrix at a particular instant in time
class MatrixSnapshot {
  final int rows;
  final int cols;
  final List<List<Rational>> values;
  final MatrixStructureType structure;
  final int? augmentedColIndex; // Column index after which vertical separator line is drawn

  MatrixSnapshot({
    required this.rows,
    required this.cols,
    required List<List<Rational>> values,
    this.structure = MatrixStructureType.standard,
    this.augmentedColIndex,
  }) : values = List.unmodifiable(
         values.map((r) => List<Rational>.unmodifiable(r)).toList(),
       );

  factory MatrixSnapshot.fromMatrix(
    Matrix matrix, {
    MatrixStructureType structure = MatrixStructureType.standard,
    int? augmentedColIndex,
  }) {
    return MatrixSnapshot(
      rows: matrix.rows,
      cols: matrix.cols,
      values: matrix.toList(),
      structure: structure,
      augmentedColIndex: augmentedColIndex,
    );
  }

  Rational get(int r, int c) => values[r][c];

  Matrix toMatrix() => Matrix(values);
}

/// Polymorphic transformation description for animation controllers
sealed class StepTransformation {
  const StepTransformation();
}

class RowSwapTransformation extends StepTransformation {
  final int rowA;
  final int rowB;
  const RowSwapTransformation(this.rowA, this.rowB);
}

class RowScaleTransformation extends StepTransformation {
  final int row;
  final Rational scalar;
  const RowScaleTransformation(this.row, this.scalar);
}

class RowEliminationTransformation extends StepTransformation {
  final int targetRow;
  final int sourceRow;

  /// targetRow ← targetRow + factor · sourceRow (the negated multiplier).
  final Rational factor;
  const RowEliminationTransformation({
    required this.targetRow,
    required this.sourceRow,
    required this.factor,
  });
}

/// A row elimination during LU factorization. The multiplier is also stored
/// in L; [lower] is L after this step and [lowerRow]/[lowerCol] the entry
/// that was written.
class LUEliminationTransformation extends RowEliminationTransformation {
  final MatrixSnapshot lower;
  final int lowerRow;
  final int lowerCol;
  const LUEliminationTransformation({
    required super.targetRow,
    required super.sourceRow,
    required super.factor,
    required this.lower,
    required this.lowerRow,
    required this.lowerCol,
  });
}

/// 2×2 adjugate: [[a, b], [c, d]] becomes [[d, -b], [-c, a]]. The diagonal
/// entries trade places and the off-diagonal entries change sign.
class AdjugateTransformation extends StepTransformation {
  const AdjugateTransformation();
}

/// Every entry multiplied by the same [scalar].
class MatrixScaleTransformation extends StepTransformation {
  final Rational scalar;
  const MatrixScaleTransformation(this.scalar);
}

/// Determinant of the original matrix after triangularization, including swaps.
class DeterminantDiagonalProductTransformation extends StepTransformation {
  final List<Rational> diagonalElements;
  final Rational sign;
  DeterminantDiagonalProductTransformation({
    required List<Rational> diagonalElements,
    required this.sign,
  }) : diagonalElements = List.unmodifiable(diagonalElements);
}

class DeterminantCrossProductTransformation extends StepTransformation {
  final Rational mainDiagonalProduct;
  final Rational antiDiagonalProduct;
  final int phase; // 1 = main diagonal, 2 = anti diagonal, 3 = both

  /// Both products were shown in earlier steps; this step only combines them.
  final bool recap;
  const DeterminantCrossProductTransformation({
    required this.mainDiagonalProduct,
    required this.antiDiagonalProduct,
    this.phase = 3,
    this.recap = false,
  });
}

class DeterminantSarrusTransformation extends StepTransformation {
  final List<Rational> positiveProducts;
  final List<Rational> negativeProducts;
  final int phase; // 1 = positive diagonals, 2 = negative diagonals, 3 = both

  /// Both groups were shown in earlier steps; this step only combines them.
  final bool recap;
  const DeterminantSarrusTransformation({
    required this.positiveProducts,
    required this.negativeProducts,
    this.phase = 3,
    this.recap = false,
  });
}

class MatrixElementMultiplicationTransformation extends StepTransformation {
  final int targetRow;
  final int targetCol;
  final List<Rational> rowElements;
  final List<Rational> colElements;
  final Rational result;
  const MatrixElementMultiplicationTransformation({
    required this.targetRow,
    required this.targetCol,
    required this.rowElements,
    required this.colElements,
    required this.result,
  });
}

class MatrixElementAdditionTransformation extends StepTransformation {
  final int row;
  final int col;
  final Rational left;
  final Rational right;
  const MatrixElementAdditionTransformation(
    this.row,
    this.col,
    this.left,
    this.right,
  );
}

class IdentitySeparationTransformation extends StepTransformation {
  final int splitCol;
  const IdentitySeparationTransformation(this.splitCol);
}

class InformationalStepTransformation extends StepTransformation {
  final String note;

  /// Formula shown above the matrix (LaTeX), when the matrix is not simply
  /// the input: an eigenvector step shows A - λI and the vector it yields.
  final String? sceneLatex;

  const InformationalStepTransformation(this.note, {this.sceneLatex});
}

enum LinearSystemType { unique, infinite, inconsistent }

class LinearSystemTransformation extends StepTransformation {
  final LinearSystemType type;
  final String summaryLatex;
  const LinearSystemTransformation(this.type, this.summaryLatex);
}

class RankNullityTransformation extends StepTransformation {
  final int rank;
  final int nullity;
  final int totalCols;
  const RankNullityTransformation({
    required this.rank,
    required this.nullity,
    required this.totalCols,
  });
}

class EigenTransformation extends StepTransformation {
  final String polynomialLatex;
  final List<Rational> realEigenvalues;
  const EigenTransformation({
    required this.polynomialLatex,
    required this.realEigenvalues,
  });
}

class LUDecompositionTransformation extends StepTransformation {
  final MatrixSnapshot lSnapshot;
  final MatrixSnapshot uSnapshot;
  const LUDecompositionTransformation({
    required this.lSnapshot,
    required this.uSnapshot,
  });
}

/// A single atomic step in a linear algebra algorithm
class MatrixStep {
  final int stepIndex;
  final String titleKey;
  final Map<String, dynamic> titleParams;
  final String explanationKey;
  final Map<String, dynamic> explanationParams;
  final MatrixSnapshot matrixBefore;
  final MatrixSnapshot matrixAfter;
  final StepTransformation transformation;
  final List<CellHighlight> highlights;
  final List<SubCalculation> subCalculations;

  const MatrixStep({
    required this.stepIndex,
    required this.titleKey,
    this.titleParams = const {},
    required this.explanationKey,
    this.explanationParams = const {},
    required this.matrixBefore,
    required this.matrixAfter,
    required this.transformation,
    required this.highlights,
    this.subCalculations = const [],
  });
}

/// The complete structured output of an algorithm execution
enum ResultAccuracy { exact, approximate }

enum ResultCompleteness { complete, partial, unsupported }

class StepSolution {
  final ResultAccuracy accuracy;
  final ResultCompleteness completeness;
  final int? decimalPlaces;
  final String operationKey;
  final Matrix initialMatrix;
  final List<MatrixStep> steps;
  final Matrix finalMatrix;
  final dynamic
  result; // e.g. Rational determinant, Matrix inverse, Vector solution, or null
  final String? resultLatex;
  final bool isSuccess;
  final String? errorMessageKey;

  const StepSolution({
    this.accuracy = ResultAccuracy.exact,
    this.completeness = ResultCompleteness.complete,
    this.decimalPlaces,
    required this.operationKey,
    required this.initialMatrix,
    required this.steps,
    required this.finalMatrix,
    this.result,
    this.resultLatex,
    this.isSuccess = true,
    this.errorMessageKey,
  });

  int get totalSteps => steps.length;
}
