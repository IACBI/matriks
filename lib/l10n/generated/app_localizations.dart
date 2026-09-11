import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Matriks · Linear Algebra'**
  String get appTitle;

  /// No description provided for @topics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get topics;

  /// No description provided for @selectTopic.
  ///
  /// In en, this message translates to:
  /// **'Your mathematics studio'**
  String get selectTopic;

  /// No description provided for @topicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a problem. See the pattern. Understand each step.'**
  String get topicSubtitle;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All Topics'**
  String get categoryAll;

  /// No description provided for @categoryElimination.
  ///
  /// In en, this message translates to:
  /// **'Elimination & Systems'**
  String get categoryElimination;

  /// No description provided for @categoryAlgebra.
  ///
  /// In en, this message translates to:
  /// **'Matrix Algebra'**
  String get categoryAlgebra;

  /// No description provided for @categoryAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Decomposition & Spectra'**
  String get categoryAdvanced;

  /// No description provided for @categoryVisual.
  ///
  /// In en, this message translates to:
  /// **'Visual & Practice'**
  String get categoryVisual;

  /// No description provided for @topicGauss.
  ///
  /// In en, this message translates to:
  /// **'Gaussian Elimination (REF)'**
  String get topicGauss;

  /// No description provided for @topicGaussDesc.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step row reduction to upper triangular echelon form.'**
  String get topicGaussDesc;

  /// No description provided for @topicRref.
  ///
  /// In en, this message translates to:
  /// **'Gauss-Jordan Elimination (RREF)'**
  String get topicRref;

  /// No description provided for @topicRrefDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete reduction to reduced row echelon form with leading ones.'**
  String get topicRrefDesc;

  /// No description provided for @topicLinearSystems.
  ///
  /// In en, this message translates to:
  /// **'Linear Systems (Ax = b)'**
  String get topicLinearSystems;

  /// No description provided for @topicLinearSystemsDesc.
  ///
  /// In en, this message translates to:
  /// **'Unique, infinite, or no solution analysis with Gauss-Jordan.'**
  String get topicLinearSystemsDesc;

  /// No description provided for @topicDeterminant.
  ///
  /// In en, this message translates to:
  /// **'Determinant'**
  String get topicDeterminant;

  /// No description provided for @topicDeterminantDesc.
  ///
  /// In en, this message translates to:
  /// **'2x2 cross-multiplication, 3x3 Sarrus rule, and row triangularization.'**
  String get topicDeterminantDesc;

  /// No description provided for @topicInverse.
  ///
  /// In en, this message translates to:
  /// **'Matrix Inverse (A⁻¹)'**
  String get topicInverse;

  /// No description provided for @topicInverseDesc.
  ///
  /// In en, this message translates to:
  /// **'2x2 adjoint formula and [A | I] Gauss-Jordan inversion.'**
  String get topicInverseDesc;

  /// No description provided for @topicRankNullity.
  ///
  /// In en, this message translates to:
  /// **'Rank & Nullity'**
  String get topicRankNullity;

  /// No description provided for @topicRankNullityDesc.
  ///
  /// In en, this message translates to:
  /// **'Compute matrix rank, nullity, and verify the Rank-Nullity Theorem.'**
  String get topicRankNullityDesc;

  /// No description provided for @topicEigen.
  ///
  /// In en, this message translates to:
  /// **'Eigenvalues & Eigenvectors'**
  String get topicEigen;

  /// No description provided for @topicEigenDesc.
  ///
  /// In en, this message translates to:
  /// **'Explore 2×2 eigenpairs and 3×3 integer roots from −20 to 20.'**
  String get topicEigenDesc;

  /// No description provided for @topicTransform2d.
  ///
  /// In en, this message translates to:
  /// **'2D Geometric Transformation'**
  String get topicTransform2d;

  /// No description provided for @topicTransform2dDesc.
  ///
  /// In en, this message translates to:
  /// **'Visualize unit square warping, basis vectors (î, ĵ), and determinant area in real-time.'**
  String get topicTransform2dDesc;

  /// No description provided for @topicAdd.
  ///
  /// In en, this message translates to:
  /// **'Matrix Addition'**
  String get topicAdd;

  /// No description provided for @topicAddDesc.
  ///
  /// In en, this message translates to:
  /// **'Element-wise matrix addition with interactive cell animations.'**
  String get topicAddDesc;

  /// No description provided for @topicMultiply.
  ///
  /// In en, this message translates to:
  /// **'Matrix Multiplication'**
  String get topicMultiply;

  /// No description provided for @topicMultiplyDesc.
  ///
  /// In en, this message translates to:
  /// **'Dot product of row and column vectors yielding each target cell.'**
  String get topicMultiplyDesc;

  /// No description provided for @matrixA.
  ///
  /// In en, this message translates to:
  /// **'Matrix A'**
  String get matrixA;

  /// No description provided for @matrixB.
  ///
  /// In en, this message translates to:
  /// **'Matrix B'**
  String get matrixB;

  /// No description provided for @rows.
  ///
  /// In en, this message translates to:
  /// **'Rows'**
  String get rows;

  /// No description provided for @cols.
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get cols;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @presetRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get presetRandom;

  /// No description provided for @presetIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get presetIdentity;

  /// No description provided for @presetClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get presetClear;

  /// No description provided for @calculate.
  ///
  /// In en, this message translates to:
  /// **'Solve'**
  String get calculate;

  /// No description provided for @fractionToggle.
  ///
  /// In en, this message translates to:
  /// **'Fraction / Decimal'**
  String get fractionToggle;

  /// No description provided for @decreaseDimension.
  ///
  /// In en, this message translates to:
  /// **'Decrease dimension'**
  String get decreaseDimension;

  /// No description provided for @increaseDimension.
  ///
  /// In en, this message translates to:
  /// **'Increase dimension'**
  String get increaseDimension;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(Object current, Object total);

  /// No description provided for @decreasePlaybackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Decrease playback speed'**
  String get decreasePlaybackSpeed;

  /// No description provided for @increasePlaybackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Increase playback speed'**
  String get increasePlaybackSpeed;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed: {speed}x'**
  String playbackSpeed(Object speed);

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextStep;

  /// No description provided for @prevStep.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get prevStep;

  /// No description provided for @jumpToStep.
  ///
  /// In en, this message translates to:
  /// **'Jump to Step'**
  String get jumpToStep;

  /// No description provided for @explanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanation;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @toggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle Theme'**
  String get toggleTheme;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get changeLanguage;

  /// No description provided for @solveError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String solveError(Object error);

  /// No description provided for @solveFallbackError.
  ///
  /// In en, this message translates to:
  /// **'Could not solve matrix.'**
  String get solveFallbackError;

  /// No description provided for @legendPivot.
  ///
  /// In en, this message translates to:
  /// **'Pivot'**
  String get legendPivot;

  /// No description provided for @legendSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get legendSource;

  /// No description provided for @legendTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get legendTarget;

  /// No description provided for @legendZeroResult.
  ///
  /// In en, this message translates to:
  /// **'0-Result'**
  String get legendZeroResult;

  /// No description provided for @cellCalculationTitle.
  ///
  /// In en, this message translates to:
  /// **'Cell ({row}, {col}) Calculation'**
  String cellCalculationTitle(Object col, Object row);

  /// No description provided for @arithmeticDetail.
  ///
  /// In en, this message translates to:
  /// **'Arithmetic Operation Detail:'**
  String get arithmeticDetail;

  /// No description provided for @resultLabel.
  ///
  /// In en, this message translates to:
  /// **'Result:'**
  String get resultLabel;

  /// No description provided for @transformScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'2D Linear Transformation'**
  String get transformScreenTitle;

  /// No description provided for @presetShear.
  ///
  /// In en, this message translates to:
  /// **'Shear'**
  String get presetShear;

  /// No description provided for @presetRotation.
  ///
  /// In en, this message translates to:
  /// **'Rotation 45°'**
  String get presetRotation;

  /// No description provided for @presetScale.
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get presetScale;

  /// No description provided for @presetReflection.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get presetReflection;

  /// No description provided for @presetProjection.
  ///
  /// In en, this message translates to:
  /// **'Projection (det=0)'**
  String get presetProjection;

  /// No description provided for @presetReset.
  ///
  /// In en, this message translates to:
  /// **'Reset (I)'**
  String get presetReset;

  /// No description provided for @step_row_swap_title.
  ///
  /// In en, this message translates to:
  /// **'Swap Row {rowA} and Row {rowB}'**
  String step_row_swap_title(Object rowA, Object rowB);

  /// No description provided for @step_row_swap_desc.
  ///
  /// In en, this message translates to:
  /// **'Swapped Row {rowA} and Row {rowB} to place a non-zero pivot ({pivot}) at Column {col}.'**
  String step_row_swap_desc(Object col, Object pivot, Object rowA, Object rowB);

  /// No description provided for @step_row_scale_title.
  ///
  /// In en, this message translates to:
  /// **'Normalize Row {row}'**
  String step_row_scale_title(Object row);

  /// No description provided for @step_row_scale_desc.
  ///
  /// In en, this message translates to:
  /// **'Multiplied Row {row} by {factor} to make the leading pivot equal to 1.'**
  String step_row_scale_desc(Object factor, Object row);

  /// No description provided for @step_row_elimination_title.
  ///
  /// In en, this message translates to:
  /// **'Eliminate Entry in Row {target}'**
  String step_row_elimination_title(Object target);

  /// No description provided for @step_row_elimination_desc.
  ///
  /// In en, this message translates to:
  /// **'Eliminated element in column {col} of Row {target}: R_{target} ← R_{target} - ({multiplier}) · R_{source}.'**
  String step_row_elimination_desc(
    Object col,
    Object multiplier,
    Object source,
    Object target,
  );

  /// No description provided for @det_1x1_title.
  ///
  /// In en, this message translates to:
  /// **'1x1 Matrix Determinant'**
  String get det_1x1_title;

  /// No description provided for @det_1x1_desc.
  ///
  /// In en, this message translates to:
  /// **'The determinant of a 1x1 matrix is simply its single element: {val}.'**
  String det_1x1_desc(Object val);

  /// No description provided for @det_2x2_main_diagonal_title.
  ///
  /// In en, this message translates to:
  /// **'Main Diagonal Product'**
  String get det_2x2_main_diagonal_title;

  /// No description provided for @det_2x2_main_diagonal_desc.
  ///
  /// In en, this message translates to:
  /// **'Multiplying main diagonal elements: {a} · {d} = {product}.'**
  String det_2x2_main_diagonal_desc(Object a, Object d, Object product);

  /// No description provided for @det_2x2_anti_diagonal_title.
  ///
  /// In en, this message translates to:
  /// **'Anti-Diagonal Product'**
  String get det_2x2_anti_diagonal_title;

  /// No description provided for @det_2x2_anti_diagonal_desc.
  ///
  /// In en, this message translates to:
  /// **'Multiplying anti-diagonal elements: {b} · {c} = {product}.'**
  String det_2x2_anti_diagonal_desc(Object b, Object c, Object product);

  /// No description provided for @det_2x2_final_title.
  ///
  /// In en, this message translates to:
  /// **'Determinant Result'**
  String get det_2x2_final_title;

  /// No description provided for @det_2x2_final_desc.
  ///
  /// In en, this message translates to:
  /// **'Determinant = (Main Diagonal) - (Anti-Diagonal): ({main}) - ({anti}) = {det}.'**
  String det_2x2_final_desc(Object anti, Object det, Object main);

  /// No description provided for @det_sarrus_pos_title.
  ///
  /// In en, this message translates to:
  /// **'Sarrus Rule: Positive Diagonals'**
  String get det_sarrus_pos_title;

  /// No description provided for @det_sarrus_pos_desc.
  ///
  /// In en, this message translates to:
  /// **'Sum of downward diagonals: {p1} + {p2} + {p3} = {total}.'**
  String det_sarrus_pos_desc(Object p1, Object p2, Object p3, Object total);

  /// No description provided for @det_sarrus_neg_title.
  ///
  /// In en, this message translates to:
  /// **'Sarrus Rule: Negative Diagonals'**
  String get det_sarrus_neg_title;

  /// No description provided for @det_sarrus_neg_desc.
  ///
  /// In en, this message translates to:
  /// **'Sum of upward diagonals: {n1} + {n2} + {n3} = {total}.'**
  String det_sarrus_neg_desc(Object n1, Object n2, Object n3, Object total);

  /// No description provided for @det_sarrus_final_title.
  ///
  /// In en, this message translates to:
  /// **'Determinant Result'**
  String get det_sarrus_final_title;

  /// No description provided for @det_sarrus_final_desc.
  ///
  /// In en, this message translates to:
  /// **'Determinant = (Positive Diagonals) - (Negative Diagonals): ({pos}) - ({neg}) = {det}.'**
  String det_sarrus_final_desc(Object det, Object neg, Object pos);

  /// No description provided for @det_singular_column_title.
  ///
  /// In en, this message translates to:
  /// **'Zero Column Encountered'**
  String get det_singular_column_title;

  /// No description provided for @det_singular_column_desc.
  ///
  /// In en, this message translates to:
  /// **'All entries in column {col} are zero. The determinant of this matrix is 0.'**
  String det_singular_column_desc(Object col);

  /// No description provided for @det_row_swap_title.
  ///
  /// In en, this message translates to:
  /// **'Row Swap (Sign Reversal)'**
  String get det_row_swap_title;

  /// No description provided for @det_row_swap_desc.
  ///
  /// In en, this message translates to:
  /// **'Swapping Row {rowA} and Row {rowB} negates the determinant sign.'**
  String det_row_swap_desc(Object rowA, Object rowB);

  /// No description provided for @det_diagonal_product_title.
  ///
  /// In en, this message translates to:
  /// **'Upper Triangular Diagonal Product'**
  String get det_diagonal_product_title;

  /// No description provided for @det_diagonal_product_desc.
  ///
  /// In en, this message translates to:
  /// **'The matrix is now in upper triangular form. Determinant = {sign}{diagonals} = {det}.'**
  String det_diagonal_product_desc(Object det, Object diagonals, Object sign);

  /// No description provided for @inverse_singular_title.
  ///
  /// In en, this message translates to:
  /// **'Matrix is Singular'**
  String get inverse_singular_title;

  /// No description provided for @inverse_singular_desc.
  ///
  /// In en, this message translates to:
  /// **'Determinant is 0. A matrix with determinant 0 is singular and does not have an inverse.'**
  String get inverse_singular_desc;

  /// No description provided for @inverse_2x2_det_title.
  ///
  /// In en, this message translates to:
  /// **'Calculate Determinant'**
  String get inverse_2x2_det_title;

  /// No description provided for @inverse_2x2_det_desc.
  ///
  /// In en, this message translates to:
  /// **'Determinant = {formula} = {det}.'**
  String inverse_2x2_det_desc(Object det, Object formula);

  /// No description provided for @inverse_2x2_adjoint_title.
  ///
  /// In en, this message translates to:
  /// **'Form Adjoint Matrix'**
  String get inverse_2x2_adjoint_title;

  /// No description provided for @inverse_2x2_adjoint_desc.
  ///
  /// In en, this message translates to:
  /// **'Swap main diagonal entries and negate off-diagonal entries.'**
  String get inverse_2x2_adjoint_desc;

  /// No description provided for @inverse_2x2_scale_title.
  ///
  /// In en, this message translates to:
  /// **'Scale Adjoint by 1/det'**
  String get inverse_2x2_scale_title;

  /// No description provided for @inverse_2x2_scale_desc.
  ///
  /// In en, this message translates to:
  /// **'Multiplied every adjoint matrix element by 1/det = {factor}.'**
  String inverse_2x2_scale_desc(Object factor);

  /// No description provided for @inverse_block_init_title.
  ///
  /// In en, this message translates to:
  /// **'Form Augmented Matrix [A | I]'**
  String get inverse_block_init_title;

  /// No description provided for @inverse_block_init_desc.
  ///
  /// In en, this message translates to:
  /// **'Augmented the {n}x{n} matrix A with the identity matrix I.'**
  String inverse_block_init_desc(Object n);

  /// No description provided for @inverse_block_extract_title.
  ///
  /// In en, this message translates to:
  /// **'Extract Inverse Matrix A⁻¹'**
  String get inverse_block_extract_title;

  /// No description provided for @inverse_block_extract_desc.
  ///
  /// In en, this message translates to:
  /// **'The left block has been transformed to I. The right block is now the inverse matrix A⁻¹.'**
  String get inverse_block_extract_desc;

  /// No description provided for @arithmetic_add_cell_title.
  ///
  /// In en, this message translates to:
  /// **'Add Element at ({row}, {col})'**
  String arithmetic_add_cell_title(Object col, Object row);

  /// No description provided for @arithmetic_add_cell_desc.
  ///
  /// In en, this message translates to:
  /// **'Added corresponding elements: {formula}.'**
  String arithmetic_add_cell_desc(Object formula);

  /// No description provided for @arithmetic_mult_cell_title.
  ///
  /// In en, this message translates to:
  /// **'Compute Element ({row}, {col})'**
  String arithmetic_mult_cell_title(Object col, Object row);

  /// No description provided for @arithmetic_mult_cell_desc.
  ///
  /// In en, this message translates to:
  /// **'Dot product of Row {row} in Matrix A and Column {col} in Matrix B: {formula}.'**
  String arithmetic_mult_cell_desc(Object col, Object formula, Object row);

  /// No description provided for @error_matrix_is_singular.
  ///
  /// In en, this message translates to:
  /// **'This matrix is singular (determinant = 0), so it has no inverse.'**
  String get error_matrix_is_singular;

  /// No description provided for @error_inverse_not_square.
  ///
  /// In en, this message translates to:
  /// **'This operation requires a square matrix.'**
  String get error_inverse_not_square;

  /// No description provided for @error_dimension_mismatch_add.
  ///
  /// In en, this message translates to:
  /// **'Matrices must have the same dimensions for addition.'**
  String get error_dimension_mismatch_add;

  /// No description provided for @error_dimension_mismatch_multiply.
  ///
  /// In en, this message translates to:
  /// **'Column count of Matrix A must equal row count of Matrix B.'**
  String get error_dimension_mismatch_multiply;

  /// No description provided for @system_inconsistent_title.
  ///
  /// In en, this message translates to:
  /// **'Row {row} Contradiction: Inconsistent System'**
  String system_inconsistent_title(Object row);

  /// No description provided for @system_inconsistent_desc.
  ///
  /// In en, this message translates to:
  /// **'Row {row} reduces to [0 ... 0 | {val}], stating 0 = {val}. This is a contradiction, so the system has no solution.'**
  String system_inconsistent_desc(Object row, Object val);

  /// No description provided for @system_unique_title.
  ///
  /// In en, this message translates to:
  /// **'Unique Solution Found'**
  String get system_unique_title;

  /// No description provided for @system_unique_desc.
  ///
  /// In en, this message translates to:
  /// **'Every unknown corresponds to a pivot column. The unique solution is {solution}.'**
  String system_unique_desc(Object solution);

  /// No description provided for @system_infinite_title.
  ///
  /// In en, this message translates to:
  /// **'Infinite Solutions ({count} Free Variables)'**
  String system_infinite_title(Object count);

  /// No description provided for @system_infinite_desc.
  ///
  /// In en, this message translates to:
  /// **'The non-pivot variables ({freeVars}) are free parameters ({params}). The solution is expressed in parametric vector form.'**
  String system_infinite_desc(Object freeVars, Object params);

  /// No description provided for @rank_nullity_title.
  ///
  /// In en, this message translates to:
  /// **'Rank = {rank}, Nullity = {nullity}'**
  String rank_nullity_title(Object nullity, Object rank);

  /// No description provided for @rank_nullity_desc.
  ///
  /// In en, this message translates to:
  /// **'The matrix has {rank} pivot columns and {nullity} free columns. By the Rank-Nullity Theorem, rank(A) + nullity(A) = {cols}.'**
  String rank_nullity_desc(Object cols, Object nullity, Object rank);

  /// No description provided for @eigen_char_poly_title.
  ///
  /// In en, this message translates to:
  /// **'Characteristic Polynomial'**
  String get eigen_char_poly_title;

  /// No description provided for @eigen_trace_det_desc.
  ///
  /// In en, this message translates to:
  /// **'For a 2x2 matrix, the characteristic equation is λ² - tr(A)λ + det(A) = 0 with trace = {trace} and det = {det}.'**
  String eigen_trace_det_desc(Object det, Object trace);

  /// No description provided for @eigen_complex_title.
  ///
  /// In en, this message translates to:
  /// **'Complex Eigenvalues'**
  String get eigen_complex_title;

  /// No description provided for @eigen_complex_desc.
  ///
  /// In en, this message translates to:
  /// **'The discriminant is negative for {poly}. The eigenvalues are complex conjugates: {roots}.'**
  String eigen_complex_desc(Object poly, Object roots);

  /// No description provided for @eigen_roots_title.
  ///
  /// In en, this message translates to:
  /// **'Eigenvalues (Roots of Characteristic Equation)'**
  String get eigen_roots_title;

  /// No description provided for @eigen_roots_approx_desc.
  ///
  /// In en, this message translates to:
  /// **'Solving {poly} gives approximate real eigenvalues, rounded to three decimal places: {roots}.'**
  String eigen_roots_approx_desc(Object poly, Object roots);

  /// No description provided for @eigen_roots_desc.
  ///
  /// In en, this message translates to:
  /// **'Solving {poly} yields the real eigenvalues: {roots}.'**
  String eigen_roots_desc(Object poly, Object roots);

  /// No description provided for @eigen_vector_title.
  ///
  /// In en, this message translates to:
  /// **'Eigenvector for λ_{index} = {lambda}'**
  String eigen_vector_title(Object index, Object lambda);

  /// No description provided for @eigen_vector_desc.
  ///
  /// In en, this message translates to:
  /// **'For (A − {lambda}I)v = 0, one representative eigenvector is {vector}.'**
  String eigen_vector_desc(Object lambda, Object vector);

  /// No description provided for @eigen_3x3_poly_desc.
  ///
  /// In en, this message translates to:
  /// **'For a 3x3 matrix, the characteristic equation is {poly} with trace = {trace} and det = {det}.'**
  String eigen_3x3_poly_desc(Object det, Object poly, Object trace);

  /// No description provided for @eigen_irrational_desc.
  ///
  /// In en, this message translates to:
  /// **'No integer root from −20 to 20 was found for {poly}. Other real or complex roots may exist; this solver does not compute them.'**
  String eigen_irrational_desc(Object poly);

  /// No description provided for @topicLu.
  ///
  /// In en, this message translates to:
  /// **'LU Decomposition (A = LU)'**
  String get topicLu;

  /// No description provided for @topicLuDesc.
  ///
  /// In en, this message translates to:
  /// **'Factorize a square matrix into lower (L) and upper (U) triangular matrices.'**
  String get topicLuDesc;

  /// No description provided for @topicPractice.
  ///
  /// In en, this message translates to:
  /// **'Self-Test & Practice Quiz'**
  String get topicPractice;

  /// No description provided for @topicPracticeDesc.
  ///
  /// In en, this message translates to:
  /// **'Interactive challenges with instant pedagogical feedback and scoring.'**
  String get topicPracticeDesc;

  /// No description provided for @lu_init_title.
  ///
  /// In en, this message translates to:
  /// **'Initialize LU Factorization'**
  String get lu_init_title;

  /// No description provided for @lu_init_desc.
  ///
  /// In en, this message translates to:
  /// **'Initialize L as identity matrix I with 1s on diagonal, and U as matrix A.'**
  String get lu_init_desc;

  /// No description provided for @lu_swap_desc.
  ///
  /// In en, this message translates to:
  /// **'Pivot was 0. Swapped Row {rowA} with Row {rowB} (requires permutation matrix P).'**
  String lu_swap_desc(Object rowA, Object rowB);

  /// No description provided for @lu_elim_title.
  ///
  /// In en, this message translates to:
  /// **'Eliminate Entry in Row {target} using Pivot Row {source}'**
  String lu_elim_title(Object source, Object target);

  /// No description provided for @lu_elim_desc.
  ///
  /// In en, this message translates to:
  /// **'Multiplier m_{target}{source} = {multiplier} is saved in L at ({target},{source}). Row operation on U: R_{target} ← R_{target} - ({multiplier})R_{source}.'**
  String lu_elim_desc(Object multiplier, Object source, Object target);

  /// No description provided for @lu_final_title.
  ///
  /// In en, this message translates to:
  /// **'LU Factorization Complete'**
  String get lu_final_title;

  /// No description provided for @lu_final_desc.
  ///
  /// In en, this message translates to:
  /// **'Matrix successfully decomposed into L (lower triangular) and U (upper triangular).'**
  String get lu_final_desc;

  /// No description provided for @practiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Self-Test (Practice Mode)'**
  String get practiceTitle;

  /// No description provided for @practiceScore.
  ///
  /// In en, this message translates to:
  /// **'{score} Points'**
  String practiceScore(Object score);

  /// No description provided for @practiceQuestionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} / {total}'**
  String practiceQuestionProgress(Object current, Object total);

  /// No description provided for @practiceHint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get practiceHint;

  /// No description provided for @practiceHideHint.
  ///
  /// In en, this message translates to:
  /// **'Hide Hint'**
  String get practiceHideHint;

  /// No description provided for @practiceCorrect.
  ///
  /// In en, this message translates to:
  /// **'Congratulations, Correct Answer!'**
  String get practiceCorrect;

  /// No description provided for @practiceIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect Selection'**
  String get practiceIncorrect;

  /// No description provided for @practiceNext.
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get practiceNext;

  /// No description provided for @practiceResults.
  ///
  /// In en, this message translates to:
  /// **'View Results'**
  String get practiceResults;

  /// No description provided for @practiceCompleted.
  ///
  /// In en, this message translates to:
  /// **'Practice Completed!'**
  String get practiceCompleted;

  /// No description provided for @practiceTotalScore.
  ///
  /// In en, this message translates to:
  /// **'Total Score: {score} / {total}'**
  String practiceTotalScore(Object score, Object total);

  /// No description provided for @practicePerfectScore.
  ///
  /// In en, this message translates to:
  /// **'Great job! You answered all questions correctly for a perfect score!'**
  String get practicePerfectScore;

  /// No description provided for @practiceGoodEffort.
  ///
  /// In en, this message translates to:
  /// **'Good effort! Try again to master matrix operations even further.'**
  String get practiceGoodEffort;

  /// No description provided for @practiceReturnTopics.
  ///
  /// In en, this message translates to:
  /// **'Return to Topics'**
  String get practiceReturnTopics;

  /// No description provided for @practiceRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart Quiz'**
  String get practiceRestart;

  /// No description provided for @searchTopics.
  ///
  /// In en, this message translates to:
  /// **'Search topics...'**
  String get searchTopics;

  /// No description provided for @noTopicsFound.
  ///
  /// In en, this message translates to:
  /// **'No matching topics found'**
  String get noTopicsFound;

  /// No description provided for @noTopicsFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different keyword or select another category.'**
  String get noTopicsFoundDesc;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearch;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @replayAnimation.
  ///
  /// In en, this message translates to:
  /// **'Replay Animation'**
  String get replayAnimation;

  /// No description provided for @basisVectorI.
  ///
  /// In en, this message translates to:
  /// **'î = ({x}, {y})'**
  String basisVectorI(Object x, Object y);

  /// No description provided for @basisVectorJ.
  ///
  /// In en, this message translates to:
  /// **'ĵ = ({x}, {y})'**
  String basisVectorJ(Object x, Object y);

  /// No description provided for @progressPercent.
  ///
  /// In en, this message translates to:
  /// **'t = {percent}%'**
  String progressPercent(Object percent);

  /// No description provided for @inputHelp.
  ///
  /// In en, this message translates to:
  /// **'Select a cell, then enter an integer, decimal, or fraction.'**
  String get inputHelp;

  /// No description provided for @inputInvalid.
  ///
  /// In en, this message translates to:
  /// **'Check matrix {matrix}, row {row}, column {column}. Enter a complete number; a fraction cannot have a zero denominator.'**
  String inputInvalid(String matrix, int row, int column);

  /// No description provided for @calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating…'**
  String get calculating;

  /// No description provided for @inputCell.
  ///
  /// In en, this message translates to:
  /// **'Matrix {matrix}, row {row}, column {column}'**
  String inputCell(String matrix, int row, int column);

  /// No description provided for @stepAlreadyReducedTitle.
  ///
  /// In en, this message translates to:
  /// **'Already in the requested form'**
  String get stepAlreadyReducedTitle;

  /// No description provided for @stepAlreadyReducedDesc.
  ///
  /// In en, this message translates to:
  /// **'No row operations are needed. The matrix shown is the result.'**
  String get stepAlreadyReducedDesc;

  /// No description provided for @keyPreviousCell.
  ///
  /// In en, this message translates to:
  /// **'Previous cell'**
  String get keyPreviousCell;

  /// No description provided for @keyNextCell.
  ///
  /// In en, this message translates to:
  /// **'Next cell'**
  String get keyNextCell;

  /// No description provided for @keySign.
  ///
  /// In en, this message translates to:
  /// **'Toggle sign'**
  String get keySign;

  /// No description provided for @keyFraction.
  ///
  /// In en, this message translates to:
  /// **'Fraction slash'**
  String get keyFraction;

  /// No description provided for @keyBackspace.
  ///
  /// In en, this message translates to:
  /// **'Delete last digit'**
  String get keyBackspace;

  /// No description provided for @keyClear.
  ///
  /// In en, this message translates to:
  /// **'Clear cell'**
  String get keyClear;

  /// No description provided for @keyDecimal.
  ///
  /// In en, this message translates to:
  /// **'Decimal point'**
  String get keyDecimal;

  /// No description provided for @instructionProgress.
  ///
  /// In en, this message translates to:
  /// **'This operation'**
  String get instructionProgress;

  /// No description provided for @customTransform.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customTransform;

  /// No description provided for @transformCoefficients.
  ///
  /// In en, this message translates to:
  /// **'Transformation matrix'**
  String get transformCoefficients;

  /// No description provided for @basisVectors.
  ///
  /// In en, this message translates to:
  /// **'Transformed basis vectors'**
  String get basisVectors;

  /// No description provided for @targetDeterminant.
  ///
  /// In en, this message translates to:
  /// **'Target determinant'**
  String get targetDeterminant;

  /// No description provided for @matrixCellLabel.
  ///
  /// In en, this message translates to:
  /// **'Row {row}, column {column}, value {value}'**
  String matrixCellLabel(int row, int column, String value);

  /// No description provided for @focusSource.
  ///
  /// In en, this message translates to:
  /// **'Understand the goal'**
  String get focusSource;

  /// No description provided for @focusOperation.
  ///
  /// In en, this message translates to:
  /// **'Follow the calculation'**
  String get focusOperation;

  /// No description provided for @focusResult.
  ///
  /// In en, this message translates to:
  /// **'Check what changed'**
  String get focusResult;

  /// No description provided for @inspectOperation.
  ///
  /// In en, this message translates to:
  /// **'Inspect this operation'**
  String get inspectOperation;

  /// No description provided for @stepExplanation.
  ///
  /// In en, this message translates to:
  /// **'Why this works'**
  String get stepExplanation;

  /// No description provided for @cellCalculations.
  ///
  /// In en, this message translates to:
  /// **'Cell calculations'**
  String get cellCalculations;

  /// No description provided for @chooseStep.
  ///
  /// In en, this message translates to:
  /// **'Choose a step'**
  String get chooseStep;

  /// No description provided for @learningPath.
  ///
  /// In en, this message translates to:
  /// **'New to matrices?'**
  String get learningPath;

  /// No description provided for @pathEliminate.
  ///
  /// In en, this message translates to:
  /// **'1 · Create zeros'**
  String get pathEliminate;

  /// No description provided for @pathReduce.
  ///
  /// In en, this message translates to:
  /// **'2 · Find the pivots'**
  String get pathReduce;

  /// No description provided for @pathSolve.
  ///
  /// In en, this message translates to:
  /// **'3 · Solve a system'**
  String get pathSolve;

  /// No description provided for @guideGenericSource.
  ///
  /// In en, this message translates to:
  /// **'Read the current matrix and the goal of this step.'**
  String get guideGenericSource;

  /// No description provided for @guideGenericApply.
  ///
  /// In en, this message translates to:
  /// **'Follow the highlighted entries. The explanation gives the reasoning.'**
  String get guideGenericApply;

  /// No description provided for @guideGenericResult.
  ///
  /// In en, this message translates to:
  /// **'Compare the result with the explanation. Continue when you are ready.'**
  String get guideGenericResult;

  /// No description provided for @guideEliminateSource.
  ///
  /// In en, this message translates to:
  /// **'Use row {source} to change row {target}. Focus on column {column}.'**
  String guideEliminateSource(String source, String target, String column);

  /// No description provided for @guideEliminateApply.
  ///
  /// In en, this message translates to:
  /// **'Add {factor} times row {source} to row {target}. Apply the same operation to every entry in the row.'**
  String guideEliminateApply(String factor, String source, String target);

  /// No description provided for @guideEliminateResult.
  ///
  /// In en, this message translates to:
  /// **'The entry in column {column} is now {value}. The row operation preserves the solution set.'**
  String guideEliminateResult(String column, String value);

  /// No description provided for @guideScaleSource.
  ///
  /// In en, this message translates to:
  /// **'Scale every entry in row {row} by the same nonzero factor: {factor}.'**
  String guideScaleSource(String row, String factor);

  /// No description provided for @guideScaleApply.
  ///
  /// In en, this message translates to:
  /// **'Apply the factor to the whole row, not just the pivot.'**
  String get guideScaleApply;

  /// No description provided for @guideScaleResult.
  ///
  /// In en, this message translates to:
  /// **'The row has been scaled. Compare each entry with the original row.'**
  String get guideScaleResult;

  /// No description provided for @guideSwapSource.
  ///
  /// In en, this message translates to:
  /// **'Rows {first} and {second} will exchange places.'**
  String guideSwapSource(String first, String second);

  /// No description provided for @guideSwapApply.
  ///
  /// In en, this message translates to:
  /// **'Move the whole rows together; the entries themselves do not change.'**
  String get guideSwapApply;

  /// No description provided for @guideSwapResult.
  ///
  /// In en, this message translates to:
  /// **'The rows are in their new positions. The solution set is unchanged.'**
  String get guideSwapResult;

  /// No description provided for @guideDotSource.
  ///
  /// In en, this message translates to:
  /// **'Pair row {row} with column {column}. Each pair contributes to one output entry.'**
  String guideDotSource(String row, String column);

  /// No description provided for @guideDotApply.
  ///
  /// In en, this message translates to:
  /// **'Multiply matching entries, then add their contributions.'**
  String get guideDotApply;

  /// No description provided for @guideDotResult.
  ///
  /// In en, this message translates to:
  /// **'The sum gives the entry at row {row}, column {column}.'**
  String guideDotResult(String row, String column);

  /// No description provided for @guideDetSource.
  ///
  /// In en, this message translates to:
  /// **'Follow the factors in each product. The signs determine which products are subtracted.'**
  String get guideDetSource;

  /// No description provided for @guideDetApply.
  ///
  /// In en, this message translates to:
  /// **'One product is highlighted at a time. Read its factors below the matrix.'**
  String get guideDetApply;

  /// No description provided for @guideDetResult.
  ///
  /// In en, this message translates to:
  /// **'The products remain visible below, so you can check the result at your own pace.'**
  String get guideDetResult;

  /// No description provided for @coefficientError.
  ///
  /// In en, this message translates to:
  /// **'Enter a number from −1000 to 1000.'**
  String get coefficientError;

  /// No description provided for @transformTransitionHint.
  ///
  /// In en, this message translates to:
  /// **'Edit a coefficient and press Enter or leave the field to apply. Values: −1000 to 1000. The slider compares the previous and new states; intermediate frames are transitions between transformations.'**
  String get transformTransitionHint;

  /// No description provided for @multiplicationSourceRow.
  ///
  /// In en, this message translates to:
  /// **'A · row {row}'**
  String multiplicationSourceRow(String row);

  /// No description provided for @multiplicationSourceColumn.
  ///
  /// In en, this message translates to:
  /// **'B · column {column}'**
  String multiplicationSourceColumn(String column);

  /// No description provided for @multiplicationOutput.
  ///
  /// In en, this message translates to:
  /// **'C = A × B · result matrix'**
  String get multiplicationOutput;

  /// No description provided for @guideEliminateReason.
  ///
  /// In en, this message translates to:
  /// **'Target {entry} ÷ pivot {pivot} = {ratio}. Subtract this multiple of the source row to cancel the target entry.'**
  String guideEliminateReason(String entry, String pivot, String ratio);

  /// No description provided for @guideEliminateSubtract.
  ///
  /// In en, this message translates to:
  /// **'Subtract {factor} times row {source} from row {target}. Apply this to every entry in the row.'**
  String guideEliminateSubtract(String factor, String source, String target);

  /// No description provided for @transformProgress.
  ///
  /// In en, this message translates to:
  /// **'Transition progress'**
  String get transformProgress;

  /// No description provided for @increaseCoefficient.
  ///
  /// In en, this message translates to:
  /// **'Increase coefficient {name}'**
  String increaseCoefficient(String name);

  /// No description provided for @decreaseCoefficient.
  ///
  /// In en, this message translates to:
  /// **'Decrease coefficient {name}'**
  String decreaseCoefficient(String name);

  /// No description provided for @guideDotReason.
  ///
  /// In en, this message translates to:
  /// **'One output entry uses a whole row of A and a whole column of B. Multiply entries in matching positions, then add their contributions.'**
  String get guideDotReason;

  /// No description provided for @guideDetReason.
  ///
  /// In en, this message translates to:
  /// **'The determinant measures signed area or volume scaling. Add the products marked + and subtract those marked −; a zero determinant means the transformation loses a dimension.'**
  String get guideDetReason;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @practiceNav.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceNav;

  /// No description provided for @transformNav.
  ///
  /// In en, this message translates to:
  /// **'Transformations'**
  String get transformNav;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @learning.
  ///
  /// In en, this message translates to:
  /// **'Learning & playback'**
  String get learning;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @solutionModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Solution view'**
  String get solutionModeLabel;

  /// No description provided for @guidedMode.
  ///
  /// In en, this message translates to:
  /// **'Guided animation'**
  String get guidedMode;

  /// No description provided for @stepsMode.
  ///
  /// In en, this message translates to:
  /// **'Static steps'**
  String get stepsMode;

  /// No description provided for @resultMode.
  ///
  /// In en, this message translates to:
  /// **'Direct result'**
  String get resultMode;

  /// No description provided for @showResult.
  ///
  /// In en, this message translates to:
  /// **'Show result'**
  String get showResult;

  /// No description provided for @viewSteps.
  ///
  /// In en, this message translates to:
  /// **'Explore steps'**
  String get viewSteps;

  /// No description provided for @motionLabel.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get motionLabel;

  /// No description provided for @motionHelp.
  ///
  /// In en, this message translates to:
  /// **'System reduced motion is always respected.'**
  String get motionHelp;

  /// No description provided for @shortExplanation.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get shortExplanation;

  /// No description provided for @detailedExplanation.
  ///
  /// In en, this message translates to:
  /// **'Detailed'**
  String get detailedExplanation;

  /// No description provided for @hiddenExplanation.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get hiddenExplanation;

  /// No description provided for @predictionLabel.
  ///
  /// In en, this message translates to:
  /// **'Prediction questions'**
  String get predictionLabel;

  /// No description provided for @predictionHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional checkpoints in worked examples.'**
  String get predictionHelp;

  /// No description provided for @predictTitle.
  ///
  /// In en, this message translates to:
  /// **'Before we try it…'**
  String get predictTitle;

  /// No description provided for @predictPrompt.
  ///
  /// In en, this message translates to:
  /// **'Which factor cancels the target entry?'**
  String get predictPrompt;

  /// No description provided for @predictCorrect.
  ///
  /// In en, this message translates to:
  /// **'Exactly! Now follow the same operation across the row.'**
  String get predictCorrect;

  /// No description provided for @predictIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Divide the target by the pivot to find the factor.'**
  String get predictIncorrect;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @numberView.
  ///
  /// In en, this message translates to:
  /// **'Number display'**
  String get numberView;

  /// No description provided for @fractionView.
  ///
  /// In en, this message translates to:
  /// **'Exact fractions'**
  String get fractionView;

  /// No description provided for @decimalView.
  ///
  /// In en, this message translates to:
  /// **'Decimals'**
  String get decimalView;

  /// No description provided for @densityLabel.
  ///
  /// In en, this message translates to:
  /// **'Layout density'**
  String get densityLabel;

  /// No description provided for @comfortable.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get comfortable;

  /// No description provided for @compact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get compact;

  /// No description provided for @accentLabel.
  ///
  /// In en, this message translates to:
  /// **'Accent palette'**
  String get accentLabel;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// No description provided for @teal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get teal;

  /// No description provided for @purple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get purple;

  /// No description provided for @shortcutsLabel.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get shortcutsLabel;

  /// No description provided for @shortcutHelp.
  ///
  /// In en, this message translates to:
  /// **'Select an action, then press a letter, Space or a horizontal arrow. Home/End and Page Up/Down remain available.'**
  String get shortcutHelp;

  /// No description provided for @pressKey.
  ///
  /// In en, this message translates to:
  /// **'Press a key'**
  String get pressKey;

  /// No description provided for @shortcutConflict.
  ///
  /// In en, this message translates to:
  /// **'That key is reserved or already assigned.'**
  String get shortcutConflict;

  /// No description provided for @resetSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset settings'**
  String get resetSettings;

  /// No description provided for @settingsStorageError.
  ///
  /// In en, this message translates to:
  /// **'Preferences could not be read or saved. Changes remain available for this session.'**
  String get settingsStorageError;

  /// No description provided for @localPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences stay on this device. Matrix history is not saved.'**
  String get localPreferences;

  /// No description provided for @resultExact.
  ///
  /// In en, this message translates to:
  /// **'Exact'**
  String get resultExact;

  /// No description provided for @resultApproximate.
  ///
  /// In en, this message translates to:
  /// **'Approximate'**
  String get resultApproximate;

  /// No description provided for @resultComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get resultComplete;

  /// No description provided for @resultPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get resultPartial;

  /// No description provided for @resultUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Unsupported'**
  String get resultUnsupported;

  /// No description provided for @eigenPrecision.
  ///
  /// In en, this message translates to:
  /// **'Eigenvalues are rounded to three decimals; vectors are approximate directions, not exact null-space solutions.'**
  String get eigenPrecision;

  /// No description provided for @eigenScope.
  ///
  /// In en, this message translates to:
  /// **'3×3 analysis searches integer roots from −20 to 20. Missing roots may be real or complex.'**
  String get eigenScope;

  /// No description provided for @eigenBasisScope.
  ///
  /// In en, this message translates to:
  /// **'One representative vector per eigenvalue is shown; a full eigenspace basis is not computed.'**
  String get eigenBasisScope;

  /// No description provided for @complexScope.
  ///
  /// In en, this message translates to:
  /// **'Complex eigenvectors are not supported. The imaginary part is rounded to two decimals.'**
  String get complexScope;

  /// No description provided for @guideAddSource.
  ///
  /// In en, this message translates to:
  /// **'Match the same position in A and B.'**
  String get guideAddSource;

  /// No description provided for @guideAddApply.
  ///
  /// In en, this message translates to:
  /// **'Add this pair of entries.'**
  String get guideAddApply;

  /// No description provided for @guideAddResult.
  ///
  /// In en, this message translates to:
  /// **'Their sum belongs in the same position in C.'**
  String get guideAddResult;

  /// No description provided for @quizQ1QuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Gaussian Elimination: Pivot & Elimination'**
  String get quizQ1QuestionTitle;

  /// No description provided for @quizQ1Prompt.
  ///
  /// In en, this message translates to:
  /// **'In the matrix below, the first pivot is at cell (1,1). Which elementary row operation eliminates the first entry in row 2?'**
  String get quizQ1Prompt;

  /// No description provided for @quizQ1Explanation.
  ///
  /// In en, this message translates to:
  /// **'The first entry in row 2 is 2, and the pivot is 1. To obtain 2 - 2(1) = 0, apply R_2 \\leftarrow R_2 - 2R_1.'**
  String get quizQ1Explanation;

  /// No description provided for @quizQ1Hint.
  ///
  /// In en, this message translates to:
  /// **'Subtract a multiple of the pivot row from the target row to create a zero.'**
  String get quizQ1Hint;

  /// No description provided for @quizQ1Feedback0.
  ///
  /// In en, this message translates to:
  /// **'Subtracting twice row 1 creates 2 − 2 = 0.'**
  String get quizQ1Feedback0;

  /// No description provided for @quizQ1Feedback1.
  ///
  /// In en, this message translates to:
  /// **'Adding twice row 1 gives 2 + 2 = 4, not zero.'**
  String get quizQ1Feedback1;

  /// No description provided for @quizQ1Feedback2.
  ///
  /// In en, this message translates to:
  /// **'Swapping rows moves the entries but does not eliminate the target entry.'**
  String get quizQ1Feedback2;

  /// No description provided for @quizQ1Feedback3.
  ///
  /// In en, this message translates to:
  /// **'Halving row 2 changes its first entry to 1, not zero.'**
  String get quizQ1Feedback3;

  /// No description provided for @quizQ2QuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Row Swap (Permutation) Requirement'**
  String get quizQ2QuestionTitle;

  /// No description provided for @quizQ2Prompt.
  ///
  /// In en, this message translates to:
  /// **'The pivot position (1,1) contains 0. Which row swap places a non-zero pivot at (1,1)?'**
  String get quizQ2Prompt;

  /// No description provided for @quizQ2Explanation.
  ///
  /// In en, this message translates to:
  /// **'The pivot entry cannot be zero. To place a non-zero leading entry in row 1, swap rows 1 and 2: R_1 \\leftrightarrow R_2.'**
  String get quizQ2Explanation;

  /// No description provided for @quizQ2Hint.
  ///
  /// In en, this message translates to:
  /// **'A zero pivot cannot eliminate other rows; swap with a row having a non-zero leading entry.'**
  String get quizQ2Hint;

  /// No description provided for @quizQ2Feedback0.
  ///
  /// In en, this message translates to:
  /// **'Adding row 2 would also create a non-zero pivot, but this question asks specifically for a row swap.'**
  String get quizQ2Feedback0;

  /// No description provided for @quizQ2Feedback1.
  ///
  /// In en, this message translates to:
  /// **'Swapping rows 1 and 2 moves the non-zero entry 3 into the pivot position.'**
  String get quizQ2Feedback1;

  /// No description provided for @quizQ2Feedback2.
  ///
  /// In en, this message translates to:
  /// **'Changing row 2 leaves the zero at (1,1) unchanged.'**
  String get quizQ2Feedback2;

  /// No description provided for @quizQ2Feedback3.
  ///
  /// In en, this message translates to:
  /// **'Scaling row 3 leaves the zero at (1,1) unchanged.'**
  String get quizQ2Feedback3;

  /// No description provided for @quizQ3QuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Pivot Normalization (Scaling)'**
  String get quizQ3QuestionTitle;

  /// No description provided for @quizQ3Prompt.
  ///
  /// In en, this message translates to:
  /// **'The pivot entry in row 2 is -3. Which operation scales this row to produce a leading one (1)?'**
  String get quizQ3Prompt;

  /// No description provided for @quizQ3Explanation.
  ///
  /// In en, this message translates to:
  /// **'Multiply every entry in row 2 by −1/3: (−3) × (−1/3) = 1.'**
  String get quizQ3Explanation;

  /// No description provided for @quizQ3Hint.
  ///
  /// In en, this message translates to:
  /// **'Multiply the entire row by the reciprocal of the pivot value.'**
  String get quizQ3Hint;

  /// No description provided for @quizQ3Feedback0.
  ///
  /// In en, this message translates to:
  /// **'Adding row 1 destroys the leading zero and does not normalize this pivot.'**
  String get quizQ3Feedback0;

  /// No description provided for @quizQ3Feedback1.
  ///
  /// In en, this message translates to:
  /// **'The reciprocal of −3 is −1/3, so their product is 1.'**
  String get quizQ3Feedback1;

  /// No description provided for @quizQ3Feedback2.
  ///
  /// In en, this message translates to:
  /// **'Multiplying −3 by 3 gives −9. Use the reciprocal instead.'**
  String get quizQ3Feedback2;

  /// No description provided for @quizQ3Feedback3.
  ///
  /// In en, this message translates to:
  /// **'Swapping rows changes positions; it does not scale −3 to 1.'**
  String get quizQ3Feedback3;

  /// No description provided for @quizQ4QuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Matrix Rank and Zero Rows'**
  String get quizQ4QuestionTitle;

  /// No description provided for @quizQ4Prompt.
  ///
  /// In en, this message translates to:
  /// **'What is the rank (number of linearly independent rows) of this echelon form matrix?'**
  String get quizQ4Prompt;

  /// No description provided for @quizQ4Explanation.
  ///
  /// In en, this message translates to:
  /// **'The matrix is in echelon form with 2 non-zero pivot rows and 1 all-zero row. Therefore, rank(A) = 2.'**
  String get quizQ4Explanation;

  /// No description provided for @quizQ4Hint.
  ///
  /// In en, this message translates to:
  /// **'Count the number of non-zero rows in row echelon form.'**
  String get quizQ4Hint;

  /// No description provided for @quizQ4Feedback0.
  ///
  /// In en, this message translates to:
  /// **'The zero row contributes no pivot. Matrix size alone does not determine rank.'**
  String get quizQ4Feedback0;

  /// No description provided for @quizQ4Feedback1.
  ///
  /// In en, this message translates to:
  /// **'There are two pivot rows in this echelon matrix.'**
  String get quizQ4Feedback1;

  /// No description provided for @quizQ4Feedback2.
  ///
  /// In en, this message translates to:
  /// **'The second non-zero row contains another pivot and must also be counted.'**
  String get quizQ4Feedback2;

  /// No description provided for @quizQ4Feedback3.
  ///
  /// In en, this message translates to:
  /// **'Rank zero would require every entry of the matrix to be zero.'**
  String get quizQ4Feedback3;

  /// No description provided for @quizQ5QuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Determinant of a Triangular Matrix'**
  String get quizQ5QuestionTitle;

  /// No description provided for @quizQ5Prompt.
  ///
  /// In en, this message translates to:
  /// **'The determinant of an upper triangular matrix equals the product of its main diagonal entries. What is det(A)?'**
  String get quizQ5Prompt;

  /// No description provided for @quizQ5Explanation.
  ///
  /// In en, this message translates to:
  /// **'For any triangular matrix, det(A) is the product of entries along the main diagonal: 2 \\cdot 3 \\cdot 4 = 24.'**
  String get quizQ5Explanation;

  /// No description provided for @quizQ5Hint.
  ///
  /// In en, this message translates to:
  /// **'When all entries below the main diagonal are zero, multiply the diagonal entries directly.'**
  String get quizQ5Hint;

  /// No description provided for @quizQ5Feedback0.
  ///
  /// In en, this message translates to:
  /// **'For a triangular determinant, multiply the diagonal entries; their sum is the trace.'**
  String get quizQ5Feedback0;

  /// No description provided for @quizQ5Feedback1.
  ///
  /// In en, this message translates to:
  /// **'The diagonal product is 2 × 3 × 4 = 24.'**
  String get quizQ5Feedback1;

  /// No description provided for @quizQ5Feedback2.
  ///
  /// In en, this message translates to:
  /// **'Zeros below the diagonal do not force determinant zero. A zero diagonal entry would.'**
  String get quizQ5Feedback2;

  /// No description provided for @quizQ5Feedback3.
  ///
  /// In en, this message translates to:
  /// **'All diagonal entries are positive; no extra negative sign is introduced.'**
  String get quizQ5Feedback3;

  /// No description provided for @eigen_vector_approx_title.
  ///
  /// In en, this message translates to:
  /// **'Approximate vector for λ_{index} ≈ {lambda}'**
  String eigen_vector_approx_title(Object index, Object lambda);

  /// No description provided for @eigen_vector_approx_desc.
  ///
  /// In en, this message translates to:
  /// **'Using λ ≈ {lambda}, an approximate direction is {vector}. The rounded value does not give an exact null-space solution.'**
  String eigen_vector_approx_desc(Object lambda, Object vector);

  /// No description provided for @spaceKey.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get spaceKey;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ru', 'tr', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
