# Changelog

## Unreleased — current workspace

- Exact matrix calculations and worked-step transformations used by Matriks.
- Existing regression coverage includes linear systems, LU step reconstruction and eigenvector dependent coordinates.
- Numerical scope and unresolved eigen certainty/completeness limitations are documented in README.md and the root roadmap.
- `Rational` arithmetic reduces through the operands' gcds (Knuth, TAOCP 4.5.1) instead of one gcd of the cross product; results are unchanged and solves on large fractions run 2–5× faster.
- `Rational.tryParse` reads decimal digits only; `0x` hexadecimal is rejected.
- Removed unused `Matrix.fromDoubles` (it threw for doubles printed in exponent form, such as `1e-7`), `Rational.toDisplayString`, and the partial `toJson` on `CellHighlight` and `SubCalculation`.

## 1.0.0

Initial package version in pubspec.yaml. No publication date or public registry release has been verified.
