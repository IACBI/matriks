// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Matriks · Álgebra lineal';

  @override
  String get topics => 'Temas';

  @override
  String get selectTopic => 'Explora el álgebra lineal';

  @override
  String get topicSubtitle => 'Comprende cada operación, paso a paso.';

  @override
  String get categoryAll => 'Todos los temas';

  @override
  String get categoryElimination => 'Eliminación y sistemas';

  @override
  String get categoryAlgebra => 'Álgebra matricial';

  @override
  String get categoryAdvanced => 'Descomposición y espectro';

  @override
  String get categoryVisual => 'Visualización y práctica';

  @override
  String get topicGauss => 'Eliminación de Gauss (REF)';

  @override
  String get topicGaussDesc =>
      'Reduce la matriz a forma escalonada, paso a paso.';

  @override
  String get topicRref => 'Eliminación de Gauss-Jordan (RREF)';

  @override
  String get topicRrefDesc =>
      'Obtén la forma escalonada reducida con pivotes iguales a uno.';

  @override
  String get topicLinearSystems => 'Sistemas lineales (Ax = b)';

  @override
  String get topicLinearSystemsDesc =>
      'Identifica una solución única, infinitas soluciones o ninguna.';

  @override
  String get topicDeterminant => 'Determinante';

  @override
  String get topicDeterminantDesc =>
      'Productos cruzados 2×2, regla de Sarrus 3×3 y triangularización.';

  @override
  String get topicInverse => 'Matriz inversa (A⁻¹)';

  @override
  String get topicInverseDesc =>
      'Adjunta 2×2 y método de Gauss-Jordan sobre [A ∣ I].';

  @override
  String get topicRankNullity => 'Rango y nulidad';

  @override
  String get topicRankNullityDesc =>
      'Calcula el rango y la dimensión del núcleo; comprueba su suma.';

  @override
  String get topicEigen => 'Valores y vectores propios';

  @override
  String get topicEigenDesc =>
      'Valores y vectores propios de matrices 2×2 y 3×3, exactos cuando las raíces son racionales.';

  @override
  String get topicTransform2d => 'Transformación geométrica 2D';

  @override
  String get topicTransform2dDesc =>
      'Explora el cuadrado unidad, los vectores base y el área orientada.';

  @override
  String get topicAdd => 'Suma de matrices';

  @override
  String get topicAddDesc =>
      'Suma los elementos correspondientes con animaciones.';

  @override
  String get topicMultiply => 'Multiplicación de matrices';

  @override
  String get topicMultiplyDesc =>
      'Combina filas y columnas para calcular cada elemento.';

  @override
  String get matrixA => 'Matriz A';

  @override
  String get matrixB => 'Matriz B';

  @override
  String get rows => 'Filas';

  @override
  String get cols => 'Columnas';

  @override
  String get size => 'Tamaño';

  @override
  String get presetRandom => 'Aleatoria';

  @override
  String get presetIdentity => 'Identidad';

  @override
  String get presetClear => 'Vaciar';

  @override
  String get calculate => 'Resolver';

  @override
  String get fractionToggle => 'Fracción / Decimal';

  @override
  String get removeRow => 'Quitar una fila';

  @override
  String get addRow => 'Añadir una fila';

  @override
  String get removeColumn => 'Quitar una columna';

  @override
  String get addColumn => 'Añadir una columna';

  @override
  String stepOf(Object current, Object total) {
    return 'Paso $current de $total';
  }

  @override
  String get decreasePlaybackSpeed => 'Reducir la velocidad de reproducción';

  @override
  String get increasePlaybackSpeed => 'Aumentar la velocidad de reproducción';

  @override
  String playbackSpeed(Object speed) {
    return 'Velocidad: $speed';
  }

  @override
  String get play => 'Reproducir';

  @override
  String get pause => 'Pausar';

  @override
  String get nextStep => 'Siguiente';

  @override
  String get prevStep => 'Anterior';

  @override
  String get jumpToStep => 'Ir al paso';

  @override
  String get explanation => 'Explicación';

  @override
  String get close => 'Cerrar';

  @override
  String get toggleTheme => 'Cambiar tema';

  @override
  String get changeLanguage => 'Idioma';

  @override
  String get solveFallbackError => 'No se pudo resolver la matriz.';

  @override
  String get legendPivot => 'Pivote';

  @override
  String get legendSource => 'Origen';

  @override
  String get legendTarget => 'Objetivo';

  @override
  String get legendZeroResult => 'Cero obtenido';

  @override
  String cellCalculationTitle(Object col, Object row) {
    return 'Cálculo del elemento ($row, $col)';
  }

  @override
  String get arithmeticDetail => 'Operación aritmética:';

  @override
  String get resultLabel => 'Resultado:';

  @override
  String get transformScreenTitle => 'Transformación lineal 2D';

  @override
  String get presetShear => 'Cizallamiento';

  @override
  String get presetRotation => 'Rotación de 45°';

  @override
  String get presetScale => 'Escalado';

  @override
  String get presetReflection => 'Reflexión';

  @override
  String get presetProjection => 'Proyección (det=0)';

  @override
  String get presetReset => 'Restablecer (I)';

  @override
  String step_row_swap_title(Object rowA, Object rowB) {
    return 'Intercambiar filas $rowA y $rowB';
  }

  @override
  String step_row_swap_desc(
    Object col,
    Object pivot,
    Object rowA,
    Object rowB,
  ) {
    return 'Intercambiamos las filas $rowA y $rowB para situar un pivote no nulo ($pivot) en la columna $col.';
  }

  @override
  String step_row_scale_title(Object row) {
    return 'Normalizar la fila $row';
  }

  @override
  String step_row_scale_desc(Object factor, Object row) {
    return 'Multiplicamos la fila $row por $factor para que el pivote sea 1.';
  }

  @override
  String step_row_elimination_title(Object source, Object target) {
    return 'Eliminar el elemento de la fila $target con la fila $source';
  }

  @override
  String step_row_elimination_desc(
    Object col,
    Object multiplier,
    Object source,
    Object target,
  ) {
    return 'Anulamos la columna $col en la fila $target: R_$target ← R_$target − ($multiplier) · R_$source.';
  }

  @override
  String get det_1x1_title => 'Determinante de una matriz 1×1';

  @override
  String det_1x1_desc(Object val) {
    return 'El determinante es su único elemento: $val.';
  }

  @override
  String get det_2x2_main_diagonal_title => 'Producto de la diagonal principal';

  @override
  String det_2x2_main_diagonal_desc(Object a, Object d, Object product) {
    return 'Multiplicamos la diagonal principal: $a · $d = $product.';
  }

  @override
  String get det_2x2_anti_diagonal_title =>
      'Producto de la diagonal secundaria';

  @override
  String det_2x2_anti_diagonal_desc(Object b, Object c, Object product) {
    return 'Multiplicamos la diagonal secundaria: $b · $c = $product.';
  }

  @override
  String get det_2x2_final_title => 'Resultado del determinante';

  @override
  String det_2x2_final_desc(Object anti, Object det, Object main) {
    return 'Restamos los productos: ($main) − ($anti) = $det.';
  }

  @override
  String get det_sarrus_pos_title => 'Sarrus: diagonales positivas';

  @override
  String det_sarrus_pos_desc(Object p1, Object p2, Object p3, Object total) {
    return 'Suma de productos descendentes: $p1 + $p2 + $p3 = $total.';
  }

  @override
  String get det_sarrus_neg_title => 'Sarrus: diagonales negativas';

  @override
  String det_sarrus_neg_desc(Object n1, Object n2, Object n3, Object total) {
    return 'Suma de productos ascendentes: $n1 + $n2 + $n3 = $total.';
  }

  @override
  String get det_sarrus_final_title => 'Resultado del determinante';

  @override
  String det_sarrus_final_desc(Object det, Object neg, Object pos) {
    return 'Determinante = positivos − negativos: ($pos) − ($neg) = $det.';
  }

  @override
  String get det_singular_column_title => 'Columna nula';

  @override
  String det_singular_column_desc(Object col) {
    return 'La columna $col es nula. El determinante es 0.';
  }

  @override
  String get det_row_swap_title => 'Intercambio de filas: cambio de signo';

  @override
  String det_row_swap_desc(Object rowA, Object rowB) {
    return 'Intercambiar las filas $rowA y $rowB cambia el signo del determinante.';
  }

  @override
  String get det_diagonal_product_title =>
      'Producto diagonal de la matriz triangular';

  @override
  String det_diagonal_product_desc(Object det, Object diagonals, Object sign) {
    return 'La matriz es triangular superior. Determinante = $sign$diagonals = $det.';
  }

  @override
  String get inverse_singular_title => 'Matriz singular';

  @override
  String get inverse_singular_desc =>
      'El determinante es 0; esta matriz no tiene inversa.';

  @override
  String get inverse_2x2_det_title => 'Calcular el determinante';

  @override
  String inverse_2x2_det_desc(Object det, Object formula) {
    return 'Determinante = $formula = $det.';
  }

  @override
  String get inverse_2x2_adjoint_title => 'Construir la matriz adjunta';

  @override
  String get inverse_2x2_adjoint_desc =>
      'Intercambia la diagonal principal y cambia el signo de los otros elementos.';

  @override
  String get inverse_2x2_scale_title => 'Multiplicar la adjunta por 1/det';

  @override
  String inverse_2x2_scale_desc(Object factor) {
    return 'Multiplicamos cada elemento de la adjunta por 1/det = $factor.';
  }

  @override
  String get inverse_block_init_title => 'Construir [A ∣ I]';

  @override
  String inverse_block_init_desc(Object n) {
    return 'Ampliamos la matriz A de $n×$n con la identidad I.';
  }

  @override
  String get inverse_block_extract_title => 'Extraer la inversa A⁻¹';

  @override
  String get inverse_block_extract_desc =>
      'El bloque izquierdo es I; el derecho es la inversa A⁻¹.';

  @override
  String arithmetic_add_cell_title(Object col, Object row) {
    return 'Sumar el elemento ($row, $col)';
  }

  @override
  String arithmetic_add_cell_desc(Object formula) {
    return 'Sumamos elementos correspondientes: $formula.';
  }

  @override
  String arithmetic_mult_cell_title(Object col, Object row) {
    return 'Calcular el elemento ($row, $col)';
  }

  @override
  String arithmetic_mult_cell_desc(Object col, Object formula, Object row) {
    return 'Producto de la fila $row de A y la columna $col de B: $formula.';
  }

  @override
  String get error_matrix_is_singular =>
      'La matriz es singular (determinante = 0) y no tiene inversa.';

  @override
  String get error_inverse_not_square =>
      'La operación requiere una matriz cuadrada.';

  @override
  String get error_dimension_mismatch_add =>
      'Las matrices deben tener las mismas dimensiones.';

  @override
  String get error_dimension_mismatch_multiply =>
      'Las columnas de A deben coincidir con las filas de B.';

  @override
  String system_inconsistent_title(Object row) {
    return 'Contradicción en la fila $row';
  }

  @override
  String system_inconsistent_desc(Object row, Object val) {
    return 'La fila $row indica 0 = $val: [0 … 0 ∣ $val]. El sistema no tiene solución.';
  }

  @override
  String get system_unique_title => 'Solución única';

  @override
  String system_unique_desc(Object solution) {
    return 'Cada incógnita tiene un pivote. La solución única es $solution.';
  }

  @override
  String system_infinite_title(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count variables libres',
      one: '1 variable libre',
    );
    return 'Infinitas soluciones ($_temp0)';
  }

  @override
  String system_infinite_desc(Object freeVars, Object params) {
    return 'Las variables $freeVars son parámetros libres ($params). Expresamos la solución en forma vectorial paramétrica.';
  }

  @override
  String rank_nullity_title(Object nullity, Object rank) {
    return 'Rango = $rank, nulidad = $nullity';
  }

  @override
  String rank_nullity_desc(Object cols, num nullity, num rank) {
    String _temp0 = intl.Intl.pluralLogic(
      rank,
      locale: localeName,
      other: '$rank columnas pivote',
      one: '1 columna pivote',
    );
    String _temp1 = intl.Intl.pluralLogic(
      nullity,
      locale: localeName,
      other: '$nullity libres',
      one: '1 libre',
    );
    return 'Hay $_temp0 y $_temp1. Rango + nulidad = $cols.';
  }

  @override
  String get eigen_char_poly_title => 'Polinomio característico';

  @override
  String eigen_trace_det_desc(Object det, Object trace) {
    return 'Para 2×2: λ² − tr(A)λ + det(A) = 0, con traza $trace y determinante $det.';
  }

  @override
  String get eigen_complex_title => 'Valores propios complejos';

  @override
  String eigen_complex_desc(Object poly, Object roots) {
    return 'El discriminante de $poly es negativo. Raíces conjugadas aproximadas: $roots.';
  }

  @override
  String get eigen_roots_title => 'Raíces de la ecuación característica';

  @override
  String eigen_roots_approx_desc(Object poly, Object roots) {
    return 'Al resolver $poly, los valores propios reales aproximados, redondeados a tres decimales, son: $roots.';
  }

  @override
  String eigen_roots_desc(Object poly, Object roots) {
    return 'De $poly obtenemos los valores propios: $roots.';
  }

  @override
  String eigen_vector_title(Object index, Object lambda) {
    return 'Vector propio para λ_$index = $lambda';
  }

  @override
  String eigen_vector_desc(Object lambda, Object vector) {
    return 'Para (A − λI)v = 0 con λ = $lambda, un vector propio es $vector.';
  }

  @override
  String eigen_3x3_poly_desc(Object det, Object poly, Object trace) {
    return 'Para 3×3: $poly, con traza $trace y determinante $det.';
  }

  @override
  String eigen_irrational_desc(Object poly) {
    return 'Las raíces de $poly no se pudieron aislar con fiabilidad con coeficientes de este tamaño. Existen raíces reales o complejas, pero este solucionador no las calcula.';
  }

  @override
  String get topicLu => 'Descomposición LU (A = LU)';

  @override
  String get topicLuDesc =>
      'Descompón la matriz en factores triangulares inferior L y superior U.';

  @override
  String get topicPractice => 'Autoevaluación y práctica';

  @override
  String get topicPracticeDesc =>
      'Retos con explicaciones inmediatas y puntuación.';

  @override
  String get lu_init_title => 'Iniciar la factorización LU';

  @override
  String get lu_init_desc => 'Empezamos con L = I y U = A.';

  @override
  String lu_swap_desc(Object rowA, Object rowB) {
    return 'El pivote era 0. Intercambiamos las filas $rowA y $rowB; se necesita la matriz de permutación P.';
  }

  @override
  String lu_elim_title(Object source, Object target) {
    return 'Eliminar en fila $target usando fila $source';
  }

  @override
  String lu_elim_desc(Object multiplier, Object source, Object target) {
    return 'Guardamos m_$target$source = $multiplier en L. En U: R_$target ← R_$target − ($multiplier)R_$source.';
  }

  @override
  String get lu_final_title => 'Factorización LU completa';

  @override
  String get lu_final_desc =>
      'Obtuvimos L triangular inferior y U triangular superior.';

  @override
  String get practiceTitle => 'Autoevaluación';

  @override
  String practiceScore(Object score) {
    return '$score puntos';
  }

  @override
  String practiceQuestionProgress(Object current, Object total) {
    return 'Pregunta $current / $total';
  }

  @override
  String get practiceHint => 'Pista';

  @override
  String get practiceHideHint => 'Ocultar pista';

  @override
  String get practiceCorrect => '¡Respuesta correcta!';

  @override
  String get practiceIncorrect => 'Revisemos esta respuesta';

  @override
  String get practiceNext => 'Siguiente pregunta';

  @override
  String get practiceResults => 'Ver resultados';

  @override
  String get practiceCompleted => '¡Práctica completada!';

  @override
  String practiceTotalScore(Object score, Object total) {
    return 'Puntuación total: $score / $total';
  }

  @override
  String get practicePerfectScore =>
      '¡Excelente! Has respondido correctamente a todas las preguntas.';

  @override
  String get practiceGoodEffort =>
      '¡Buen esfuerzo! Inténtalo otra vez para afianzar lo aprendido.';

  @override
  String get practiceReturnTopics => 'Volver a los temas';

  @override
  String get practiceRestart => 'Reiniciar práctica';

  @override
  String get searchTopics => 'Buscar temas…';

  @override
  String get noTopicsFound => 'No hay temas coincidentes';

  @override
  String get noTopicsFoundDesc => 'Prueba otra palabra o categoría.';

  @override
  String get clearSearch => 'Borrar búsqueda';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get replayAnimation => 'Repetir animación';

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
      'Selecciona un elemento e introduce un entero, decimal o fracción.';

  @override
  String inputInvalid(String matrix, int row, int column) {
    return 'Revisa la matriz $matrix, fila $row, columna $column. Introduce un número completo; el denominador no puede ser cero.';
  }

  @override
  String get calculating => 'Calculando…';

  @override
  String inputCell(String matrix, int row, int column) {
    return 'Matriz $matrix, fila $row, columna $column';
  }

  @override
  String get stepAlreadyReducedTitle => 'Ya está en la forma solicitada';

  @override
  String get stepAlreadyReducedDesc =>
      'No hacen falta operaciones de fila. La matriz mostrada es el resultado.';

  @override
  String get keyPreviousCell => 'Elemento anterior';

  @override
  String get keyNextCell => 'Elemento siguiente';

  @override
  String get keySign => 'Cambiar signo';

  @override
  String get keyFraction => 'Barra de fracción';

  @override
  String get keyBackspace => 'Borrar último dígito';

  @override
  String get keyClear => 'Vaciar elemento';

  @override
  String get keyDecimal => 'Separador decimal';

  @override
  String get instructionProgress => 'Esta operación';

  @override
  String get customTransform => 'Personalizada';

  @override
  String get transformCoefficients => 'Matriz de transformación';

  @override
  String get basisVectors => 'Vectores base transformados';

  @override
  String get targetDeterminant => 'Determinante objetivo';

  @override
  String matrixCellLabel(int row, int column, String value) {
    return 'Fila $row, columna $column, valor $value';
  }

  @override
  String get focusSource => 'Comprende el objetivo';

  @override
  String get focusOperation => 'Sigue el cálculo';

  @override
  String get focusResult => 'Comprueba qué cambió';

  @override
  String get inspectOperation => 'Inspeccionar esta operación';

  @override
  String get stepExplanation => 'Por qué funciona';

  @override
  String get cellCalculations => 'Cálculos de elementos';

  @override
  String get stepDetails => 'Detalles';

  @override
  String get chooseStep => 'Elegir un paso';

  @override
  String get learningPath => '¿Empiezas con matrices?';

  @override
  String get continueLearning => 'Continúa donde lo dejaste';

  @override
  String get continueAction => 'Continuar';

  @override
  String get topicCompleted => 'Completado';

  @override
  String pathProgress(int done, int total) {
    return '$done de $total temas completados';
  }

  @override
  String get pathEliminate => '1 · Crear ceros';

  @override
  String get pathReduce => '2 · Encontrar pivotes';

  @override
  String get pathSolve => '3 · Resolver un sistema';

  @override
  String guideEliminateSource(String source, String target, String column) {
    return 'Usa la fila $source para cambiar la fila $target. Mira la columna $column.';
  }

  @override
  String guideEliminateApply(String factor, String source, String target) {
    return 'Suma $factor veces la fila $source a la fila $target, en todos sus elementos.';
  }

  @override
  String guideEliminateResult(String column, String value) {
    return 'La columna $column ahora contiene $value. Se conserva el conjunto de soluciones.';
  }

  @override
  String guideScaleSource(String row, String factor) {
    return 'Multiplica toda la fila $row por el mismo factor no nulo: $factor.';
  }

  @override
  String get guideScaleApply =>
      'Aplica el factor a toda la fila, no solo al pivote.';

  @override
  String get guideScaleResult =>
      'Compara cada elemento escalado con el original.';

  @override
  String guideSwapSource(String first, String second) {
    return 'Las filas $first y $second intercambiarán sus posiciones.';
  }

  @override
  String get guideSwapApply =>
      'Mueve las filas completas; los valores no cambian.';

  @override
  String get guideSwapResult =>
      'Las filas están en sus nuevas posiciones. Las soluciones no cambian.';

  @override
  String guideDotSource(String row, String column) {
    return 'Empareja la fila $row y la columna $column. Cada pareja aporta al resultado.';
  }

  @override
  String get guideDotApply => 'Multiplica cada pareja y suma los productos.';

  @override
  String guideDotResult(String row, String column) {
    return 'La suma ocupa la fila $row, columna $column.';
  }

  @override
  String get guideDetSource =>
      'Observa los factores y los signos de cada producto.';

  @override
  String get guideDetApply =>
      'Sigue un producto cada vez y revisa sus factores.';

  @override
  String get guideDetResult =>
      'Su suma es la aportación de este grupo al determinante.';

  @override
  String get coefficientError => 'Introduce un número entre −1000 y 1000.';

  @override
  String get transformTransitionHint =>
      'Edita un coeficiente y pulsa Intro o sal del campo para aplicarlo. Rango: −1000 a 1000. El deslizador muestra la transición entre estados.';

  @override
  String multiplicationSourceRow(String row) {
    return 'A · fila $row';
  }

  @override
  String multiplicationSourceColumn(String column) {
    return 'B · columna $column';
  }

  @override
  String get multiplicationOutput => 'C = A × B · matriz resultado';

  @override
  String guideEliminateReason(String entry, String pivot, String ratio) {
    return 'Objetivo $entry ÷ pivote $pivot = $ratio. Resta ese múltiplo de la fila origen para obtener cero.';
  }

  @override
  String guideEliminateSubtract(String factor, String source, String target) {
    return 'Resta $factor veces la fila $source de la fila $target, en todos sus elementos.';
  }

  @override
  String get transformProgress => 'Progreso de la transición';

  @override
  String increaseCoefficient(String name) {
    return 'Aumentar el coeficiente $name';
  }

  @override
  String decreaseCoefficient(String name) {
    return 'Reducir el coeficiente $name';
  }

  @override
  String get guideDotReason =>
      'Un elemento de C usa una fila completa de A y una columna completa de B. Multiplica las posiciones correspondientes y suma.';

  @override
  String get guideDetReason =>
      'El determinante mide el cambio de área o volumen con signo. Suma los productos + y resta los −; si es cero, se pierde una dimensión.';

  @override
  String get settings => 'Ajustes';

  @override
  String get practiceNav => 'Práctica';

  @override
  String get transformNav => 'Transformaciones';

  @override
  String get appearance => 'Apariencia';

  @override
  String get learning => 'Aprendizaje y reproducción';

  @override
  String get themeLabel => 'Tema';

  @override
  String get lightTheme => 'Claro';

  @override
  String get darkTheme => 'Oscuro';

  @override
  String get solutionModeLabel => 'Vista de solución';

  @override
  String get guidedMode => 'Animación guiada';

  @override
  String get stepsMode => 'Pasos sin animación';

  @override
  String get resultMode => 'Resultado directo';

  @override
  String get showResult => 'Ver resultado';

  @override
  String get viewSteps => 'Explorar pasos';

  @override
  String get motionLabel => 'Reducir movimiento';

  @override
  String get motionHelp =>
      'Siempre se respeta la preferencia de movimiento reducido del sistema.';

  @override
  String get shortExplanation => 'Breve';

  @override
  String get detailedExplanation => 'Detallada';

  @override
  String get hiddenExplanation => 'Oculta';

  @override
  String get predictionLabel => 'Preguntas de predicción';

  @override
  String get predictionHelp => 'Preguntas opcionales en los ejemplos guiados.';

  @override
  String get predictTitle => 'Antes de intentarlo…';

  @override
  String get predictPrompt => '¿Qué factor anula el elemento objetivo?';

  @override
  String get predictCorrect =>
      '¡Exacto! Sigue ahora la misma operación en toda la fila.';

  @override
  String get predictIncorrect =>
      'Divide el elemento objetivo entre el pivote para hallar el factor.';

  @override
  String get skip => 'Omitir';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get numberView => 'Formato numérico';

  @override
  String get fractionView => 'Fracciones exactas';

  @override
  String get decimalView => 'Decimales';

  @override
  String get densityLabel => 'Densidad de diseño';

  @override
  String get comfortable => 'Cómoda';

  @override
  String get compact => 'Compacta';

  @override
  String get shortcutsLabel => 'Atajos de teclado';

  @override
  String get shortcutHelp =>
      'Selecciona una acción y pulsa una letra, Espacio o una flecha horizontal. Inicio/Fin y Re Pág/Av Pág siguen disponibles.';

  @override
  String get pressKey => 'Pulsa una tecla';

  @override
  String get shortcutConflict =>
      'Esta tecla está reservada o ya está asignada.';

  @override
  String get resetSettings => 'Restablecer ajustes';

  @override
  String get moreOptions => 'Más opciones';

  @override
  String get resetProgress => 'Restablecer progreso';

  @override
  String get settingsStorageError =>
      'No se pudieron leer o guardar los ajustes. Los cambios siguen disponibles en esta sesión.';

  @override
  String get localPreferences =>
      'Los ajustes y las lecciones que terminaste se guardan en este dispositivo. No se guardan matrices ni respuestas del cuestionario.';

  @override
  String get resultExact => 'Exacto';

  @override
  String get resultApproximate => 'Aproximado';

  @override
  String get checkTitle => 'Comprueba el resultado';

  @override
  String get checkHolds => 'Se cumple';

  @override
  String get checkFails => 'No se cumple';

  @override
  String get checkInverse =>
      'Al multiplicar A por su inversa se obtiene la matriz identidad.';

  @override
  String get checkDetRows =>
      'Reducir por filas a una matriz triangular da el mismo valor.';

  @override
  String get checkDetCofactor =>
      'El desarrollo por cofactores de la primera fila da el mismo valor.';

  @override
  String get checkLu =>
      'Multiplicar L por U devuelve A, con las filas en el orden que indica P.';

  @override
  String get checkSystem => 'Sustituir x en las ecuaciones da b.';

  @override
  String get checkRank =>
      'La mayor submatriz cuadrada con determinante no nulo da el rango; las columnas restantes dan la nulidad.';

  @override
  String get checkEigen => 'A solo estira v: Av es igual a λv.';

  @override
  String get seeAsTransform => 'Verlo como transformación';

  @override
  String get resultComplete => 'Completo';

  @override
  String get resultPartial => 'Parcial';

  @override
  String get resultUnsupported => 'No compatible';

  @override
  String get eigenPrecision =>
      'Los valores propios se redondean a tres decimales; los vectores son direcciones aproximadas, no soluciones exactas del núcleo.';

  @override
  String get eigenScope =>
      'Las raíces 3×3 son exactas si son racionales; las demás raíces reales se redondean a tres decimales. Con coeficientes muy grandes pueden quedar raíces sin resolver.';

  @override
  String get eigenBasisScope =>
      'Se muestra un vector por valor propio; no se calcula una base completa del espacio propio.';

  @override
  String get complexScope =>
      'No se admiten vectores propios complejos. La parte imaginaria se redondea a dos decimales.';

  @override
  String get guideAddSource => 'Empareja la misma posición en A y B.';

  @override
  String get guideAddApply => 'Suma este par de elementos.';

  @override
  String get guideAddResult => 'Su suma ocupa la misma posición en C.';

  @override
  String get quizQ1QuestionTitle => 'Gauss: pivote y eliminación';

  @override
  String get quizQ1Prompt =>
      'El pivote está en (1,1). ¿Qué operación anula el primer elemento de la fila 2?';

  @override
  String get quizQ1Explanation =>
      'El objetivo es 2 y el pivote 1: restar dos veces la primera fila da 2 − 2×1 = 0.';

  @override
  String get quizQ1Hint => 'Resta un múltiplo de la fila pivote.';

  @override
  String get quizQ1Feedback0 => 'Restar dos veces la fila 1 da 2 − 2 = 0.';

  @override
  String get quizQ1Feedback1 => 'Sumar da 2 + 2 = 4, no cero.';

  @override
  String get quizQ1Feedback2 =>
      'Intercambiar mueve los elementos, pero no anula el objetivo.';

  @override
  String get quizQ1Feedback3 => 'Dividir la fila 2 entre dos da 1, no cero.';

  @override
  String get quizQ2QuestionTitle => 'Intercambio de filas';

  @override
  String get quizQ2Prompt =>
      'El pivote (1,1) es 0. ¿Qué intercambio sitúa allí un elemento no nulo?';

  @override
  String get quizQ2Explanation =>
      'Intercambiar las filas 1 y 2 sitúa el 3 en la posición pivote.';

  @override
  String get quizQ2Hint =>
      'Busca una fila con primer elemento distinto de cero.';

  @override
  String get quizQ2Feedback0 =>
      'Sumar también crea un pivote no nulo, pero se pide un intercambio.';

  @override
  String get quizQ2Feedback1 => 'El intercambio lleva el 3 a (1,1).';

  @override
  String get quizQ2Feedback2 =>
      'Cambiar la fila 2 no modifica el cero de (1,1).';

  @override
  String get quizQ2Feedback3 =>
      'Escalar la fila 3 no modifica el cero de (1,1).';

  @override
  String get quizQ3QuestionTitle => 'Normalización del pivote';

  @override
  String get quizQ3Prompt =>
      'El pivote de la fila 2 es −3. ¿Qué operación lo convierte en 1?';

  @override
  String get quizQ3Explanation =>
      'Multiplica toda la fila 2 por −1/3: (−3)×(−1/3) = 1.';

  @override
  String get quizQ3Hint => 'Usa el recíproco del pivote.';

  @override
  String get quizQ3Feedback0 =>
      'Sumar la fila 1 rompe el cero inicial y no normaliza el pivote.';

  @override
  String get quizQ3Feedback1 => 'El recíproco de −3 es −1/3; su producto es 1.';

  @override
  String get quizQ3Feedback2 => '−3×3 = −9. Necesitas el recíproco.';

  @override
  String get quizQ3Feedback3 => 'Intercambiar filas no convierte −3 en 1.';

  @override
  String get quizQ4QuestionTitle => 'Rango y filas nulas';

  @override
  String get quizQ4Prompt => '¿Cuál es el rango de esta matriz escalonada?';

  @override
  String get quizQ4Explanation =>
      'Hay dos filas pivote no nulas y una fila nula: rango(A) = 2.';

  @override
  String get quizQ4Hint => 'Cuenta las filas no nulas en forma escalonada.';

  @override
  String get quizQ4Feedback0 =>
      'La fila nula no aporta un pivote; el tamaño no determina el rango.';

  @override
  String get quizQ4Feedback1 => 'La matriz tiene dos filas pivote.';

  @override
  String get quizQ4Feedback2 =>
      'La segunda fila no nula también tiene un pivote.';

  @override
  String get quizQ4Feedback3 =>
      'El rango sería cero solo si todos los elementos fueran cero.';

  @override
  String get quizQ5QuestionTitle => 'Determinante triangular';

  @override
  String get quizQ5Prompt =>
      'En una matriz triangular, multiplica la diagonal principal. ¿Cuánto vale det(A)?';

  @override
  String get quizQ5Explanation => 'El producto de la diagonal es 2×3×4 = 24.';

  @override
  String get quizQ5Hint =>
      'Con ceros bajo la diagonal, multiplica los elementos diagonales.';

  @override
  String get quizQ5Feedback0 => 'Multiplica la diagonal; la suma es la traza.';

  @override
  String get quizQ5Feedback1 => '2×3×4 = 24.';

  @override
  String get quizQ5Feedback2 =>
      'Los ceros bajo la diagonal no anulan el determinante; un cero diagonal sí.';

  @override
  String get quizQ5Feedback3 =>
      'Todos los elementos diagonales son positivos; no hay signo negativo adicional.';

  @override
  String get genDetTitle => 'Determinante 2×2';

  @override
  String get genDetPrompt => '¿Cuánto vale det(A) para la matriz de abajo?';

  @override
  String get genDetHint =>
      'En una matriz 2×2, multiplica la diagonal principal y resta el producto de la otra diagonal: ad − bc.';

  @override
  String genDetExplanation(
    String a,
    String b,
    String c,
    String d,
    String value,
  ) {
    return 'det(A) = $a·$d − $b·$c = $value.';
  }

  @override
  String get genDetFeedbackSign =>
      'Eso suma los dos productos diagonales; el segundo se resta.';

  @override
  String get genDetFeedbackRows =>
      'Eso multiplica a lo largo de las filas. El determinante usa las diagonales.';

  @override
  String get genDetFeedbackOrder =>
      'El orden está invertido: primero va la diagonal principal, así que el signo cambia.';

  @override
  String get genElimTitle => 'Elegir el multiplicador';

  @override
  String get genElimPrompt =>
      '¿Qué operación de fila anula la primera entrada de la fila 2?';

  @override
  String get genElimHint =>
      'Divide la entrada que quieres anular entre el pivote que tiene encima.';

  @override
  String genElimExplanation(String entry, String pivot, String factor) {
    return 'El multiplicador es la entrada dividida entre el pivote: $entry ÷ $pivot = $factor. Restar $factor veces la fila 1 deja la entrada en 0.';
  }

  @override
  String get genElimFeedbackSign =>
      'Con el signo contrario la entrada crece en lugar de anularse.';

  @override
  String get genElimFeedbackRatio =>
      'La razón está invertida: divide la entrada entre el pivote, no el pivote entre la entrada.';

  @override
  String get genElimFeedbackRow =>
      'Eso cambia la fila 1, la del pivote. La fila que debe cambiar es la 2.';

  @override
  String get genProductTitle => 'Una entrada de un producto';

  @override
  String get genProductPrompt =>
      '¿Cuál es la entrada de la fila 1, columna 2 de A·A?';

  @override
  String get genProductHint =>
      'La fila 1 del primer factor se encuentra con la columna 2 del segundo: multiplica par a par y suma.';

  @override
  String genProductExplanation(
    String r1,
    String r2,
    String c1,
    String c2,
    String value,
  ) {
    return 'La fila 1 es ($r1, $r2) y la columna 2 es ($c1, $c2), así que la entrada es $r1·$c1 + $r2·$c2 = $value.';
  }

  @override
  String get genProductFeedbackSquare =>
      'Elevar la entrada al cuadrado no es multiplicar matrices; se usa una fila y una columna completas.';

  @override
  String get genProductFeedbackRows =>
      'Eso empareja la fila 1 con la fila 2. El segundo factor aporta una columna.';

  @override
  String get genProductFeedbackColumns =>
      'Eso empareja dos columnas. El primer factor aporta una fila.';

  @override
  String get genInverseTitle => 'Inversa de una matriz 2×2';

  @override
  String get genInversePrompt => '¿Qué matriz es A⁻¹?';

  @override
  String get genInverseHint =>
      'Intercambia las entradas de la diagonal principal, cambia el signo de las otras dos y divide entre det(A).';

  @override
  String genInverseExplanation(String det) {
    return 'det(A) = $det. a y d se intercambian, b y c cambian de signo y todo se multiplica por 1/$det.';
  }

  @override
  String get genInverseFeedbackSigns =>
      'La diagonal está intercambiada, pero b y c también cambian de signo.';

  @override
  String get genInverseFeedbackSwap =>
      'b y c cambian de signo, pero a y d también deben intercambiarse.';

  @override
  String get genInverseFeedbackNegated =>
      'Aquí cambian de signo todas las entradas; solo cambian b y c.';

  @override
  String get newQuestions => 'Nuevas preguntas';

  @override
  String eigen_vector_approx_title(Object index, Object lambda) {
    return 'Vector aproximado para λ_$index ≈ $lambda';
  }

  @override
  String eigen_vector_approx_desc(Object lambda, Object vector) {
    return 'Con λ ≈ $lambda, una dirección aproximada es $vector; no es una solución exacta del núcleo.';
  }

  @override
  String get spaceKey => 'Espacio';

  @override
  String matrixCellPendingLabel(int row, int column) {
    return 'Fila $row, columna $column, aún sin calcular';
  }

  @override
  String eigen_cubic_complex_desc(Object complex, Object poly, Object roots) {
    return 'Al resolver $poly se obtiene el valor propio real $roots y el par conjugado complejo λ ≈ $complex. Solo el valor propio real tiene un vector propio real.';
  }

  @override
  String get keyNextRow => 'Fila siguiente';

  @override
  String get multiplyRowsLocked =>
      'B tiene tantas filas como columnas tiene A, así A × B está definido.';

  @override
  String get lessonComplete => 'Lección completada';

  @override
  String get lessonCompleteHint =>
      'Revisa el resultado, vuelve a ver la lección o continúa con tu propia matriz.';

  @override
  String get replayLesson => 'Ver de nuevo';

  @override
  String get tryOwnMatrix => 'Prueba tu propia matriz';

  @override
  String get editMatrix => 'Cambiar la matriz';

  @override
  String presetApplied(String matrix) {
    return 'Matriz $matrix reemplazada.';
  }

  @override
  String get undo => 'Deshacer';

  @override
  String get transformShortcutsHint =>
      'Teclado: Espacio reproduce o invierte, S cizalla, P proyección, R identidad.';

  @override
  String get transformLegendOriginal =>
      'Cuadrícula tenue: el plano antes de la transformación.';

  @override
  String get transformLegendEigen =>
      'Líneas discontinuas: direcciones de vectores propios reales, que permanecen en su propia recta.';

  @override
  String guideLuReason(
    String entry,
    String pivot,
    String ratio,
    String row,
    String column,
  ) {
    return 'Objetivo $entry ÷ pivote $pivot = $ratio. Restar $ratio veces la fila pivote anula el objetivo, y el mismo $ratio se escribe en L en ($row, $column), de modo que L · U reconstruye A.';
  }

  @override
  String get guideAdjSource =>
      'En [[a, b], [c, d]], observa la diagonal a, d y las otras dos entradas b, c.';

  @override
  String get guideAdjApply =>
      'a y d intercambian lugares; b y c se quedan en su sitio pero cambian de signo.';

  @override
  String get guideAdjResult =>
      'Esta es adj(A). Al dividirla entre det(A) se obtiene la inversa.';

  @override
  String get guideAdjReason =>
      'Para una matriz 2×2, A · adj(A) = det(A) · I. Por eso A⁻¹ = adj(A) ÷ det(A) siempre que det(A) ≠ 0.';

  @override
  String guideScaleAllSource(String factor) {
    return 'Cada entrada de adj(A) se multiplica por el mismo número, 1/det(A) = $factor.';
  }

  @override
  String get guideScaleAllApply => 'Multiplica las entradas una por una.';

  @override
  String get guideScaleAllResult =>
      'El resultado es A⁻¹. Comprobación: A · A⁻¹ = I.';

  @override
  String get guideDiagSource =>
      'La matriz ya es triangular superior, así que su determinante es el producto de la diagonal.';

  @override
  String get guideDiagApply =>
      'Multiplica las entradas diagonales una a una. El primer factor lleva un −1 por cada intercambio de filas.';

  @override
  String get guideDiagResult =>
      'Las eliminaciones de filas no cambian el determinante, así que este producto es el det de la matriz original.';

  @override
  String get guideDetRecapSource =>
      'Ambos totales se conocen de los pasos anteriores.';

  @override
  String get guideDetRecapApply => 'Resta el total − del total +.';

  @override
  String get guideDetRecapResult => 'La diferencia es el determinante.';
}
