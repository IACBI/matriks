# Changelog

## Unreleased — current workspace

- Exact matrix calculations and worked-step transformations used by Matriks.
- Existing regression coverage includes linear systems, LU step reconstruction and eigenvector dependent coordinates.
- Eigen analysis of 2×2 and 3×3 matrices is exact end to end. Irrational eigenvalues are closed forms with square roots, cube roots (Cardano) or cosines instead of three-decimal roundings; complex eigenvalues are exact and have eigenvectors; rational roots are found for coefficients of any size, so no spectrum is reported as missing; repeated eigenvalues get a full eigenspace basis and defective matrices are identified. Eigen solutions are always `ResultAccuracy.exact` and `ResultCompleteness.complete`.
- New exports: `RationalPolynomial`, `NumberField`, `NumberFieldElement`, `ExactEigenvalue`, `ExactEigenpair`, and `EigenResult.eigenpairs`, `characteristicPolynomial` and `isDiagonalizable`. `EigenResult.realEigenpairs` now holds only rational eigenvalues.
- Eigen step keys: `eigen_roots_surd_desc`, `eigen_roots_factored_desc`, `eigen_roots_cardano_desc`, `eigen_roots_trig_desc`, `eigen_vector_surd_desc`, `eigen_vector_complex_desc`, `eigen_vector_cubic_title`, `eigen_vector_cubic_desc`, `eigen_eigenspace_desc` and `eigen_defective_desc` replace `eigen_roots_approx_desc`, `eigen_vector_approx_title`, `eigen_vector_approx_desc`, `eigen_cubic_complex_desc` and `eigen_irrational_desc`.
- `Rational` arithmetic reduces through the operands' gcds (Knuth, TAOCP 4.5.1) instead of one gcd of the cross product; results are unchanged and solves on large fractions run 2–5× faster.
- `Rational.tryParse` reads decimal digits only; `0x` hexadecimal is rejected.
- `Matrix.fromDoubles` reads doubles printed in exponent form (`1e-7`, `1.5e21`) exactly instead of throwing a `FormatException`, and rejects NaN and infinity with an `ArgumentError`.
- Written calculations bracket a negative operand everywhere (row scaling, the 2×2 inverse, the 2×2 eigen trace and determinant, the diagonal product of a determinant), through one helper, so no formula reads `2 \cdot -4`.
- The contradiction row of an inconsistent system is written `0 \neq c` instead of `0 = c \implies \text{False}`, which carried an English word into every language.

## 1.0.0

Initial package version in pubspec.yaml. No publication date or public registry release has been verified.
