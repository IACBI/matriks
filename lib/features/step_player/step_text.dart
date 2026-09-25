import '../../l10n/generated/app_localizations.dart';

/// Localized title or explanation of a solver step.
///
/// The engine names each text by an ARB key with loosely typed parameters, so
/// an unknown key or a parameter of the wrong type yields the key itself
/// instead of throwing; `rendered_prose_regression_test.dart` and
/// `step_text_test.dart` check that every emitted key resolves.
String localizedStepText(
  AppLocalizations l10n,
  String key,
  Map<String, dynamic> params,
) {
  try {
    switch (key) {
      case 'stepAlreadyReducedTitle':
        return l10n.stepAlreadyReducedTitle;
      case 'stepAlreadyReducedDesc':
        return l10n.stepAlreadyReducedDesc;
      case 'step_row_swap_title':
        return l10n.step_row_swap_title(
          params['rowA'] ?? 0,
          params['rowB'] ?? 0,
        );
      case 'step_row_swap_desc':
        return l10n.step_row_swap_desc(
          params['col'] ?? 0,
          params['pivot']?.toString() ?? '',
          params['rowA'] ?? 0,
          params['rowB'] ?? 0,
        );
      case 'step_row_scale_title':
        return l10n.step_row_scale_title(params['row'] ?? 0);
      case 'step_row_scale_desc':
        return l10n.step_row_scale_desc(
          params['factor']?.toString() ?? '',
          params['row'] ?? 0,
        );
      case 'step_row_elimination_title':
        return l10n.step_row_elimination_title(
          params['source'] ?? 0,
          params['target'] ?? 0,
        );
      case 'step_row_elimination_desc':
        return l10n.step_row_elimination_desc(
          params['col'] ?? 0,
          params['multiplier']?.toString() ?? '',
          params['source'] ?? 0,
          params['target'] ?? 0,
        );

      // Determinant keys
      case 'det_1x1_title':
        return l10n.det_1x1_title;
      case 'det_1x1_desc':
        return l10n.det_1x1_desc(params['val']?.toString() ?? '');
      case 'det_2x2_main_diagonal_title':
        return l10n.det_2x2_main_diagonal_title;
      case 'det_2x2_main_diagonal_desc':
        return l10n.det_2x2_main_diagonal_desc(
          params['a']?.toString() ?? '',
          params['d']?.toString() ?? '',
          params['product']?.toString() ?? '',
        );
      case 'det_2x2_anti_diagonal_title':
        return l10n.det_2x2_anti_diagonal_title;
      case 'det_2x2_anti_diagonal_desc':
        return l10n.det_2x2_anti_diagonal_desc(
          params['b']?.toString() ?? '',
          params['c']?.toString() ?? '',
          params['product']?.toString() ?? '',
        );
      case 'det_2x2_final_title':
        return l10n.det_2x2_final_title;
      case 'det_2x2_final_desc':
        return l10n.det_2x2_final_desc(
          params['anti']?.toString() ?? '',
          params['det']?.toString() ?? '',
          params['main']?.toString() ?? '',
        );
      case 'det_sarrus_pos_title':
        return l10n.det_sarrus_pos_title;
      case 'det_sarrus_pos_desc':
        return l10n.det_sarrus_pos_desc(
          params['p1']?.toString() ?? '',
          params['p2']?.toString() ?? '',
          params['p3']?.toString() ?? '',
          params['total']?.toString() ?? '',
        );
      case 'det_sarrus_neg_title':
        return l10n.det_sarrus_neg_title;
      case 'det_sarrus_neg_desc':
        return l10n.det_sarrus_neg_desc(
          params['n1']?.toString() ?? '',
          params['n2']?.toString() ?? '',
          params['n3']?.toString() ?? '',
          params['total']?.toString() ?? '',
        );
      case 'det_sarrus_final_title':
        return l10n.det_sarrus_final_title;
      case 'det_sarrus_final_desc':
        return l10n.det_sarrus_final_desc(
          params['det']?.toString() ?? '',
          params['neg']?.toString() ?? '',
          params['pos']?.toString() ?? '',
        );
      case 'det_singular_column_title':
        return l10n.det_singular_column_title;
      case 'det_singular_column_desc':
        return l10n.det_singular_column_desc(params['col'] ?? 0);
      case 'det_row_swap_title':
        return l10n.det_row_swap_title;
      case 'det_row_swap_desc':
        return l10n.det_row_swap_desc(params['rowA'] ?? 0, params['rowB'] ?? 0);
      case 'det_diagonal_product_title':
        return l10n.det_diagonal_product_title;
      case 'det_diagonal_product_desc':
        return l10n.det_diagonal_product_desc(
          params['det']?.toString() ?? '',
          params['diagonals']?.toString() ?? '',
          params['sign']?.toString() ?? '',
        );

      // Inverse keys
      case 'inverse_singular_title':
        return l10n.inverse_singular_title;
      case 'inverse_singular_desc':
        return l10n.inverse_singular_desc;
      case 'inverse_2x2_det_title':
        return l10n.inverse_2x2_det_title;
      case 'inverse_2x2_det_desc':
        return l10n.inverse_2x2_det_desc(
          params['det']?.toString() ?? '',
          params['formula']?.toString() ?? '',
        );
      case 'inverse_2x2_adjoint_title':
        return l10n.inverse_2x2_adjoint_title;
      case 'inverse_2x2_adjoint_desc':
        return l10n.inverse_2x2_adjoint_desc;
      case 'inverse_2x2_scale_title':
        return l10n.inverse_2x2_scale_title;
      case 'inverse_2x2_scale_desc':
        return l10n.inverse_2x2_scale_desc(params['factor']?.toString() ?? '');
      case 'inverse_block_init_title':
        return l10n.inverse_block_init_title;
      case 'inverse_block_init_desc':
        return l10n.inverse_block_init_desc(params['n'] ?? 0);
      case 'inverse_block_extract_title':
        return l10n.inverse_block_extract_title;
      case 'inverse_block_extract_desc':
        return l10n.inverse_block_extract_desc;

      // Arithmetic keys
      case 'arithmetic_add_cell_title':
        return l10n.arithmetic_add_cell_title(
          params['col'] ?? 0,
          params['row'] ?? 0,
        );
      case 'arithmetic_add_cell_desc':
        return l10n.arithmetic_add_cell_desc(
          params['formula']?.toString() ?? '',
        );
      case 'arithmetic_mult_cell_title':
        return l10n.arithmetic_mult_cell_title(
          params['col'] ?? 0,
          params['row'] ?? 0,
        );
      case 'arithmetic_mult_cell_desc':
        return l10n.arithmetic_mult_cell_desc(
          params['col'] ?? 0,
          params['formula']?.toString() ?? '',
          params['row'] ?? 0,
        );

      // Linear systems
      case 'system_inconsistent_title':
        return l10n.system_inconsistent_title(params['row'] ?? 0);
      case 'system_inconsistent_desc':
        return l10n.system_inconsistent_desc(
          params['row'] ?? 0,
          params['val']?.toString() ?? '',
        );
      case 'system_unique_title':
        return l10n.system_unique_title;
      case 'system_unique_desc':
        return l10n.system_unique_desc(params['solution']?.toString() ?? '');
      case 'system_infinite_title':
        return l10n.system_infinite_title(params['count'] ?? 0);
      case 'system_infinite_desc':
        return l10n.system_infinite_desc(
          params['freeVars']?.toString() ?? '',
          params['params']?.toString() ?? '',
        );

      // Rank-nullity
      case 'rank_nullity_title':
        return l10n.rank_nullity_title(
          params['nullity'] ?? 0,
          params['rank'] ?? 0,
        );
      case 'rank_nullity_desc':
        return l10n.rank_nullity_desc(
          params['cols'] ?? 0,
          params['nullity'] ?? 0,
          params['rank'] ?? 0,
        );

      case 'eigen_vector_approx_title':
        return l10n.eigen_vector_approx_title(
          params['index'].toString(),
          params['lambda'].toString(),
        );
      case 'eigen_vector_approx_desc':
        return l10n.eigen_vector_approx_desc(
          params['lambda'].toString(),
          params['vector'].toString(),
        );
      // Eigen
      case 'eigen_char_poly_title':
        return l10n.eigen_char_poly_title;
      case 'eigen_trace_det_desc':
        return l10n.eigen_trace_det_desc(
          params['det']?.toString() ?? '',
          params['trace']?.toString() ?? '',
        );
      case 'eigen_complex_title':
        return l10n.eigen_complex_title;
      case 'eigen_complex_desc':
        return l10n.eigen_complex_desc(
          params['poly']?.toString() ?? '',
          params['roots']?.toString() ?? '',
        );
      case 'eigen_roots_title':
        return l10n.eigen_roots_title;
      case 'eigen_roots_approx_desc':
        return l10n.eigen_roots_approx_desc(
          params['poly']?.toString() ?? '',
          params['roots']?.toString() ?? '',
        );
      case 'eigen_roots_desc':
        return l10n.eigen_roots_desc(
          params['poly']?.toString() ?? '',
          params['roots']?.toString() ?? '',
        );
      case 'eigen_vector_title':
        return l10n.eigen_vector_title(
          params['index'] ?? 0,
          params['lambda']?.toString() ?? '',
        );
      case 'eigen_vector_desc':
        return l10n.eigen_vector_desc(
          params['lambda']?.toString() ?? '',
          params['vector']?.toString() ?? '',
        );
      case 'eigen_3x3_poly_desc':
        return l10n.eigen_3x3_poly_desc(
          params['det']?.toString() ?? '',
          params['poly']?.toString() ?? '',
          params['trace']?.toString() ?? '',
        );
      case 'eigen_cubic_complex_desc':
        return l10n.eigen_cubic_complex_desc(
          params['complex']?.toString() ?? '',
          params['poly']?.toString() ?? '',
          params['roots']?.toString() ?? '',
        );
      case 'eigen_irrational_desc':
        return l10n.eigen_irrational_desc(params['poly']?.toString() ?? '');

      // LU Decomposition
      case 'lu_init_title':
        return l10n.lu_init_title;
      case 'lu_init_desc':
        return l10n.lu_init_desc;
      case 'lu_swap_desc':
        return l10n.lu_swap_desc(params['rowA'] ?? 0, params['rowB'] ?? 0);
      case 'lu_elim_title':
        return l10n.lu_elim_title(params['source'] ?? 0, params['target'] ?? 0);
      case 'lu_elim_desc':
        return l10n.lu_elim_desc(
          params['multiplier']?.toString() ?? '',
          params['source'] ?? 0,
          params['target'] ?? 0,
        );
      case 'lu_final_title':
        return l10n.lu_final_title;
      case 'lu_final_desc':
        return l10n.lu_final_desc;

      default:
        return key;
    }
  } catch (_) {
    return key;
  }
}

/// Localized message for a solver's `errorMessageKey`.
String localizedSolverError(AppLocalizations l10n, String? key) =>
    switch (key) {
      'error_matrix_is_singular' => l10n.error_matrix_is_singular,
      'error_inverse_not_square' => l10n.error_inverse_not_square,
      'error_dimension_mismatch_add' => l10n.error_dimension_mismatch_add,
      'error_dimension_mismatch_multiply' =>
        l10n.error_dimension_mismatch_multiply,
      _ => l10n.solveFallbackError,
    };
