# Matriks — Arayüz ve öğretici animasyon değerlendirmesi

> Historical implementation record. For the latest review, cleanup status and proposed work, see [PROJECT_REVIEW.md](PROJECT_REVIEW.md) and [ROADMAP.md](ROADMAP.md).

> Workspace cleanup, 2026-09-06: disposable logs, screenshots, browser recordings, backup archives, and old build caches referenced below were removed at the owner's request. Historical results are retained in this report; the underlying old artifacts are no longer included. The reusable benchmark is preserved at `tool/motion_benchmark_test.dart` (relative to the project root). Rerun checks to produce current evidence.

Tarih: 6 Eylül 2026. Bu rapor, `AUDIT.md` içindeki ilk ürün denetiminden sonra uygulanan arayüz ve animasyon planının sonucunu kaydeder.

## Uygulanan kapsam

- Beş ana ekran aynı nötr yüzey, tipografi, ayırıcı, odak ve eylem sistemini kullanıyor. Katalog hizalı konu satırlarına; matris girişi ve oynatıcı geniş ekranlarda yan yana çalışma alanlarına dönüştürüldü. Dar veya büyük metinli ekranlar kaydırılabilir düzene geçiyor.
- Giriş hatası ilgili matris hücresine bağlandı. Hücre düzeltildiğinde veya boyut küçültülerek kaldırıldığında eski hata bildirimi kayboluyor. Uzun sayılar ve kesirler küçültülmeden yatay kaydırılabiliyor.
- Oynatma tek denetim alanında toplandı. Ders adımları ile işlemin ilerleme çubuğu ayrı etiketlendi; tekrar gösterme korundu. Bağımsız periyodik ders zamanlayıcısı kaldırıldı.
- Öğretici zaman çizgisi kaynak 350 ms → işlem 900 ms → sonuç 550 ms olarak uygulandı. Hız bütün çizgiyi ölçekler; hız değişimi ilerlemeyi korur. Eski adım bildirimleri yeni adımı ilerletemez. Elle seçim, sürükleme ve hesap ayrıntısı otomatik ilerlemeyi durdurur; arka plana geçiş oynatmayı duraklatır.
- Satır değişimleri doğru başlangıç ve sonuç hücrelerini izler; eliminasyon kaynak ve hedef ilişkisini, çarpım gerçek terim katkılarını gösterir. Sayılar rastgele ara değerlere dönüştürülmez. Azaltılmış harekette konumsal hareket kaldırılır ve okuma süresi korunur.
- Dönüşüm katsayıları 2×2 kontrol grubunda; hazır dönüşüm seçimi ve Özel durumu görünür. Baz vektörleri ve hedef determinant ayrı etiketli.
- Alıştırmaların soru, seçenek, açıklama ve sonraki eylem hiyerarşisi sadeleştirildi. Sonuç renk yanında simge ve metinle sunuluyor. Açıklamalardaki sayısal kesirler, satır indisleri ve işlem okları okunabilir düz metne çevriliyor; tam formüller mevcut matematik bileşeninde kalıyor.
- Dekoratif sıçrama ve parıltılar kaldırıldı. Ortak etkileşim süreleri 120/180/220 ms. Gereksiz animasyon parametreleri temizlendi; sabit matematik hücreleri adım başına sınırlı önbellekte tutuluyor.

Bu aşamada hesaplama motorunun veri tipleri, sonuçları ve bağımlılıklar değiştirilmedi. Türkçe/İngilizce, açık/koyu tema ve mevcut işlem akışları korundu.

## Son doğrulama

| Kontrol | Sonuç |
| --- | --- |
| Flutter analiz / statik tür kontrolü | Sorun yok |
| Uygulama testleri | 75 geçti |
| Ayrı motor analizi ve testleri | Sorun yok; 34 geçti |
| Web üretim derlemesi | Başarılı; 86,5 s |
| Windows üretim derlemesi | Başarılı; 41,6 s |
| İncelenen yerel tarayıcı oturumu | 0 hata, 0 uyarı |

Widget testleri beş ana ekranı 320×568 ve %200 metinde her iki temayla kapsıyor. Ek durumlar: 600×800, 960×768, 1440×900 ve 800×380; Türkçe/İngilizce ve azaltılmış hareket örnekleri. Bunlar seçilmiş kombinasyonlardır, tüm cihazların eksiksiz çapraz testi değildir.

