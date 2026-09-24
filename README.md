<a id="top"></a>
# Matriks

Interactive linear algebra with exact matrix arithmetic and guided visual solutions.

![Flutter 3.47.1](https://img.shields.io/badge/Flutter-3.47.1-02569B?logo=flutter&logoColor=white)
![Dart 3.13.1](https://img.shields.io/badge/Dart-3.13.1-0175C2?logo=dart&logoColor=white)
![Platforms](https://img.shields.io/badge/platforms-web%20%7C%20windows%20%7C%20android%20%7C%20ios%20%7C%20linux%20%7C%20macos-555)
![Tests](https://img.shields.io/badge/tests-255%20app%20%2B%2049%20engine-success)
![License](https://img.shields.io/badge/license-Apache--2.0-blue)

**Read this in:** [English](#english) · [Türkçe](#turkce)

---
<a id="english"></a>
## English

### Overview

**Try it in the browser:** <https://iacbi.github.io/matriks/> — the full app, nothing to install.

Matriks teaches linear algebra by showing the work. Twelve topics — from Gauss-Jordan elimination to eigenvectors — are solved with exact `BigInt` rational arithmetic, so a fraction stays a fraction and never drifts into floating-point noise. Each solution is replayed step by step: the operands that feed a cell are highlighted while the cell changes, and the arithmetic behind it stays on screen afterwards.

Results are labelled honestly. Every solution carries an accuracy (exact or approximate) and a completeness (complete, partial or unsupported), so an approximation is never presented as an exact answer.

Everything runs on the device. There is no backend, account system or remote data store; only presentation preferences are persisted, never matrices or quiz history.

Know the numerical boundaries before relying on it. Most operations accept dimensions 1–5. Eigen analysis covers 2×2 and 3×3 only: rational roots are exact, irrational roots are rounded to three decimals with approximate eigenvectors, complex eigenvalues are reported without eigenvectors, and 3×3 matrices with very large coefficients may be labelled incomplete. It is not a general-purpose numerical eigensolver. Cell input is capped at 32 characters to bound user-controlled computation.

### Features

- **Twelve topics** in four groups — elimination and systems (RREF, REF, `Ax = b`), matrix algebra (determinant, inverse, addition, multiplication), decomposition and spectra (rank-nullity, eigenvalues, LU), and visual practice (2D transformations, quiz).
- **Exact arithmetic** throughout. Rationals are stored as `BigInt` numerator and denominator; results are shown as fractions or decimals on demand.
- **Guided playback** driven by the visible animation rather than a background timer: pause, step forward and back, scrub inside an operation, replay, and scale speed from 0.25× to 4×.
- **Readable work.** Long exact expressions shrink to a 14 px floor and then scroll instead of truncating; the full calculation for any cell is one tap away.
- **Five languages** (English, Turkish, Simplified Chinese, Spanish, Russian), light and dark themes, adaptive layout from 320 px upwards, system text scaling and reduced-motion support.

### Requirements

A Flutter SDK satisfying the Dart constraint `^3.13.1` in `pubspec.yaml`. Validated against Flutter 3.47.1 / Dart 3.13.1.

### Installation

The engine is a separate package, so resolve both:

```sh
flutter pub get
cd packages/matrix_engine
dart pub get
cd ../..
flutter gen-l10n
```

### Usage

```sh
flutter run
```

Release builds:

```sh
flutter build web --release
flutter build windows --release
```

Serve `build/web` through any HTTP server. When distributing the Windows build, ship the whole `build/windows/x64/runner/Release` directory — the executable needs its DLLs and `data` folder.

Web, Windows and the test suites are the validated paths. Android, iOS, Linux and macOS targets are scaffolded but unverified here, Android release still uses the debug signing configuration, and the inspected Windows executable is unsigned.

### Configuration

Language, theme, accent palette, solution mode, default playback speed and player keyboard shortcuts live in the in-app Settings tab and persist locally through versioned preferences.

Translations are edited in all five `lib/l10n/app_*.arb` source files and regenerated with `flutter gen-l10n`. Never edit `lib/l10n/generated/` by hand.

### Contributing

[CONTRIBUTING.md](CONTRIBUTING.md) is the short version; [AGENTS.md](AGENTS.md) is the working contract: architecture boundaries, playback invariants, UI and accessibility rules, and the commands expected before delivery. Read it before changing the step player or the engine. Security reports go through [SECURITY.md](SECURITY.md), not a public issue.

```sh
flutter analyze
flutter test
cd packages/matrix_engine && dart analyze && dart test
```

An optional animation benchmark is excluded from the default suite:

```sh
flutter test tool/motion_benchmark_test.dart --reporter expanded
```

Start from the [documentation index](docs/README.md); [PROJECT_REVIEW.md](docs/PROJECT_REVIEW.md) records dated findings and [ROADMAP.md](docs/ROADMAP.md) lists proposed work, which is not implemented behaviour. Keep disposable logs and screenshots in the ignored `output/` directory.

### License

Apache License 2.0 — see [LICENSE](LICENSE). It grants use, modification and
redistribution, requires modified files to be marked, and includes an express
patent grant from every contributor.

Maintained by 𝓐.𝓒.𝓑.

[⬆ Back to top](#top)

---
<a id="turkce"></a>
## Türkçe

### Genel Bakış

**Tarayıcıda deneyin:** <https://iacbi.github.io/matriks/> — uygulamanın tamamı, kurulum gerekmez.

Matriks lineer cebiri işlemi göstererek öğretir. Gauss-Jordan eliminasyonundan özvektörlere kadar on iki konu, tam `BigInt` rasyonel aritmetiğiyle çözülür; kesir kesir kalır, kayan nokta gürültüsüne dönüşmez. Her çözüm adım adım oynatılır: bir hücreyi besleyen operandlar hücre değişirken vurgulanır, arkasındaki aritmetik sonrasında da ekranda durur.

Sonuçlar dürüstçe etiketlenir. Her çözüm bir doğruluk (tam ya da yaklaşık) ve bir kapsam (tamamlanmış, kısmi ya da desteklenmiyor) taşır; yaklaşık bir değer hiçbir zaman kesin sonuçmuş gibi sunulmaz.

Her şey cihazda çalışır. Arka uç, hesap sistemi veya uzak veri deposu yoktur; yalnızca sunum tercihleri saklanır, matrisler ve sınav geçmişi saklanmaz.

Güvenmeden önce sayısal sınırları bilin. İşlemlerin çoğu 1–5 boyutlarını kabul eder. Özdeğer analizi yalnızca 2×2 ve 3×3 kapsar: rasyonel kökler kesindir, irrasyonel kökler üç ondalığa yuvarlanır ve özvektörleri yaklaşıktır, karmaşık özdeğerler özvektörsüz raporlanır, çok büyük katsayılı 3×3 matrisler eksik olarak işaretlenebilir. Genel amaçlı bir sayısal özdeğer çözücüsü değildir. Kullanıcı kaynaklı hesaplamayı sınırlamak için hücre girdisi 32 karakterle sınırlıdır.

### Özellikler

- **On iki konu**, dört grup hâlinde — eliminasyon ve sistemler (RREF, REF, `Ax = b`), matris cebiri (determinant, ters, toplama, çarpma), ayrışım ve spektral teori (rank-sıfırlık, özdeğerler, LU) ve görsel alıştırma (2B dönüşümler, sınav).
- **Baştan sona tam aritmetik.** Rasyonel sayılar `BigInt` pay ve payda olarak tutulur; sonuçlar istendiğinde kesir ya da ondalık gösterilir.
- **Rehberli oynatma**, arka planda çalışan bir sayaçla değil görünen animasyonla ilerler: duraklatma, ileri/geri adım, işlem içinde gezinme, tekrar oynatma ve 0,25×–4× arası hız.
- **Okunabilir işlem.** Uzun tam ifadeler 14 px tabanına kadar küçülür, sonra kırpılmak yerine kaydırılır; herhangi bir hücrenin tam hesabı tek dokunuş uzaklıktadır.
- **Beş dil** (İngilizce, Türkçe, Basitleştirilmiş Çince, İspanyolca, Rusça), açık ve koyu tema, 320 px'ten itibaren uyarlanan yerleşim, sistem yazı ölçeği ve azaltılmış hareket desteği.

### Gereksinimler

`pubspec.yaml` içindeki `^3.13.1` Dart kısıtını karşılayan bir Flutter SDK. Flutter 3.47.1 / Dart 3.13.1 ile doğrulandı.

### Kurulum

Motor ayrı bir paket olduğu için ikisini de çözün:

```sh
flutter pub get
cd packages/matrix_engine
dart pub get
cd ../..
flutter gen-l10n
```

### Kullanım

```sh
flutter run
```

Yayın derlemeleri:

```sh
flutter build web --release
flutter build windows --release
```

`build/web` dizinini herhangi bir HTTP sunucusuyla yayınlayın. Windows derlemesini dağıtırken `build/windows/x64/runner/Release` dizininin tamamını gönderin — çalıştırılabilir dosya kendi DLL'lerine ve `data` klasörüne ihtiyaç duyar.

Doğrulanmış yollar web, Windows ve test paketleridir. Android, iOS, Linux ve macOS hedefleri hazır ama burada doğrulanmadı; Android yayın derlemesi hâlâ debug imzalama yapılandırmasını kullanıyor ve incelenen Windows çalıştırılabilir dosyası imzasız.

### Yapılandırma

Dil, tema, vurgu paleti, çözüm modu, varsayılan oynatma hızı ve oynatıcı klavye kısayolları uygulama içindeki Ayarlar sekmesinde yer alır ve sürümlenmiş tercihler aracılığıyla yerelde saklanır.

Çeviriler beş `lib/l10n/app_*.arb` kaynak dosyasının tamamında düzenlenir ve `flutter gen-l10n` ile yeniden üretilir. `lib/l10n/generated/` dizinini elle düzenlemeyin.

### Katkı

[CONTRIBUTING.md](CONTRIBUTING.md) kısa özettir; [AGENTS.md](AGENTS.md) çalışma sözleşmesidir: mimari sınırlar, oynatma değişmezleri, arayüz ve erişilebilirlik kuralları, teslimden önce beklenen komutlar. Step player'a veya motora dokunmadan önce okuyun. Güvenlik bildirimleri açık bir issue yerine [SECURITY.md](SECURITY.md) üzerinden iletilir.

```sh
flutter analyze
flutter test
cd packages/matrix_engine && dart analyze && dart test
```

Varsayılan paketin dışında tutulan isteğe bağlı bir animasyon benchmark'ı var:

```sh
flutter test tool/motion_benchmark_test.dart --reporter expanded
```

[Dokümantasyon dizininden](docs/README.md) başlayın; [PROJECT_REVIEW.md](docs/PROJECT_REVIEW.md) tarihli bulguları kaydeder, [ROADMAP.md](docs/ROADMAP.md) önerilen işleri listeler — bunlar uygulanmış davranış değildir. Atılabilir log ve ekran görüntülerini yoksayılan `output/` dizininde tutun.

### Lisans

Apache License 2.0 — bkz. [LICENSE](LICENSE). Kullanma, değiştirme ve yeniden
dağıtma hakkı verir, değiştirilen dosyaların işaretlenmesini şart koşar ve her
katkıcıdan açık bir patent hakkı devri içerir.

𝓐.𝓒.𝓑 tarafından sürdürülmektedir.

[⬆ Başa Dön](#top)
