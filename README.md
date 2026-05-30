# AURA.POS // Masa Yönetim Sistemi

AURA.POS, kafe ve restoranlar için özel olarak tasarlanmış, modern, şık ve tablet uyumlu bir masa yönetim ve POS (Point of Sale) uygulamasıdır. Cyberpunk esintili görsel tasarımı, neon renk paletleri ve glassmorphic kart arayüzleri ile kullanıcılara premium bir deneyim sunar.

---

## 🚀 Temel Özellikler

*   **Dinamik Masa Takibi:** 16 masanın doluluk, sipariş adedi ve hesap durumunu anlık olarak ana ekrandan takip edin.
*   **Detaylı Sipariş Yönetimi:** Masaların içerisine girerek özel sipariş notları (örn: *Çay, Tost, Filtre Kahve*) ve fiyat bilgisi ile sipariş ekleyin veya silin.
*   **Hızlı Tutar Ekleme:** Sık kullanılan tutarlar (`+₺10`, `+₺20`, `+₺50`, `+₺100`, `+₺200`) için hızlı seçim butonları ile sipariş girişini hızlandırın.
*   **Hesap Kapatma ve Ciro Takibi:** Ana ekranda anlık aktif ciro takibi yapın ve hesabı tahsil edilen masaları tek tıkla sıfırlayarak kapatın.
*   **Yerel Veri Saklama (Persistence):** Sipariş ve masa verileri `Path Provider` aracılığıyla otomatik olarak JSON formatında cihaz hafızasına (`tables_data.json`) kaydedilir. Uygulama kapatılıp açılsa dahi verileriniz kaybolmaz.
*   **Neon & Cyberpunk Tema:** Koyu arka plan üzerinde Cyan (`#00F2FE`) ve Magenta (`#EC008C`) neon vurgularla tasarlanmış göz yormayan, modern görsel arayüz.

---

## 🛠️ Kullanılan Teknolojiler

*   **Framework:** [Flutter](https://flutter.dev) (Dart SDK `^3.7.0`)
*   **Veri Depolama:** `path_provider` (JSON Serialization & File I/O)
*   **UI/UX:** Custom Material Design (Dark Theme, Glassmorphism, Neon Glow & Subtle Aura)

---

## 📦 Kurulum ve Çalıştırma

Projeyi yerel bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyin:

### 1. Gereksinimler
*   Bilgisayarınızda Flutter SDK kurulu olmalıdır. ([Flutter Kurulum Rehberi](https://docs.flutter.dev/get-started/install))
*   Android Studio, VS Code veya benzeri bir IDE.

### 2. Projeyi Klonlayın
```bash
git clone https://github.com/KULLANICI_ADINIZ/auropos.git
cd auropos
```

### 3. Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### 4. Uygulamayı Başlatın
```bash
flutter run
```

---

## 📂 Proje Yapısı

```text
lib/
└── main.dart         # Uygulamanın tüm UI, state yönetimi ve veri modellerini barındıran ana dosya.
android/              # Android platformuna özgü yapılandırmalar (Gradle, Manifest vb.).
ios/                  # iOS platformuna özgü yapılandırmalar.
web/                  # Web platformu yapılandırması.
```

---

## 📄 Lisans

Bu proje **MIT Lisansı** ile lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına göz atabilirsiniz.
