# 04 — Çoklu Doğrusal Regresyon (Yönerge 2.2)

> Kod: `R/04_multiple_linear.R`
> Tablolar: `output/tables/04_table1_initial_model.csv` (Tablo 1), `04_table2_final_model.csv` (Tablo 2),
> `04_model_comparison.csv`, `04_revision_log.csv` (boş: hiç değişken çıkarılmadı)
> Veri: `data/clean_listings.csv` (16.303 ilan)
> Aşağıdakiler rapor paragrafı değil, kendi metnini yazman için taslak notlardır.

## Step 1 — Başlangıç modeli

### Değişkenler
- **Y:** `price` (TL).
- **Sayısal X (5):** `accommodates`, `bedrooms`, `bathrooms`, `number_of_reviews`, `availability_365`.
- **İki kategorili X (2):** `host_is_superhost`, `shared_bath`.
- **3+ kategorili X (1):** `room_type` (4 kategori).
- Yönerge şartı (≥2 sayısal, ≥1 iki kategorili, ≥1 üç+ kategorili) sağlanıyor ✔

### Referans kategoriler (factor'e çevrildi)
- `host_is_superhost` → **No** (= FALSE, superhost değil). Veride "No/Yes" olarak kodlu; "No" = FALSE.
- `shared_bath` → **No** (= Hayır, özel banyo).
- `room_type` → **Entire home/apt**.
- Ne demek: R her kategorik değişken için referans dışındaki her kategoriye bir kukla (0/1) değişken açar.
  Katsayılar **referans kategoriye göre fark** olarak okunur. Referansın kendi katsayısı yok (sabit terime gömülü).
  - Bu yüzden 8 değişken ama 10 katsayı (+ sabit) var: room_type 3 kukla, diğer iki kategorik 1'er kukla.

### Sonuçlar (Tablo 1)

| Terim | B | SE | t | p |
|---|---:|---:|---:|---:|
| (Sabit) | 254,31 | 110,67 | 2,30 | 0,022 |
| accommodates | 373,97 | 22,03 | 16,98 | < 0,001 |
| bedrooms | 1.267,08 | 54,93 | 23,07 | < 0,001 |
| bathrooms | 1.379,35 | 66,31 | 20,80 | < 0,001 |
| number_of_reviews | −4,26 | 0,46 | −9,22 | < 0,001 |
| availability_365 | 1,36 | 0,27 | 4,97 | < 0,001 |
| host_is_superhost: Yes | 1.054,27 | 59,66 | 17,67 | < 0,001 |
| shared_bath: Yes | −859,04 | 158,84 | −5,41 | < 0,001 |
| room_type: Private room | −119,10 | 70,17 | −1,70 | 0,090 |
| room_type: Hotel room | 4.455,75 | 233,26 | 19,10 | < 0,001 |
| room_type: Shared room | 482,37 | 349,09 | 1,38 | 0,167 |
| **room_type (bütün olarak)** | F = 128,33 (df = 3) | | | **< 0,001** |

- **Genel F testi:** F(10; 16.292) = 972,21, p < 0,001 → model anlamlı (en az bir X fiyatı açıklıyor).
  - df1 = 10 → katsayı sayısı (sabit hariç); df2 = 16.303 − 11.
- **R² = 0,3737**, **düzeltilmiş R² = 0,3733**.

### room_type'ın bütün olarak anlamlılığı (car::Anova)
- Tek tek kuklalara bakınca: Private room (p = 0,090) ve Shared room (p = 0,167) **anlamsız**, Hotel room anlamlı.
- Ama yönerge 2.2 Step 2: 3+ kategorili değişken **bütün olarak** değerlendirilmeli, tek tek kuklalara göre değil.
- `car::Anova` (Type II) room_type'ın 3 kuklasını **birlikte** test ediyor (kısmi F testi):
  - H₀: room_type'ın hiçbir kategorisi fiyatı etkilemiyor (3 katsayının hepsi 0).
  - **F(3; 16.292) = 128,33, p < 0,001** → H₀ reddedilir → **room_type bütün olarak anlamlı → modelde kalır**.
