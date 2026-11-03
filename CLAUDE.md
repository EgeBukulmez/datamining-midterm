# Data Mining Vize Projesi — Claude Code Talimatları

Bu klasör, Haliç Üniversitesi Data Mining dersi 2026-2027 Güz vize projesi içindir.
Kullanıcıyla **Türkçe** konuş. Kod, değişken adları ve R yorumları İngilizce olabilir.

## 1. TEK KAYNAK: HOCA_YONERGE.md

- Projenin bütün gereksinimleri `HOCA_YONERGE.md` dosyasındadır (hocanın orijinal yönergesi, birebir).
- **Yönergenin dışına çıkma.** Yönergede istenmeyen hiçbir analiz, model, test, grafik veya bölüm ekleme.
  - YAPMA: train/test ayırma, çapraz doğrulama, ROC/AUC, VIF raporu, karar ağacı, random forest,
    stepwise AIC, etkileşim terimleri, korelasyon ısı haritası, histogram yığını, ekstra "bonus" analizler.
  - Bir şeyin istenip istenmediğinden emin değilsen: **yapma, kullanıcıya sor.**
- Yönergede istenen her şeyi eksiksiz yap. Her adımda yönergedeki ilgili maddenin numarasını belirt
  (örn. "Bu, yönerge 2.2 Step 2'yi karşılıyor").
- Yönerge ile bu dosya çelişirse **yönerge kazanır.**

## 2. Çalışma şekli

- **Küçük adımlarla ilerle.** Her prompt yalnızca bir aşamayı kapsar. Sonraki aşamaya kullanıcı istemeden geçme.
- Her aşamanın sonunda kullanıcıya Türkçe ve kısa şunları ver:
  1. Ne yaptın, hangi yönerge maddesini karşıladın.
  2. Önemli çıktılar (sayılar, tablolar).
  3. Kullanıcının vermesi gereken kararlar (varsa) — **kararı kendin verme, seçenekleri ve gerekçelerini sun.**
- Kullanıcı her kod bloğunu anlamak istiyor: koda kısa, açıklayıcı yorumlar ekle.
- Rapor metnini (Giriş, yorumlar, Sonuç) kullanıcı kendi cümleleriyle yazacak.
  Sen her aşamada `notlar/` klasörüne **madde madde Türkçe yorum notları** yaz
  (katsayı ne demek, p-değeri ne gösteriyor vb.). Bunlar kullanıcının anlaması ve kendi metnini yazması için taslak notlardır,
  hazır rapor paragrafı değil.

## 3. Teknik kurallar

- Analizler **RStudio**'da çalıştırılacak (yönerge şartı). Kodu `.R` dosyaları olarak yaz;
  kullanıcı RStudio'da çalıştıracak. Kontrol için `Rscript` ile kendin de çalıştırabilirsin.
- R kurulu değilse dur ve kullanıcıya söyle; R'ı kendin kurmaya çalışma.
- Sadece şu paketler: `tidyverse` (readr, dplyr, ggplot2, stringr), `ResourceSelection` (Hosmer–Lemeshow),
  `DescTools` (pseudo R²), `car` (kategorik değişkenin bütün olarak anlamlılığı için `Anova`).
  Başka paket gerekiyorsa önce kullanıcıya sor.
- Modeller: doğrusal → `lm()`, lojistik → `glm(..., family = binomial)`.
- `set.seed()` gerekmez (rastgelelik yok). Rastgele örnekleme yapma.
- Bütün bölümler **aynı temizlenmiş veri setini** kullanır: `data/clean_listings.csv`.

## 4. Klasör yapısı

```
proje/
├── HOCA_YONERGE.md        # hocanın yönergesi (değiştirme)
├── CLAUDE.md              # bu dosya
├── PROMPTLAR.md           # kullanıcının sırayla vereceği promptlar
├── data/
│   ├── listings.csv.gz    # ham veri (değiştirme)
│   └── clean_listings.csv # 1. bölümün çıktısı
├── R/
│   ├── 01_import_explore.R
│   ├── 02_cleaning.R
│   ├── 03_simple_linear.R
│   ├── 04_multiple_linear.R
│   ├── 05_logistic_models.R
│   └── 06_logistic_evaluation.R
├── output/
│   ├── tables/            # rapora girecek tablolar (.csv)
│   └── figures/           # grafikler (.png)
└── notlar/                # her aşama için Türkçe yorum notları (.md)
```

Ham veriyi (`data/listings.csv.gz`) asla değiştirme; bütün düzeltmeler R kodunda yapılır.

## 5. Veri seti (kararlaştırıldı)

- **Kaynak:** Inside Airbnb — Istanbul, Marmara, Turkey, `listings.csv.gz` (Detailed Listings data),
  **25 Eylül 2026 tarihli veri yayını (veri toplama: 28–29 Eylül 2026)**. https://insideairbnb.com/get-the-data/ — Creative Commons lisanslı.
- **Ham boyut:** 27.232 satır, 90 sütun. `read_csv()` .gz dosyasını doğrudan okuyabilir.
- **Sayısal bağımlı değişken (Y):** `price` (gecelik fiyat; değerler TL olmasına rağmen `$3,000.00` biçiminde metin).

