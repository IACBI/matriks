// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Matriks · Lineer Cebir';

  @override
  String get topics => 'Konular';

  @override
  String get selectTopic => 'Matematik stüdyon';

  @override
  String get topicSubtitle => 'Bir problem seç. Örüntüyü gör. Her adımı anla.';

  @override
  String get categoryAll => 'Tüm Konular';

  @override
  String get categoryElimination => 'İndirgeme ve Sistemler';

  @override
  String get categoryAlgebra => 'Matris Cebiri';

  @override
  String get categoryAdvanced => 'Ayrışım ve Spektral Teori';

  @override
  String get categoryVisual => 'Görsel ve Alıştırma';

  @override
  String get topicGauss => 'Gauss Eliminasyonu (REF)';

  @override
  String get topicGaussDesc =>
      'Temel satır işlemleriyle üst üçgensel satır eşelon biçimine (REF) adım adım indirgeme.';

  @override
  String get topicRref => 'Gauss-Jordan Eliminasyonu (RREF)';

  @override
  String get topicRrefDesc =>
      'Baş elemanları 1 olan indirgenmiş satır eşelon biçimine (RREF) tam çözüm.';

  @override
  String get topicLinearSystems => 'Lineer Denklem Sistemleri (Ax = b)';

  @override
  String get topicLinearSystemsDesc =>
      'Gauss-Jordan ile tek çözüm, sonsuz çözüm ve tutarsızlık analizi.';

  @override
  String get topicDeterminant => 'Determinant';

  @override
  String get topicDeterminantDesc =>
      '2x2 çapraz çarpım, 3x3 Sarrus kuralı ve satır işlemleriyle üçgenleme.';

  @override
  String get topicInverse => 'Matris Tersi (A⁻¹)';

  @override
  String get topicInverseDesc =>
      '2x2 ek (adjoint) matris formülü ve [A | I] genişletilmiş blok matris Gauss-Jordan yöntemi.';

  @override
  String get topicRankNullity => 'Rank ve Sıfırlık (Rank-Nullity)';

  @override
  String get topicRankNullityDesc =>
      'Matris rankını, sıfırlığını (nullity) ve Rank-Sıfırlık Teoremini adım adım keşfet.';

  @override
  String get topicEigen => 'Özdeğerler ve Özvektörler';

  @override
  String get topicEigenDesc =>
      '2×2 ve 3×3 matrislerin özdeğer ve özvektörlerini incele; rasyonel kökler kesin hesaplanır.';

  @override
  String get topicTransform2d => '2B Geometrik Lineer Dönüşüm';

  @override
  String get topicTransform2dDesc =>
      'Birim karenin bükülmesini, taban vektörlerini (î, ĵ) ve determinant alanını etkileşimli incele.';

  @override
  String get topicAdd => 'Matris Toplama';

  @override
  String get topicAddDesc =>
      'Etkileşimli hücre animasyonlarıyla eleman eleman toplama.';

  @override
  String get topicMultiply => 'Matris Çarpımı';

  @override
  String get topicMultiplyDesc =>
      'Hedef hücreyi oluşturan satır ve sütun vektörlerinin iç çarpımı.';

  @override
  String get matrixA => 'A Matrisi';

  @override
  String get matrixB => 'B Matrisi';

  @override
  String get rows => 'Satır';

  @override
  String get cols => 'Sütun';

  @override
  String get size => 'Boyut';

  @override
  String get presetRandom => 'Rastgele';

  @override
  String get presetIdentity => 'Birim Matris';

  @override
  String get presetClear => 'Temizle';

  @override
  String get calculate => 'Çöz';

  @override
  String get fractionToggle => 'Kesir / Ondalık';

  @override
  String get decreaseDimension => 'Boyutu azalt';

  @override
  String get increaseDimension => 'Boyutu artır';

  @override
  String stepOf(Object current, Object total) {
    return 'Adım $current / $total';
  }

  @override
  String get decreasePlaybackSpeed => 'Oynatma hızını azalt';

  @override
  String get increasePlaybackSpeed => 'Oynatma hızını artır';

  @override
  String playbackSpeed(Object speed) {
    return 'Hız: $speed×';
  }

  @override
  String get play => 'Oynat';

  @override
  String get pause => 'Duraklat';

  @override
  String get nextStep => 'İleri';

  @override
  String get prevStep => 'Geri';

  @override
  String get jumpToStep => 'Adıma Git';

  @override
  String get explanation => 'Açıklama';

  @override
  String get close => 'Kapat';

  @override
  String get toggleTheme => 'Temayı Değiştir';

  @override
  String get changeLanguage => 'Dil';

  @override
  String get solveFallbackError => 'Matris çözülemedi.';

  @override
  String get legendPivot => 'Pivot';

  @override
  String get legendSource => 'Kaynak';

  @override
  String get legendTarget => 'Hedef';

  @override
  String get legendZeroResult => '0-Sonuç';

  @override
  String cellCalculationTitle(Object col, Object row) {
    return 'Hücre ($row, $col) Hesabı';
  }

  @override
  String get arithmeticDetail => 'Aritmetik İşlem Detayı:';

  @override
  String get resultLabel => 'Sonuç:';

  @override
  String get transformScreenTitle => '2B Lineer Dönüşüm';

  @override
  String get presetShear => 'Kayma (Shear)';

  @override
  String get presetRotation => 'Dönme 45°';

  @override
  String get presetScale => 'Ölçekleme';

  @override
  String get presetReflection => 'Yansıma';

  @override
  String get presetProjection => 'İzdüşüm (det=0)';

  @override
  String get presetReset => 'Sıfırla (Birim)';

  @override
  String step_row_swap_title(Object rowA, Object rowB) {
    return '$rowA. ve $rowB. satırların yerini değiştir';
  }

  @override
  String step_row_swap_desc(
    Object col,
    Object pivot,
    Object rowA,
    Object rowB,
  ) {
    return '$col. sütuna sıfırdan farklı bir baş eleman (pivot: $pivot) getirmek için Satır $rowA ve Satır $rowB yer değiştirdi.';
  }

  @override
  String step_row_scale_title(Object row) {
    return '$row. satırı ölçekle';
  }

  @override
  String step_row_scale_desc(Object factor, Object row) {
    return 'Satır $row elemanları $factor ile çarpılarak baş eleman (pivot) 1 yapıldı.';
  }

  @override
  String step_row_elimination_title(Object target) {
    return '$target. satırdaki elemanı sıfırla';
  }

  @override
  String step_row_elimination_desc(
    Object col,
    Object multiplier,
    Object source,
    Object target,
  ) {
    return 'Satır $target içinde $col. sütun elemanını sıfırlamak için: R_$target ← R_$target - ($multiplier) · R_$source işlemi uygulandı.';
  }

  @override
  String get det_1x1_title => '1x1 Matris Determinantı';

  @override
  String det_1x1_desc(Object val) {
    return '1x1 matrisin determinantı doğrudan tek elemanının değerine eşittir: $val.';
  }

  @override
  String get det_2x2_main_diagonal_title => 'Asal Köşegen Çarpımı';

  @override
  String det_2x2_main_diagonal_desc(Object a, Object d, Object product) {
    return 'Asal köşegen elemanları çarpımı: $a · $d = $product.';
  }

  @override
  String get det_2x2_anti_diagonal_title => 'Yedek Köşegen Çarpımı';

  @override
  String det_2x2_anti_diagonal_desc(Object b, Object c, Object product) {
    return 'Yedek köşegen elemanları çarpımı: $b · $c = $product.';
  }

  @override
  String get det_2x2_final_title => 'Determinant Sonucu';

  @override
  String det_2x2_final_desc(Object anti, Object det, Object main) {
    return 'Determinant = (Asal Köşegen) - (Yedek Köşegen): ($main) - ($anti) = $det.';
  }

  @override
  String get det_sarrus_pos_title => 'Sarrus Kuralı: Pozitif Köşegenler';

  @override
  String det_sarrus_pos_desc(Object p1, Object p2, Object p3, Object total) {
    return 'Aşağı yönlü köşegenlerin toplamı: $p1 + $p2 + $p3 = $total.';
  }

  @override
  String get det_sarrus_neg_title => 'Sarrus Kuralı: Negatif Köşegenler';

  @override
  String det_sarrus_neg_desc(Object n1, Object n2, Object n3, Object total) {
    return 'Yukarı yönlü köşegenlerin toplamı: $n1 + $n2 + $n3 = $total.';
  }

  @override
  String get det_sarrus_final_title => 'Determinant Sonucu';

  @override
  String det_sarrus_final_desc(Object det, Object neg, Object pos) {
    return 'Determinant = (Pozitif Köşegenler) - (Negatif Köşegenler): ($pos) - ($neg) = $det.';
  }

  @override
  String get det_singular_column_title => 'Sıfır Sütun Tespit Edildi';

  @override
  String det_singular_column_desc(Object col) {
    return '$col. sütundaki tüm elemanlar sıfırdır. Bu matrisin determinantı 0\'dır.';
  }

  @override
  String get det_row_swap_title => 'Satır Değişimi (İşaret Değişimi)';

  @override
  String det_row_swap_desc(Object rowA, Object rowB) {
    return 'Satır $rowA ile Satır $rowB yer değiştirdiğinde determinantın işareti değişir (-1 ile çarpılır).';
  }

  @override
  String get det_diagonal_product_title => 'Üst Üçgensel Köşegen Çarpımı';

  @override
  String det_diagonal_product_desc(Object det, Object diagonals, Object sign) {
    return 'Matris üst üçgensel forma dönüştürüldü. Determinant = $sign$diagonals = $det.';
  }

  @override
  String get inverse_singular_title => 'Matris Tekildir (Singular)';

  @override
  String get inverse_singular_desc =>
      'Determinant 0 olduğundan bu matris tekildir ve tersi (inversi) mevcut değildir.';

  @override
  String get inverse_2x2_det_title => 'Determinant Hesabı';

  @override
  String inverse_2x2_det_desc(Object det, Object formula) {
    return 'Determinant = $formula = $det.';
  }

  @override
  String get inverse_2x2_adjoint_title => 'Ek (Adjoint) Matrisi Oluşturma';

  @override
  String get inverse_2x2_adjoint_desc =>
      'Asal köşegen elemanlarının yerleri değiştirildi, yedek köşegen elemanlarının işaretleri ters çevrildi.';

  @override
  String get inverse_2x2_scale_title => 'Ek Matrisi 1/det ile Çarpma';

  @override
  String inverse_2x2_scale_desc(Object factor) {
    return 'Ek matrisin her elemanı 1/det = $factor ile çarpılarak ters matris elde edildi.';
  }

  @override
  String get inverse_block_init_title =>
      'Genişletilmiş Matrisi Oluşturma [A | I]';

  @override
  String inverse_block_init_desc(Object n) {
    return '${n}x$n boyutundaki A matrisinin sağına aynı boyuttaki birim matris I eklendi.';
  }

  @override
  String get inverse_block_extract_title => 'Ters Matrisi (A⁻¹) Ayırma';

  @override
  String get inverse_block_extract_desc =>
      'Sol blok birim matrise (I) dönüştü. Sağ bloktaki matris artık A matrisinin tersidir.';

  @override
  String arithmetic_add_cell_title(Object col, Object row) {
    return '($row, $col) Elemanlarını Toplama';
  }

  @override
  String arithmetic_add_cell_desc(Object formula) {
    return 'Karşılık gelen elemanlar toplandı: $formula.';
  }

  @override
  String arithmetic_mult_cell_title(Object col, Object row) {
    return '($row, $col) Elemanını Hesaplama';
  }

  @override
  String arithmetic_mult_cell_desc(Object col, Object formula, Object row) {
    return 'A matrisinin $row. satırı ile B matrisinin $col. sütununun iç çarpımı: $formula.';
  }

  @override
  String get error_matrix_is_singular =>
      'Bu matris tekildir (determinant = 0), dolayısıyla tersi yoktur.';

  @override
  String get error_inverse_not_square => 'Bu işlem kare matris gerektirir.';

  @override
  String get error_dimension_mismatch_add =>
      'Matris toplaması için matrislerin boyutları aynı olmalıdır.';

  @override
  String get error_dimension_mismatch_multiply =>
      'Matris çarpımı için birinci matrisin sütun sayısı ikinci matrisin satır sayısına eşit olmalıdır.';

  @override
  String system_inconsistent_title(Object row) {
    return 'Satır $row Çelişkisi: Tutarsız Sistem';
  }

  @override
  String system_inconsistent_desc(Object row, Object val) {
    return 'Satır $row [0 ... 0 | $val] biçimine indirgendi; bu da 0 = $val demektir. Bu bir çelişkidir, dolayısıyla sistemin çözümü yoktur.';
  }

  @override
  String get system_unique_title => 'Tek Çözüm Bulundu';

  @override
  String system_unique_desc(Object solution) {
    return 'Her değişken bir pivot sütununa karşılık gelir. Tek çözüm: $solution.';
  }

  @override
  String system_infinite_title(Object count) {
    return 'Sonsuz Çözüm ($count Serbest Değişken)';
  }

  @override
  String system_infinite_desc(Object freeVars, Object params) {
    return 'Pivot olmayan ($freeVars) değişkenleri serbest parametrelerdir ($params). Çözüm parametrik vektör formunda yazılmıştır.';
  }

  @override
  String rank_nullity_title(Object nullity, Object rank) {
    return 'Rank = $rank, Sıfırlık = $nullity';
  }

  @override
  String rank_nullity_desc(Object cols, Object nullity, Object rank) {
    return 'Matrisin $rank pivot sütunu ve $nullity serbest sütunu vardır. Rank-Sıfırlık Teoremi gereği: rank(A) + nullity(A) = $cols.';
  }

  @override
  String get eigen_char_poly_title => 'Karakteristik Polinom';

  @override
  String eigen_trace_det_desc(Object det, Object trace) {
    return '2x2 matris için karakteristik denklem λ² - tr(A)λ + det(A) = 0 olup, iz = $trace ve det = $det değerlerindedir.';
  }

  @override
  String get eigen_complex_title => 'Karmaşık Özdeğerler';

  @override
  String eigen_complex_desc(Object poly, Object roots) {
    return '$poly için diskriminant negatiftir. Özdeğerler karmaşık eşleniklerdir: $roots.';
  }

  @override
  String get eigen_roots_title =>
      'Özdeğerler (Karakteristik Denklemin Kökleri)';

  @override
  String eigen_roots_approx_desc(Object poly, Object roots) {
    return '$poly için üç ondalık basamağa yuvarlanan yaklaşık gerçek özdeğerler: $roots.';
  }

  @override
  String eigen_roots_desc(Object poly, Object roots) {
    return '$poly çözüldüğünde gerçek özdeğerler elde edilir: $roots.';
  }

  @override
  String eigen_vector_title(Object index, Object lambda) {
    return 'λ_$index = $lambda için Özvektör';
  }

  @override
  String eigen_vector_desc(Object lambda, Object vector) {
    return 'λ = $lambda için (A − λI)v = 0 çözülür; örnek bir özvektör $vector.';
  }

  @override
  String eigen_3x3_poly_desc(Object det, Object poly, Object trace) {
    return '3x3 matris için karakteristik denklem: $poly, iz = $trace ve det = $det.';
  }

  @override
  String eigen_irrational_desc(Object poly) {
    return 'Katsayılar bu kadar büyük olduğunda $poly kökleri güvenilir biçimde ayrılamadı. Gerçek veya karmaşık kökler vardır ama bu çözücü onları hesaplamaz.';
  }

  @override
  String get topicLu => 'LU Ayrışımı (A = LU)';

  @override
  String get topicLuDesc =>
      'Kare matrisi alt (L) ve üst (U) üçgensel matris çarpanlarına ayır.';

  @override
  String get topicPractice => 'Kendini Sına (Alıştırma & Test)';

  @override
  String get topicPracticeDesc =>
      'Adım adım doğru işlemi tahmin ederek kendini test et ve puan topla.';

  @override
  String get lu_init_title => 'LU Ayrışımını Başlat';

  @override
  String get lu_init_desc =>
      'L matrisi köşegeninde 1 olan birim matris I olarak, U matrisi ise doğrudan A matrisi olarak başlatılır.';

  @override
  String lu_swap_desc(Object rowA, Object rowB) {
    return 'Pivot 0 idi. Satır $rowA ile Satır $rowB takas edildi (permütasyon matrisi P gerekir).';
  }

  @override
  String lu_elim_title(Object source, Object target) {
    return 'Satır $target Elemanını Sıfırla (Pivot Satır $source)';
  }

  @override
  String lu_elim_desc(Object multiplier, Object source, Object target) {
    return 'Çarpan m_$target$source = $multiplier değeri L matrisinin ($target,$source) hücresine kaydedildi. U matrisindeki işlem: R_$target ← R_$target - ($multiplier)R_$source.';
  }

  @override
  String get lu_final_title => 'LU Ayrışımı Tamamlandı';

  @override
  String get lu_final_desc =>
      'Matris başarıyla L (alt üçgensel) ve U (üst üçgensel) çarpanlarına ayrıştırıldı.';

  @override
  String get practiceTitle => 'Kendini Sına (Alıştırma Modu)';

  @override
  String practiceScore(Object score) {
    return '$score Puan';
  }

  @override
  String practiceQuestionProgress(Object current, Object total) {
    return 'Soru $current / $total';
  }

  @override
  String get practiceHint => 'İpucu';

  @override
  String get practiceHideHint => 'İpucunu Gizle';

  @override
  String get practiceCorrect => 'Tebrikler, Doğru Cevap!';

  @override
  String get practiceIncorrect => 'Yanlış Seçim';

  @override
  String get practiceNext => 'Sonraki Soruya Geç';

  @override
  String get practiceResults => 'Sonuçları Gör';

  @override
  String get practiceCompleted => 'Alıştırma Tamamlandı!';

  @override
  String practiceTotalScore(Object score, Object total) {
    return 'Toplam puanın: $score / $total';
  }

  @override
  String get practicePerfectScore =>
      'Harika! Tüm soruları doğru cevaplayarak tam puan aldın!';

  @override
  String get practiceGoodEffort =>
      'İyi çalışma! Matris işlemlerinde daha da ustalaşmak için tekrar deneyebilirsin.';

  @override
  String get practiceReturnTopics => 'Konulara Dön';

  @override
  String get practiceRestart => 'Tekrar Başla';

  @override
  String get searchTopics => 'Konularda ara...';

  @override
  String get noTopicsFound => 'Eşleşen konu bulunamadı';

  @override
  String get noTopicsFoundDesc =>
      'Farklı bir arama terimi dene veya başka bir kategori seç.';

  @override
  String get clearSearch => 'Aramayı Temizle';

  @override
  String get systemDefault => 'Sistem Varsayılanı';

  @override
  String get replayAnimation => 'Animasyonu Tekrar Oynat';

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
      'Bir hücre seçip tam sayı, ondalık sayı veya kesir gir.';

  @override
  String inputInvalid(String matrix, int row, int column) {
    return '$matrix matrisinde $row. satır, $column. sütunu kontrol et. Tam bir sayı gir; kesrin paydası sıfır olamaz.';
  }

  @override
  String get calculating => 'Hesaplanıyor…';

  @override
  String inputCell(String matrix, int row, int column) {
    return '$matrix matrisi, $row. satır, $column. sütun';
  }

  @override
  String get stepAlreadyReducedTitle => 'Matris zaten istenen biçimde';

  @override
  String get stepAlreadyReducedDesc =>
      'Satır işlemine gerek yok. Gösterilen matris sonuçtur.';

  @override
  String get keyPreviousCell => 'Önceki hücre';

  @override
  String get keyNextCell => 'Sonraki hücre';

  @override
  String get keySign => 'İşareti değiştir';

  @override
  String get keyFraction => 'Kesir çizgisi';

  @override
  String get keyBackspace => 'Son basamağı sil';

  @override
  String get keyClear => 'Hücreyi temizle';

  @override
  String get keyDecimal => 'Ondalık ayırıcı';

  @override
  String get instructionProgress => 'Bu işlemin ilerlemesi';

  @override
  String get customTransform => 'Özel';

  @override
  String get transformCoefficients => 'Dönüşüm matrisi';

  @override
  String get basisVectors => 'Dönüşen baz vektörleri';

  @override
  String get targetDeterminant => 'Hedef determinant';

  @override
  String matrixCellLabel(int row, int column, String value) {
    return 'Satır $row, sütun $column, değer $value';
  }

  @override
  String get focusSource => 'Hedefi anla';

  @override
  String get focusOperation => 'Hesabı takip et';

  @override
  String get focusResult => 'Değişimi kontrol et';

  @override
  String get inspectOperation => 'Bu işlemi incele';

  @override
  String get stepExplanation => 'Neden bu işlem?';

  @override
  String get cellCalculations => 'Hücre hesapları';

  @override
  String get stepDetails => 'Ayrıntılar';

  @override
  String get chooseStep => 'Adım seç';

  @override
  String get learningPath => 'Matrislere yeni mi başlıyorsun?';

  @override
  String get continueLearning => 'Kaldığın yerden devam et';

  @override
  String get continueAction => 'Devam et';

  @override
  String get topicCompleted => 'Tamamlandı';

  @override
  String pathProgress(int done, int total) {
    return '$total konudan $done tanesi tamamlandı';
  }

  @override
  String get pathEliminate => '1 · Sıfırları oluştur';

  @override
  String get pathReduce => '2 · Pivotları bul';

  @override
  String get pathSolve => '3 · Sistemi çöz';

  @override
  String guideEliminateSource(String source, String target, String column) {
    return '$target. satırı değiştirmek için $source. satırı kullanıyoruz. $column. sütuna odaklan.';
  }

  @override
  String guideEliminateApply(String factor, String source, String target) {
    return '$source. satırın $factor katını $target. satıra ekle. Aynı işlemi satırdaki her elemana uygula.';
  }

  @override
  String guideEliminateResult(String column, String value) {
    return '$column. sütundaki eleman artık $value. Satır işlemi çözüm kümesini korur.';
  }

  @override
  String guideScaleSource(String row, String factor) {
    return '$row. satırdaki her elemanı aynı sıfırdan farklı katsayıyla çarp: $factor.';
  }

  @override
  String get guideScaleApply =>
      'Katsayıyı yalnızca pivota değil, satırın tamamına uygula.';

  @override
  String get guideScaleResult =>
      'Satır ölçeklendi. Her elemanı başlangıçtaki satırla karşılaştır.';

  @override
  String guideSwapSource(String first, String second) {
    return '$first. ve $second. satırlar yer değiştirecek.';
  }

  @override
  String get guideSwapApply =>
      'Satırları bütün olarak taşı; elemanların değerleri değişmez.';

  @override
  String get guideSwapResult =>
      'Satırlar yeni yerlerinde. Çözüm kümesi değişmedi.';

  @override
  String guideDotSource(String row, String column) {
    return '$row. satırı $column. sütunla eşleştir. Her çift aynı sonuç elemanına katkı yapar.';
  }

  @override
  String get guideDotApply =>
      'Eşleşen elemanları çarp, ardından katkıları topla.';

  @override
  String guideDotResult(String row, String column) {
    return 'Toplam, $row. satır ve $column. sütundaki sonuç elemanını verir.';
  }

  @override
  String get guideDetSource =>
      'Her çarpımın elemanlarını takip et. İşaretler hangi çarpımların çıkarılacağını belirler.';

  @override
  String get guideDetApply =>
      'Her seferinde bir çarpım vurgulanır. Elemanlarını matrisin altındaki hesapta incele.';

  @override
  String get guideDetResult =>
      'Bu çarpımların toplamı, grubun determinanta katkısıdır.';

  @override
  String get coefficientError => '−1000 ile 1000 arasında bir sayı gir.';

  @override
  String get transformTransitionHint =>
      'Katsayıyı yazıp Enter’a bas veya alandan çık. Değer aralığı: −1000–1000. Sürgü önceki ve yeni durumu karşılaştırır; ara kareler dönüşümler arasındaki geçişi gösterir.';

  @override
  String multiplicationSourceRow(String row) {
    return 'A · $row. satır';
  }

  @override
  String multiplicationSourceColumn(String column) {
    return 'B · $column. sütun';
  }

  @override
  String get multiplicationOutput => 'C = A × B · sonuç matrisi';

  @override
  String guideEliminateReason(String entry, String pivot, String ratio) {
    return 'Hedefteki $entry ÷ pivot $pivot = $ratio. Hedef elemanı sıfırlamak için kaynak satırın bu katını çıkar.';
  }

  @override
  String guideEliminateSubtract(String factor, String source, String target) {
    return '$target. satırdan $source. satırın $factor katını çıkar. İşlemi satırdaki her elemana uygula.';
  }

  @override
  String get transformProgress => 'Dönüşümün ilerlemesi';

  @override
  String increaseCoefficient(String name) {
    return '$name katsayısını artır';
  }

  @override
  String decreaseCoefficient(String name) {
    return '$name katsayısını azalt';
  }

  @override
  String get guideDotReason =>
      'Bir sonuç elemanı, A’nın bir satırı ile B’nin bir sütununun tamamından oluşur. Aynı sıradaki elemanları çarp, sonra bu katkıları topla.';

  @override
  String get guideDetReason =>
      'Determinant, alanın veya hacmin işaretli ölçeklenmesini ölçer. Pozitif gruptaki çarpımları topla, negatif gruptakileri çıkar. Determinant sıfırsa dönüşüm en az bir boyutu kaybettirir.';

  @override
  String get settings => 'Ayarlar';

  @override
  String get practiceNav => 'Alıştırmalar';

  @override
  String get transformNav => 'Dönüşümler';

  @override
  String get appearance => 'Görünüm';

  @override
  String get learning => 'Öğrenme ve oynatma';

  @override
  String get themeLabel => 'Tema';

  @override
  String get lightTheme => 'Açık';

  @override
  String get darkTheme => 'Koyu';

  @override
  String get solutionModeLabel => 'Çözüm görünümü';

  @override
  String get guidedMode => 'Rehberli animasyon';

  @override
  String get stepsMode => 'Adım adım (animasyonsuz)';

  @override
  String get resultMode => 'Doğrudan sonuç';

  @override
  String get showResult => 'Sonucu göster';

  @override
  String get viewSteps => 'Adımları incele';

  @override
  String get motionLabel => 'Hareketi azalt';

  @override
  String get motionHelp =>
      'Sistemin azaltılmış hareket tercihi her zaman korunur.';

  @override
  String get shortExplanation => 'Kısa';

  @override
  String get detailedExplanation => 'Ayrıntılı';

  @override
  String get hiddenExplanation => 'Gizli';

  @override
  String get predictionLabel => 'Tahmin soruları';

  @override
  String get predictionHelp =>
      'Başlangıç örneklerinde atlanabilir düşünme soruları.';

  @override
  String get predictTitle => 'Denemeden önce…';

  @override
  String get predictPrompt => 'Hedef elemanı hangi katsayı sıfırlar?';

  @override
  String get predictCorrect =>
      'Aynen öyle! Şimdi aynı işlemi satır boyunca izleyelim.';

  @override
  String get predictIncorrect => 'Katsayıyı bulmak için hedefi pivota böl.';

  @override
  String get skip => 'Atla';

  @override
  String get continueLabel => 'Devam et';

  @override
  String get numberView => 'Sayı görünümü';

  @override
  String get fractionView => 'Kesirler';

  @override
  String get decimalView => 'Ondalık';

  @override
  String get densityLabel => 'Görünüm yoğunluğu';

  @override
  String get comfortable => 'Rahat';

  @override
  String get compact => 'Kompakt';

  @override
  String get shortcutsLabel => 'Klavye kısayolları';

  @override
  String get shortcutHelp =>
      'Bir eylem seç; harf, boşluk veya yatay ok tuşuna bas. Home/End ve Page Up/Down kullanılabilir kalır.';

  @override
  String get pressKey => 'Bir tuşa bas';

  @override
  String get shortcutConflict =>
      'Bu tuş ayrılmış veya başka bir eyleme atanmış.';

  @override
  String get resetSettings => 'Ayarları sıfırla';

  @override
  String get moreOptions => 'Diğer seçenekler';

  @override
  String get resetProgress => 'İlerlemeyi sıfırla';

  @override
  String get settingsStorageError =>
      'Ayarlar okunamadı veya kaydedilemedi. Değişiklikler bu oturumda kullanılabilir.';

  @override
  String get localPreferences =>
      'Ayarlar ve bitirdiğin dersler bu cihazda tutulur. Matrisler ve test cevapları kaydedilmez.';

  @override
  String get resultExact => 'Kesin';

  @override
  String get resultApproximate => 'Yaklaşık';

  @override
  String get checkTitle => 'Sonucu doğrula';

  @override
  String get checkHolds => 'Doğru';

  @override
  String get checkFails => 'Sağlanmıyor';

  @override
  String get checkInverse => 'A\'yı tersiyle çarpınca birim matris çıkar.';

  @override
  String get checkDetRows =>
      'Satır işlemleriyle üçgen matrise indirgemek aynı değeri verir.';

  @override
  String get checkDetCofactor =>
      'İlk satır boyunca kofaktör açılımı aynı değeri verir.';

  @override
  String get checkLu =>
      'L ile U\'yu çarpmak A\'yı geri verir; satırlar P\'nin gösterdiği sıradadır.';

  @override
  String get checkSystem => 'x\'i denklemlerde yerine koyunca b elde edilir.';

  @override
  String get checkRank =>
      'Rank ile sıfırlığın toplamı sütun sayısı n\'ye eşittir.';

  @override
  String get checkEigen => 'A, v\'yi yalnızca uzatır: Av, λv\'ye eşittir.';

  @override
  String get seeAsTransform => 'Dönüşüm olarak gör';

  @override
  String get resultComplete => 'Tam';

  @override
  String get resultPartial => 'Kısmi';

  @override
  String get resultUnsupported => 'Desteklenmiyor';

  @override
  String get eigenPrecision =>
      'Özdeğerler üç ondalığa yuvarlanır; vektörler kesin sıfır uzayı çözümleri değil, yaklaşık yönlerdir.';

  @override
  String get eigenScope =>
      '3×3 kökler rasyonelse kesindir; diğer gerçek kökler üç ondalığa yuvarlanır. Çok büyük katsayılarda kökler bulunamayabilir.';

  @override
  String get eigenBasisScope =>
      'Her özdeğer için bir örnek vektör gösterilir; özuzayın tam bazı hesaplanmaz.';

  @override
  String get complexScope =>
      'Karmaşık özvektörler desteklenmiyor. Sanal kısım iki ondalığa yuvarlanır.';

  @override
  String get guideAddSource => 'A ve B\'deki aynı konumları eşleştir.';

  @override
  String get guideAddApply => 'Bu iki elemanı topla.';

  @override
  String get guideAddResult => 'Toplamları C\'deki aynı konuma gelir.';

  @override
  String get quizQ1QuestionTitle => 'Gauss Eliminasyonu: Pivot ve Sıfırlama';

  @override
  String get quizQ1Prompt =>
      'Aşağıdaki matriste 1. sütundaki ilk pivot (1,1) hücresidir. 2. satırın ilk elemanını sıfırlamak için hangi satır işlemi uygulanmalıdır?';

  @override
  String get quizQ1Explanation =>
      '2. satırın ilk elemanı 2, pivot ise 1 dir. 2 - 2(1) = 0 elde etmek için R_2 \\leftarrow R_2 - 2R_1 işlemi uygulanmalıdır.';

  @override
  String get quizQ1Hint =>
      'Hedef satırdaki elemanı (2), pivot satırının (1) katı ile çıkararak sıfırla.';

  @override
  String get quizQ1Feedback0 =>
      'İlk satırın iki katını çıkarmak 2 − 2 = 0 sonucunu verir.';

  @override
  String get quizQ1Feedback1 =>
      'İlk satırın iki katını eklemek 2 + 2 = 4 verir; hedef eleman sıfırlanmaz.';

  @override
  String get quizQ1Feedback2 =>
      'Satır takası elemanları taşır; hedef elemanı sıfırlamaz.';

  @override
  String get quizQ1Feedback3 =>
      'İkinci satırı yarıya bölmek ilk elemanı 1 yapar; sıfır yapmaz.';

  @override
  String get quizQ2QuestionTitle => 'Satır Takası (Row Swap) İhtiyacı';

  @override
  String get quizQ2Prompt =>
      '1. sütunda pivot pozisyonunda 0 bulunmaktadır. (1,1) konumuna sıfır olmayan bir pivot getirmek için hangi satır takası yapılmalıdır?';

  @override
  String get quizQ2Explanation =>
      'Pivot pozisyonu (1,1) sıfır olamaz. Sıfır olmayan bir elemanı başa almak için 1. ve 2. satırlar takas edilmelidir: R_1 \\leftrightarrow R_2.';

  @override
  String get quizQ2Hint =>
      'Sıfır olan bir pivotla bölme yapılamaz; sıfır olmayan bir satırla yer değiştir.';

  @override
  String get quizQ2Feedback0 =>
      'İkinci satırı eklemek de sıfır olmayan pivot oluşturur; ancak bu soru özellikle satır takasını soruyor.';

  @override
  String get quizQ2Feedback1 =>
      'İlk iki satırı takas etmek, sıfır olmayan 3 değerini pivot konumuna getirir.';

  @override
  String get quizQ2Feedback2 =>
      'İkinci satırı değiştirmek (1,1) konumundaki sıfırı değiştirmez.';

  @override
  String get quizQ2Feedback3 =>
      'Üçüncü satırı ölçeklemek (1,1) konumundaki sıfırı değiştirmez.';

  @override
  String get quizQ3QuestionTitle => 'Pivot Normalizasyonu (Scaling)';

  @override
  String get quizQ3Prompt =>
      '2. satırdaki pivot elemanı -3 tür. Bu pivotu 1 yapmak için hangi işlem yapılmalıdır?';

  @override
  String get quizQ3Explanation =>
      'İkinci satırın her elemanını −1/3 ile çarpalım: (−3) × (−1/3) = 1.';

  @override
  String get quizQ3Hint =>
      'Bir sayıyı 1 yapmak için onu çarpma işlemine göre tersiyle çarp.';

  @override
  String get quizQ3Feedback0 =>
      'İlk satırı eklemek baştaki sıfırı bozar ve bu pivotu 1 yapmaz.';

  @override
  String get quizQ3Feedback1 =>
      '−3 sayısının çarpmaya göre tersi −1/3 olduğundan çarpımları 1 olur.';

  @override
  String get quizQ3Feedback2 =>
      '−3 ile 3 çarpıldığında −9 olur. Sayının çarpmaya göre tersini kullan.';

  @override
  String get quizQ3Feedback3 =>
      'Satır takası konumları değiştirir; −3 değerini 1 yapacak ölçeklemeyi sağlamaz.';

  @override
  String get quizQ4QuestionTitle => 'Rank ve Sıfır Satırı Tespiti';

  @override
  String get quizQ4Prompt =>
      'Aşağıdaki basamak matrisin rankı (bağımsız satır sayısı) kaçtır?';

  @override
  String get quizQ4Explanation =>
      'Matris echelon formdadır. 2 adet sıfırdan farklı satır (pivot satırı) ve 1 adet tamamen sıfır satırı vardır. Dolayısıyla rank(A) = 2 dir.';

  @override
  String get quizQ4Hint => 'Eşelon formdaki sıfırdan farklı satırları say.';

  @override
  String get quizQ4Feedback0 =>
      'Sıfır satırı pivot oluşturmaz. Matrisin boyutu tek başına rankını belirlemez.';

  @override
  String get quizQ4Feedback1 =>
      'Bu basamak matrisinde iki pivot satırı vardır.';

  @override
  String get quizQ4Feedback2 =>
      'İkinci sıfırdan farklı satırda da bir pivot var; onu da saymalısın.';

  @override
  String get quizQ4Feedback3 =>
      'Rankın sıfır olması için matrisin bütün elemanlarının sıfır olması gerekir.';

  @override
  String get quizQ5QuestionTitle => 'Determinant ve Üçgensel Matris';

  @override
  String get quizQ5Prompt =>
      'Üst üçgensel bir matrisin determinantı köşegen elemanlarının çarpımıdır. Bu matrisin det(A) değeri nedir?';

  @override
  String get quizQ5Explanation =>
      'Üçgensel matrislerin determinantı asal köşegen üzerindeki elemanların çarpımıdır: 2 \\cdot 3 \\cdot 4 = 24.';

  @override
  String get quizQ5Hint =>
      'Köşegenin altı tamamen sıfırsa yalnızca köşegen elemanlarını çarp.';

  @override
  String get quizQ5Feedback0 =>
      'Üçgensel determinant için köşegen elemanlarını çarp. Toplamları matrisin izini verir.';

  @override
  String get quizQ5Feedback1 => 'Köşegen çarpımı 2 × 3 × 4 = 24 olur.';

  @override
  String get quizQ5Feedback2 =>
      'Köşegen altındaki sıfırlar determinantı sıfır yapmaz; köşegende sıfır olması bunu yapar.';

  @override
  String get quizQ5Feedback3 =>
      'Köşegen elemanlarının hepsi pozitif; ek bir eksi işareti gelmez.';

  @override
  String get genDetTitle => '2×2 determinant';

  @override
  String get genDetPrompt => 'Aşağıdaki matris için det(A) kaçtır?';

  @override
  String get genDetHint =>
      '2×2 matriste ana köşegenin çarpımından diğer köşegenin çarpımını çıkar: ad − bc.';

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
      'Bu, iki köşegen çarpımını topluyor; ikincisi çıkarılmalı.';

  @override
  String get genDetFeedbackRows =>
      'Bu, satırlar boyunca çarpıyor. Determinant köşegenleri kullanır.';

  @override
  String get genDetFeedbackOrder =>
      'Sıra ters: önce ana köşegen gelir, bu yüzden işaret değişir.';

  @override
  String get genElimTitle => 'Çarpanı seçmek';

  @override
  String get genElimPrompt =>
      'Hangi satır işlemi 2. satırın ilk elemanını sıfır yapar?';

  @override
  String get genElimHint =>
      'Sıfırlamak istediğin elemanı üstündeki pivota böl.';

  @override
  String genElimExplanation(String entry, String pivot, String factor) {
    return 'Çarpan, eleman bölü pivottur: $entry ÷ $pivot = $factor. 1. satırın $factor katını çıkarınca eleman 0 olur.';
  }

  @override
  String get genElimFeedbackSign =>
      'Ters işaretle eleman sıfırlanmak yerine büyür.';

  @override
  String get genElimFeedbackRatio =>
      'Oran ters çevrilmiş: pivotu elemana değil, elemanı pivota böl.';

  @override
  String get genElimFeedbackRow =>
      'Bu, pivot satırı olan 1. satırı değiştirir. Değişmesi gereken satır 2. satır.';

  @override
  String get genProductTitle => 'Çarpımın bir elemanı';

  @override
  String get genProductPrompt =>
      'A·A çarpımının 1. satır, 2. sütundaki elemanı kaçtır?';

  @override
  String get genProductHint =>
      'İlk çarpanın 1. satırı ile ikinci çarpanın 2. sütununu eşleştir: ikişer ikişer çarp ve topla.';

  @override
  String genProductExplanation(
    String r1,
    String r2,
    String c1,
    String c2,
    String value,
  ) {
    return '1. satır ($r1, $r2), 2. sütun ($c1, $c2); eleman $r1·$c1 + $r2·$c2 = $value.';
  }

  @override
  String get genProductFeedbackSquare =>
      'Elemanın karesini almak matris çarpımı değildir; bütün bir satır ve sütun kullanılır.';

  @override
  String get genProductFeedbackRows =>
      'Bu, 1. satırı 2. satırla eşleştiriyor. İkinci çarpan bir sütun verir.';

  @override
  String get genProductFeedbackColumns =>
      'Bu, iki sütunu eşleştiriyor. İlk çarpan bir satır verir.';

  @override
  String get genInverseTitle => '2×2 matrisin tersi';

  @override
  String get genInversePrompt => 'Hangi matris A⁻¹\'dir?';

  @override
  String get genInverseHint =>
      'Ana köşegendeki elemanların yerini değiştir, diğer ikisinin işaretini değiştir ve det(A)\'ya böl.';

  @override
  String genInverseExplanation(String det) {
    return 'det(A) = $det. a ile d yer değiştirir, b ile c\'nin işareti değişir ve hepsi 1/$det ile çarpılır.';
  }

  @override
  String get genInverseFeedbackSigns =>
      'Köşegen yer değiştirmiş, ama b ile c\'nin işareti de değişmeli.';

  @override
  String get genInverseFeedbackSwap =>
      'b ile c\'nin işareti değişmiş, ama a ile d de yer değiştirmeli.';

  @override
  String get genInverseFeedbackNegated =>
      'Burada bütün elemanların işareti değişmiş; yalnızca b ile c\'nin işareti değişir.';

  @override
  String get newQuestions => 'Yeni sorular';

  @override
  String eigen_vector_approx_title(Object index, Object lambda) {
    return 'λ_$index ≈ $lambda için yaklaşık vektör';
  }

  @override
  String eigen_vector_approx_desc(Object lambda, Object vector) {
    return 'λ ≈ $lambda kullanılarak yaklaşık yön $vector bulunur. Yuvarlanan değer, kesin sıfır uzayı çözümü vermez.';
  }

  @override
  String get spaceKey => 'Boşluk';

  @override
  String matrixCellPendingLabel(int row, int column) {
    return 'Satır $row, sütun $column, henüz hesaplanmadı';
  }

  @override
  String eigen_cubic_complex_desc(Object complex, Object poly, Object roots) {
    return '$poly çözüldüğünde gerçek özdeğer $roots ve karmaşık eşlenik çift λ ≈ $complex bulunur. Yalnızca gerçek özdeğerin gerçek bir özvektörü vardır.';
  }

  @override
  String get keyNextRow => 'Sonraki satır';

  @override
  String get multiplyRowsLocked =>
      'B’nin satır sayısı A’nın sütun sayısına eşit tutulur; böylece A × B tanımlı olur.';

  @override
  String get lessonComplete => 'Ders tamamlandı';

  @override
  String get lessonCompleteHint =>
      'Sonucu kontrol et, dersi yeniden izle ya da kendi matrisinle devam et.';

  @override
  String get replayLesson => 'Yeniden izle';

  @override
  String get tryOwnMatrix => 'Kendi matrisini dene';

  @override
  String get editMatrix => 'Matrisi değiştir';

  @override
  String presetApplied(String matrix) {
    return '$matrix matrisi değiştirildi.';
  }

  @override
  String get undo => 'Geri al';

  @override
  String get transformShortcutsHint =>
      'Klavye: Boşluk oynatır veya geri sarar, S kayma, P izdüşüm, R birim matris.';

  @override
  String get transformLegendOriginal =>
      'Soluk ızgara: dönüşümden önceki düzlem.';

  @override
  String get transformLegendEigen =>
      'Kesikli çizgiler: kendi doğrusu üzerinde kalan gerçek özvektör yönleri.';

  @override
  String guideLuReason(
    String entry,
    String pivot,
    String ratio,
    String row,
    String column,
  ) {
    return 'Hedefteki $entry ÷ pivot $pivot = $ratio. Pivot satırının $ratio katını çıkarmak hedefi sıfırlar; aynı $ratio değeri L matrisinin ($row, $column) konumuna yazılır, böylece L · U yeniden A olur.';
  }

  @override
  String get guideAdjSource =>
      '[[a, b], [c, d]] için köşegendeki a, d ile diğer iki eleman b, c’ye bak.';

  @override
  String get guideAdjApply =>
      'a ile d yer değiştirir; b ve c yerinde kalır ama işaret değiştirir.';

  @override
  String get guideAdjResult =>
      'Bu, adj(A) matrisidir. det(A)’ya bölününce ters matris elde edilir.';

  @override
  String get guideAdjReason =>
      '2×2 bir matris için A · adj(A) = det(A) · I olur. Bu yüzden det(A) ≠ 0 ise A⁻¹ = adj(A) ÷ det(A).';

  @override
  String guideScaleAllSource(String factor) {
    return 'adj(A)’nın her elemanı aynı sayıyla, 1/det(A) = $factor ile çarpılır.';
  }

  @override
  String get guideScaleAllApply => 'Elemanları tek tek çarp.';

  @override
  String get guideScaleAllResult => 'Sonuç A⁻¹’dir. Kontrol: A · A⁻¹ = I.';

  @override
  String get guideDiagSource =>
      'Matris artık üst üçgensel; determinantı köşegen elemanlarının çarpımıdır.';

  @override
  String get guideDiagApply =>
      'Köşegen elemanlarını tek tek çarp. İlk çarpan, her satır değişimi için bir −1 taşır.';

  @override
  String get guideDiagResult =>
      'Satır eleme işlemleri determinantı değiştirmez; bu çarpım başlangıçtaki matrisin determinantıdır.';

  @override
  String get guideDetRecapSource =>
      'İki toplam da önceki adımlardan biliniyor.';

  @override
  String get guideDetRecapApply => '+ toplamından − toplamını çıkar.';

  @override
  String get guideDetRecapResult => 'Aradaki fark determinanttır.';
}