- Raporda açıklanacak nokta: "Private room ve Shared room kuklaları tek başına anlamlı olmasa da, room_type değişkeni
  bütün olarak anlamlı olduğu için modelden çıkarılmadı."
- **Tablo 2'nin altındaki not** (`T/04_table2_final_model.csv` son satırı, script otomatik üretiyor):
  *"Note: room_type is significant as a whole (car::Anova partial F test: F(3, 16292) = 128.33, p < 0.001). Private room and
  Shared room are not significant on their own, but a multicategory variable is judged as a whole (Guideline 2.2 Step 2),
  so room_type is kept with all its categories."* → Raporda kendi ifadenle Tablo 2'nin altına yaz.
- Diğer 7 değişken tek dereceli (df = 1) olduğu için Anova p'si t testinin p'siyle aynı.

### Anlamlı / anlamsız değişkenler
- **Anlamlı (p < 0,05):** 8 değişkenin hepsi → accommodates, bedrooms, bathrooms, number_of_reviews, availability_365,
  host_is_superhost, shared_bath, room_type.
- **Anlamsız:** yok. (Sadece room_type'ın iki kuklası tek başına anlamsız; değişken bütün olarak anlamlı.)

## Step 2 — Revizyon

- Kural: p ≥ 0,05 olan değişkenleri en yüksek p'den başlayarak birer birer çıkar.
- **Başlangıç modelinde anlamsız değişken yok → hiçbir değişken çıkarılmadı.**
- **Son model = başlangıç modeli.** (Kod döngüyü yine de çalıştırıyor ve bunu açıkça yazdırıyor.)
- Neden hepsi anlamlı çıktı? (yorum fikri)
  - 16.303 gözlem çok büyük bir örneklem → standart hatalar çok küçük → küçük etkiler bile anlamlı çıkıyor.
  - Bu yüzden anlamlılığın yanında **etkinin büyüklüğüne** de bakmak gerekiyor: ör. availability_365 anlamlı ama
    etkisi küçük (günde 1,36 TL; 100 gün fark = 136 TL).

## Step 3 — Son model

- **Denklem** (kuklalar ilgili kategori için 1, değilse 0):

  Tahmini fiyat = 254,31 + 373,97·accommodates + 1.267,08·bedrooms + 1.379,35·bathrooms
  − 4,26·number_of_reviews + 1,36·availability_365 + 1.054,27·Superhost(Yes)
  − 859,04·SharedBath(Yes) − 119,10·PrivateRoom + 4.455,75·HotelRoom + 482,37·SharedRoom

- **F testi:** F(10; 16.292) = 972,21, p < 0,001 → son model anlamlı.
- **R² = 0,3737** → fiyattaki değişkenliğin **%37,4'ü** açıklanıyor.
- **Düzeltilmiş R² = 0,3733** → R²'ye çok yakın; değişkenler gerçekten katkı sağlıyor (gereksiz değişken cezası yok denecek kadar az).
- **Başlangıç modelinden farkı:** fark yok (aynı model). Değişken çıkarılmadığı için R² ve düzeltilmiş R² aynı kaldı.
- **Basit regresyonla (2.1) karşılaştırma** (açıklama gücündeki değişim için kullanılabilir):
  - R²: 0,2829 → 0,3737 → yaklaşık **9 puan artış**. Ek değişkenler fiyatı açıklamaya anlamlı katkı sağladı.
  - Artık standart hatası: 3.668 → 3.429 TL → tahmin hatası biraz azaldı.
  - Hâlâ %62,6 açıklanamıyor → konum, ev kalitesi, sezon gibi modelde olmayan etkenler.

## Special Rule kontrolü
- Son modelde **hem sayısal (5) hem kategorik (3) değişken var** → yönergeye göre son modelden **en az bir sayısal ve
  bir kategorik katsayı** yorumlanacak. Başlangıç modelinden anlamsız katsayı yorumlamaya gerek yok.

## Katsayıların yorumu

> Çoklu regresyonda her katsayı **"diğer değişkenler sabitken"** yorumlanır. Bu ifade şart.

### Sayısal katsayılar (nasıl okunur: "X 1 birim artınca, diğerleri sabitken, fiyat ortalama B TL değişir")
- **bedrooms (B = 1.267,08):** Diğer değişkenler sabitken, **1 ek yatak odası** gecelik fiyatı ortalama **1.267 TL artırıyor**.
- **bathrooms (B = 1.379,35):** Diğer değişkenler sabitken, **1 ek banyo** fiyatı ortalama **1.379 TL artırıyor**
  (yarım banyo ≈ 690 TL).
- **accommodates (B = 373,97):** Diğer değişkenler sabitken, **1 kişilik ek kapasite** fiyatı ortalama **374 TL artırıyor**.
  - Basit regresyonda 1.049 TL idi. Neden düştü? Kişi kapasitesi yatak odası ve banyo sayısıyla birlikte artıyor;
    basit modelde bu değişkenlerin etkisi de accommodates'a yükleniyordu. Çoklu modelde etkiler ayrıştırıldı →
    "aynı yatak odası ve banyo sayısında, sadece kapasite 1 artarsa" etkisi 374 TL.
- **number_of_reviews (B = −4,26):** Diğer değişkenler sabitken, **her ek yorum** fiyatı ortalama **4,26 TL azaltıyor**
  (100 yorum ≈ 426 TL daha ucuz).
  - Olası açıklama: çok yorum alan ilanlar daha çok kiralanan, daha uygun fiyatlı ilanlar olabilir (nedensellik değil, ilişki).
- **availability_365 (B = 1,36):** Diğer değişkenler sabitken, yılda **1 gün daha fazla müsait** olmak fiyatı ortalama
  **1,36 TL artırıyor**. Anlamlı ama pratikte küçük bir etki.

### Kategorik katsayılar (nasıl okunur: "bu kategori, referansa göre, diğerleri sabitken ortalama B TL daha pahalı/ucuz")
- **host_is_superhost = Yes (B = 1.054,27):** Superhost olan ev sahiplerinin ilanları, superhost olmayanlara (referans) göre,
  diğer değişkenler sabitken ortalama **1.054 TL daha pahalı**.
- **shared_bath = Yes (B = −859,04):** Paylaşımlı banyolu ilanlar, özel banyolu ilanlara (referans) göre, diğer değişkenler
  sabitken ortalama **859 TL daha ucuz**.
- **room_type** (referans = Entire home/apt):
  - **Hotel room (B = 4.455,75, p < 0,001):** Otel odaları, aynı kapasite/oda/banyo sayısındaki bütün ev/dairelere göre
    ortalama **4.456 TL daha pahalı**.
  - **Private room (B = −119,10, p = 0,090):** Tek başına **anlamlı değil** → diğer değişkenler sabitken özel odaların
    fiyatı bütün ev/dairelerden istatistiksel olarak farklı değil. (Ham ortalamada özel odalar çok daha ucuz: 4.256 TL vs 6.156 TL — `R/04` Step 3'teki "Mean price by room type" tablosu;
    özel odaların ortalama yatak odası sayısı da 1,04 vs 1,58. Bu fark
    büyük ölçüde daha az yatak odası/banyo/kapasiteden geliyor ve model bunu zaten bu değişkenlerle açıklıyor.)
  - **Shared room (B = 482,37, p = 0,167):** Tek başına **anlamlı değil**; ayrıca sadece 126 ilan var → tahmin belirsiz (SE = 349).
- **Sabit terim (B₀ = 254,31):** bütün sayısal değişkenler 0 ve bütün kategoriler referansta olduğunda tahmini fiyat.
  0 kişilik ilan olmadığı için pratik anlamı yok.

## Rapor için "Explain" maddeleri (yönerge 2.2 Required Reporting)
- **Hangi değişkenler çıkarıldı?** Hiçbiri.
- **Neden?** Başlangıç modelindeki bütün değişkenler %5 düzeyinde anlamlı (room_type bütün olarak).
- **Hangileri anlamlı kaldı?** 8 değişkenin hepsi.
- **Sayısal ve kategorik katsayılar nasıl yorumlanır?** Yukarıdaki iki bölüm (bedrooms + superhost en net örnekler).
- **Açıklama gücü nasıl değişti?** Başlangıç → son: değişmedi (R² 0,3737). Basit regresyona göre: 0,2829 → 0,3737.
