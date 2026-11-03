# 03 — Basit Doğrusal Regresyon (Yönerge 2.1)

> Kod: `R/03_simple_linear.R` · Tablo: `output/tables/03_simple_linear.csv`
> Tahmin örnekleri: `output/tables/03_simple_linear_predictions.csv`
> Veri: `data/clean_listings.csv` (16.303 ilan)
> Aşağıdakiler rapor paragrafı değil, kendi metnini yazman için taslak notlardır.

## Sonuç tablosu (özet)

| | B | Std. hata | t | p |
|---|---:|---:|---:|---:|
| (Sabit) | 1.789,30 | 56,38 | 31,74 | < 0,001 |
| accommodates | 1.049,31 | 13,08 | 80,20 | < 0,001 |

- F(1; 16.301) = 6.431,74 · p < 0,001
- R² = 0,2829 · Düzeltilmiş R² = 0,2829
- Artıkların standart hatası (residual standard error) = 3.668 TL

## Madde 1 — Bağımlı ve bağımsız değişken
- **Bağımlı (Y):** `price`, ilanın gecelik fiyatı (TL), sayısal.
- **Bağımsız (X):** `accommodates`, ilanın ağırlayabileceği en fazla misafir sayısı, sayısal (1–16).

## Madde 2 — Neden bu değişkenler (kendi cümlelerinle yazmak için fikirler)
- `price`: projenin bütününde kullanılan sayısal bağımlı değişken (yönerge aynı Y'yi şart koşuyor).
- `accommodates`:
  - Fiyatı belirleyen en temel özellik → büyük ev / daha çok kişi = daha yüksek fiyat beklentisi (sezgisel, teorik gerekçe).
  - Eksik değeri hiç yok, ham veride de tamamen doluydu → temiz, güvenilir bir değişken.
  - Fiyatla korelasyonu **r = 0,5319** (orta-güçlü pozitif ilişki; `R/03` Item 2 bölümünde hesaplanıyor).
    - Basit regresyonda R² = r² → 0,5319² = 0,2829 (Madde 8'deki R² ile aynı).
  - Medyan fiyat kişi sayısıyla düzenli artıyor: 1 kişi 2.040 TL, 2 kişi 3.100, 4 kişi 5.016, 6 kişi 7.245 TL
    (`R/03` "Median price by accommodates" tablosu; 9–10 ve 15–16 kişide küçük düşüşler var, o gruplarda ilan az).

## Madde 3 — Model
- R kodu: `lm(price ~ accommodates, data = listings)`
- Matematiksel model: **price = β₀ + β₁ · accommodates + ε**
- `lm()` en küçük kareler (OLS) yöntemiyle, tahmin hatalarının kareleri toplamını en küçük yapan doğruyu bulur.

## Madde 4 — Modelin genel anlamlılığı (F testi)
- H₀: model fiyatı açıklamıyor (β₁ = 0). H₁: model fiyatı açıklıyor (β₁ ≠ 0).
- **F = 6.431,74**, serbestlik dereceleri (1; 16.301), **p < 0,001**.
  - df1 = 1 → modeldeki bağımsız değişken sayısı.
  - df2 = 16.301 → gözlem sayısı − tahmin edilen parametre sayısı (16.303 − 2).
- p < 0,05 → H₀ reddedilir → **model istatistiksel olarak anlamlı**.
- F değeri ne demek: modelin açıkladığı varyans, açıklayamadığı varyansın kaç katı (ortalama kareler oranı). Çok büyük → model,
  "hiç değişken yok" modelinden çok daha iyi.
- Not: basit regresyonda tek X olduğu için F testi ile X'in t testi aynı hipotezi test eder; F = t² (80,20² ≈ 6.432).

## Madde 5 — accommodates'ın anlamlılığı (t testi)
- H₀: β₁ = 0 (kişi sayısının fiyata etkisi yok). H₁: β₁ ≠ 0.
- **t = 80,20**, **p < 0,001** → H₀ reddedilir → `accommodates` **anlamlı**.
- t değeri = B / standart hata = 1.049,31 / 13,08. Katsayının sıfırdan kaç standart hata uzakta olduğunu gösterir.
  ±1,96'dan büyükse %5 düzeyinde anlamlı; 80 çok büyük.
- R çıktısında p `<2e-16` görünüyor = R'ın gösterebileceğinden küçük. Raporda **"p < 0,001"** yaz, "p = 0" yazma.
- Standart hata (13,08): B'nin tahminindeki belirsizlik. B'ye göre çok küçük → katsayı çok kesin tahmin edilmiş
  (büyük örneklem sayesinde).

## Madde 6 — B katsayısının yorumu
- **B₁ = 1.049,31:** kapasite **1 kişi arttığında** gecelik fiyat **ortalama ~1.049 TL artıyor**.
  - Pozitif işaret → doğru yönlü ilişki (beklentiyle uyumlu).
  - "Ortalama" ve "ilişkili" kelimeleri önemli: bu bir ortalama eğilim; tek tek her ilan için geçerli değil ve
    nedensellik iddiası değil.
- **B₀ = 1.789,30 (sabit terim):** accommodates = 0 olduğunda tahmini fiyat. 0 kişilik ilan olmadığı için
  **pratik bir anlamı yok**; sadece doğrunun y eksenini kestiği nokta.

## Madde 7 — Tahmini regresyon denklemi
- **Tahmini fiyat = 1.789,30 + 1.049,31 × accommodates**

## Madde 8 — R² ve düzeltilmiş R²
- **R² = 0,2829** → fiyattaki değişkenliğin (varyansın) **%28,3'ü** sadece kişi kapasitesiyle açıklanıyor.
  - Geri kalan **%71,7** modelde olmayan etkenlerden geliyor (konum/ilçe, oda tipi, ev kalitesi, manzara, sezon vb.).
  - Tek değişkenli bir model ve gerçek fiyat verisi için makul bir değer; ama tek başına fiyatı iyi tahmin etmeye yetmez.
- **Düzeltilmiş R² = 0,2829** → R²'yi değişken sayısına göre cezalandırır. Tek X ve 16.303 gözlem olduğu için
  R² ile neredeyse aynı (0,28293 vs 0,28288).
  - Fark çoklu regresyonda (2.2) önem kazanacak: değişken ekleyince R² hep artar, düzeltilmiş R² ise
    sadece değişken gerçekten katkı sağlıyorsa artar.
- Artıkların standart hatası 3.668 TL → tahminler gerçek fiyattan tipik olarak ±3.700 TL kadar sapıyor
  (ortalama fiyat 5.680 TL düşünülürse büyük bir hata payı → R²'nin orta düzeyde olmasıyla uyumlu).

## Madde 9 — Tahmin değerleri
- Her ilan için tahmin: `predict(model_slr)` → `predicted_price` sütunu (koddaki ilk 6 satır gerçek vs tahmin gösteriyor).
  - Örn. 12 kişilik bir ilanın gerçek fiyatı 33.791 TL, tahmin 14.381 TL → model pahalı/lüks ilanları düşük tahmin ediyor.
- **Tahmin örnekleri** (yeni ilanlar için):

  | accommodates | Tahmini fiyat |
  |---:|---:|
  | 2 kişi | **3.887,92 TL** |
  | 4 kişi | **5.986,55 TL** |

  - Hesap: 1.789,30 + 1.049,31 × 2 = 3.887,92 · 1.789,30 + 1.049,31 × 4 = 5.986,55.
  - İki tahmin arasındaki fark (2.098,62 TL) = 2 × B₁ → B'nin yorumunu doğruluyor.
  - Karşılaştırma için gerçek medyanlar: 2 kişi ~3.100 TL, 4 kişi ~5.016 TL → tahminler biraz yüksek, çünkü ortalama
    tabanlı model sağa çarpık fiyatlardan (pahalı ilanlardan) etkileniyor.
- Tahminleri veri aralığının (1–16 kişi) dışına taşımamak gerekir (ör. 30 kişilik ilan için tahmin güvenilmez).

## Madde 10 — Bulguların genel yorumu (fikirler)
- Kişi kapasitesi fiyatın **anlamlı ve pozitif** bir belirleyicisi: her ek kişi ~1.049 TL.
- Model istatistiksel olarak çok anlamlı (F ve t testleri p < 0,001), ama **açıklama gücü orta düzeyde** (R² ≈ %28).
- Büyük örneklemde çok küçük etkiler bile anlamlı çıkabilir; bu yüzden anlamlılıkla birlikte etkinin
  **büyüklüğüne** (B) ve **R²**'ye de bakmak gerekir. Burada etki hem anlamlı hem de pratikte büyük.
- Fiyatın geri kalan değişkenliği için başka değişkenlere ihtiyaç var → çoklu regresyona (2.2) geçiş gerekçesi olarak kullanılabilir.
