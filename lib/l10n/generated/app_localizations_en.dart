// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Matriks · Linear Algebra';

  @override
  String get topics => 'Topics';

  @override
  String get selectTopic => 'Your mathematics studio';

  @override
  String get topicSubtitle =>
      'Choose a problem. See the pattern. Understand each step.';

  @override
  String get categoryAll => 'All Topics';

  @override
  String get categoryElimination => 'Elimination & Systems';

  @override
  String get categoryAlgebra => 'Matrix Algebra';

  @override
  String get categoryAdvanced => 'Decomposition & Spectra';

  @override
  String get categoryVisual => 'Visual & Practice';

  @override
  String get topicGauss => 'Gaussian Elimination (REF)';

  @override
  String get topicGaussDesc =>
      'Step-by-step row reduction to upper triangular echelon form.';

  @override
  String get topicRref => 'Gauss-Jordan Elimination (RREF)';

  @override
  String get topicRrefDesc =>
      'Complete reduction to reduced row echelon form with leading ones.';

  @override
  String get topicLinearSystems => 'Linear Systems (Ax = b)';

  @override
  String get topicLinearSystemsDesc =>
      'Unique, infinite, or no solution analysis with Gauss-Jordan.';

  @override
  String get topicDeterminant => 'Determinant';

  @override
  String get topicDeterminantDesc =>
      '2x2 cross-multiplication, 3x3 Sarrus rule, and row triangularization.';

  @override
  String get topicInverse => 'Matrix Inverse (A⁻¹)';

  @override
  String get topicInverseDesc =>
      '2x2 adjoint formula and [A | I] Gauss-Jordan inversion.';

  @override
  String get topicRankNullity => 'Rank & Nullity';

  @override
  String get topicRankNullityDesc =>
      'Compute matrix rank, nullity, and verify the Rank-Nullity Theorem.';

  @override
  String get topicEigen => 'Eigenvalues & Eigenvectors';

  @override
  String get topicEigenDesc =>
      'Explore eigenvalues and eigenvectors of 2×2 and 3×3 matrices, exact where the roots are rational.';

  @override
  String get topicTransform2d => '2D Geometric Transformation';

  @override
  String get topicTransform2dDesc =>
      'Visualize unit square warping, basis vectors (î, ĵ), and determinant area in real-time.';

  @override
  String get topicAdd => 'Matrix Addition';

  @override
  String get topicAddDesc =>
      'Element-wise matrix addition with interactive cell animations.';

  @override
  String get topicMultiply => 'Matrix Multiplication';

  @override
  String get topicMultiplyDesc =>
      'Dot product of row and column vectors yielding each target cell.';

  @override
  String get matrixA => 'Matrix A';

  @override
  String get matrixB => 'Matrix B';

  @override
  String get rows => 'Rows';

  @override
  String get cols => 'Columns';

  @override
  String get size => 'Size';

  @override
  String get presetRandom => 'Random';

  @override
  String get presetIdentity => 'Identity';

  @override
  String get presetClear => 'Clear';

  @override
  String get calculate => 'Solve';

  @override
  String get fractionToggle => 'Fraction / Decimal';

  @override
  String get decreaseDimension => 'Decrease dimension';

  @override
  String get increaseDimension => 'Increase dimension';

  @override
  String stepOf(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get decreasePlaybackSpeed => 'Decrease playback speed';

  @override
  String get increasePlaybackSpeed => 'Increase playback speed';

  @override
  String playbackSpeed(Object speed) {
    return 'Speed: $speed×';
  }

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get nextStep => 'Next';

  @override
  String get prevStep => 'Previous';

  @override
  String get jumpToStep => 'Jump to Step';

  @override
  String get explanation => 'Explanation';

  @override
  String get close => 'Close';

  @override
  String get toggleTheme => 'Toggle Theme';

  @override
  String get changeLanguage => 'Language';

  @override
  String get solveFallbackError => 'Could not solve matrix.';

  @override
  String get legendPivot => 'Pivot';

  @override
  String get legendSource => 'Source';

  @override
  String get legendTarget => 'Target';

  @override
  String get legendZeroResult => '0-Result';

  @override
  String cellCalculationTitle(Object col, Object row) {
    return 'Cell ($row, $col) Calculation';
  }

  @override
  String get arithmeticDetail => 'Arithmetic Operation Detail:';

  @override
  String get resultLabel => 'Result:';

  @override
  String get transformScreenTitle => '2D Linear Transformation';

  @override
  String get presetShear => 'Shear';

  @override
  String get presetRotation => 'Rotation 45°';

  @override
  String get presetScale => 'Scale';

  @override
  String get presetReflection => 'Reflection';

  @override
  String get presetProjection => 'Projection (det=0)';

  @override
  String get presetReset => 'Reset (I)';

  @override
  String step_row_swap_title(Object rowA, Object rowB) {
    return 'Swap Row $rowA and Row $rowB';
  }

  @override
  String step_row_swap_desc(
    Object col,
    Object pivot,
    Object rowA,
    Object rowB,
  ) {
    return 'Swapped Row $rowA and Row $rowB to place a non-zero pivot ($pivot) at Column $col.';
  }

  @override
  String step_row_scale_title(Object row) {
    return 'Normalize Row $row';
  }

  @override
  String step_row_scale_desc(Object factor, Object row) {
    return 'Multiplied Row $row by $factor to make the leading pivot equal to 1.';
  }

  @override
  String step_row_elimination_title(Object target) {
    return 'Eliminate Entry in Row $target';
  }

  @override
  String step_row_elimination_desc(
    Object col,
    Object multiplier,
    Object source,
    Object target,
  ) {
    return 'Eliminated element in column $col of Row $target: R_$target ← R_$target - ($multiplier) · R_$source.';
  }

  @override
  String get det_1x1_title => '1x1 Matrix Determinant';

  @override
  String det_1x1_desc(Object val) {
    return 'The determinant of a 1x1 matrix is simply its single element: $val.';
  }

  @override
  String get det_2x2_main_diagonal_title => 'Main Diagonal Product';

  @override
  String det_2x2_main_diagonal_desc(Object a, Object d, Object product) {
    return 'Multiplying main diagonal elements: $a · $d = $product.';
  }

  @override
  String get det_2x2_anti_diagonal_title => 'Anti-Diagonal Product';

  @override
  String det_2x2_anti_diagonal_desc(Object b, Object c, Object product) {
    return 'Multiplying anti-diagonal elements: $b · $c = $product.';
  }

  @override
  String get det_2x2_final_title => 'Determinant Result';

  @override
  String det_2x2_final_desc(Object anti, Object det, Object main) {
    return 'Determinant = (Main Diagonal) - (Anti-Diagonal): ($main) - ($anti) = $det.';
  }

  @override
  String get det_sarrus_pos_title => 'Sarrus Rule: Positive Diagonals';

  @override
  String det_sarrus_pos_desc(Object p1, Object p2, Object p3, Object total) {
    return 'Sum of downward diagonals: $p1 + $p2 + $p3 = $total.';
  }

  @override
  String get det_sarrus_neg_title => 'Sarrus Rule: Negative Diagonals';

  @override
  String det_sarrus_neg_desc(Object n1, Object n2, Object n3, Object total) {
    return 'Sum of upward diagonals: $n1 + $n2 + $n3 = $total.';
  }

  @override
  String get det_sarrus_final_title => 'Determinant Result';

  @override
  String det_sarrus_final_desc(Object det, Object neg, Object pos) {
    return 'Determinant = (Positive Diagonals) - (Negative Diagonals): ($pos) - ($neg) = $det.';
  }

  @override
  String get det_singular_column_title => 'Zero Column Encountered';

  @override
  String det_singular_column_desc(Object col) {
    return 'All entries in column $col are zero. The determinant of this matrix is 0.';
  }

  @override
  String get det_row_swap_title => 'Row Swap (Sign Reversal)';

  @override
  String det_row_swap_desc(Object rowA, Object rowB) {
    return 'Swapping Row $rowA and Row $rowB negates the determinant sign.';
  }

  @override
  String get det_diagonal_product_title => 'Upper Triangular Diagonal Product';

  @override
  String det_diagonal_product_desc(Object det, Object diagonals, Object sign) {
    return 'The matrix is now in upper triangular form. Determinant = $sign$diagonals = $det.';
  }

  @override
  String get inverse_singular_title => 'Matrix is Singular';

  @override
  String get inverse_singular_desc =>
      'Determinant is 0. A matrix with determinant 0 is singular and does not have an inverse.';

  @override
  String get inverse_2x2_det_title => 'Calculate Determinant';

  @override
  String inverse_2x2_det_desc(Object det, Object formula) {
    return 'Determinant = $formula = $det.';
  }

  @override
  String get inverse_2x2_adjoint_title => 'Form Adjoint Matrix';

  @override
  String get inverse_2x2_adjoint_desc =>
      'Swap main diagonal entries and negate off-diagonal entries.';

  @override
  String get inverse_2x2_scale_title => 'Scale Adjoint by 1/det';

  @override
  String inverse_2x2_scale_desc(Object factor) {
    return 'Multiplied every adjoint matrix element by 1/det = $factor.';
  }

  @override
  String get inverse_block_init_title => 'Form Augmented Matrix [A | I]';

  @override
  String inverse_block_init_desc(Object n) {
    return 'Augmented the ${n}x$n matrix A with the identity matrix I.';
  }

  @override
  String get inverse_block_extract_title => 'Extract Inverse Matrix A⁻¹';

  @override
  String get inverse_block_extract_desc =>
      'The left block has been transformed to I. The right block is now the inverse matrix A⁻¹.';

  @override
  String arithmetic_add_cell_title(Object col, Object row) {
    return 'Add Element at ($row, $col)';
  }

  @override
  String arithmetic_add_cell_desc(Object formula) {
    return 'Added corresponding elements: $formula.';
  }

  @override
  String arithmetic_mult_cell_title(Object col, Object row) {
    return 'Compute Element ($row, $col)';
  }

  @override
  String arithmetic_mult_cell_desc(Object col, Object formula, Object row) {
    return 'Dot product of Row $row in Matrix A and Column $col in Matrix B: $formula.';
  }

  @override
  String get error_matrix_is_singular =>
      'This matrix is singular (determinant = 0), so it has no inverse.';

  @override
  String get error_inverse_not_square =>
      'This operation requires a square matrix.';

  @override
  String get error_dimension_mismatch_add =>
      'Matrices must have the same dimensions for addition.';

  @override
  String get error_dimension_mismatch_multiply =>
      'Column count of Matrix A must equal row count of Matrix B.';

  @override
  String system_inconsistent_title(Object row) {
    return 'Row $row Contradiction: Inconsistent System';
  }

  @override
  String system_inconsistent_desc(Object row, Object val) {
    return 'Row $row reduces to [0 ... 0 | $val], stating 0 = $val. This is a contradiction, so the system has no solution.';
  }

  @override
  String get system_unique_title => 'Unique Solution Found';

  @override
  String system_unique_desc(Object solution) {
    return 'Every unknown corresponds to a pivot column. The unique solution is $solution.';
  }

  @override
  String system_infinite_title(Object count) {
    return 'Infinite Solutions ($count Free Variables)';
  }

  @override
  String system_infinite_desc(Object freeVars, Object params) {
    return 'The non-pivot variables ($freeVars) are free parameters ($params). The solution is expressed in parametric vector form.';
  }

  @override
  String rank_nullity_title(Object nullity, Object rank) {
    return 'Rank = $rank, Nullity = $nullity';
  }

  @override
  String rank_nullity_desc(Object cols, Object nullity, Object rank) {
    return 'The matrix has $rank pivot columns and $nullity free columns. By the Rank-Nullity Theorem, rank(A) + nullity(A) = $cols.';
  }

  @override
  String get eigen_char_poly_title => 'Characteristic Polynomial';

  @override
  String eigen_trace_det_desc(Object det, Object trace) {
    return 'For a 2x2 matrix, the characteristic equation is λ² - tr(A)λ + det(A) = 0 with trace = $trace and det = $det.';
  }

  @override
  String get eigen_complex_title => 'Complex Eigenvalues';

  @override
  String eigen_complex_desc(Object poly, Object roots) {
    return 'The discriminant is negative for $poly. The eigenvalues are complex conjugates: $roots.';
  }

  @override
  String get eigen_roots_title =>
      'Eigenvalues (Roots of Characteristic Equation)';

  @override
  String eigen_roots_approx_desc(Object poly, Object roots) {
    return 'Solving $poly gives approximate real eigenvalues, rounded to three decimal places: $roots.';
  }

  @override
  String eigen_roots_desc(Object poly, Object roots) {
    return 'Solving $poly yields the real eigenvalues: $roots.';
  }

  @override
  String eigen_vector_title(Object index, Object lambda) {
    return 'Eigenvector for λ_$index = $lambda';
  }

  @override
  String eigen_vector_desc(Object lambda, Object vector) {
    return 'For (A − λI)v = 0 with λ = $lambda, one representative eigenvector is $vector.';
  }

  @override
  String eigen_3x3_poly_desc(Object det, Object poly, Object trace) {
    return 'For a 3x3 matrix, the characteristic equation is $poly with trace = $trace and det = $det.';
  }

  @override
  String eigen_irrational_desc(Object poly) {
    return 'The roots of $poly could not be isolated reliably for coefficients of this size. Real or complex roots exist, but this solver does not compute them.';
  }

  @override
  String get topicLu => 'LU Decomposition (A = LU)';

  @override
  String get topicLuDesc =>
      'Factorize a square matrix into lower (L) and upper (U) triangular matrices.';

  @override
  String get topicPractice => 'Self-Test & Practice Quiz';

  @override
  String get topicPracticeDesc =>
      'Interactive challenges with instant pedagogical feedback and scoring.';

  @override
  String get lu_init_title => 'Initialize LU Factorization';

  @override
  String get lu_init_desc =>
      'Initialize L as identity matrix I with 1s on diagonal, and U as matrix A.';

  @override
  String lu_swap_desc(Object rowA, Object rowB) {
    return 'Pivot was 0. Swapped Row $rowA with Row $rowB (requires permutation matrix P).';
  }

  @override
  String lu_elim_title(Object source, Object target) {
    return 'Eliminate Entry in Row $target using Pivot Row $source';
  }

  @override
  String lu_elim_desc(Object multiplier, Object source, Object target) {
    return 'Multiplier m_$target$source = $multiplier is saved in L at ($target,$source). Row operation on U: R_$target ← R_$target - ($multiplier)R_$source.';
  }

  @override
  String get lu_final_title => 'LU Factorization Complete';

  @override
  String get lu_final_desc =>
      'Matrix successfully decomposed into L (lower triangular) and U (upper triangular).';

  @override
  String get practiceTitle => 'Self-Test (Practice Mode)';

  @override
  String practiceScore(Object score) {
    return '$score Points';
  }

  @override
  String practiceQuestionProgress(Object current, Object total) {
    return 'Question $current / $total';
  }

  @override
  String get practiceHint => 'Hint';

  @override
  String get practiceHideHint => 'Hide Hint';

  @override
  String get practiceCorrect => 'Congratulations, Correct Answer!';

  @override
  String get practiceIncorrect => 'Incorrect Selection';

  @override
  String get practiceNext => 'Next Question';

  @override
  String get practiceResults => 'View Results';

  @override
  String get practiceCompleted => 'Practice Completed!';

  @override
  String practiceTotalScore(Object score, Object total) {
    return 'Total Score: $score / $total';
  }

  @override
  String get practicePerfectScore =>
      'Great job! You answered all questions correctly for a perfect score!';

  @override
  String get practiceGoodEffort =>
      'Good effort! Try again to master matrix operations even further.';

  @override
  String get practiceReturnTopics => 'Return to Topics';

  @override
  String get practiceRestart => 'Restart Quiz';

  @override
  String get searchTopics => 'Search topics...';

  @override
  String get noTopicsFound => 'No matching topics found';

  @override
  String get noTopicsFoundDesc =>
      'Try searching with a different keyword or select another category.';

  @override
  String get clearSearch => 'Clear Search';

  @override
  String get systemDefault => 'System Default';

  @override
  String get replayAnimation => 'Replay Animation';

  @override
  String basisVectorI(Object x, Object y) {
    return 'î = ($x, $y)';
  }

  @override
  String basisVectorJ(Object x, Object y) {
    return 'ĵ = ($x, $y)';
  }

  @override
  String progressPercent(Object percent) {
    return 't = $percent%';
  }

  @override
  String get inputHelp =>
      'Select a cell, then enter an integer, decimal, or fraction.';

  @override
  String inputInvalid(String matrix, int row, int column) {
    return 'Check matrix $matrix, row $row, column $column. Enter a complete number; a fraction cannot have a zero denominator.';
  }

  @override
  String get calculating => 'Calculating…';

  @override
  String inputCell(String matrix, int row, int column) {
    return 'Matrix $matrix, row $row, column $column';
  }

  @override
  String get stepAlreadyReducedTitle => 'Already in the requested form';

  @override
  String get stepAlreadyReducedDesc =>
      'No row operations are needed. The matrix shown is the result.';

  @override
  String get keyPreviousCell => 'Previous cell';

  @override
  String get keyNextCell => 'Next cell';

  @override
  String get keySign => 'Toggle sign';

  @override
  String get keyFraction => 'Fraction slash';

  @override
  String get keyBackspace => 'Delete last digit';

  @override
  String get keyClear => 'Clear cell';

  @override
  String get keyDecimal => 'Decimal point';

  @override
  String get instructionProgress => 'This operation';

  @override
  String get customTransform => 'Custom';

  @override
  String get transformCoefficients => 'Transformation matrix';

  @override
  String get basisVectors => 'Transformed basis vectors';

  @override
  String get targetDeterminant => 'Target determinant';

  @override
  String matrixCellLabel(int row, int column, String value) {
    return 'Row $row, column $column, value $value';
  }

  @override
  String get focusSource => 'Understand the goal';

  @override
  String get focusOperation => 'Follow the calculation';

  @override
  String get focusResult => 'Check what changed';

  @override
  String get inspectOperation => 'Inspect this operation';

  @override
  String get stepExplanation => 'Why this works';

  @override
  String get cellCalculations => 'Cell calculations';

  @override
  String get chooseStep => 'Choose a step';

  @override
  String get learningPath => 'New to matrices?';

  @override
  String get pathEliminate => '1 · Create zeros';

  @override
  String get pathReduce => '2 · Find the pivots';

  @override
  String get pathSolve => '3 · Solve a system';

  @override
  String guideEliminateSource(String source, String target, String column) {
    return 'Use row $source to change row $target. Focus on column $column.';
  }

  @override
  String guideEliminateApply(String factor, String source, String target) {
    return 'Add $factor times row $source to row $target. Apply the same operation to every entry in the row.';
  }

  @override
  String guideEliminateResult(String column, String value) {
    return 'The entry in column $column is now $value. The row operation preserves the solution set.';
  }

  @override
  String guideScaleSource(String row, String factor) {
    return 'Scale every entry in row $row by the same nonzero factor: $factor.';
  }

  @override
  String get guideScaleApply =>
      'Apply the factor to the whole row, not just the pivot.';

  @override
  String get guideScaleResult =>
      'The row has been scaled. Compare each entry with the original row.';

  @override
  String guideSwapSource(String first, String second) {
    return 'Rows $first and $second will exchange places.';
  }

  @override
  String get guideSwapApply =>
      'Move the whole rows together; the entries themselves do not change.';

  @override
  String get guideSwapResult =>
      'The rows are in their new positions. The solution set is unchanged.';

  @override
  String guideDotSource(String row, String column) {
    return 'Pair row $row with column $column. Each pair contributes to one output entry.';
  }

  @override
  String get guideDotApply =>
      'Multiply matching entries, then add their contributions.';

  @override
  String guideDotResult(String row, String column) {
    return 'The sum gives the entry at row $row, column $column.';
  }

  @override
  String get guideDetSource =>
      'Follow the factors in each product. The signs determine which products are subtracted.';

  @override
  String get guideDetApply =>
      'One product is highlighted at a time. Read its factors below the matrix.';

  @override
  String get guideDetResult =>
      'Their sum is this group\'s contribution to the determinant.';

  @override
  String get coefficientError => 'Enter a number from −1000 to 1000.';

  @override
  String get transformTransitionHint =>
      'Edit a coefficient and press Enter or leave the field to apply. Values: −1000 to 1000. The slider compares the previous and new states; intermediate frames are transitions between transformations.';

  @override
  String multiplicationSourceRow(String row) {
    return 'A · row $row';
  }

  @override
  String multiplicationSourceColumn(String column) {
    return 'B · column $column';
  }

  @override
  String get multiplicationOutput => 'C = A × B · result matrix';

  @override
  String guideEliminateReason(String entry, String pivot, String ratio) {
    return 'Target $entry ÷ pivot $pivot = $ratio. Subtract this multiple of the source row to cancel the target entry.';
  }

  @override
  String guideEliminateSubtract(String factor, String source, String target) {
    return 'Subtract $factor times row $source from row $target. Apply this to every entry in the row.';
  }

  @override
  String get transformProgress => 'Transition progress';

  @override
  String increaseCoefficient(String name) {
    return 'Increase coefficient $name';
  }

  @override
  String decreaseCoefficient(String name) {
    return 'Decrease coefficient $name';
  }

  @override
  String get guideDotReason =>
      'One output entry uses a whole row of A and a whole column of B. Multiply entries in matching positions, then add their contributions.';

  @override
  String get guideDetReason =>
      'The determinant measures signed area or volume scaling. Add the products marked + and subtract those marked −; a zero determinant means the transformation loses a dimension.';

  @override
  String get settings => 'Settings';

  @override
  String get practiceNav => 'Practice';

  @override
  String get transformNav => 'Transformations';

  @override
  String get appearance => 'Appearance';

  @override
  String get learning => 'Learning & playback';

  @override
  String get themeLabel => 'Theme';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get solutionModeLabel => 'Solution view';

  @override
  String get guidedMode => 'Guided animation';

  @override
  String get stepsMode => 'Static steps';

  @override
  String get resultMode => 'Direct result';

  @override
  String get showResult => 'Show result';

  @override
  String get viewSteps => 'Explore steps';

  @override
  String get motionLabel => 'Reduce motion';

  @override
  String get motionHelp => 'System reduced motion is always respected.';

  @override
  String get shortExplanation => 'Short';

  @override
  String get detailedExplanation => 'Detailed';

  @override
  String get hiddenExplanation => 'Hidden';

  @override
  String get predictionLabel => 'Prediction questions';

  @override
  String get predictionHelp => 'Optional checkpoints in worked examples.';

  @override
  String get predictTitle => 'Before we try it…';

  @override
  String get predictPrompt => 'Which factor cancels the target entry?';

  @override
  String get predictCorrect =>
      'Exactly! Now follow the same operation across the row.';

  @override
  String get predictIncorrect =>
      'Divide the target by the pivot to find the factor.';

  @override
  String get skip => 'Skip';

  @override
  String get continueLabel => 'Continue';

  @override
  String get numberView => 'Number display';

  @override
  String get fractionView => 'Exact fractions';

  @override
  String get decimalView => 'Decimals';

  @override
  String get densityLabel => 'Layout density';

  @override
  String get comfortable => 'Comfortable';

  @override
  String get compact => 'Compact';

  @override
  String get accentLabel => 'Accent palette';

  @override
  String get blue => 'Blue';

  @override
  String get teal => 'Teal';

  @override
  String get purple => 'Purple';

  @override
  String get shortcutsLabel => 'Keyboard shortcuts';

  @override
  String get shortcutHelp =>
      'Select an action, then press a letter, Space or a horizontal arrow. Home/End and Page Up/Down remain available.';

  @override
  String get pressKey => 'Press a key';

  @override
  String get shortcutConflict => 'That key is reserved or already assigned.';

  @override
  String get resetSettings => 'Reset settings';

  @override
  String get settingsStorageError =>
      'Preferences could not be read or saved. Changes remain available for this session.';

  @override
  String get localPreferences =>
      'Preferences stay on this device. Matrix history is not saved.';

  @override
  String get resultExact => 'Exact';

  @override
  String get resultApproximate => 'Approximate';

  @override
  String get resultComplete => 'Complete';

  @override
  String get resultPartial => 'Partial';

  @override
  String get resultUnsupported => 'Unsupported';

  @override
  String get eigenPrecision =>
      'Eigenvalues are rounded to three decimals; vectors are approximate directions, not exact null-space solutions.';

  @override
  String get eigenScope =>
      '3×3 roots are exact when rational; other real roots are rounded to three decimals. Very large coefficients may leave roots unresolved.';

  @override
  String get eigenBasisScope =>
      'One representative vector per eigenvalue is shown; a full eigenspace basis is not computed.';

  @override
  String get complexScope =>
      'Complex eigenvectors are not supported. The imaginary part is rounded to two decimals.';

  @override
  String get guideAddSource => 'Match the same position in A and B.';

  @override
  String get guideAddApply => 'Add this pair of entries.';

  @override
  String get guideAddResult => 'Their sum belongs in the same position in C.';

  @override
  String get quizQ1QuestionTitle => 'Gaussian Elimination: Pivot & Elimination';

  @override
  String get quizQ1Prompt =>
      'In the matrix below, the first pivot is at cell (1,1). Which elementary row operation eliminates the first entry in row 2?';

  @override
  String get quizQ1Explanation =>
      'The first entry in row 2 is 2, and the pivot is 1. To obtain 2 - 2(1) = 0, apply R_2 \\leftarrow R_2 - 2R_1.';

  @override
  String get quizQ1Hint =>
      'Subtract a multiple of the pivot row from the target row to create a zero.';

  @override
  String get quizQ1Feedback0 => 'Subtracting twice row 1 creates 2 − 2 = 0.';

  @override
  String get quizQ1Feedback1 => 'Adding twice row 1 gives 2 + 2 = 4, not zero.';

  @override
  String get quizQ1Feedback2 =>
      'Swapping rows moves the entries but does not eliminate the target entry.';

  @override
  String get quizQ1Feedback3 =>
      'Halving row 2 changes its first entry to 1, not zero.';

  @override
  String get quizQ2QuestionTitle => 'Row Swap (Permutation) Requirement';

  @override
  String get quizQ2Prompt =>
      'The pivot position (1,1) contains 0. Which row swap places a non-zero pivot at (1,1)?';

  @override
  String get quizQ2Explanation =>
      'The pivot entry cannot be zero. To place a non-zero leading entry in row 1, swap rows 1 and 2: R_1 \\leftrightarrow R_2.';

  @override
  String get quizQ2Hint =>
      'A zero pivot cannot eliminate other rows; swap with a row having a non-zero leading entry.';

  @override
  String get quizQ2Feedback0 =>
      'Adding row 2 would also create a non-zero pivot, but this question asks specifically for a row swap.';

  @override
  String get quizQ2Feedback1 =>
      'Swapping rows 1 and 2 moves the non-zero entry 3 into the pivot position.';

  @override
  String get quizQ2Feedback2 =>
      'Changing row 2 leaves the zero at (1,1) unchanged.';

  @override
  String get quizQ2Feedback3 =>
      'Scaling row 3 leaves the zero at (1,1) unchanged.';

  @override
  String get quizQ3QuestionTitle => 'Pivot Normalization (Scaling)';

  @override
  String get quizQ3Prompt =>
      'The pivot entry in row 2 is -3. Which operation scales this row to produce a leading one (1)?';

  @override
  String get quizQ3Explanation =>
      'Multiply every entry in row 2 by −1/3: (−3) × (−1/3) = 1.';

  @override
  String get quizQ3Hint =>
      'Multiply the entire row by the reciprocal of the pivot value.';

  @override
  String get quizQ3Feedback0 =>
      'Adding row 1 destroys the leading zero and does not normalize this pivot.';

  @override
  String get quizQ3Feedback1 =>
      'The reciprocal of −3 is −1/3, so their product is 1.';

  @override
  String get quizQ3Feedback2 =>
      'Multiplying −3 by 3 gives −9. Use the reciprocal instead.';

  @override
  String get quizQ3Feedback3 =>
      'Swapping rows changes positions; it does not scale −3 to 1.';

  @override
  String get quizQ4QuestionTitle => 'Matrix Rank and Zero Rows';

  @override
  String get quizQ4Prompt =>
      'What is the rank (number of linearly independent rows) of this echelon form matrix?';

  @override
  String get quizQ4Explanation =>
      'The matrix is in echelon form with 2 non-zero pivot rows and 1 all-zero row. Therefore, rank(A) = 2.';

  @override
  String get quizQ4Hint =>
      'Count the number of non-zero rows in row echelon form.';

  @override
  String get quizQ4Feedback0 =>
      'The zero row contributes no pivot. Matrix size alone does not determine rank.';

  @override
  String get quizQ4Feedback1 =>
      'There are two pivot rows in this echelon matrix.';

  @override
  String get quizQ4Feedback2 =>
      'The second non-zero row contains another pivot and must also be counted.';

  @override
  String get quizQ4Feedback3 =>
      'Rank zero would require every entry of the matrix to be zero.';

  @override
  String get quizQ5QuestionTitle => 'Determinant of a Triangular Matrix';

  @override
  String get quizQ5Prompt =>
      'The determinant of an upper triangular matrix equals the product of its main diagonal entries. What is det(A)?';

  @override
  String get quizQ5Explanation =>
      'For any triangular matrix, det(A) is the product of entries along the main diagonal: 2 \\cdot 3 \\cdot 4 = 24.';

  @override
  String get quizQ5Hint =>
      'When all entries below the main diagonal are zero, multiply the diagonal entries directly.';

  @override
  String get quizQ5Feedback0 =>
      'For a triangular determinant, multiply the diagonal entries; their sum is the trace.';

  @override
  String get quizQ5Feedback1 => 'The diagonal product is 2 × 3 × 4 = 24.';

  @override
  String get quizQ5Feedback2 =>
      'Zeros below the diagonal do not force determinant zero. A zero diagonal entry would.';

  @override
  String get quizQ5Feedback3 =>
      'All diagonal entries are positive; no extra negative sign is introduced.';

  @override
  String eigen_vector_approx_title(Object index, Object lambda) {
    return 'Approximate vector for λ_$index ≈ $lambda';
  }

  @override
  String eigen_vector_approx_desc(Object lambda, Object vector) {
    return 'Using λ ≈ $lambda, an approximate direction is $vector. The rounded value does not give an exact null-space solution.';
  }

  @override
  String get spaceKey => 'Space';

  @override
  String matrixCellPendingLabel(int row, int column) {
    return 'Row $row, column $column, not calculated yet';
  }

  @override
  String eigen_cubic_complex_desc(Object complex, Object poly, Object roots) {
    return 'Solving $poly gives the real eigenvalue $roots and the complex conjugate pair λ ≈ $complex. Only the real eigenvalue has a real eigenvector.';
  }

  @override
  String get keyNextRow => 'Next row';

  @override
  String get multiplyRowsLocked =>
      'B has as many rows as A has columns, so A × B is defined.';

  @override
  String get lessonComplete => 'Lesson complete';

  @override
  String get lessonCompleteHint =>
      'Check the result, watch the lesson again, or continue with a matrix of your own.';

  @override
  String get replayLesson => 'Watch again';

  @override
  String get tryOwnMatrix => 'Try your own matrix';

  @override
  String get editMatrix => 'Change the matrix';

  @override
  String presetApplied(String matrix) {
    return 'Matrix $matrix replaced.';
  }

  @override
  String get undo => 'Undo';

  @override
  String get transformShortcutsHint =>
      'Keyboard: Space plays or reverses, S shear, P projection, R identity.';

  @override
  String get transformLegendOriginal =>
      'Faint grid: the plane before the transformation.';

  @override
  String get transformLegendEigen =>
      'Dashed lines: real eigenvector directions, which stay on their own line.';

  @override
  String guideLuReason(
    String entry,
    String pivot,
    String ratio,
    String row,
    String column,
  ) {
    return 'Target $entry ÷ pivot $pivot = $ratio. Subtracting $ratio times the pivot row cancels the target, and the same $ratio is written into L at ($row, $column), so L · U rebuilds A.';
  }

  @override
  String get guideAdjSource =>
      'For [[a, b], [c, d]], look at the diagonal a, d and the other two entries b, c.';

  @override
  String get guideAdjApply =>
      'a and d trade places; b and c keep their places but change sign.';

  @override
  String get guideAdjResult =>
      'This is adj(A). Dividing it by det(A) gives the inverse.';

  @override
  String get guideAdjReason =>
      'For a 2×2 matrix, A · adj(A) = det(A) · I. So A⁻¹ = adj(A) ÷ det(A) whenever det(A) ≠ 0.';

  @override
  String guideScaleAllSource(String factor) {
    return 'Every entry of adj(A) is multiplied by the same number, 1/det(A) = $factor.';
  }

  @override
  String get guideScaleAllApply => 'Multiply the entries one at a time.';

  @override
  String get guideScaleAllResult => 'The result is A⁻¹. Check: A · A⁻¹ = I.';

  @override
  String get guideDiagSource =>
      'The matrix is now upper triangular, so its determinant is the product of the diagonal.';

  @override
  String get guideDiagApply =>
      'Multiply the diagonal entries one by one. The first factor carries a −1 for each row swap.';

  @override
  String get guideDiagResult =>
      'Row eliminations did not change the determinant, so this product is det of the original matrix.';

  @override
  String get guideDetRecapSource =>
      'Both totals are known from the previous steps.';

  @override
  String get guideDetRecapApply => 'Subtract the − total from the + total.';

  @override
  String get guideDetRecapResult => 'The difference is the determinant.';
}
