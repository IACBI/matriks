// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Matriks · 线性代数';

  @override
  String get topics => '主题';

  @override
  String get selectTopic => '探索线性代数';

  @override
  String get topicSubtitle => '逐步理解每一次运算。';

  @override
  String get categoryAll => '全部主题';

  @override
  String get categoryElimination => '消元与方程组';

  @override
  String get categoryAlgebra => '矩阵代数';

  @override
  String get categoryAdvanced => '分解与谱';

  @override
  String get categoryVisual => '可视化与练习';

  @override
  String get topicGauss => '高斯消元（REF）';

  @override
  String get topicGaussDesc => '逐步将矩阵化为行阶梯形。';

  @override
  String get topicRref => '高斯－若尔当消元（RREF）';

  @override
  String get topicRrefDesc => '化为主元为 1 的简化行阶梯形。';

  @override
  String get topicLinearSystems => '线性方程组（Ax = b）';

  @override
  String get topicLinearSystemsDesc => '判断唯一解、无穷多解或无解。';

  @override
  String get topicDeterminant => '行列式';

  @override
  String get topicDeterminantDesc => '2×2 交叉乘积、3×3 萨吕斯法则与三角化。';

  @override
  String get topicInverse => '逆矩阵（A⁻¹）';

  @override
  String get topicInverseDesc => '2×2 伴随矩阵法与 [A ∣ I] 高斯－若尔当法。';

  @override
  String get topicRankNullity => '秩与零度';

  @override
  String get topicRankNullityDesc => '计算秩与零空间维数，验证它们的和。';

  @override
  String get topicEigen => '特征值与特征向量';

  @override
  String get topicEigenDesc => '探索 2×2 与 3×3 矩阵的特征值和特征向量；有理根精确求得。';

  @override
  String get topicTransform2d => '二维几何变换';

  @override
  String get topicTransform2dDesc => '探索单位正方形、基向量与有向面积。';

  @override
  String get topicAdd => '矩阵加法';

  @override
  String get topicAddDesc => '通过动画观察对应元素相加。';

  @override
  String get topicMultiply => '矩阵乘法';

  @override
  String get topicMultiplyDesc => '通过行与列的点积计算每个元素。';

  @override
  String get matrixA => '矩阵 A';

  @override
  String get matrixB => '矩阵 B';

  @override
  String get rows => '行';

  @override
  String get cols => '列';

  @override
  String get size => '大小';

  @override
  String get presetRandom => '随机';

  @override
  String get presetIdentity => '单位矩阵';

  @override
  String get presetClear => '清空';

  @override
  String get calculate => '求解';

  @override
  String get fractionToggle => '分数／小数';

  @override
  String get removeRow => '删除一行';

  @override
  String get addRow => '添加一行';

  @override
  String get removeColumn => '删除一列';

  @override
  String get addColumn => '添加一列';

  @override
  String stepOf(Object current, Object total) {
    return '第 $current 步，共 $total 步';
  }

  @override
  String get decreasePlaybackSpeed => '降低播放速度';

  @override
  String get increasePlaybackSpeed => '提高播放速度';

  @override
  String playbackSpeed(Object speed) {
    return '速度：$speed';
  }

  @override
  String get play => '播放';

  @override
  String get pause => '暂停';

  @override
  String get nextStep => '下一步';

  @override
  String get prevStep => '上一步';

  @override
  String get jumpToStep => '跳转步骤';

  @override
  String get explanation => '说明';

  @override
  String get close => '关闭';

  @override
  String get toggleTheme => '切换主题';

  @override
  String get changeLanguage => '语言';

  @override
  String get solveFallbackError => '无法完成矩阵求解。';

  @override
  String get legendPivot => '主元';

  @override
  String get legendSource => '来源';

  @override
  String get legendTarget => '目标';

  @override
  String get legendZeroResult => '已消为零';

  @override
  String cellCalculationTitle(Object col, Object row) {
    return '元素（$row，$col）的计算';
  }

  @override
  String get arithmeticDetail => '算术运算：';

  @override
  String get resultLabel => '结果：';

  @override
  String get transformScreenTitle => '二维线性变换';

  @override
  String get presetShear => '剪切';

  @override
  String get presetRotation => '旋转 45°';

  @override
  String get presetScale => '缩放';

  @override
  String get presetReflection => '反射';

  @override
  String get presetProjection => '投影（det=0）';

  @override
  String get presetReset => '重置（I）';

  @override
  String step_row_swap_title(Object rowA, Object rowB) {
    return '交换第 $rowA 行与第 $rowB 行';
  }

  @override
  String step_row_swap_desc(
    Object col,
    Object pivot,
    Object rowA,
    Object rowB,
  ) {
    return '交换第 $rowA 行与第 $rowB 行，将非零主元（$pivot）放在第 $col 列。';
  }

  @override
  String step_row_scale_title(Object row) {
    return '归一化第 $row 行';
  }

  @override
  String step_row_scale_desc(Object factor, Object row) {
    return '将第 $row 行乘以 $factor，使主元变为 1。';
  }

  @override
  String step_row_elimination_title(Object source, Object target) {
    return '用第 $source 行消去第 $target 行的元素';
  }

  @override
  String step_row_elimination_desc(
    Object col,
    Object multiplier,
    Object source,
    Object target,
  ) {
    return '消去第 $target 行第 $col 列的元素：R_$target ← R_$target − ($multiplier) · R_$source。';
  }

  @override
  String get det_1x1_title => '1×1 矩阵的行列式';

  @override
  String det_1x1_desc(Object val) {
    return '行列式就是唯一的元素：$val。';
  }

  @override
  String get det_2x2_main_diagonal_title => '主对角线乘积';

  @override
  String det_2x2_main_diagonal_desc(Object a, Object d, Object product) {
    return '主对角线元素相乘：$a · $d = $product。';
  }

  @override
  String get det_2x2_anti_diagonal_title => '副对角线乘积';

  @override
  String det_2x2_anti_diagonal_desc(Object b, Object c, Object product) {
    return '副对角线元素相乘：$b · $c = $product。';
  }

  @override
  String get det_2x2_final_title => '行列式结果';

  @override
  String det_2x2_final_desc(Object anti, Object det, Object main) {
    return '两乘积相减：($main) − ($anti) = $det。';
  }

  @override
  String get det_sarrus_pos_title => '萨吕斯：正向对角线';

  @override
  String det_sarrus_pos_desc(Object p1, Object p2, Object p3, Object total) {
    return '向下对角线乘积之和：$p1 + $p2 + $p3 = $total。';
  }

  @override
  String get det_sarrus_neg_title => '萨吕斯：反向对角线';

  @override
  String det_sarrus_neg_desc(Object n1, Object n2, Object n3, Object total) {
    return '向上对角线乘积之和：$n1 + $n2 + $n3 = $total。';
  }

  @override
  String get det_sarrus_final_title => '行列式结果';

  @override
  String det_sarrus_final_desc(Object det, Object neg, Object pos) {
    return '行列式 = 正向 − 反向：($pos) − ($neg) = $det。';
  }

  @override
  String get det_singular_column_title => '零列';

  @override
  String det_singular_column_desc(Object col) {
    return '第 $col 列全为零，行列式为 0。';
  }

  @override
  String get det_row_swap_title => '交换行：符号改变';

  @override
  String det_row_swap_desc(Object rowA, Object rowB) {
    return '交换第 $rowA 行与第 $rowB 行使行列式变号。';
  }

  @override
  String get det_diagonal_product_title => '三角矩阵的对角线乘积';

  @override
  String det_diagonal_product_desc(Object det, Object diagonals, Object sign) {
    return '矩阵已为上三角形。行列式 = $sign$diagonals = $det。';
  }

  @override
  String get inverse_singular_title => '奇异矩阵';

  @override
  String get inverse_singular_desc => '行列式为 0，该矩阵不存在逆矩阵。';

  @override
  String get inverse_2x2_det_title => '计算行列式';

  @override
  String inverse_2x2_det_desc(Object det, Object formula) {
    return '行列式 = $formula = $det。';
  }

  @override
  String get inverse_2x2_adjoint_title => '构造伴随矩阵';

  @override
  String get inverse_2x2_adjoint_desc => '交换主对角线元素，并将其他元素变号。';

  @override
  String get inverse_2x2_scale_title => '将伴随矩阵乘以 1/det';

  @override
  String inverse_2x2_scale_desc(Object factor) {
    return '将伴随矩阵每个元素乘以 1/det = $factor。';
  }

  @override
  String get inverse_block_init_title => '构造 [A ∣ I]';

  @override
  String inverse_block_init_desc(Object n) {
    return '将 $n×$n 矩阵 A 与单位矩阵 I 拼接。';
  }

  @override
  String get inverse_block_extract_title => '提取逆矩阵 A⁻¹';

  @override
  String get inverse_block_extract_desc => '左侧已变为 I，右侧就是逆矩阵 A⁻¹。';

  @override
  String arithmetic_add_cell_title(Object col, Object row) {
    return '计算元素（$row，$col）的和';
  }

  @override
  String arithmetic_add_cell_desc(Object formula) {
    return '对应元素相加：$formula。';
  }

  @override
  String arithmetic_mult_cell_title(Object col, Object row) {
    return '计算元素（$row，$col）';
  }

  @override
  String arithmetic_mult_cell_desc(Object col, Object formula, Object row) {
    return 'A 的第 $row 行与 B 的第 $col 列的点积：$formula。';
  }

  @override
  String get error_matrix_is_singular => '矩阵奇异（行列式 = 0），不存在逆矩阵。';

  @override
  String get error_inverse_not_square => '该运算需要方阵。';

  @override
  String get error_dimension_mismatch_add => '矩阵维度必须相同。';

  @override
  String get error_dimension_mismatch_multiply => 'A 的列数必须等于 B 的行数。';

  @override
  String system_inconsistent_title(Object row) {
    return '第 $row 行矛盾';
  }

  @override
  String system_inconsistent_desc(Object row, Object val) {
    return '第 $row 行得到 [0 … 0 ∣ $val]，即 0 = $val，所以方程组无解。';
  }

  @override
  String get system_unique_title => '唯一解';

  @override
  String system_unique_desc(Object solution) {
    return '每个未知量对应一个主元列。唯一解为 $solution。';
  }

  @override
  String system_infinite_title(num count) {
    return '无穷多解（$count 个自由变量）';
  }

  @override
  String system_infinite_desc(Object freeVars, Object params) {
    return '变量 $freeVars 为自由参数（$params），解以参数向量形式表示。';
  }

  @override
  String rank_nullity_title(Object nullity, Object rank) {
    return '秩 = $rank，零度 = $nullity';
  }

  @override
  String rank_nullity_desc(Object cols, num nullity, num rank) {
    return '有 $rank 个主元列和 $nullity 个自由列。秩 + 零度 = $cols。';
  }

  @override
  String get eigen_char_poly_title => '特征多项式';

  @override
  String eigen_trace_det_desc(Object det, Object trace) {
    return '对于 2×2：λ² − tr(A)λ + det(A) = 0，迹为 $trace，行列式为 $det。';
  }

  @override
  String get eigen_complex_title => '复特征值';

  @override
  String eigen_complex_desc(Object poly, Object roots) {
    return '$poly 的判别式为负。近似共轭根：$roots。';
  }

  @override
  String get eigen_roots_title => '特征方程的根';

  @override
  String eigen_roots_approx_desc(Object poly, Object roots) {
    return '求解 $poly 得到保留三位小数的近似实特征值：$roots。';
  }

  @override
  String eigen_roots_desc(Object poly, Object roots) {
    return '由 $poly 得到特征值：$roots。';
  }

  @override
  String eigen_vector_title(Object index, Object lambda) {
    return 'λ_$index = $lambda 对应的特征向量';
  }

  @override
  String eigen_vector_desc(Object lambda, Object vector) {
    return '当 λ = $lambda 时，对于 (A − λI)v = 0，一个特征向量为 $vector。';
  }

  @override
  String eigen_3x3_poly_desc(Object det, Object poly, Object trace) {
    return '对于 3×3：$poly，迹为 $trace，行列式为 $det。';
  }

  @override
  String eigen_irrational_desc(Object poly) {
    return '系数过大，无法可靠地分离 $poly 的根。实根或复根存在，但本求解器不计算它们。';
  }

  @override
  String get topicLu => 'LU 分解（A = LU）';

  @override
  String get topicLuDesc => '将矩阵分解为下三角矩阵 L 与上三角矩阵 U。';

  @override
  String get topicPractice => '自测与练习';

  @override
  String get topicPracticeDesc => '通过即时讲解和评分练习。';

  @override
  String get lu_init_title => '开始 LU 分解';

  @override
  String get lu_init_desc => '初始设 L = I，U = A。';

  @override
  String lu_swap_desc(Object rowA, Object rowB) {
    return '主元为 0。交换第 $rowA 行与第 $rowB 行，需要置换矩阵 P。';
  }

  @override
  String lu_elim_title(Object source, Object target) {
    return '用第 $source 行消去第 $target 行的元素';
  }

  @override
  String lu_elim_desc(Object multiplier, Object source, Object target) {
    return '将 m_$target$source = $multiplier 存入 L。在 U 中：R_$target ← R_$target − ($multiplier)R_$source。';
  }

  @override
  String get lu_final_title => 'LU 分解完成';

  @override
  String get lu_final_desc => '得到下三角矩阵 L 与上三角矩阵 U。';

  @override
  String get practiceTitle => '自测';

  @override
  String practiceScore(Object score) {
    return '$score 分';
  }

  @override
  String practiceQuestionProgress(Object current, Object total) {
    return '第 $current 题／共 $total 题';
  }

  @override
  String get practiceHint => '提示';

  @override
  String get practiceHideHint => '隐藏提示';

  @override
  String get practiceCorrect => '回答正确！';

  @override
  String get practiceIncorrect => '来看看这个答案';

  @override
  String get practiceNext => '下一题';

  @override
  String get practiceResults => '查看结果';

  @override
  String get practiceCompleted => '练习完成！';

  @override
  String practiceTotalScore(Object score, Object total) {
    return '总分：$score／$total';
  }

  @override
  String get practicePerfectScore => '太棒了！你答对了所有问题。';

  @override
  String get practiceGoodEffort => '做得不错！再试一次，巩固所学知识。';

  @override
  String get practiceReturnTopics => '返回主题';

  @override
  String get practiceRestart => '重新开始';

  @override
  String get searchTopics => '搜索主题……';

  @override
  String get noTopicsFound => '未找到匹配主题';

  @override
  String get noTopicsFoundDesc => '请尝试其他关键词或分类。';

  @override
  String get clearSearch => '清除搜索';

  @override
  String get systemDefault => '跟随系统';

  @override
  String get replayAnimation => '重播动画';

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
  String get inputHelp => '选择元素，输入整数、小数或分数。';

  @override
  String inputInvalid(String matrix, int row, int column) {
    return '请检查矩阵 $matrix 的第 $row 行第 $column 列。请输入完整数字，分母不能为零。';
  }

  @override
  String get calculating => '计算中……';

  @override
  String inputCell(String matrix, int row, int column) {
    return '矩阵 $matrix，第 $row 行，第 $column 列';
  }

  @override
  String get stepAlreadyReducedTitle => '已为所需形式';

  @override
  String get stepAlreadyReducedDesc => '无需行运算，所示矩阵即为结果。';

  @override
  String get keyPreviousCell => '上一个元素';

  @override
  String get keyNextCell => '下一个元素';

  @override
  String get keySign => '切换正负号';

  @override
  String get keyFraction => '分数斜线';

  @override
  String get keyBackspace => '删除最后一位';

  @override
  String get keyClear => '清空元素';

  @override
  String get keyDecimal => '小数点';

  @override
  String get instructionProgress => '本次运算';

  @override
  String get customTransform => '自定义';

  @override
  String get transformCoefficients => '变换矩阵';

  @override
  String get basisVectors => '变换后的基向量';

  @override
  String get targetDeterminant => '目标行列式';

  @override
  String matrixCellLabel(int row, int column, String value) {
    return '第 $row 行，第 $column 列，值 $value';
  }

  @override
  String get focusSource => '理解目标';

  @override
  String get focusOperation => '跟随计算';

  @override
  String get focusResult => '检查变化';

  @override
  String get inspectOperation => '查看本次运算';

  @override
  String get stepExplanation => '为什么这样做';

  @override
  String get cellCalculations => '元素计算';

  @override
  String get stepDetails => '详细信息';

  @override
  String get chooseStep => '选择步骤';

  @override
  String get learningPath => '刚开始学习矩阵？';

  @override
  String get continueLearning => '从上次离开的地方继续';

  @override
  String get continueAction => '继续';

  @override
  String get topicCompleted => '已完成';

  @override
  String pathProgress(int done, int total) {
    return '已完成 $done/$total 个主题';
  }

  @override
  String get pathEliminate => '1 · 消为零';

  @override
  String get pathReduce => '2 · 寻找主元';

  @override
  String get pathSolve => '3 · 求解方程组';

  @override
  String guideEliminateSource(String source, String target, String column) {
    return '用第 $source 行改变第 $target 行，关注第 $column 列。';
  }

  @override
  String guideEliminateApply(String factor, String source, String target) {
    return '将第 $source 行的 $factor 倍加到第 $target 行，对整行执行。';
  }

  @override
  String guideEliminateResult(String column, String value) {
    return '第 $column 列现在为 $value，解集保持不变。';
  }

  @override
  String guideScaleSource(String row, String factor) {
    return '将第 $row 行的所有元素乘以同一个非零倍数：$factor。';
  }

  @override
  String get guideScaleApply => '将倍数应用到整行，而不仅是主元。';

  @override
  String get guideScaleResult => '比较倍乘前后的每个元素。';

  @override
  String guideSwapSource(String first, String second) {
    return '第 $first 行与第 $second 行将交换位置。';
  }

  @override
  String get guideSwapApply => '整行移动，数值不变。';

  @override
  String get guideSwapResult => '行已到达新位置，解集不变。';

  @override
  String guideDotSource(String row, String column) {
    return '配对第 $row 行与第 $column 列，每对元素贡献一个乘积。';
  }

  @override
  String get guideDotApply => '将每对元素相乘，再把乘积相加。';

  @override
  String guideDotResult(String row, String column) {
    return '和位于第 $row 行第 $column 列。';
  }

  @override
  String get guideDetSource => '观察每个乘积的因子和符号。';

  @override
  String get guideDetApply => '逐个观察乘积并检查因子。';

  @override
  String get guideDetResult => '这些乘积之和就是该组对行列式的贡献。';

  @override
  String get coefficientError => '请输入 −1000 到 1000 的数字。';

  @override
  String get transformTransitionHint =>
      '编辑系数后按 Enter 或离开输入框应用。范围为 −1000 到 1000。滑块显示状态之间的过渡。';

  @override
  String multiplicationSourceRow(String row) {
    return 'A · 第 $row 行';
  }

  @override
  String multiplicationSourceColumn(String column) {
    return 'B · 第 $column 列';
  }

  @override
  String get multiplicationOutput => 'C = A × B · 结果矩阵';

  @override
  String guideEliminateReason(String entry, String pivot, String ratio) {
    return '目标元素 $entry ÷ 主元 $pivot = $ratio。减去来源行的这个倍数即可消为零。';
  }

  @override
  String guideEliminateSubtract(String factor, String source, String target) {
    return '从第 $target 行减去第 $source 行的 $factor 倍，对整行执行。';
  }

  @override
  String get transformProgress => '过渡进度';

  @override
  String increaseCoefficient(String name) {
    return '增大系数 $name';
  }

  @override
  String decreaseCoefficient(String name) {
    return '减小系数 $name';
  }

  @override
  String get guideDotReason => 'C 的一个元素使用 A 的整行与 B 的整列。对应元素相乘，再求和。';

  @override
  String get guideDetReason => '行列式衡量有向面积或体积的缩放。加上正项，减去负项；行列式为零表示损失了一个维度。';

  @override
  String get settings => '设置';

  @override
  String get practiceNav => '练习';

  @override
  String get transformNav => '变换';

  @override
  String get appearance => '外观';

  @override
  String get learning => '学习与播放';

  @override
  String get themeLabel => '主题';

  @override
  String get lightTheme => '浅色';

  @override
  String get darkTheme => '深色';

  @override
  String get solutionModeLabel => '解答视图';

  @override
  String get guidedMode => '引导动画';

  @override
  String get stepsMode => '静态步骤';

  @override
  String get resultMode => '直接显示结果';

  @override
  String get showResult => '显示结果';

  @override
  String get viewSteps => '查看步骤';

  @override
  String get motionLabel => '减少动态效果';

  @override
  String get motionHelp => '始终遵循系统的减少动态效果设置。';

  @override
  String get shortExplanation => '简短';

  @override
  String get detailedExplanation => '详细';

  @override
  String get hiddenExplanation => '隐藏';

  @override
  String get predictionLabel => '预测问题';

  @override
  String get predictionHelp => '讲解示例中的可选思考问题。';

  @override
  String get predictTitle => '开始之前……';

  @override
  String get predictPrompt => '用哪个倍数可以消去目标元素？';

  @override
  String get predictCorrect => '答对了！现在看看同一运算如何应用到整行。';

  @override
  String get predictIncorrect => '用目标元素除以主元即可得到倍数。';

  @override
  String get skip => '跳过';

  @override
  String get continueLabel => '继续';

  @override
  String get numberView => '数字显示';

  @override
  String get fractionView => '精确分数';

  @override
  String get decimalView => '小数';

  @override
  String get densityLabel => '布局密度';

  @override
  String get comfortable => '宽松';

  @override
  String get compact => '紧凑';

  @override
  String get shortcutsLabel => '键盘快捷键';

  @override
  String get shortcutHelp => '选择操作后按字母、空格或左右方向键。Home/End 和 Page Up/Down 仍可使用。';

  @override
  String get pressKey => '请按键';

  @override
  String get shortcutConflict => '该按键已保留或已分配。';

  @override
  String get resetSettings => '重置设置';

  @override
  String get moreOptions => '更多选项';

  @override
  String get resetProgress => '重置学习进度';

  @override
  String get settingsStorageError => '无法读取或保存偏好设置。更改在本次会话中仍然有效。';

  @override
  String get localPreferences => '偏好设置和已完成的课程保存在此设备上，不保存矩阵和测验答案。';

  @override
  String get resultExact => '精确';

  @override
  String get resultApproximate => '近似';

  @override
  String get checkTitle => '验证结果';

  @override
  String get checkHolds => '成立';

  @override
  String get checkFails => '不成立';

  @override
  String get checkInverse => 'A 乘以它的逆矩阵得到单位矩阵。';

  @override
  String get checkDetRows => '通过行化简化为三角矩阵得到相同的值。';

  @override
  String get checkDetCofactor => '按第一行的余子式展开得到相同的值。';

  @override
  String get checkLu => 'L 乘以 U 得回 A，行的顺序由 P 记录。';

  @override
  String get checkSystem => '将 x 代回方程组得到 b。';

  @override
  String get checkRank => '秩加零度等于列数 n。';

  @override
  String get checkEigen => 'A 只拉伸 v：Av 等于 λv。';

  @override
  String get seeAsTransform => '作为变换查看';

  @override
  String get resultComplete => '完整';

  @override
  String get resultPartial => '部分';

  @override
  String get resultUnsupported => '不支持';

  @override
  String get eigenPrecision => '特征值保留三位小数；向量表示近似方向，并非零空间的精确解。';

  @override
  String get eigenScope => '3×3 的有理根为精确值；其他实根四舍五入到三位小数。系数过大时，部分根可能无法求出。';

  @override
  String get eigenBasisScope => '每个特征值仅显示一个代表向量，不计算完整的特征空间基。';

  @override
  String get complexScope => '不支持复特征向量。虚部保留两位小数。';

  @override
  String get guideAddSource => '对应 A 和 B 中的相同位置。';

  @override
  String get guideAddApply => '将这两个元素相加。';

  @override
  String get guideAddResult => '将和放在 C 中的相同位置。';

  @override
  String get quizQ1QuestionTitle => '高斯消元：主元与消元';

  @override
  String get quizQ1Prompt => '主元位于 (1,1)。哪种运算能将第 2 行首元素消为零？';

  @override
  String get quizQ1Explanation => '目标元素为 2，主元为 1。减去第一行的两倍，得到 2 − 2×1 = 0。';

  @override
  String get quizQ1Hint => '减去主元行的适当倍数。';

  @override
  String get quizQ1Feedback0 => '减去第一行的两倍，得到 2 − 2 = 0。';

  @override
  String get quizQ1Feedback1 => '相加得到 2 + 2 = 4，而不是零。';

  @override
  String get quizQ1Feedback2 => '交换行只会移动元素，不能消去目标元素。';

  @override
  String get quizQ1Feedback3 => '将第二行除以 2，首元素变为 1，不是零。';

  @override
  String get quizQ2QuestionTitle => '交换行';

  @override
  String get quizQ2Prompt => '主元位置 (1,1) 为 0。哪次行交换能将非零元素放到该位置？';

  @override
  String get quizQ2Explanation => '交换第 1、2 行可将 3 放到主元位置。';

  @override
  String get quizQ2Hint => '寻找首元素不为零的行。';

  @override
  String get quizQ2Feedback0 => '相加也能得到非零主元，但本题要求交换行。';

  @override
  String get quizQ2Feedback1 => '交换后，3 位于 (1,1)。';

  @override
  String get quizQ2Feedback2 => '改变第二行不会改变 (1,1) 的零。';

  @override
  String get quizQ2Feedback3 => '倍乘第三行不会改变 (1,1) 的零。';

  @override
  String get quizQ3QuestionTitle => '主元归一化';

  @override
  String get quizQ3Prompt => '第二行主元为 −3。哪种运算使它变为 1？';

  @override
  String get quizQ3Explanation => '将第二行乘以 −1/3：(−3)×(−1/3) = 1。';

  @override
  String get quizQ3Hint => '使用主元的倒数。';

  @override
  String get quizQ3Feedback0 => '加上第一行会破坏开头的零，也不能使主元归一化。';

  @override
  String get quizQ3Feedback1 => '−3 的倒数是 −1/3，两者乘积为 1。';

  @override
  String get quizQ3Feedback2 => '−3×3 = −9，需要使用倒数。';

  @override
  String get quizQ3Feedback3 => '交换行不能把 −3 变为 1。';

  @override
  String get quizQ4QuestionTitle => '秩与零行';

  @override
  String get quizQ4Prompt => '这个行阶梯形矩阵的秩是多少？';

  @override
  String get quizQ4Explanation => '有两个非零主元行和一个零行，因此 rank(A) = 2。';

  @override
  String get quizQ4Hint => '计算行阶梯形矩阵中的非零行数。';

  @override
  String get quizQ4Feedback0 => '零行不提供主元，矩阵大小不能单独决定秩。';

  @override
  String get quizQ4Feedback1 => '矩阵有两个主元行。';

  @override
  String get quizQ4Feedback2 => '第二个非零行也有主元，需要计入。';

  @override
  String get quizQ4Feedback3 => '只有所有元素都为零时，秩才为零。';

  @override
  String get quizQ5QuestionTitle => '三角矩阵的行列式';

  @override
  String get quizQ5Prompt => '三角矩阵的行列式等于主对角线元素的乘积。det(A) 是多少？';

  @override
  String get quizQ5Explanation => '主对角线乘积为 2×3×4 = 24。';

  @override
  String get quizQ5Hint => '对角线下方全为零时，直接将对角线元素相乘。';

  @override
  String get quizQ5Feedback0 => '需要相乘，对角线之和是矩阵的迹。';

  @override
  String get quizQ5Feedback1 => '2×3×4 = 24。';

  @override
  String get quizQ5Feedback2 => '对角线下方的零不会使行列式为零，对角线上的零才会。';

  @override
  String get quizQ5Feedback3 => '对角线元素均为正，没有额外的负号。';

  @override
  String get genDetTitle => '2×2 行列式';

  @override
  String get genDetPrompt => '下面矩阵的 det(A) 是多少？';

  @override
  String get genDetHint => '对于 2×2 矩阵，用主对角线的乘积减去另一条对角线的乘积：ad − bc。';

  @override
  String genDetExplanation(
    String a,
    String b,
    String c,
    String d,
    String value,
  ) {
    return 'det(A) = $a·$d − $b·$c = $value。';
  }

  @override
  String get genDetFeedbackSign => '这里把两条对角线的乘积相加了；第二个应当减去。';

  @override
  String get genDetFeedbackRows => '这里是按行相乘。行列式使用的是对角线。';

  @override
  String get genDetFeedbackOrder => '顺序反了：应先取主对角线，所以符号相反。';

  @override
  String get genElimTitle => '选择乘数';

  @override
  String get genElimPrompt => '哪个行变换能使第 2 行的第一个元素变为零？';

  @override
  String get genElimHint => '用要消去的元素除以它上方的主元。';

  @override
  String genElimExplanation(String entry, String pivot, String factor) {
    return '乘数等于元素除以主元：$entry ÷ $pivot = $factor。减去第 1 行的 $factor 倍，该元素变为 0。';
  }

  @override
  String get genElimFeedbackSign => '符号相反时，元素会变大而不是变为零。';

  @override
  String get genElimFeedbackRatio => '比值颠倒了：应当用元素除以主元，而不是主元除以元素。';

  @override
  String get genElimFeedbackRow => '这改变的是主元所在的第 1 行，而需要改变的是第 2 行。';

  @override
  String get genProductTitle => '乘积中的一个元素';

  @override
  String get genProductPrompt => 'A·A 第 1 行第 2 列的元素是多少？';

  @override
  String get genProductHint => '第一个因子的第 1 行与第二个因子的第 2 列相遇：逐对相乘再相加。';

  @override
  String genProductExplanation(
    String r1,
    String r2,
    String c1,
    String c2,
    String value,
  ) {
    return '第 1 行是 ($r1, $r2)，第 2 列是 ($c1, $c2)，所以该元素为 $r1·$c1 + $r2·$c2 = $value。';
  }

  @override
  String get genProductFeedbackSquare => '把元素平方不是矩阵乘法；要用整行和整列。';

  @override
  String get genProductFeedbackRows => '这里把第 1 行和第 2 行配对了。第二个因子提供的是列。';

  @override
  String get genProductFeedbackColumns => '这里把两列配对了。第一个因子提供的是行。';

  @override
  String get genInverseTitle => '2×2 矩阵的逆';

  @override
  String get genInversePrompt => '哪个矩阵是 A⁻¹？';

  @override
  String get genInverseHint => '交换主对角线上的元素，改变另外两个元素的符号，再除以 det(A)。';

  @override
  String genInverseExplanation(String det) {
    return 'det(A) = $det。a 与 d 交换，b 与 c 变号，然后整体乘以 1/$det。';
  }

  @override
  String get genInverseFeedbackSigns => '对角线已交换，但 b 和 c 也要变号。';

  @override
  String get genInverseFeedbackSwap => 'b 和 c 已变号，但 a 和 d 也要交换位置。';

  @override
  String get genInverseFeedbackNegated => '这里所有元素都变了号；只有 b 和 c 需要变号。';

  @override
  String get newQuestions => '新题目';

  @override
  String eigen_vector_approx_title(Object index, Object lambda) {
    return 'λ_$index ≈ $lambda 的近似向量';
  }

  @override
  String eigen_vector_approx_desc(Object lambda, Object vector) {
    return '使用 λ ≈ $lambda 得到近似方向 $vector，它不是零空间的精确解。';
  }

  @override
  String get spaceKey => '空格';

  @override
  String matrixCellPendingLabel(int row, int column) {
    return '第 $row 行，第 $column 列，尚未计算';
  }

  @override
  String eigen_cubic_complex_desc(Object complex, Object poly, Object roots) {
    return '求解 $poly 得到实特征值 $roots 和一对共轭复特征值 λ ≈ $complex。只有实特征值有实特征向量。';
  }

  @override
  String get keyNextRow => '下一行';

  @override
  String get multiplyRowsLocked => 'B 的行数与 A 的列数相同，因此 A × B 有定义。';

  @override
  String get lessonComplete => '课程完成';

  @override
  String get lessonCompleteHint => '查看结果、重看本课，或用你自己的矩阵继续。';

  @override
  String get replayLesson => '再看一遍';

  @override
  String get tryOwnMatrix => '试试你自己的矩阵';

  @override
  String get editMatrix => '修改矩阵';

  @override
  String presetApplied(String matrix) {
    return '矩阵 $matrix 已替换。';
  }

  @override
  String get undo => '撤销';

  @override
  String get transformShortcutsHint => '键盘：空格播放或倒放，S 剪切，P 投影，R 单位矩阵。';

  @override
  String get transformLegendOriginal => '浅色网格：变换前的平面。';

  @override
  String get transformLegendEigen => '虚线：实特征向量方向，变换后仍在自身所在直线上。';

  @override
  String guideLuReason(
    String entry,
    String pivot,
    String ratio,
    String row,
    String column,
  ) {
    return '目标 $entry ÷ 主元 $pivot = $ratio。减去主元行的 $ratio 倍可消去目标元素，同一个 $ratio 写入 L 的 ($row, $column) 位置，因此 L · U 可还原 A。';
  }

  @override
  String get guideAdjSource => '对于 [[a, b], [c, d]]，观察对角线上的 a、d 以及另外两个元素 b、c。';

  @override
  String get guideAdjApply => 'a 与 d 交换位置；b 和 c 位置不变但改变符号。';

  @override
  String get guideAdjResult => '这就是 adj(A)。除以 det(A) 即得逆矩阵。';

  @override
  String get guideAdjReason =>
      '对 2×2 矩阵，A · adj(A) = det(A) · I。因此当 det(A) ≠ 0 时，A⁻¹ = adj(A) ÷ det(A)。';

  @override
  String guideScaleAllSource(String factor) {
    return 'adj(A) 的每个元素都乘以同一个数 1/det(A) = $factor。';
  }

  @override
  String get guideScaleAllApply => '逐个元素相乘。';

  @override
  String get guideScaleAllResult => '结果是 A⁻¹。检验：A · A⁻¹ = I。';

  @override
  String get guideDiagSource => '矩阵现在是上三角矩阵，因此其行列式等于对角线元素之积。';

  @override
  String get guideDiagApply => '逐个乘以对角线元素。每次行交换都在第一个因子中带来一个 −1。';

  @override
  String get guideDiagResult => '行消元不改变行列式，因此这个乘积就是原矩阵的行列式。';

  @override
  String get guideDetRecapSource => '两组的和都已在前面的步骤中得到。';

  @override
  String get guideDetRecapApply => '用 + 组的和减去 − 组的和。';

  @override
  String get guideDetRecapResult => '差值就是行列式。';
}
