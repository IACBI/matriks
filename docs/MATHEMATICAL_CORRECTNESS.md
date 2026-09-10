# Mathematical correctness review — 2026-09-10

All 12 catalog topics were reviewed through source inspection and automated
checks. These checks establish specific invariants and regressions; they do not
prove correctness for every possible input.

## Corrected findings

1. **Triangular determinant explanation lost the permutation sign.** For
   `[[0,1,0,0],[1,0,0,0],[0,0,2,0],[0,0,0,3]]`, the engine correctly returned
   −6 while the lesson displayed `(6) - (0) = 6`. Triangularization now emits a
   dedicated diagonal-product transformation carrying the exact diagonal entries
   and row-swap sign. The lesson progressively multiplies these factors; it no
   longer treats this operation as a 2×2 cross product. Regression failed before
   the fix and passes afterward.
2. **Large irrational 2×2 eigenvalue calculations could fail or lose precision.**
   With diagonal entries 10000000000000000000000 and off-diagonals 2 and 1,
   conversion to double produced exponent notation that Rational.parse rejected.
   The replacement uses exact rational lower/upper square-root bounds, refining
   until both endpoints round identically to three decimals. It avoids floating
   point cancellation and exponent parsing. The two results retain offsets
   +1.414 and −1.414 from the large diagonal value.
3. **Small distinct irrational roots could collapse into one reported root.**
   Both mathematical roots are retained even when three-decimal rounding makes
   their displayed values equal. Approximate eigenvalue explanations explicitly
   disclose rounding in all five languages. Eigenvectors remain approximate in
   this branch; they are not exact null-space solutions.
4. **LU wording overstated the shape of U.** The English and Turkish descriptions
   now say upper triangular, removing the echelon claim, which need not hold for
   singular matrices. The other locales already used triangular wording.

## Topic coverage

| Topic | Verification |
| --- | --- |
| Gaussian elimination / REF | Replayed row swaps, scaling and elimination against snapshots; reducing REF yields the same RREF. |
| Gauss–Jordan / RREF | Strictly increasing pivots, unit pivot columns, zero rows last and idempotence; exact fractions. |
| Linear systems | Constructed consistent rectangular systems in all 1–5 shapes; unique solutions satisfy Ax=b; reconstructed particular and free-variable directions satisfy Ax=b and Av=0; inconsistent case and existing system tests. |
| Determinant | Independent recursive cofactor reference vs automatic and triangular methods, 125 seeded fraction/zero matrices across sizes 1–5; signed lesson regression. |
| Inverse | Singular detection agrees with independent determinant; both A·inverse and inverse·A equal identity on nonsingular cases. |
| Rank/nullity | Rank checked against independently enumerated nonzero minors; rank + nullity = column count, across 1–5 rectangular shapes. |
| Eigenvalues/vectors | All 625 integer 2×2 matrices with entries −2…2: exact pairs have nonzero v and Av=λv; approximate real roots agree with the independent quadratic formula within 0.0005. Thirty 3×3 similar matrices have known complete distinct spectra and exact zero residuals. Large/small root regressions and existing repeated/complex/out-of-range tests. |
| LU | PA=LU, unit lower triangular L, upper triangular U and row-operation snapshots on the 125 square cases. |
| Addition | Entrywise reference for all 1–5 rectangular shapes. |
| Multiplication | Independent dot-product reference for compatible rectangular shapes, plus existing source-animation tests. |
| 2D transformations | Projection idempotence, rotation length preservation throughout interpolation, reflection/scale/shear determinants and existing visualizer tests. |
| Practice | All five answer keys checked against their matrix operations in every language, plus quiz flow tests. |

The main new tests are `packages/matrix_engine/test/topic_correctness_test.dart`
and `test/topic_correctness_test.dart`. Inputs are deterministic and failures
remain reproducible. No dependency was added.

## Fresh verification

- Engine: **49 tests passed**; `dart analyze` clean.
- App: **131 tests passed**, including themes, locales and responsive layouts.
- Combined source/test/tool analysis: no issues.
- `flutter build web --release`: successful.
- Evidence: `output/math-engine-tests.log`, `output/math-full-tests.log`,
  `output/math-analysis-final.log`, `output/math-web-build.log`.
- Before-fix failures: `output/math-engine-before.log`, `output/math-ui-before.log`.

## Remaining scope limits

3×3 eigen analysis still searches only integer roots −20…20 and explicitly
labels missing/partial spectra. Repeated eigenvalues still provide representative
vectors rather than a complete eigenspace basis. Irrational 2×2 eigenpairs remain
three-decimal approximations; complex eigenvectors are unsupported. The public
cofactor determinant method selection currently falls back to triangularization;
this review uses cofactor expansion only as an independent test oracle and does
not claim that an instructional cofactor solver was added.

No fresh native Windows build or physical-device manual walkthrough was run.
The web release compiled, but this is not a browser-runtime or performance
measurement. Existing release signing limitations are unchanged.
