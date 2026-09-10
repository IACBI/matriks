import 'package:matrix_engine/matrix_engine.dart';

void main() {
  final m = Matrix.fromInts([
    [1, 2],
    [3, 4],
  ]);

  final detSolution = DeterminantSolver.solve(m);
  print('Determinant of m: ${detSolution.result}');
  print('Total steps: ${detSolution.totalSteps}');
}
