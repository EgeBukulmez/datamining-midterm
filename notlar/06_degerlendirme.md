# 06 — Lojistik Model Değerlendirme (Yönerge 4.1–4.3)

> Kod: `R/06_logistic_evaluation.R` · Özet tablo: `output/tables/06_logistic_summary.csv`
> Grafikler: `output/figures/06_model1_probability_curve.png`, `06_model2_probability.png`,
> `06_model3_probability.png`, `06_model4_probability_curves.png`
> Modeller: `output/05_logistic_models.rds` (05_logistic_models.R'dan)
> Aşağıdakiler rapor paragrafı değil, kendi metnini yazman için taslak notlardır.

## Özet tablo

| Model | HL χ² (df) | HL p | McFadden | Cox & Snell | Nagelkerke | TN | FP | FN | TP | Accuracy |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 1: accommodates | 37,14 (4) | < 0,001 | 0,180 | 0,221 | 0,295 | 6.361 | 1.801 | 2.866 | 5.275 | **%71,37** |
| 2: host_is_superhost | uygulanamaz | — | 0,033 | 0,045 | 0,060 | 6.243 | 1.919 | 4.584 | 3.557 | **%60,11** |
| 3: room_type | uygulanamaz | — | 0,054 | 0,072 | 0,096 | 3.118 | 5.044 | 1.180 | 6.961 | **%61,82** |
| 4: karma | 65,00 (8) | < 0,001 | 0,234 | 0,277 | 0,370 | 6.660 | 1.502 | 2.599 | 5.542 | **%74,85** |

- Taban oran (hep "0" tahmin etmek): **%50,06**.
- Her ölçüte göre en iyi model **Model 4**, sonra Model 1. Model 2 ve 3 zayıf ama yine de taban oranın üstünde.

---

## 4.1 Model uyumu

### Hosmer–Lemeshow (HL) testi
- **Ne yapar:** İlanları tahmini olasılığa göre sıralayıp g = 10 gruba (ondalık dilimler) böler. Her grupta
  **gözlenen** "1" sayısını modelin **beklediği** "1" sayısıyla (olasılıkların toplamı) karşılaştırır → ki-kare istatistiği.
- **Hipotezler:**
  - H₀: model veriye **uyuyor** (gözlenen ve beklenen frekanslar uyumlu).
  - H₁: model veriye uymuyor.
- **Yorum kuralı — dikkat, alışılmışın tersi:**
  - **p > 0,05 → H₀ reddedilmez → "iyi uyum"** (modelin kötü uyduğuna dair kanıt yok). İstenen sonuç bu.
  - **p < 0,05 → H₀ reddedilir → "kötü uyum"** (tahminler ile gerçek oranlar arasında sistematik fark var).
  - Katsayı testlerinde küçük p "iyi" (anlamlı) iken, HL'de büyük p "iyi".
  - Kesin dil: p > 0,05 "modelin mükemmel olduğunu" kanıtlamaz; sadece "uyumsuzluk kanıtı yok" der.
- **Df = grup sayısı − 2.**

#### Sonuçlar
- **Model 1:** χ² = 37,14, df = 4, **p < 0,001 → kötü uyum** (H₀ reddedildi).
  - Önemli teknik not: 10 grup istendi ama **sadece 6 grup oluştu**. accommodates sadece 16 farklı değer alıyor ve
    ilanların %35,23'ü 2 kişilik (5.743 ilan; `R/06` "distribution of accommodates" tablosu) → aynı olasılığa sahip
    çok ilan var, ondalık dilim sınırları çakışıyor.
    Fonksiyon çakışan sınırları birleştiriyor → 6 grup, df = 6 − 2 = 4. Raporda bunu belirtmek gerekiyor.
  - Anlamı: S eğrisi bazı kapasite gruplarında gerçek yüksek fiyat oranını tam yakalayamıyor.
- **Model 2 ve Model 3: test uygulanamaz (sonuç üretilmedi).** Gerekçe:
  - Modellerde sadece bir kategorik değişken var → aynı kategorideki **bütün ilanlara aynı olasılık** veriliyor.
    Model 2'de sadece **2**, Model 3'te sadece **4** farklı tahmini olasılık var → **10 grup oluşturmak imkânsız**.
    (Model 2'de fonksiyon hata veriyor: tek grup oluşuyor, df negatif.)
  - Daha temel neden: bu modeller **doymuş (saturated)** → her kategori için tahmin edilen olasılık, o kategorideki
    gerçek yüksek fiyat oranına **tam olarak eşit** (ör. superhost'ta tahmin %65,0 = gerçek oran %65,0).
    Gözlenen = beklenen olduğu için istatistik zaten 0 çıkar; uyum hakkında hiçbir bilgi vermez.
  - Model 3'te test zorla çalıştırılırsa χ² ≈ 0, p = 1 çıkıyor → "mükemmel uyum" gibi görünür ama **anlamsız**
    (yanıltıcı olmasın diye raporlanmadı).
  - Raporda: "HL testi sürekli/çok değerli tahminler gerektirdiğinden tek kategorik değişkenli modellerde
    uygulanamaz; bu modellerin uyumu pseudo R² ile değerlendirildi" denebilir.
- **Model 4:** χ² = 65,00, df = 8 (10 grup oluştu), **p < 0,001 → kötü uyum** (H₀ reddedildi).
- **Model 1 ve 4'ün HL'de kötü çıkmasını yorumlarken (fikir):**
  - HL testi **çok büyük örneklemlerde aşırı hassastır**: 16.303 ilanda gözlenen ve beklenen arasındaki çok küçük
    farklar bile anlamlı çıkar. Literatürde büyük örneklemlerde HL'nin "neredeyse her zaman reddettiği" bilinir.
  - Bu yüzden HL sonucunu pseudo R² ve accuracy ile **birlikte** değerlendirmek gerekir: Model 4'ün accuracy'si
    %74,9 ve Nagelkerke 0,37 → pratikte işe yarar bir model, ama olasılık tahminleri her grupta tam kalibre değil.
  - Dürüst ifade: "HL testine göre model uyumu yeterli değildir; ancak bu sonuç büyük örneklemden etkilenmiş olabilir."

### Pseudo R²'ler
| | Ne ölçer | Aralık |
|---|---|---|
| **McFadden** | 1 − (modelin log-olabilirliği / sadece sabitli modelin log-olabilirliği). Modelin "hiçbir değişken yok" modeline göre ne kadar iyileştirdiği. | 0 – 1 (pratikte çok daha düşük) |
| **Cox & Snell** | Olabilirlik oranına dayanır; **ikili Y'de maksimumu 1'e ulaşamaz** (burada **0,7500**; `R/06`'da hesaplanıyor: 1 − e^(2·LL₀/n)). Sınıflar tam dengeli olduğu için tam 0,75. | 0 – <1 |
| **Nagelkerke** | Cox & Snell'in maksimumuna bölünmüş hali → 0–1 aralığına ölçeklenmiş. Hep Cox & Snell'den büyük. | 0 – 1 |

- Her modelde sıralama aynı: McFadden < Cox & Snell < Nagelkerke (beklenen durum).
- **Neden doğrusal R² gibi yorumlanmaz?** (yönerge özellikle istiyor)
  - Doğrusal R² = "Y'deki varyansın açıklanan oranı". Lojistikte Y sadece 0/1, en küçük kareler değil
    **maksimum olabilirlik** kullanılıyor → "açıklanan varyans" diye bir kavram yok.
  - Pseudo R²'ler olabilirlik (likelihood) iyileşmesine dayanır; **"%X açıklandı" denemez**.
    "Nagelkerke = 0,37 → varyansın %37'si açıklandı" demek **YANLIŞ**.
  - Değerleri doğası gereği düşüktür: McFadden'da **0,2–0,4 arası çok iyi uyum** kabul edilir (McFadden'ın kendi önerisi).
  - Üç ölçüt farklı formüllerle hesaplandığı için farklı değerler verir → birbiriyle de doğrudan karşılaştırılmaz.
  - Doğru kullanım: **aynı veri setindeki modelleri birbiriyle karşılaştırmak** (hangisi daha iyi?).
- **Model bazında:**
  - Model 4: McFadden 0,234 → 0,2–0,4 aralığında, iyi uyum. Dört modelin en iyisi.
  - Model 1: McFadden 0,180 → tek değişkenle oldukça iyi; accommodates güçlü bir belirleyici.
  - Model 2 (0,033) ve Model 3 (0,054): çok düşük → değişkenler anlamlı ama tek başına yüksek fiyatı açıklamakta zayıf.
  - Model 1 → Model 4: bütün pseudo R²'ler arttı → ek değişkenler uyumu iyileştirdi.

---

## 4.2 Sınıflandırma başarısı

### Bağımlı değişkenin dağılımı (taban oran)
- 0: 8.162 (%50,06) · 1: 8.141 (%49,94) → **dengeli**.
- **Taban oran (baseline) = %50,06:** hiçbir değişken kullanmadan herkese çoğunluk sınıfını ("0") tahmin eden
  "model" bile %50,06 doğru olurdu. Yazı-tura atmakla neredeyse aynı.

### Karışıklık matrisi nasıl okunur (satır = gerçek, sütun = tahmin; eşik 0,50)
- **TN (gerçek 0, tahmin 0):** düşük/orta fiyatlıyı doğru bildi.
- **FP (gerçek 0, tahmin 1):** düşük fiyatlıya yanlışlıkla "yüksek" dedi.
- **FN (gerçek 1, tahmin 0):** yüksek fiyatlıya yanlışlıkla "düşük" dedi.
- **TP (gerçek 1, tahmin 1):** yüksek fiyatlıyı doğru bildi.
- **Accuracy = (TP + TN) / toplam** = doğru tahminlerin oranı.

### Accuracy taban orana göre nasıl yorumlanır
- Accuracy tek başına anlamsızdır; **taban orana göre ne kadar iyileştirme** sağladığına bakılır.
  - Dengesiz veride (ör. %90 – %10) hep çoğunluğu tahmin eden model %90 accuracy alır ama hiçbir şey öğrenmemiştir.
  - Bizim veri dengeli (medyan eşiği sayesinde) → accuracy doğrudan anlamlı; %50 üstündeki her puan modelin katkısı.
- **Model 4: %74,85 → taban orana göre +24,8 puan.** Her 4 ilandan 3'ünü doğru sınıflıyor. En iyi model.
- **Model 1: %71,37 → +21,3 puan.** Sadece kapasiteyle bile güçlü.
- **Model 3: %61,82 → +11,8 puan.** Model 2: **%60,11 → +10,1 puan.** Zayıf ama şanstan iyi.
- Model 4, Model 1'e göre sadece +3,5 puan → kapasite tek başına sınıflandırmanın büyük kısmını yapıyor.

### Modellerin hata yapısı (matrislerden okunan, yorum için)
- **Model 2:** superhost olan herkese "yüksek" (p = 0,65), olmayana "düşük" (p = 0,42) diyor.
  FN çok yüksek (4.584): yüksek fiyatlıların çoğu superhost değil → kaçırılıyor.
- **Model 3:** Entire home/apt (p = 0,58) ve Hotel room (p = 0,63) → hep "yüksek"; Private ve Shared room → hep "düşük".
  FP çok yüksek (5.044): ucuz bütün ev/daireler yanlışlıkla "yüksek" sayılıyor.
- Tek kategorik değişkenli modeller her kategoriye tek bir tahmin verebildiği için kaba sınıflandırma yapıyor.
- **Model 1 ve 4:** FN > FP → model yüksek fiyatlı ilanları kaçırmaya daha yatkın (yüksek fiyatlı ama küçük
  kapasiteli ilanları "düşük" sanıyor).

---

## 4.3 Olasılık grafikleri — olasılık nasıl değişiyor

### Model 1 (accommodates — lojistik eğri)
- Klasik **S şeklinde** eğri: kapasite arttıkça yüksek fiyatlı olma olasılığı artıyor.
  - 1 kişi ≈ 0,16 · 2 kişi **0,270** · 4 kişi **0,590** · 6 kişi **0,848** · 8+ kişide 0,95'in üstü, 16 kişide ≈ 1.
- **0,50 eşiğini ~3,5 kişide** geçiyor → 0,50 eşiğiyle 1–3 kişilik ilanlar "düşük", 4+ kişilik ilanlar "yüksek" sınıflanıyor.
- Eğri **ortada dik, uçlarda yatık**: en büyük artış 2–6 kişi arasında; 8 kişiden sonra olasılık zaten 1'e yakın,
  ek kişi neredeyse fark yaratmıyor. → Odds her kişide sabit 1,97 kat artarken, olasılıktaki artış sabit değil
  (05 notlarındaki odds ≠ olasılık açıklamasının görsel kanıtı).

### Model 2 (host_is_superhost — kategori başına nokta)
- Superhost değil (referans): **0,423** → superhost: **0,650** → olasılık **~23 puan artıyor**.
- Referans grup 0,50 eşiğinin altında, superhost grubu üstünde → sınıflandırma tamamen bu ayrıma dayanıyor.

### Model 3 (room_type — kategori başına nokta)
- Entire home/apt (referans) **0,579** · Hotel room **0,627** · Private room **0,278** · Shared room **0,175**.
- Referanstan diğer kategorilere geçince:
  - Hotel room: +5 puan (küçük, anlamsız fark — 05'te p = 0,144).
  - Private room: −30 puan; Shared room: −40 puan → oda kiralamak yüksek fiyatlı olma olasılığını belirgin düşürüyor.
- Eşiğin üstünde: Entire home/apt ve Hotel room; altında: Private room ve Shared room.

### Model 4 (accommodates × room_type — dört eğri)
- **Sabitleme kuralı** (grafiğin altyazısında): diğer sayısal değişkenler medyanda (bedrooms = 1, bathrooms = 1,
  number_of_reviews = 9, availability_365 = 342), diğer kategorikler referansta (superhost = No, shared_bath = No).
  → Yani grafik "superhost olmayan, 1 yatak odalı, 1 banyolu, özel banyolu tipik bir ilan" için.
- Dört eğri de kapasiteyle artıyor (aynı S şekli) ama **room_type eğriyi yukarı/aşağı kaydırıyor**:

  | Kişi | Entire home/apt | Private room | Hotel room | Shared room |
  |---:|---:|---:|---:|---:|
  | 2 | 0,280 | 0,212 | **0,613** | 0,218 |
  | 4 | 0,454 | 0,364 | **0,772** | 0,372 |
  | 6 | 0,639 | 0,550 | **0,878** | 0,559 |

- **Hotel room** en üstte: 1 kişilikte bile p > 0,50 (Model 4'teki Exp(B) = 4,07 ile uyumlu).
- **Entire home/apt** (referans) ortada: 0,50 eşiğini ~4,5 kişide geçiyor.
- **Private room ve Shared room** eğrileri **neredeyse üst üste** (katsayıları çok yakın: −0,371 ve −0,337) → diğer
  özellikler sabitken bu iki oda tipi arasında pratikte fark yok; eşiği ~5,5 kişide geçiyorlar.
  (Bir çizim hatası değil; raporda belirtmek iyi olur.)
- Kategoriler arası fark **orta kapasitelerde en büyük**, çok yüksek kapasitelerde eğriler 1'e yakınsıyor.
- Dikkat: grafik bütün kategorileri 1–16 kişi aralığında çiziyor; gerçekte 16 kişilik paylaşımlı oda/otel odası
  pek yok → eğrilerin uç kısımları modelin **uzatılmış (extrapolation)** tahminleri, temkinli yorumlanmalı.
- Model 1 ile fark: Model 1'de 2 kişi → 0,270, Model 4'te (Entire home, diğerleri sabit) 0,280 → benzer; ama Model 4'te
  eğri daha yatık, çünkü kapasitenin etkisinin bir kısmı artık yatak odası/banyo değişkenlerinde (Exp(B) 1,97 → 1,46).
