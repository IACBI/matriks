import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/features/matrix_input/matrix_input_cubit.dart';
import 'package:matriks/features/topics/models/topic_item.dart';

void main() {
  TopicItem topic(TopicType type) =>
      TopicItem.allTopics.firstWhere((t) => t.type == type);

  test('Shrinking B preserves valid focus and subsequent input', () {
    final cubit = MatrixInputCubit(topic(TopicType.multiply))
      // Start from empty 3x3 factors; the topic opens on a 2x2 example.
      ..setDimensionsA(3, 3)
      ..setDimensionsB(3, 3)
      ..selectMatrix(1)
      ..presetClear()
      ..selectMatrix(0);
    addTearDown(cubit.close);
    cubit.selectMatrix(1);
    cubit.setFocus(2, 2);
    cubit.setDimensionsB(3, 1);
    cubit.onKeyPressed('7');
    expect(cubit.state.focusedCol, 0);
    expect(cubit.state.dataB[2][0], '7');
  });

  test('Resizing A clamps focus against active B dimensions', () {
    final cubit = MatrixInputCubit(topic(TopicType.multiply))
      // Start from empty 3x3 factors; the topic opens on a 2x2 example.
      ..setDimensionsA(3, 3)
      ..setDimensionsB(3, 3)
      ..selectMatrix(1)
      ..presetClear()
      ..selectMatrix(0);
    addTearDown(cubit.close);
    cubit.setDimensionsB(3, 1);
    cubit.selectMatrix(1);
    cubit.setFocus(2, 0);
    cubit.setDimensionsA(1, 2);
    cubit.onKeyPressed('8');
    expect(cubit.state.focusedRow, 1);
    expect(cubit.state.dataB[1][0], '8');
  });

  test('Malformed fractions are never silently converted to zero', () {
    final cubit = MatrixInputCubit(topic(TopicType.rref));
    addTearDown(cubit.close);
    cubit.onKeyPressed('/');
    cubit.onKeyPressed('0');
    expect(cubit.state.toMatrixA, throwsFormatException);
  });

  test('Input rejects nonnumeric strings and bounds cell length', () {
    final cubit = MatrixInputCubit(topic(TopicType.rref));
    addTearDown(cubit.close);
    cubit.onKeyPressed('invalid');
    expect(cubit.state.dataA[0][0], '1');
    for (var i = 0; i < 100; i++) {
      cubit.onKeyPressed('9');
    }
    expect(cubit.state.dataA[0][0].length, 32);
  });

  test('Eigen editor allows only supported sizes', () {
    final cubit = MatrixInputCubit(topic(TopicType.eigen));
    addTearDown(cubit.close);
    cubit.setDimensionsA(5, 5);
    expect(cubit.state.rowsA, 3);
    cubit.setDimensionsA(1, 1);
    expect(cubit.state.rowsA, 2);
  });
}