### Ön incelemede görülen sorunlar (1.3'te kullanıcıya kendi kodunla tekrar göster, buraya güvenme — doğrula)
- `price` metin (`$` ve virgül) → sayıya çevrilmeli; ~2.679 eksik.
- `price` aşırı uç değerler (maks ~4.99 milyon; %99'luk dilim ~38 bin). Uç değer kuralı **kullanıcının kararı**.
- `minimum_nights` = 100 olan ~9.087 ilan (aylık kiralık olabilir). Ne yapılacağı **kullanıcının kararı**.
- `bathrooms` tamamen boş; banyo bilgisi `bathrooms_text` içinde metin (`"1 shared bath"`, `"1.5 baths"`).
- `host_is_superhost`, `host_identity_verified`: `"t"/"f"` metin.
- `review_scores_rating`, `reviews_per_month`: ~9.661 eksik (hiç yorum almamış ilanlar).
- `instant_bookable`, `host_since`, `host_response_rate`, `bathrooms`: tamamen boş → çıkarılmalı.
- `room_type`: 4 kategori; "Hotel room" (~272) ve "Shared room" (~158) az.
- `neighbourhood_cleansed`: 39 ilçe — doğrudan kullanmak yerine gruplama gerekebilir (**kullanıcının kararı**).

### Aday değişkenler (kesin seçim kullanıcıda)
- Sayısal X: `accommodates`, `bedrooms`, `beds`, banyo sayısı (`bathrooms_text`'ten), `number_of_reviews`,
  `review_scores_rating`, `minimum_nights`, `availability_365`.
- İki kategorili X: `host_is_superhost` (ana aday); `bathrooms_text`'ten türetilen paylaşımlı banyo (ops.).
- 3+ kategorili X: `room_type` (ana aday), gruplanmış ilçe (ops.).
- İkili Y: ör. `high_price` = 1 eğer `price` > medyan, değilse 0. Eşik ve gerekçe **kullanıcının kararı**.
- Y için `log(price)` kullanılıp kullanılmayacağı **kullanıcının kararı** (fiyat dağılımı çok çarpık).

## 6. Yönergeden kritik noktalar (kontrol listesi)

- Aynı veri seti ve aynı temel Y tüm projede. Doğrusal regresyonda sayısal Y, lojistikte ondan türetilen 0/1 Y.
- **Orijinal `price` (veya log'u) lojistik modellerde bağımsız değişken olarak ASLA kullanılmaz.**
- Ham veri incelemesi tam olarak: `head()`, `dim()`, `str()`, `summary()` (1.3). Son kontrol: `str()`, `summary()`, `dim()` (1.6).
- 1.5: ikili değişkenin her kategorisindeki sayı ve yüzde raporlanır + doğru oluşturulduğu doğrulanır.
- 2.1: tablo = B, SE, t, p, F ve p'si, R², düzeltilmiş R² + denklem + en az bir tahmin örneği.
- 2.2 başlangıç modeli: ≥2 sayısal + ≥1 iki kategorili + ≥1 üç+ kategorili X. Referans kategoriler belirtilir.
- 2.2 revizyon: anlamsız değişkenleri çıkar, yeniden kur, tümü anlamlı olana kadar devam et.
  3+ kategorili değişkenin anlamlılığı **bütün olarak** değerlendirilir (`car::Anova` veya `anova()` ile kısmi F testi).
  Çıkarma işlemini **birer birer** (en yüksek p'li değişkenden) yap ve her adımı kaydet.
- 2.2 özel kural: son modelde yalnızca bir tür X kalırsa, diğer türden bir katsayı başlangıç modelinden yorumlanır
  ve anlamlı olmadığı açıkça belirtilir.
- Tablo 1 (başlangıç modeli) ve Tablo 2 (son model) ayrı ayrı üretilir.
- Lojistik: 4 model (1: tek sayısal, 2: tek iki kategorili, 3: tek 3+ kategorili, 4: karma). Hepsinde B, Exp(B), anlamlılık.
- Model 1 için ayrıca: denklem, tahmini olasılıklar, olasılık eğrisi.
- 4.1 her model için: Hosmer–Lemeshow, McFadden, Cox & Snell, Nagelkerke. Pseudo R², doğrusal R² gibi yorumlanmaz.
- 4.2 her model için: 0.50 eşiği, karışıklık matrisi (TN, FP, FN, TP — yönergedeki tablo düzeniyle), accuracy;
  ikili Y'nin dağılımı (sınıf dengesi) göz önünde tutularak yorum.
- 4.3: 4 modelin her biri için olasılık grafiği. X ekseni bağımsız değişken(ler), Y ekseni tahmini olasılık.
  Kategorik modellerde (Model 2, 3) kategori bazında tahmini olasılık gösterilir; Model 4'te sayısal değişken X ekseninde,
  kategoriler ayrı eğriler olarak.
- Rapor bölüm yapısı yönerge Part 5'teki gibi; Ek'te bütün R kodları.
