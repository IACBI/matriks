// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Matriks · Линейная алгебра';

  @override
  String get topics => 'Темы';

  @override
  String get selectTopic => 'Изучайте линейную алгебру';

  @override
  String get topicSubtitle => 'Разберитесь в каждой операции шаг за шагом.';

  @override
  String get categoryAll => 'Все темы';

  @override
  String get categoryElimination => 'Исключение и системы';

  @override
  String get categoryAlgebra => 'Алгебра матриц';

  @override
  String get categoryAdvanced => 'Разложения и спектр';

  @override
  String get categoryVisual => 'Визуализация и практика';

  @override
  String get topicGauss => 'Метод Гаусса (REF)';

  @override
  String get topicGaussDesc => 'Пошаговое приведение к ступенчатому виду.';

  @override
  String get topicRref => 'Метод Гаусса — Жордана (RREF)';

  @override
  String get topicRrefDesc =>
      'Получите приведённый ступенчатый вид с единичными ведущими элементами.';

  @override
  String get topicLinearSystems => 'Линейные системы (Ax = b)';

  @override
  String get topicLinearSystemsDesc =>
      'Определите, имеет ли система одно, бесконечно много решений или ни одного.';

  @override
  String get topicDeterminant => 'Определитель';

  @override
  String get topicDeterminantDesc =>
      'Перекрёстные произведения 2×2, правило Саррюса 3×3 и приведение к треугольному виду.';

  @override
  String get topicInverse => 'Обратная матрица (A⁻¹)';

  @override
  String get topicInverseDesc =>
      'Присоединённая матрица 2×2 и метод Гаусса — Жордана для [A ∣ I].';

  @override
  String get topicRankNullity => 'Ранг и дефект';

  @override
  String get topicRankNullityDesc =>
      'Найдите ранг и размерность ядра; проверьте их сумму.';

  @override
  String get topicEigen => 'Собственные значения и векторы';

  @override
  String get topicEigenDesc =>
      'Собственные значения и векторы матриц 2×2 и 3×3; рациональные корни находятся точно.';

  @override
  String get topicTransform2d => 'Геометрические преобразования 2D';

  @override
  String get topicTransform2dDesc =>
      'Исследуйте единичный квадрат, базисные векторы и ориентированную площадь.';

  @override
  String get topicAdd => 'Сложение матриц';

  @override
  String get topicAddDesc => 'Сложение соответствующих элементов с анимацией.';

  @override
  String get topicMultiply => 'Умножение матриц';

  @override
  String get topicMultiplyDesc =>
      'Вычисляйте каждый элемент как скалярное произведение строки и столбца.';

  @override
  String get matrixA => 'Матрица A';

  @override
  String get matrixB => 'Матрица B';

  @override
  String get rows => 'Строки';

  @override
  String get cols => 'Столбцы';

  @override
  String get size => 'Размер';

  @override
  String get presetRandom => 'Случайная';

  @override
  String get presetIdentity => 'Единичная';

  @override
  String get presetClear => 'Очистить';

  @override
  String get calculate => 'Решить';

  @override
  String get fractionToggle => 'Дробь / Десятичная';

  @override
  String get decreaseDimension => 'Уменьшить размер';

  @override
  String get increaseDimension => 'Увеличить размер';

  @override
  String stepOf(Object current, Object total) {
    return 'Шаг $current из $total';
  }

  @override
  String get decreasePlaybackSpeed => 'Уменьшить скорость воспроизведения';

  @override
  String get increasePlaybackSpeed => 'Увеличить скорость воспроизведения';

  @override
  String playbackSpeed(Object speed) {
    return 'Скорость: $speed×';
  }

  @override
  String get play => 'Воспроизвести';

  @override
  String get pause => 'Пауза';

  @override
  String get nextStep => 'Далее';

  @override
  String get prevStep => 'Назад';

  @override
  String get jumpToStep => 'Перейти к шагу';

  @override
  String get explanation => 'Пояснение';

  @override
  String get close => 'Закрыть';

  @override
  String get toggleTheme => 'Сменить тему';

  @override
  String get changeLanguage => 'Язык';

  @override
  String get solveFallbackError => 'Не удалось выполнить вычисление.';

  @override
  String get legendPivot => 'Ведущий элемент';

  @override
  String get legendSource => 'Источник';

  @override
  String get legendTarget => 'Цель';

  @override
  String get legendZeroResult => 'Обнулено';

  @override
  String cellCalculationTitle(Object col, Object row) {
    return 'Расчёт элемента ($row, $col)';
  }

  @override
  String get arithmeticDetail => 'Арифметическая операция:';

  @override
  String get resultLabel => 'Результат:';

  @override
  String get transformScreenTitle => 'Линейное преобразование 2D';

  @override
  String get presetShear => 'Сдвиг';

  @override
  String get presetRotation => 'Поворот на 45°';

  @override
  String get presetScale => 'Масштабирование';

  @override
  String get presetReflection => 'Отражение';

  @override
  String get presetProjection => 'Проекция (det=0)';

  @override
  String get presetReset => 'Сброс (I)';

  @override
  String step_row_swap_title(Object rowA, Object rowB) {
    return 'Поменять строки $rowA и $rowB';
  }

  @override
  String step_row_swap_desc(
    Object col,
    Object pivot,
    Object rowA,
    Object rowB,
  ) {
    return 'Меняем строки $rowA и $rowB, чтобы поставить ненулевой ведущий элемент ($pivot) в столбец $col.';
  }

  @override
  String step_row_scale_title(Object row) {
    return 'Нормировать строку $row';
  }

  @override
  String step_row_scale_desc(Object factor, Object row) {
    return 'Умножаем строку $row на $factor, чтобы ведущий элемент стал равен 1.';
  }

  @override
  String step_row_elimination_title(Object target) {
    return 'Обнулить элемент строки $target';
  }

  @override
  String step_row_elimination_desc(
    Object col,
    Object multiplier,
    Object source,
    Object target,
  ) {
    return 'Обнуляем столбец $col в строке $target: R_$target ← R_$target − ($multiplier) · R_$source.';
  }

  @override
  String get det_1x1_title => 'Определитель матрицы 1×1';

  @override
  String det_1x1_desc(Object val) {
    return 'Определитель равен единственному элементу: $val.';
  }

  @override
  String get det_2x2_main_diagonal_title => 'Произведение главной диагонали';

  @override
  String det_2x2_main_diagonal_desc(Object a, Object d, Object product) {
    return 'Перемножаем главную диагональ: $a · $d = $product.';
  }

  @override
  String get det_2x2_anti_diagonal_title => 'Произведение побочной диагонали';

  @override
  String det_2x2_anti_diagonal_desc(Object b, Object c, Object product) {
    return 'Перемножаем побочную диагональ: $b · $c = $product.';
  }

  @override
  String get det_2x2_final_title => 'Результат определителя';

  @override
  String det_2x2_final_desc(Object anti, Object det, Object main) {
    return 'Вычитаем произведения: ($main) − ($anti) = $det.';
  }

  @override
  String get det_sarrus_pos_title => 'Саррюс: положительные диагонали';

  @override
  String det_sarrus_pos_desc(Object p1, Object p2, Object p3, Object total) {
    return 'Сумма нисходящих произведений: $p1 + $p2 + $p3 = $total.';
  }

  @override
  String get det_sarrus_neg_title => 'Саррюс: отрицательные диагонали';

  @override
  String det_sarrus_neg_desc(Object n1, Object n2, Object n3, Object total) {
    return 'Сумма восходящих произведений: $n1 + $n2 + $n3 = $total.';
  }

  @override
  String get det_sarrus_final_title => 'Результат определителя';

  @override
  String det_sarrus_final_desc(Object det, Object neg, Object pos) {
    return 'Определитель = положительные − отрицательные: ($pos) − ($neg) = $det.';
  }

  @override
  String get det_singular_column_title => 'Нулевой столбец';

  @override
  String det_singular_column_desc(Object col) {
    return 'Столбец $col нулевой. Определитель равен 0.';
  }

  @override
  String get det_row_swap_title => 'Перестановка строк: смена знака';

  @override
  String det_row_swap_desc(Object rowA, Object rowB) {
    return 'Перестановка строк $rowA и $rowB меняет знак определителя.';
  }

  @override
  String get det_diagonal_product_title =>
      'Диагональное произведение треугольной матрицы';

  @override
  String det_diagonal_product_desc(Object det, Object diagonals, Object sign) {
    return 'Матрица верхнетреугольная. Определитель = $sign$diagonals = $det.';
  }

  @override
  String get inverse_singular_title => 'Вырожденная матрица';

  @override
  String get inverse_singular_desc =>
      'Определитель равен 0; обратной матрицы не существует.';

  @override
  String get inverse_2x2_det_title => 'Вычислить определитель';

  @override
  String inverse_2x2_det_desc(Object det, Object formula) {
    return 'Определитель = $formula = $det.';
  }

  @override
  String get inverse_2x2_adjoint_title => 'Построить присоединённую матрицу';

  @override
  String get inverse_2x2_adjoint_desc =>
      'Поменяйте местами элементы главной диагонали и смените знак остальных.';

  @override
  String get inverse_2x2_scale_title =>
      'Умножить присоединённую матрицу на 1/det';

  @override
  String inverse_2x2_scale_desc(Object factor) {
    return 'Умножаем каждый элемент присоединённой матрицы на 1/det = $factor.';
  }

  @override
  String get inverse_block_init_title => 'Построить [A ∣ I]';

  @override
  String inverse_block_init_desc(Object n) {
    return 'Дополняем матрицу A размера $n×$n единичной матрицей I.';
  }

  @override
  String get inverse_block_extract_title => 'Выделить обратную матрицу A⁻¹';

  @override
  String get inverse_block_extract_desc =>
      'Левый блок стал I; правый блок — обратная матрица A⁻¹.';

  @override
  String arithmetic_add_cell_title(Object col, Object row) {
    return 'Сложить элемент ($row, $col)';
  }

  @override
  String arithmetic_add_cell_desc(Object formula) {
    return 'Складываем соответствующие элементы: $formula.';
  }

  @override
  String arithmetic_mult_cell_title(Object col, Object row) {
    return 'Вычислить элемент ($row, $col)';
  }

  @override
  String arithmetic_mult_cell_desc(Object col, Object formula, Object row) {
    return 'Произведение строки $row матрицы A и столбца $col матрицы B: $formula.';
  }

  @override
  String get error_matrix_is_singular =>
      'Матрица вырождена (определитель = 0), обратной матрицы нет.';

  @override
  String get error_inverse_not_square => 'Операция требует квадратной матрицы.';

  @override
  String get error_dimension_mismatch_add =>
      'Матрицы должны иметь одинаковые размеры.';

  @override
  String get error_dimension_mismatch_multiply =>
      'Число столбцов A должно совпадать с числом строк B.';

  @override
  String system_inconsistent_title(Object row) {
    return 'Противоречие в строке $row';
  }

  @override
  String system_inconsistent_desc(Object row, Object val) {
    return 'Строка $row даёт 0 = $val: [0 … 0 ∣ $val]. Система не имеет решений.';
  }

  @override
  String get system_unique_title => 'Единственное решение';

  @override
  String system_unique_desc(Object solution) {
    return 'Каждой неизвестной соответствует ведущий столбец. Решение: $solution.';
  }

  @override
  String system_infinite_title(Object count) {
    return 'Бесконечно много решений ($count свободных переменных)';
  }

  @override
  String system_infinite_desc(Object freeVars, Object params) {
    return 'Переменные $freeVars — свободные параметры ($params). Решение записано в параметрическом векторном виде.';
  }

  @override
  String rank_nullity_title(Object nullity, Object rank) {
    return 'Ранг = $rank, дефект = $nullity';
  }

  @override
  String rank_nullity_desc(Object cols, Object nullity, Object rank) {
    return 'Ведущих столбцов: $rank, свободных: $nullity. Ранг + дефект = $cols.';
  }

  @override
  String get eigen_char_poly_title => 'Характеристический многочлен';

  @override
  String eigen_trace_det_desc(Object det, Object trace) {
    return 'Для 2×2: λ² − tr(A)λ + det(A) = 0, след $trace, определитель $det.';
  }

  @override
  String get eigen_complex_title => 'Комплексные собственные значения';

  @override
  String eigen_complex_desc(Object poly, Object roots) {
    return 'Дискриминант $poly отрицателен. Приближённые сопряжённые корни: $roots.';
  }

  @override
  String get eigen_roots_title => 'Корни характеристического уравнения';

  @override
  String eigen_roots_approx_desc(Object poly, Object roots) {
    return 'При решении $poly приближённые действительные собственные значения, округлённые до трёх знаков: $roots.';
  }

  @override
  String eigen_roots_desc(Object poly, Object roots) {
    return 'Из $poly получаем собственные значения: $roots.';
  }

  @override
  String eigen_vector_title(Object index, Object lambda) {
    return 'Собственный вектор для λ_$index = $lambda';
  }

  @override
  String eigen_vector_desc(Object lambda, Object vector) {
    return 'Для (A − λI)v = 0 при λ = $lambda один из собственных векторов: $vector.';
  }

  @override
  String eigen_3x3_poly_desc(Object det, Object poly, Object trace) {
    return 'Для 3×3: $poly, след $trace, определитель $det.';
  }

  @override
  String eigen_irrational_desc(Object poly) {
    return 'Корни $poly не удалось надёжно выделить при коэффициентах такого размера. Вещественные или комплексные корни существуют, но этот решатель их не вычисляет.';
  }

  @override
  String get topicLu => 'Разложение LU (A = LU)';

  @override
  String get topicLuDesc =>
      'Разложите матрицу на нижний треугольный множитель L и верхний U.';

  @override
  String get topicPractice => 'Самопроверка и практика';

  @override
  String get topicPracticeDesc => 'Задачи с мгновенными пояснениями и баллами.';

  @override
  String get lu_init_title => 'Начать разложение LU';

  @override
  String get lu_init_desc => 'Начинаем с L = I и U = A.';

  @override
  String lu_swap_desc(Object rowA, Object rowB) {
    return 'Ведущий элемент равен 0. Меняем строки $rowA и $rowB; нужна матрица перестановки P.';
  }

  @override
  String lu_elim_title(Object source, Object target) {
    return 'Обнулить строку $target с помощью строки $source';
  }

  @override
  String lu_elim_desc(Object multiplier, Object source, Object target) {
    return 'Сохраняем m_$target$source = $multiplier в L. В U: R_$target ← R_$target − ($multiplier)R_$source.';
  }

  @override
  String get lu_final_title => 'Разложение LU завершено';

  @override
  String get lu_final_desc =>
      'Получены нижнетреугольная L и верхнетреугольная U.';

  @override
  String get practiceTitle => 'Самопроверка';

  @override
  String practiceScore(Object score) {
    return '$score баллов';
  }

  @override
  String practiceQuestionProgress(Object current, Object total) {
    return 'Вопрос $current / $total';
  }

  @override
  String get practiceHint => 'Подсказка';

  @override
  String get practiceHideHint => 'Скрыть подсказку';

  @override
  String get practiceCorrect => 'Верный ответ!';

  @override
  String get practiceIncorrect => 'Разберём этот ответ';

  @override
  String get practiceNext => 'Следующий вопрос';

  @override
  String get practiceResults => 'Посмотреть результаты';

  @override
  String get practiceCompleted => 'Практика завершена!';

  @override
  String practiceTotalScore(Object score, Object total) {
    return 'Всего баллов: $score / $total';
  }

  @override
  String get practicePerfectScore =>
      'Отлично! Вы верно ответили на все вопросы.';

  @override
  String get practiceGoodEffort =>
      'Хорошая работа! Попробуйте снова, чтобы закрепить знания.';

  @override
  String get practiceReturnTopics => 'Вернуться к темам';

  @override
  String get practiceRestart => 'Начать заново';

  @override
  String get searchTopics => 'Поиск тем…';

  @override
  String get noTopicsFound => 'Темы не найдены';

  @override
  String get noTopicsFoundDesc => 'Попробуйте другое слово или категорию.';

  @override
  String get clearSearch => 'Очистить поиск';

  @override
  String get systemDefault => 'Системная настройка';

  @override
  String get replayAnimation => 'Повторить анимацию';

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
      'Выберите элемент и введите целое число, десятичное число или дробь.';

  @override
  String inputInvalid(String matrix, int row, int column) {
    return 'Проверьте матрицу $matrix, строку $row, столбец $column. Введите полное число; знаменатель не может быть нулём.';
  }

  @override
  String get calculating => 'Вычисление…';

  @override
  String inputCell(String matrix, int row, int column) {
    return 'Матрица $matrix, строка $row, столбец $column';
  }

  @override
  String get stepAlreadyReducedTitle => 'Уже в нужном виде';

  @override
  String get stepAlreadyReducedDesc =>
      'Строковые операции не нужны. Показанная матрица — результат.';

  @override
  String get keyPreviousCell => 'Предыдущий элемент';

  @override
  String get keyNextCell => 'Следующий элемент';

  @override
  String get keySign => 'Сменить знак';

  @override
  String get keyFraction => 'Дробная черта';

  @override
  String get keyBackspace => 'Удалить последнюю цифру';

  @override
  String get keyClear => 'Очистить элемент';

  @override
  String get keyDecimal => 'Десятичная точка';

  @override
  String get instructionProgress => 'Эта операция';

  @override
  String get customTransform => 'Своя';

  @override
  String get transformCoefficients => 'Матрица преобразования';

  @override
  String get basisVectors => 'Преобразованные базисные векторы';

  @override
  String get targetDeterminant => 'Целевой определитель';

  @override
  String matrixCellLabel(int row, int column, String value) {
    return 'Строка $row, столбец $column, значение $value';
  }

  @override
  String get focusSource => 'Поймите цель';

  @override
  String get focusOperation => 'Проследите вычисление';

  @override
  String get focusResult => 'Проверьте изменения';

  @override
  String get inspectOperation => 'Изучить эту операцию';

  @override
  String get stepExplanation => 'Почему это работает';

  @override
  String get cellCalculations => 'Вычисления элементов';

  @override
  String get chooseStep => 'Выбрать шаг';

  @override
  String get learningPath => 'Впервые изучаете матрицы?';

  @override
  String get pathEliminate => '1 · Создать нули';

  @override
  String get pathReduce => '2 · Найти ведущие элементы';

  @override
  String get pathSolve => '3 · Решить систему';

  @override
  String guideEliminateSource(String source, String target, String column) {
    return 'Используйте строку $source, чтобы изменить строку $target. Следите за столбцом $column.';
  }

  @override
  String guideEliminateApply(String factor, String source, String target) {
    return 'Прибавьте строку $source, умноженную на $factor, к каждому элементу строки $target.';
  }

  @override
  String guideEliminateResult(String column, String value) {
    return 'В столбце $column теперь $value. Множество решений сохраняется.';
  }

  @override
  String guideScaleSource(String row, String factor) {
    return 'Умножьте всю строку $row на ненулевой множитель $factor.';
  }

  @override
  String get guideScaleApply =>
      'Умножайте всю строку, а не только ведущий элемент.';

  @override
  String get guideScaleResult => 'Сравните каждый элемент с исходным.';

  @override
  String guideSwapSource(String first, String second) {
    return 'Строки $first и $second поменяются местами.';
  }

  @override
  String get guideSwapApply =>
      'Перемещайте строки целиком; значения не меняются.';

  @override
  String get guideSwapResult =>
      'Строки на новых местах. Множество решений не изменилось.';

  @override
  String guideDotSource(String row, String column) {
    return 'Сопоставьте строку $row и столбец $column. Каждая пара вносит вклад в результат.';
  }

  @override
  String get guideDotApply => 'Перемножьте пары и сложите произведения.';

  @override
  String guideDotResult(String row, String column) {
    return 'Сумма занимает строку $row, столбец $column.';
  }

  @override
  String get guideDetSource => 'Следите за множителями и знаками произведений.';

  @override
  String get guideDetApply =>
      'Следите за одним произведением за раз и проверяйте множители.';

  @override
  String get guideDetResult => 'Их сумма — вклад этой группы в определитель.';

  @override
  String get coefficientError => 'Введите число от −1000 до 1000.';

  @override
  String get transformTransitionHint =>
      'Измените коэффициент и нажмите Enter или выйдите из поля. Диапазон: от −1000 до 1000. Ползунок показывает переход между состояниями.';

  @override
  String multiplicationSourceRow(String row) {
    return 'A · строка $row';
  }

  @override
  String multiplicationSourceColumn(String column) {
    return 'B · столбец $column';
  }

  @override
  String get multiplicationOutput => 'C = A × B · результат';

  @override
  String guideEliminateReason(String entry, String pivot, String ratio) {
    return 'Целевой элемент $entry ÷ ведущий $pivot = $ratio. Вычтите этот кратный исходной строки, чтобы получить ноль.';
  }

  @override
  String guideEliminateSubtract(String factor, String source, String target) {
    return 'Вычтите строку $source, умноженную на $factor, из всей строки $target.';
  }

  @override
  String get transformProgress => 'Ход перехода';

  @override
  String increaseCoefficient(String name) {
    return 'Увеличить коэффициент $name';
  }

  @override
  String decreaseCoefficient(String name) {
    return 'Уменьшить коэффициент $name';
  }

  @override
  String get guideDotReason =>
      'Один элемент C использует целую строку A и столбец B. Перемножьте соответствующие элементы и сложите.';

  @override
  String get guideDetReason =>
      'Определитель задаёт изменение ориентированной площади или объёма. Сложите произведения + и вычтите −; ноль означает потерю размерности.';

  @override
  String get settings => 'Настройки';

  @override
  String get practiceNav => 'Практика';

  @override
  String get transformNav => 'Преобразования';

  @override
  String get appearance => 'Оформление';

  @override
  String get learning => 'Обучение и воспроизведение';

  @override
  String get themeLabel => 'Тема';

  @override
  String get lightTheme => 'Светлая';

  @override
  String get darkTheme => 'Тёмная';

  @override
  String get solutionModeLabel => 'Вид решения';

  @override
  String get guidedMode => 'Анимация с пояснениями';

  @override
  String get stepsMode => 'Шаги без анимации';

  @override
  String get resultMode => 'Сразу результат';

  @override
  String get showResult => 'Показать результат';

  @override
  String get viewSteps => 'Изучить шаги';

  @override
  String get motionLabel => 'Уменьшить движение';

  @override
  String get motionHelp =>
      'Системная настройка уменьшения движения всегда учитывается.';

  @override
  String get shortExplanation => 'Кратко';

  @override
  String get detailedExplanation => 'Подробно';

  @override
  String get hiddenExplanation => 'Скрыто';

  @override
  String get predictionLabel => 'Вопросы на прогноз';

  @override
  String get predictionHelp => 'Необязательные вопросы в учебных примерах.';

  @override
  String get predictTitle => 'Прежде чем начать…';

  @override
  String get predictPrompt => 'Какой множитель обнулит целевой элемент?';

  @override
  String get predictCorrect =>
      'Верно! Теперь проследите эту операцию по всей строке.';

  @override
  String get predictIncorrect =>
      'Разделите целевой элемент на ведущий, чтобы найти множитель.';

  @override
  String get skip => 'Пропустить';

  @override
  String get continueLabel => 'Продолжить';

  @override
  String get numberView => 'Формат чисел';

  @override
  String get fractionView => 'Точные дроби';

  @override
  String get decimalView => 'Десятичные';

  @override
  String get densityLabel => 'Плотность интерфейса';

  @override
  String get comfortable => 'Свободная';

  @override
  String get compact => 'Компактная';

  @override
  String get accentLabel => 'Цвет акцента';

  @override
  String get blue => 'Синий';

  @override
  String get teal => 'Бирюзовый';

  @override
  String get purple => 'Фиолетовый';

  @override
  String get shortcutsLabel => 'Сочетания клавиш';

  @override
  String get shortcutHelp =>
      'Выберите действие и нажмите букву, пробел или горизонтальную стрелку. Home/End и Page Up/Down остаются доступны.';

  @override
  String get pressKey => 'Нажмите клавишу';

  @override
  String get shortcutConflict =>
      'Эта клавиша зарезервирована или уже назначена.';

  @override
  String get resetSettings => 'Сбросить настройки';

  @override
  String get settingsStorageError =>
      'Не удалось прочитать или сохранить настройки. Изменения доступны в этом сеансе.';

  @override
  String get localPreferences =>
      'Настройки хранятся на этом устройстве. История матриц не сохраняется.';

  @override
  String get resultExact => 'Точно';

  @override
  String get resultApproximate => 'Приближённо';

  @override
  String get resultComplete => 'Полностью';

  @override
  String get resultPartial => 'Частично';

  @override
  String get resultUnsupported => 'Не поддерживается';

  @override
  String get eigenPrecision =>
      'Собственные значения округлены до трёх знаков; векторы задают приближённые направления, а не точные решения ядра.';

  @override
  String get eigenScope =>
      'Рациональные корни 3×3 находятся точно; остальные вещественные корни округляются до трёх знаков. При очень больших коэффициентах корни могут остаться ненайденными.';

  @override
  String get eigenBasisScope =>
      'Для каждого собственного значения показан один вектор; полный базис собственного подпространства не вычисляется.';

  @override
  String get complexScope =>
      'Комплексные собственные векторы не поддерживаются. Мнимая часть округлена до двух знаков.';

  @override
  String get guideAddSource => 'Сопоставьте одинаковые позиции в A и B.';

  @override
  String get guideAddApply => 'Сложите эту пару элементов.';

  @override
  String get guideAddResult => 'Их сумма занимает ту же позицию в C.';

  @override
  String get quizQ1QuestionTitle => 'Гаусс: ведущий элемент и исключение';

  @override
  String get quizQ1Prompt =>
      'Ведущий элемент находится в (1,1). Какая операция обнулит первый элемент строки 2?';

  @override
  String get quizQ1Explanation =>
      'Целевой элемент 2, ведущий 1: вычитаем удвоенную первую строку и получаем 2 − 2×1 = 0.';

  @override
  String get quizQ1Hint => 'Вычтите кратную ведущей строки.';

  @override
  String get quizQ1Feedback0 => 'Вычитание удвоенной строки 1 даёт 2 − 2 = 0.';

  @override
  String get quizQ1Feedback1 => 'Прибавление даёт 2 + 2 = 4, а не ноль.';

  @override
  String get quizQ1Feedback2 =>
      'Перестановка перемещает элементы, но не обнуляет целевой.';

  @override
  String get quizQ1Feedback3 => 'Деление строки 2 пополам даёт 1, а не ноль.';

  @override
  String get quizQ2QuestionTitle => 'Перестановка строк';

  @override
  String get quizQ2Prompt =>
      'В позиции (1,1) стоит 0. Какая перестановка поставит туда ненулевой элемент?';

  @override
  String get quizQ2Explanation =>
      'Перестановка строк 1 и 2 ставит 3 на место ведущего элемента.';

  @override
  String get quizQ2Hint => 'Найдите строку с ненулевым первым элементом.';

  @override
  String get quizQ2Feedback0 =>
      'Прибавление тоже создаёт ненулевой элемент, но требуется перестановка.';

  @override
  String get quizQ2Feedback1 => 'Перестановка переносит 3 в (1,1).';

  @override
  String get quizQ2Feedback2 => 'Изменение строки 2 не меняет ноль в (1,1).';

  @override
  String get quizQ2Feedback3 => 'Умножение строки 3 не меняет ноль в (1,1).';

  @override
  String get quizQ3QuestionTitle => 'Нормирование ведущего элемента';

  @override
  String get quizQ3Prompt =>
      'Ведущий элемент строки 2 равен −3. Какая операция превратит его в 1?';

  @override
  String get quizQ3Explanation =>
      'Умножьте всю строку 2 на −1/3: (−3)×(−1/3) = 1.';

  @override
  String get quizQ3Hint => 'Используйте обратное к ведущему элементу число.';

  @override
  String get quizQ3Feedback0 =>
      'Прибавление строки 1 нарушает начальный ноль и не нормирует ведущий элемент.';

  @override
  String get quizQ3Feedback1 =>
      'Обратное к −3 число — −1/3; их произведение равно 1.';

  @override
  String get quizQ3Feedback2 => '−3×3 = −9. Нужно обратное число.';

  @override
  String get quizQ3Feedback3 => 'Перестановка строк не превращает −3 в 1.';

  @override
  String get quizQ4QuestionTitle => 'Ранг и нулевые строки';

  @override
  String get quizQ4Prompt => 'Каков ранг этой ступенчатой матрицы?';

  @override
  String get quizQ4Explanation =>
      'Есть две ненулевые ведущие строки и одна нулевая: rank(A) = 2.';

  @override
  String get quizQ4Hint => 'Сосчитайте ненулевые строки ступенчатой матрицы.';

  @override
  String get quizQ4Feedback0 =>
      'Нулевая строка не даёт ведущего элемента; размер не определяет ранг.';

  @override
  String get quizQ4Feedback1 => 'В матрице две ведущие строки.';

  @override
  String get quizQ4Feedback2 =>
      'Вторая ненулевая строка тоже содержит ведущий элемент.';

  @override
  String get quizQ4Feedback3 =>
      'Нулевой ранг возможен только при всех нулевых элементах.';

  @override
  String get quizQ5QuestionTitle => 'Определитель треугольной матрицы';

  @override
  String get quizQ5Prompt =>
      'У треугольной матрицы перемножьте главную диагональ. Чему равен det(A)?';

  @override
  String get quizQ5Explanation => 'Произведение главной диагонали: 2×3×4 = 24.';

  @override
  String get quizQ5Hint =>
      'Если под диагональю нули, перемножьте диагональные элементы.';

  @override
  String get quizQ5Feedback0 =>
      'Диагональ нужно перемножить; сумма — это след.';

  @override
  String get quizQ5Feedback1 => '2×3×4 = 24.';

  @override
  String get quizQ5Feedback2 =>
      'Нули под диагональю не обнуляют определитель, а ноль на диагонали — да.';

  @override
  String get quizQ5Feedback3 =>
      'Все диагональные элементы положительны; дополнительного минуса нет.';

  @override
  String eigen_vector_approx_title(Object index, Object lambda) {
    return 'Приближённый вектор для λ_$index ≈ $lambda';
  }

  @override
  String eigen_vector_approx_desc(Object lambda, Object vector) {
    return 'При λ ≈ $lambda приближённое направление: $vector; это не точное решение ядра.';
  }

  @override
  String get spaceKey => 'Пробел';

  @override
  String matrixCellPendingLabel(int row, int column) {
    return 'Строка $row, столбец $column, ещё не вычислено';
  }

  @override
  String eigen_cubic_complex_desc(Object complex, Object poly, Object roots) {
    return 'Решение $poly даёт вещественное собственное значение $roots и пару комплексно сопряжённых λ ≈ $complex. Вещественный собственный вектор есть только у вещественного значения.';
  }

  @override
  String get keyNextRow => 'Следующая строка';

  @override
  String get multiplyRowsLocked =>
      'Число строк B равно числу столбцов A, поэтому A × B определено.';

  @override
  String get lessonComplete => 'Урок завершён';

  @override
  String get lessonCompleteHint =>
      'Проверьте результат, посмотрите урок ещё раз или продолжите со своей матрицей.';

  @override
  String get replayLesson => 'Смотреть снова';

  @override
  String get tryOwnMatrix => 'Попробовать свою матрицу';

  @override
  String get editMatrix => 'Изменить матрицу';

  @override
  String presetApplied(String matrix) {
    return 'Матрица $matrix заменена.';
  }

  @override
  String get undo => 'Отменить';

  @override
  String get transformShortcutsHint =>
      'Клавиатура: Пробел — воспроизвести или обратно, S — сдвиг, P — проекция, R — единичная.';

  @override
  String get transformLegendOriginal =>
      'Бледная сетка: плоскость до преобразования.';

  @override
  String get transformLegendEigen =>
      'Пунктир: направления вещественных собственных векторов, остающиеся на своей прямой.';

  @override
  String guideLuReason(
    String entry,
    String pivot,
    String ratio,
    String row,
    String column,
  ) {
    return 'Цель $entry ÷ опорный $pivot = $ratio. Вычитание $ratio опорных строк обнуляет цель, а то же $ratio записывается в L на место ($row, $column), поэтому L · U снова даёт A.';
  }

  @override
  String get guideAdjSource =>
      'В [[a, b], [c, d]] посмотрите на диагональ a, d и два других элемента b, c.';

  @override
  String get guideAdjApply =>
      'a и d меняются местами; b и c остаются на месте, но меняют знак.';

  @override
  String get guideAdjResult =>
      'Это adj(A). Разделив её на det(A), получаем обратную матрицу.';

  @override
  String get guideAdjReason =>
      'Для матрицы 2×2 A · adj(A) = det(A) · I. Поэтому A⁻¹ = adj(A) ÷ det(A), если det(A) ≠ 0.';

  @override
  String guideScaleAllSource(String factor) {
    return 'Каждый элемент adj(A) умножается на одно и то же число 1/det(A) = $factor.';
  }

  @override
  String get guideScaleAllApply => 'Умножайте элементы по одному.';

  @override
  String get guideScaleAllResult => 'Результат — A⁻¹. Проверка: A · A⁻¹ = I.';

  @override
  String get guideDiagSource =>
      'Матрица теперь верхнетреугольная, поэтому её определитель — произведение диагонали.';

  @override
  String get guideDiagApply =>
      'Перемножайте диагональные элементы по одному. Первый множитель несёт −1 за каждую перестановку строк.';

  @override
  String get guideDiagResult =>
      'Исключение строк не меняет определитель, поэтому это произведение — det исходной матрицы.';

  @override
  String get guideDetRecapSource => 'Обе суммы известны из предыдущих шагов.';

  @override
  String get guideDetRecapApply => 'Вычтите сумму «−» из суммы «+».';

  @override
  String get guideDetRecapResult => 'Разность и есть определитель.';
}
