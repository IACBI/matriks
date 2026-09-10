# Matriks — kısa yayın rehberi

Bu proje web, Android, iOS ve Windows için hazırlanabilir. Mağazaya yüklemek ile mağaza onayı almak ayrı adımlardır. Bu çalışma mağazaya gönderim yapmaz.

## 1. Ortak hazırlık

1. Uygulama adını, size ait kalıcı uygulama/paket kimliklerini ve sürümü belirleyin. Sürüm kaynağı: pubspec.yaml.
2. Kaynak kodunun geri yüklenebilir bir Git kopyasını oluşturun. İmza anahtarlarını ve parolaları kaynak koduna koymayın.
3. Uygulama ve motor analiz/testlerini çalıştırın; hedef cihazlarda temel akışları, ekran okuyucuyu, büyük yazıyı ve performansı kontrol edin.
4. Beş dilde ekran görüntüleri, mağaza açıklamaları, destek adresi ve gerçek veri kullanımını anlatan gizlilik sayfasını hazırlayın. Uygulama hesap açmaz; tercihleri yerel olarak saklar. Web sunucusunun günlükleri ve barındırma hizmetleri ayrıca değerlendirilmelidir.
5. Özdeğerlerin yaklaşık/kısmi kapsamını ve tek temsilci vektör sınırını ürün açıklamasında koruyun.

## 2. Web

1. Proje kökünde flutter build web --release çalıştırın.
2. build/web klasörünün tamamını HTTPS destekleyen statik barındırmaya yükleyin.
3. Alt dizinde yayınlayacaksanız uygun --base-href ile yeniden derleyin.
4. Canlı adreste sayfa yenileme, beş dil, ayarların yeniden yükleme sonrası korunması, matematik yazı tipleri ve mobil tarayıcıları test edin.
5. Önceki sürümü geri yükleyebilecek bir dağıtım kopyası tutun. Çevrimdışı kurulum otomatik olarak garanti edilmez.

[Resmi Flutter web rehberi](https://docs.flutter.dev/deployment/web)

## 3. Google Play

1. Play Console geliştirici hesabını açın ve kimlik doğrulamasını tamamlayın.
2. Size ait uygulama kimliğini kesinleştirin. Upload key oluşturup güvenli yedekleyin; Gradle release yapılandırmasını bu anahtara bağlayın.
3. Mevcut Android release yapılandırması debug anahtarını kullanır. Bunu değiştirmeden üretim sürümü göndermeyin.
4. flutter build appbundle --release çalıştırın.
5. AAB dosyasını Play Console'a yükleyin; veri güvenliği, içerik derecelendirmesi ve hesabınız için geçerli test koşullarını tamamlayın.
6. Test cihazlarında doğrulayıp incelemeye gönderin; onaydan sonra kademeli yayınlayın.

[Resmi Flutter Android rehberi](https://docs.flutter.dev/deployment/android)

## 4. Apple App Store

1. Apple Developer üyeliğini ve macOS/Xcode derleme ortamını hazırlayın.
2. Bundle ID, Team ve imzalamayı kendi yayıncı hesabınızla yapılandırın.
3. iPhone ve iPad üzerinde kontrol edin; flutter build ipa --release ile paket oluşturun.
4. App Store Connect'e yükleyin, TestFlight üzerinden test edin.
5. Gizlilik bilgileri, yaş derecelendirmesi ve mağaza içeriğini tamamlayıp incelemeye gönderin.

Windows ortamından iOS üretim derlemesi doğrulanmadı; Mac ve gerçek Apple cihazı gerekir.

[Resmi Flutter iOS rehberi](https://docs.flutter.dev/deployment/ios)

## 5. Microsoft Store

1. Partner Center hesabınızla uygulama adını ayırın ve mağaza kimliğini alın.
2. Windows geliştirici modunda sembolik bağlantı desteğini etkinleştirin; Visual Studio C++ araç zincirini kontrol edin.
3. flutter build windows --release çalıştırın.
4. Release klasörünü bütün DLL ve data dosyalarıyla, mağazanın verdiği Identity/Publisher bilgileriyle MSIX paketine alın.
5. Paketi temiz bir Windows cihazında test edin; Partner Center'a mağaza içeriğiyle gönderin.

Bu çalışma sırasında Windows derlemesi, makinedeki sembolik bağlantı desteği kapalı olduğu için tamamlanamadı. Mevcut eski release çıktısını yeni sürüm gibi dağıtmayın.

[Resmi Flutter Windows rehberi](https://docs.flutter.dev/deployment/windows)

## Yerel doğrulama

Proje kökünde flutter pub get, ardından packages/matrix_engine içinde dart pub get çalıştırın.
Kökte flutter gen-l10n, flutter analyze, flutter test; motor klasöründe dart analyze ve dart test çalıştırın.
İkon boyutlarını yeniden üretmek için Pillow kurulu Python ile python tool/export_branding.py kullanın.

Hesap açma, ücret ödeme, üretim imzaları ve mağazaya gönderme yayın sahibinin sorumluluğundadır. Mağaza kuralları değişebilir; gönderim sırasında bağlı resmi rehberleri yeniden kontrol edin.
