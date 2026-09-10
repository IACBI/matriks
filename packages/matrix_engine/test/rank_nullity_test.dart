import 'package:matrix_engine/src/algorithms/rank_nullity.dart';
import 'package:matrix_engine/src/model/matrix.dart';
import 'package:test/test.dart';

void main() {
  group('RankNullitySolver (Realistic Linear Algebra Problems)', () {
    test('Problem 1: Invertible 3x3 has full rank 3 and nullity 0', () {
      // Invertible matrix (det = 1)
      // [ 1 2 3 ]
      // [ 0 1 4 ]
      // [ 5 6 0 ]
      final m = Matrix.fromInts([
        [1, 2, 3],
        [0, 1, 4],
        [5, 6, 0],
      ]);

      final sol = RankNullitySolver.solve(m);
      expect(sol.isSuccess, isTrue);

      final result = sol.result as RankNullityResult;
      expect(result.rank, equals(3));
      expect(result.nullity, equals(0));
      expect(result.rank + result.nullity, equals(result.totalCols));
    });

    test('Problem 2: Rank-deficient 3x3 matrix (dependent rows)', () {
      // Row 1 + Row 3 = Row 2
      // [ 1  2 -1 ]
      // [ 2  1  1 ]
      // [ 1 -1  2 ]
      final m = Matrix.fromInts([
        [1, 2, -1],
        [2, 1, 1],
        [1, -1, 2],
      ]);

      final sol = RankNullitySolver.solve(m);
      expect(sol.isSuccess, isTrue);

      final result = sol.result as RankNullityResult;
      expect(result.rank, equals(2));
      expect(result.nullity, equals(1));
      expect(result.pivotColumnIndices.length, equals(2));
      expect(result.freeColumnIndices.length, equals(1));
    });

    test('Problem 3: Zero matrix has rank 0 and nullity = cols', () {
      final m = Matrix.zero(2, 4);
      final sol = RankNullitySolver.solve(m);
      final result = sol.result as RankNullityResult;
      expect(result.rank, equals(0));
      expect(result.nullity, equals(4));
    });
  });
}