Davranış testleri aşama sınırlarını, tamamlanma ve eski bildirimleri, duraklatma/devam, tekrar, sürükleme, hız değişimi, ekranın kapanması ve düzen değişirken ilerlemenin korunmasını kapsıyor. Ayrıca 5×5 uzun/negatif kesirler animasyonun başlangıcında ve işlem ortasında, boş çözüm korumaları, geçersiz hız, hücre hatasının düzeltilmesi, klavye odağı, arama/kategori boş durumu ve küçük matematik rozetlerinin metin kontrastı doğrulandı.

Günlükler ve ekran görüntüleri `output/motion-audit/` altındaydı; bu dizin artık saklanmıyor. `catalog-desktop.png`, `catalog-mobile-dark.png`, `input-desktop.png`, `input-mobile.png`, `player-desktop.png`, `player-mobile.png`, `transform-mobile-dark.png` ve `practice-desktop.png` görsel inceleme kanıtıdır. Görseller çalışma boyunca kaydedildi; hepsi son derlemenin birebir anlık görüntüsü değildir.

## Ölçülen performans

Aynı 5×5 eliminasyon senaryosu, debug widget test düzeneğinde dört kez çalıştırıldı; ilk ısınma turu dışarıda bırakıldı. Kalan 336 örnekte bir 16 ms animasyon adımını test düzeneğinde işleme maliyeti:

| Ölçüm | Önce | Sonra | Azalma |
| --- | ---: | ---: | ---: |
| Medyan | 23,517 ms | 13,265 ms | %43,6 |
| p95 | 41,821 ms | 25,497 ms | %39,0 |

Betik: `tool/motion_benchmark_test.dart`; ham sonuçlar: `before-performance.log` ve `after-performance.log`. Bu sayılar test düzeneği maliyetidir; GPU çizim süresi, Flutter raster ölçümü veya kullanıcı cihazı FPS değeri değildir. Ayrı çalıştırmalar makine yükünden etkilenebilir.

Bu ölçüm hücre önbelleği optimizasyonundan sonra, son açıklama ve uzun kesir yerleşimi rötuşlarından önce kaydedildi.

Yerel web sürümünde başlatılan dönüşüm sırasında alınan 120 tarayıcı requestAnimationFrame aralığında medyan 13,8 ms, p95 20,9 ms; 15 aralık 20 ms üzerindeydi. Örnek kısa bir animasyon sonrası durağan bölümü de içerir. Geçerli bir önceki tarayıcı karşılaştırması yoktur. 16,7 ms hedefinin tüm karelerde karşılandığı iddia edilmez; fiziksel cihaz ve saha Core Web Vitals ölçümü yapılmadı.

## İkinci denetim ve sınırlar

Son geçişte tüm ana ekranların düzenleri, ortak stiller, oynatma yaşam döngüsü, matematik metinleri ve hata kurtarma davranışı yeniden incelendi. Sayfa içeriğini yanlışlıkla tek bir progressbar semantiğinde birleştiren dekoratif ilerleme göstergeleri erişilebilirlik ağacından çıkarıldı. Son genişletilmiş kesir testi, %200 metinde üst işlem formülünün taşmasını da yakaladı; formül kaydırılabilir yapıldı ve geçici kaynak satırındaki son küçültme bileşeni kaldırıldı. Değişen katmanlar sabit açıklamalardan ayrıldı; kullanılmayan animasyon özellikleri temizlendi.

Uygulama yerel hesaplama yapmaya devam ediyor; yeni kimlik doğrulama, uzak API, kalıcı hassas veri veya bağımlılık eklenmedi. Önceki bağımlılık denetimi 5 Eylül 2026 tarihli anlık kontroldür (`AUDIT.md`); bu çalışma yeni bir güvenlik sertifikasyonu değildir.

Fiziksel cihaz ekran okuyucuları, Android/iOS/macOS üretim derlemeleri, saha performansı ve tam WCAG 2.2 AA sertifikasyonu kapsam dışında kaldı. Android yayın imzası, barındırma başlıkları ve ilk ziyaret çevrimdışı davranışı için önceki rapordaki yayın sınırları geçerli. Çalışma alanında Git deposu bulunmadığı için commit veya PR üretilmedi.
