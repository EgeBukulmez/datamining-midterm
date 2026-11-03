# 05 — İkili Lojistik Regresyon: Model 1–4 (Yönerge 3.1–3.4)

> Kod: `R/05_logistic_models.R`
> Tablolar: `output/tables/05_model1.csv` … `05_model4.csv`, `05_model1_predicted_probabilities.csv`
> Modeller: `output/05_logistic_models.rds` (Prompt 7'deki değerlendirme scripti tekrar kullanacak)
> Bağımlı değişken: `high_price` (1 = fiyat > 4.457,5 TL; 0 = değil) · 16.303 ilan · 8.141 tane 1, 8.162 tane 0
> `price` hiçbir modelde bağımsız değişken olarak kullanılmadı.
> Uyum iyiliği (Hosmer–Lemeshow, pseudo R²), karışıklık matrisi/accuracy ve grafikler → Prompt 7 (Part 4).
> Aşağıdakiler rapor paragrafı değil, kendi metnini yazman için taslak notlardır.

## Önce temel: olasılık, odds, log-odds ve Exp(B)

| Kavram | Tanım | Aralık | Örnek |
|---|---|---|---|
| **Olasılık (p)** | Olayın gerçekleşme şansı | 0 – 1 | p = 0,75 → %75 ihtimalle yüksek fiyatlı |
| **Odds** | p / (1 − p) = gerçekleşme / gerçekleşmeme | 0 – ∞ | p = 0,75 → odds = 0,75/0,25 = **3** ("3'e 1") |
| **Log-odds (logit)** | ln(odds) | −∞ – +∞ | ln(3) = 1,10 |
| **Exp(B) (odds oranı)** | İki durumun odds'larının oranı | 0 – ∞ | Exp(B) = 2 → odds **2 katına** çıkar |

- Lojistik model doğrudan olasılığı değil, **log-odds**'u doğrusal modeller:
  **ln[p / (1 − p)] = β₀ + β₁X₁ + …**
- **B** → X 1 birim artınca **log-odds**'taki değişim. Doğrudan yorumlamak zor; sadece **işareti** sezgisel
  (B > 0 → yüksek fiyat ihtimali artar, B < 0 → azalır).
- **Exp(B)** → X 1 birim artınca **odds'un kaç katına çıktığı** (çarpımsal etki).
  - Exp(B) > 1 → odds artar; **(Exp(B) − 1) × 100** = % artış.
  - Exp(B) < 1 → odds azalır; **(1 − Exp(B)) × 100** = % azalış.
  - Exp(B) = 1 → etki yok (B = 0 ile aynı şey).

### ⚠️ Odds ≠ olasılık (en sık yapılan hata)
- "Exp(B) = 1,97 → olasılık 1,97 kat artar" **YANLIŞ**. Doğrusu: "**odds** 1,97 kat artar".
- Olasılık 1'i geçemez; odds geçebilir. Odds'u ikiye katlamak olasılığı ikiye katlamaz:
  - p = 0,27 (odds 0,37) → odds ×1,97 → odds 0,73 → p = 0,42 (olasılık 1,56 kat arttı, 1,97 değil).
  - p = 0,85 (odds 5,58) → odds ×1,97 → odds 11,0 → p = 0,92 (olasılık sadece 1,08 kat arttı).
- Yani **Exp(B) sabittir** (her X değerinde aynı oran), ama **olasılıktaki değişim X'in nerede olduğuna bağlıdır**
  (S şeklindeki eğri; ortada hızlı, uçlarda yavaş değişir). Model 1'deki örnekler bunu gösteriyor (aşağıda).
- **Wald z testi** (tablodaki z): z = B / SE; doğrusal regresyondaki t testinin lojistikteki karşılığı. |z| > 1,96 → %5'te anlamlı.

---

## Model 1 — Tek sayısal X: accommodates (Yönerge 3.1)

| | B | SE | z | p | Exp(B) |
|---|---:|---:|---:|---:|---:|
| (Sabit) | −2,3503 | 0,0470 | −50,02 | < 0,001 | 0,0953 |
| accommodates | **0,6782** | 0,0134 | 50,64 | < 0,001 | **1,9704** |

- **Madde 2 – Anlamlılık:** z = 50,64, p < 0,001 → accommodates **anlamlı**.
- **Madde 3 – B:** B = 0,678 > 0 → kapasite arttıkça yüksek fiyatlı olma ihtimali artıyor. Teknik olarak:
  1 kişi artış log-odds'u 0,678 artırıyor.
- **Madde 4 – Exp(B):** **Kapasite 1 kişi arttığında yüksek fiyatlı olma odds'u 1,97 kat artıyor (≈ %97 artış).**
  - 2 kişi artınca: 1,97² ≈ 3,88 kat (odds'lar çarpılarak birikir, toplanmaz).
- **Sabit (Exp(B₀) = 0,095):** accommodates = 0 için odds; pratik anlamı yok (0 kişilik ilan yok).
- **Madde 5 – Denklem:**
  - **logit(p) = ln[p/(1−p)] = −2,3503 + 0,6782 × accommodates**
  - Olasılık olarak: **p = 1 / (1 + e^−(−2,3503 + 0,6782 × accommodates))**
- **Madde 6 – Tahmini olasılıklar:**

  | Kişi | logit | odds | **Olasılık** |
  |---:|---:|---:|---:|
  | 2 | −0,994 | 0,370 | **0,270 (%27,0)** |
  | 4 | 0,363 | 1,437 | **0,590 (%59,0)** |
  | 6 | 1,719 | 5,579 | **0,848 (%84,8)** |

  - Hesap örneği (2 kişi): logit = −2,3503 + 0,6782×2 = −0,994 → odds = e^−0,994 = 0,370 → p = 0,370/1,370 = 0,270.
  - Odds her 2 kişide 1,97² = 3,88 kat artıyor (0,370 → 1,437 → 5,579) — **sabit oran**.
  - Olasılık ise 2→4 kişide +32 puan, 4→6 kişide +26 puan artıyor — **sabit değil** (yukarıdaki odds ≠ olasılık notu).
  - Yorum: 2 kişilik bir ilanın yüksek fiyatlı olma olasılığı %27, 6 kişilik bir ilanın %85.
  - Model 4 kişiden itibaren p > 0,50 veriyor → 0,50 eşiğiyle 4+ kişilik ilanlar "yüksek fiyat" olarak sınıflanacak (Part 4).
- Madde 7–9 (uyum iyiliği, accuracy, olasılık eğrisi) → Prompt 7.

---

## Model 2 — İki kategorili X: host_is_superhost (Yönerge 3.2)

- **Madde 1 – Referans kategori:** **No** (superhost değil).

| | B | SE | z | p | Exp(B) |
|---|---:|---:|---:|---:|---:|
| (Sabit) | −0,3089 | 0,0195 | −15,88 | < 0,001 | 0,7343 |
| Superhost: Yes | **0,9260** | 0,0344 | 26,95 | < 0,001 | **2,5244** |

- **Madde 3 – Anlamlılık:** z = 26,95, p < 0,001 → superhost durumu **anlamlı**.
- **Madde 4 – B ve Exp(B):**
  - B = 0,926 > 0 → superhost ilanlarının yüksek fiyatlı olma ihtimali daha yüksek.
  - **Superhost olan ev sahiplerinin ilanlarının yüksek fiyatlı olma odds'u, superhost olmayanlara göre 2,52 kat
    (≈ %152 daha yüksek).**
  - Sabit: Exp(B₀) = 0,734 → **referans grubun** (superhost değil) odds'u.
- Olasılık ve odds karşılaştırması (odds ≠ olasılık örneği):

  | Grup | Olasılık | Odds |
  |---|---:|---:|
  | No (referans) | 0,423 (%42,3) | 0,734 |
  | Yes | 0,650 (%65,0) | 1,854 |

  - Odds oranı: 1,854 / 0,734 = **2,52** = Exp(B) ✔
  - Olasılık oranı ise 0,650 / 0,423 = 1,53 → "olasılık 2,52 kat" demek **yanlış** olur.
  - Tek kategorik X'li modelde tahmini olasılıklar, gruplardaki gerçek yüksek fiyat oranlarına eşittir.
- Madde 5–6 (uyum iyiliği, accuracy) → Prompt 7.

---

## Model 3 — 3+ kategorili X: room_type (Yönerge 3.3)

- **Madde 1:** room_type factor'e çevrildi (4 düzey). **Madde 2 – Referans:** **Entire home/apt**.

| | B | SE | z | p | Exp(B) |
|---|---:|---:|---:|---:|---:|
| (Sabit) | 0,3184 | 0,0187 | 17,06 | < 0,001 | 1,3749 |
| Private room | −1,2749 | 0,0393 | −32,45 | < 0,001 | **0,2794** |
| Hotel room | 0,2018 | 0,1382 | 1,46 | 0,144 | **1,2236** |
| Shared room | −1,8717 | 0,2354 | −7,95 | < 0,001 | **0,1539** |

- **room_type bütün olarak (car::Anova, olabilirlik oranı testi):** χ²(3) = 1.222,9, p < 0,001 → **anlamlı**.
  - Lojistikte kısmi F yerine **olabilirlik oranı (likelihood-ratio, LR) ki-kare testi** kullanılır; mantık aynı:
    3 kuklanın hepsi birlikte 0 mı? → Hayır.
- **Madde 4–5 – Her kategorinin odds'u referansa göre** (yönergenin istediği açıklama):
  - **Private room:** Exp(B) = 0,279 → özel odaların yüksek fiyatlı olma odds'u, bütün ev/dairelerin odds'unun
    **0,28 katı** → **%72 daha düşük** (p < 0,001, anlamlı).
  - **Hotel room:** Exp(B) = 1,224 → otel odalarının odds'u bütün ev/dairelerden **%22 daha yüksek**, ama
    **anlamlı değil** (p = 0,144) → bu modelde otel odaları ile bütün ev/daireler arasında istatistiksel fark yok.
    Sadece 228 otel odası var → SE büyük.
  - **Shared room:** Exp(B) = 0,154 → paylaşımlı odaların odds'u bütün ev/dairelerin **0,15 katı** → **%85 daha düşük**
    (p < 0,001, anlamlı).
  - Sabit: Exp(B₀) = 1,375 → referans grubun (Entire home/apt) odds'u.
- Kategorilere göre olasılık ve odds:

  | Kategori | n | Olasılık | Odds | Odds oranı (ref'e göre) |
  |---|---:|---:|---:|---:|
  | Entire home/apt (ref) | 11.777 | 0,579 | 1,375 | 1 |
  | Private room | 4.172 | 0,278 | 0,384 | 0,279 |
  | Hotel room | 228 | 0,627 | 1,682 | 1,224 |
  | Shared room | 126 | 0,175 | 0,211 | 0,154 |

- Madde 6–7 (uyum iyiliği, accuracy) → Prompt 7.

---

## Model 4 — Karma (Yönerge 3.4)

- **Madde 1 – Bağımsız değişkenler:**
  - Sayısal: accommodates, bedrooms, bathrooms, number_of_reviews, availability_365.
  - Kategorik: host_is_superhost (ref No), shared_bath (ref No), room_type (ref Entire home/apt).
  - Çoklu doğrusal modeldeki (2.2) değişkenlerin aynısı → sonuçlar karşılaştırılabilir.

| | B | SE | z | p | Exp(B) |
|---|---:|---:|---:|---:|---:|
| (Sabit) | −3,1880 | 0,1071 | −29,76 | < 0,001 | 0,0413 |
| accommodates | 0,3791 | 0,0187 | 20,23 | < 0,001 | 1,4609 |
| bedrooms | 0,7159 | 0,0462 | 15,50 | < 0,001 | 2,0461 |
| bathrooms | 0,6209 | 0,0815 | 7,62 | < 0,001 | 1,8607 |
| number_of_reviews | −0,0034 | 0,0003 | −9,83 | < 0,001 | 0,9966 |
| availability_365 | 0,0005 | 0,0002 | 2,79 | 0,005 | 1,0005 |
| Superhost: Yes | 0,9203 | 0,0411 | 22,41 | < 0,001 | 2,5100 |
| Shared bath: Yes | −0,3349 | 0,1193 | −2,81 | 0,005 | 0,7154 |
| Private room | −0,3713 | 0,0474 | −7,84 | < 0,001 | 0,6898 |
| Hotel room | 1,4046 | 0,1459 | 9,62 | < 0,001 | 4,0738 |
| Shared room | −0,3366 | 0,2853 | −1,18 | 0,238 | 0,7142 |

- **Madde 3 – Anlamlılık:** 8 değişkenin hepsi anlamlı (tek dereceli değişkenler Wald z testi, hepsi p < 0,01;
  room_type car::Anova LR testi).
  - room_type bütün olarak: χ²(3) = 187,0, p < 0,001 → anlamlı. Shared room kuklası tek başına anlamsız (p = 0,238),
    ama değişken bütün olarak anlamlı (2.2'deki mantıkla aynı).

### Madde 4 + 6 — Sayısal katsayılar (diğer değişkenler sabitken, X 1 birim artınca)
- **accommodates (Exp(B) = 1,461):** kapasite **1 kişi arttığında** yüksek fiyatlı olma **odds'u 1,46 kat** (≈ %46) artıyor.
  - Model 1'de 1,97 idi → yatak odası/banyo kontrol edilince kapasitenin kendi etkisi küçüldü (2.2'dekiyle aynı durum).
- **bedrooms (Exp(B) = 2,046):** **1 ek yatak odası** odds'u **2,05 kat** (≈ %105) artırıyor → en güçlü sayısal etki.
- **bathrooms (Exp(B) = 1,861):** **1 ek banyo** odds'u **1,86 kat** (≈ %86) artırıyor.
- **number_of_reviews (Exp(B) = 0,9966):** her ek yorum odds'u **%0,34 azaltıyor**.
  - 1 birim çok küçük olduğu için 100 yorum üzerinden düşünmek daha anlaşılır: e^(100 × B) = **0,7104** →
    **100 ek yorum odds'u %29,0 azaltıyor** (`R/05` "Odds ratio for +100 units" tablosu).
- **availability_365 (Exp(B) = 1,0005):** 1 gün daha müsait olmak odds'u %0,05 artırıyor;
  100 gün → e^(100 × B) = **1,0541** → **%5,4 artış** (`R/05` aynı tablo). Anlamlı ama küçük bir etki.

### Madde 5 + 6 — Kategorik katsayılar (diğer değişkenler sabitken, referansa göre)
- **Superhost: Yes (Exp(B) = 2,510):** superhost ilanlarının yüksek fiyatlı olma **odds'u**, superhost olmayanlara göre
  **2,51 kat** (≈ %151 daha yüksek). Model 2'deki değere (2,52) çok yakın → bu etki diğer değişkenlerden bağımsız.
- **Shared bath: Yes (Exp(B) = 0,715):** paylaşımlı banyolu ilanların odds'u özel banyolulara göre **%28,5 daha düşük**.
- **room_type** (ref = Entire home/apt):
  - **Hotel room (Exp(B) = 4,074):** aynı kapasite/oda/banyo sayısında otel odalarının odds'u bütün ev/dairelerin
    **4,07 katı**. (Model 3'te anlamsızdı! Neden değişti: otel odaları küçük — az yatak odası/kapasite — ama yine de
    pahalı. Bu özellikler sabit tutulunca "otel olmanın" kendi etkisi ortaya çıkıyor.)
  - **Private room (Exp(B) = 0,690):** özel odaların odds'u **%31 daha düşük** (Model 3'teki %72'den çok daha az; farkın
    büyük kısmı küçük oda/kapasiteden geliyordu).
  - **Shared room (Exp(B) = 0,714, p = 0,238):** anlamlı değil → diğer değişkenler sabitken paylaşımlı odalar bütün
    ev/dairelerden farklı değil.
- Sabit (Exp(B₀) = 0,041): bütün sayısal değişkenler 0 ve kategoriler referansta → pratik anlamı yok.

### Madde 9 — Genel yorum için fikirler
- Yüksek fiyatlı olma ihtimalini en çok artıran özellikler: **Hotel room**, **superhost**, **yatak odası** ve **banyo sayısı**.
- Azaltanlar: özel oda, paylaşımlı banyo, çok sayıda yorum.
- Doğrusal model (2.2) ile **yönler tutarlı** (aynı işaretler) → iki yöntem aynı hikâyeyi anlatıyor.
  Fark: doğrusal model "kaç TL" der, lojistik "yüksek fiyat grubunda olma odds'u kaç kat" der.
- Tek değişkenli modellerle (Model 1–3) karşılaştırınca katsayılar değişiyor → değişkenler birbiriyle ilişkili;
  çoklu model her birinin **kendi** etkisini gösteriyor.
- Model 4'ün uyumu ve sınıflandırma başarısı Prompt 7'de; Model 1–3 ile karşılaştırma orada yapılacak.
