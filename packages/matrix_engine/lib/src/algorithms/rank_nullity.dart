import '../model/matrix.dart';
import '../model/step.dart';
import 'gauss_jordan.dart';

class RankNullityResult {
  final int rank;
  final int nullity;
  final int totalCols;
  final List<int> pivotColumnIndices;
  final List<int> freeColumnIndices;

  const RankNullityResult({
    required this.rank,
    required this.nullity,
    required this.totalCols,
    required this.pivotColumnIndices,
    required this.freeColumnIndices,
  });
}

class RankNullitySolver {
  /// Computes rank and nullity of matrix with step-by-step educational explanations
  static StepSolution solve(Matrix matrix) {
    final gjSolution = GaussJordanSolver.solve(
      matrix,
      const EliminationOptions(toRref: true, normalizePivotToOne: true),
    );

    final rref = gjSolution.finalMatrix;
    final steps = List<MatrixStep>.from(gjSolution.steps);
    var stepCounter = steps.length;

    final pivotCols = <int>[];
    final rowCount = rref.rows;
    final colCount = rref.cols;

    for (int r = 0; r < rowCount; r++) {
      for (int c = 0; c < colCount; c++) {
        if (!rref.get(r, c).isZero) {
          pivotCols.add(c);
          break; // Next row
        }
      }
    }

    final rank = pivotCols.length;
    final nullity = colCount - rank;
    final freeCols = <int>[];
    for (int c = 0; c < colCount; c++) {
      if (!pivotCols.contains(c)) {
        freeCols.add(c);
      }
    }

    final rrefSnap = MatrixSnapshot.fromMatrix(rref);

    // Final step: Rank-Nullity Theorem summary
    final highlights = <CellHighlight>[
      for (final pc in pivotCols)
        for (int r = 0; r < rowCount; r++)
          CellHighlight(row: r, col: pc, type: HighlightType.pivot),
      for (final fc in freeCols)
        for (int r = 0; r < rowCount; r++)
          CellHighlight(row: r, col: fc, type: HighlightType.source),
    ];

    final summaryLatex =
        '\\text{rank}(A) + \\text{nullity}(A) = $rank + $nullity = $colCount';

    steps.add(MatrixStep(
      stepIndex: ++stepCounter,
      titleKey: 'rank_nullity_title',
      titleParams: {'rank': rank, 'nullity': nullity},
      explanationKey: 'rank_nullity_desc',
      explanationParams: {
        'rank': rank,
        'nullity': nullity,
        'cols': colCount,
        'formula': summaryLatex,
      },
      matrixBefore: rrefSnap,
      matrixAfter: rrefSnap,
      transformation: RankNullityTransformation(
        rank: rank,
        nullity: nullity,
        totalCols: colCount,
      ),
      highlights: highlights,
    ));

    return StepSolution(
      operationKey: 'op_rank_nullity',
      initialMatrix: matrix,
      steps: steps,
      finalMatrix: rref,
      result: RankNullityResult(
        rank: rank,
        nullity: nullity,
        totalCols: colCount,
        pivotColumnIndices: pivotCols,
        freeColumnIndices: freeCols,
      ),
      resultLatex: summaryLatex,
    );
  }
}
