import '../model/matrix.dart';
import '../model/step.dart';
import '../rational/rational.dart';
import 'gauss_jordan.dart';

class LinearSystemResult {
  final LinearSystemType type;
  final List<Rational>? uniqueSolution; // Present if unique
  final List<int> basicVariables;
  final List<int> freeVariables;
  final String solutionLatex;

  const LinearSystemResult({
    required this.type,
    this.uniqueSolution,
    required this.basicVariables,
    required this.freeVariables,
    required this.solutionLatex,
  });
}

class LinearSystemsSolver {
  /// Solves the linear system A * x = b, represented by augmented matrix [A | b]
  static StepSolution solve(Matrix augmentedMatrix) {
    final rowCount = augmentedMatrix.rows;
    final totalCols = augmentedMatrix.cols;
    if (totalCols < 2) {
      throw ArgumentError('Augmented matrix must have at least 2 columns [A | b].');
    }
    final varCount = totalCols - 1; // Number of unknown variables x_1 .. x_n

    // Step 1..K: Gauss-Jordan elimination on augmented matrix
    final gjSolution = GaussJordanSolver.solve(
      augmentedMatrix,
      EliminationOptions(
        toRref: true,
        normalizePivotToOne: true,
        augmentedColIndex: varCount,
        structure: MatrixStructureType.augmented,
      ),
    );

    final rref = gjSolution.finalMatrix;
    final steps = List<MatrixStep>.from(gjSolution.steps);
    var stepCounter = steps.length;

    // Analyze RREF for consistency & solutions
    int? contradictionRow;
    final pivotCols = <int>[];
    final pivotRowForCol = <int, int>{};

    for (int r = 0; r < rowCount; r++) {
      int firstNonZeroCol = -1;
      for (int c = 0; c < varCount; c++) {
        if (!rref.get(r, c).isZero) {
          firstNonZeroCol = c;
          break;
        }
      }

      if (firstNonZeroCol == -1) {
        // All coefficients in row are zero
        final constVal = rref.get(r, varCount);
        if (!constVal.isZero) {
          contradictionRow = r;
          break;
        }
      } else {
        pivotCols.add(firstNonZeroCol);
        pivotRowForCol[firstNonZeroCol] = r;
      }
    }

    final freeCols = <int>[];
    for (int c = 0; c < varCount; c++) {
      if (!pivotCols.contains(c)) {
        freeCols.add(c);
      }
    }

    final rrefSnap = MatrixSnapshot.fromMatrix(
      rref,
      structure: MatrixStructureType.augmented,
      augmentedColIndex: varCount,
    );

    // Case 1: Inconsistent (No Solution)
    if (contradictionRow != null) {
      final constVal = rref.get(contradictionRow, varCount);
      final highlights = <CellHighlight>[
        for (int c = 0; c < varCount; c++)
          CellHighlight(row: contradictionRow, col: c, type: HighlightType.zeroed),
        CellHighlight(row: contradictionRow, col: varCount, type: HighlightType.target, badgeText: '≠ 0'),
      ];

      final formula = '0 = ${constVal.toLatex()} \\implies \\text{False}';

      steps.add(MatrixStep(
        stepIndex: ++stepCounter,
        titleKey: 'system_inconsistent_title',
        titleParams: {'row': contradictionRow + 1},
        explanationKey: 'system_inconsistent_desc',
        explanationParams: {
          'row': contradictionRow + 1,
          'val': constVal.toLatex(),
        },
        matrixBefore: rrefSnap,
        matrixAfter: rrefSnap,
        transformation: const LinearSystemTransformation(
          LinearSystemType.inconsistent,
          r'\text{No Solution (Inconsistent System)}',
        ),
        highlights: highlights,
        subCalculations: [
          SubCalculation(
            targetRow: contradictionRow,
            targetCol: varCount,
            formulaLatex: formula,
            result: constVal,
          ),
        ],
      ));

      return StepSolution(
        operationKey: 'op_linear_systems',
        initialMatrix: augmentedMatrix,
        steps: steps,
        finalMatrix: rref,
        result: const LinearSystemResult(
          type: LinearSystemType.inconsistent,
          basicVariables: [],
          freeVariables: [],
          solutionLatex: r'\text{No Solution } (\emptyset)',
        ),
        resultLatex: r'\text{No Solution}',
      );
    }

    // Case 2: Unique Solution (Every variable is a pivot variable)
    if (freeCols.isEmpty && pivotCols.length == varCount) {
      final solutionValues = <Rational>[];
      final highlights = <CellHighlight>[];
      final solStrings = <String>[];

      for (int c = 0; c < varCount; c++) {
        final r = pivotRowForCol[c]!;
        final val = rref.get(r, varCount);
        solutionValues.add(val);
        highlights.add(CellHighlight(row: r, col: c, type: HighlightType.pivot));
        highlights.add(CellHighlight(row: r, col: varCount, type: HighlightType.selected));
        solStrings.add('x_{${c + 1}} = ${val.toLatex()}');
      }

      final solValStr = solutionValues.map((v) => v.toLatex()).join(r' \\ ');
      final vectorLatex = '\\mathbf{x} = \\begin{pmatrix}$solValStr\\end{pmatrix}';

      steps.add(MatrixStep(
        stepIndex: ++stepCounter,
        titleKey: 'system_unique_title',
        explanationKey: 'system_unique_desc',
        explanationParams: {
          'solution': solStrings.join(', '),
        },
        matrixBefore: rrefSnap,
        matrixAfter: rrefSnap,
        transformation: LinearSystemTransformation(
          LinearSystemType.unique,
          vectorLatex,
        ),
        highlights: highlights,
      ));

      return StepSolution(
        operationKey: 'op_linear_systems',
        initialMatrix: augmentedMatrix,
        steps: steps,
        finalMatrix: rref,
        result: LinearSystemResult(
          type: LinearSystemType.unique,
          uniqueSolution: solutionValues,
          basicVariables: pivotCols,
          freeVariables: freeCols,
          solutionLatex: vectorLatex,
        ),
        resultLatex: vectorLatex,
      );
    }

    // Case 3: Infinite Solutions (Parametric Vector Form)
    final paramNames = ['t', 's', 'u', 'v', 'w'];
    final freeParamMap = <int, String>{};
    for (int i = 0; i < freeCols.length; i++) {
      freeParamMap[freeCols[i]] = i < paramNames.length ? paramNames[i] : 't_{${i + 1}}';
    }

    final particularVector = List.generate(varCount, (_) => Rational.zero);
    final directionVectors = <String, List<Rational>>{};
    for (final p in freeParamMap.values) {
      directionVectors[p] = List.generate(varCount, (_) => Rational.zero);
    }

    // Set free variables: x_f = 1 * parameter
    for (final f in freeCols) {
      final p = freeParamMap[f]!;
      directionVectors[p]![f] = Rational.one;
    }

    // Solve basic variables: x_b = const - sum(coeff * x_f)
    for (final b in pivotCols) {
      final r = pivotRowForCol[b]!;
      particularVector[b] = rref.get(r, varCount);
      for (final f in freeCols) {
        final coeff = rref.get(r, f);
        final p = freeParamMap[f]!;
        directionVectors[p]![b] = -coeff;
      }
    }

    // Form parametric string
    final terms = <String>[];
    final partStr = particularVector.map((v) => v.toLatex()).join(r' \\ ');
    terms.add('\\begin{pmatrix}$partStr\\end{pmatrix}');

    for (final f in freeCols) {
      final p = freeParamMap[f]!;
      final vec = directionVectors[p]!;
      final vecStr = vec.map((v) => v.toLatex()).join(r' \\ ');
      terms.add('$p \\begin{pmatrix}$vecStr\\end{pmatrix}');
    }

    final parametricLatex = '\\mathbf{x} = ${terms.join(' + ')}';

    final highlights = <CellHighlight>[
      for (final b in pivotCols)
        CellHighlight(row: pivotRowForCol[b]!, col: b, type: HighlightType.pivot),
    ];

    steps.add(MatrixStep(
      stepIndex: ++stepCounter,
      titleKey: 'system_infinite_title',
      titleParams: {'count': freeCols.length},
      explanationKey: 'system_infinite_desc',
      explanationParams: {
        'freeVars': freeCols.map((c) => 'x_{${c + 1}}').join(', '),
        'params': freeParamMap.values.join(', '),
      },
      matrixBefore: rrefSnap,
      matrixAfter: rrefSnap,
      transformation: LinearSystemTransformation(
        LinearSystemType.infinite,
        parametricLatex,
      ),
      highlights: highlights,
    ));

    return StepSolution(
      operationKey: 'op_linear_systems',
      initialMatrix: augmentedMatrix,
      steps: steps,
      finalMatrix: rref,
      result: LinearSystemResult(
        type: LinearSystemType.infinite,
        basicVariables: pivotCols,
        freeVariables: freeCols,
        solutionLatex: parametricLatex,
      ),
      resultLatex: parametricLatex,
    );
  }
}
