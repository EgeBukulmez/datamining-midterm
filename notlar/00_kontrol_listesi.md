# 00 — Yönergeye Uygunluk Kontrol Listesi

> Kontrol tarihi: 3 Kasım 2026 (kararlardan sonra güncellendi) · Kaynak: `HOCA_YONERGE.md` (baştan sona tekrar okundu)
> ✅ karşılandı · ⚠️ kısmen / dikkat gerekiyor · ❌ karşılanmadı
> Kısaltmalar: `R/` = scriptler, `T/` = `output/tables/`, `F/` = `output/figures/`, `N/` = `notlar/`

## Özet
- **Analizler:** 1.1–4.3 arasındaki bütün maddeler karşılandı. İki madde ⚠️: 4.1 (Model 2–3'te HL testi
  uygulanamıyor) ve 4.3 (Model 2–3'te sayısal X olmadığı için eğri yerine nokta grafiği). İkisi de verinin/modelin
  doğasından kaynaklanıyor ve gerekçesi notlarda var; raporda açıkça yazılmalı.
- **Rapor (Part 5):** metin henüz yazılmadı (bilinçli — senin işin). Bütün malzeme hazır → `N/00_rapor_haritasi.md`.
- **Çalıştırma:** kararlar uygulandıktan sonra 6 script temiz R oturumlarında sırayla yeniden çalıştı → **0 hata, 0 uyarı**.
  Ek dosyası yeniden oluşturuldu ve tek oturumda da çalıştı (0 hata, 0 uyarı). Temiz veri bire bir aynı (md5 değişmedi).
- **Uygulanan kararlar:** (1) car::Anova yalnızca room_type için yazdırılıyor (2.2 ve Model 4); ikili Y doğrulaması dışındaki
  elle kontrol satırları kaldırıldı. (2) Script dışında hesaplanan sayılar scriptlere eklendi. (3) Veri tarihi:
  "25 Eylül 2026 tarihli veri yayını (veri toplama: 28–29 Eylül 2026)". (4) Tablo 2'nin altına room_type notu eklendi.

---

## PART 1 — Veri yükleme, inceleme, ön işleme

| Madde | Durum | Nerede | Eksik / zayıf |
|---|---|---|---|
| **1.1** ≥100 gözlem, ≥4 sayısal, ≥3 kategorik, iki kategorili X, 3+ kategorili X, sayısal Y | ✅ | `R/02_cleaning.R` (1.1 REQUIREMENTS CHECK), `N/02_temizleme.md` | — (16.303 gözlem, 6 sayısal, 3 kategorik) |
| 1.1 Veri seti adı ve kaynağı | ✅ | `CLAUDE.md` §5, `N/01` §1.2, `R/01` başlığı | Tarih kararlaştırıldı: "25 Eylül 2026 tarihli veri yayını (veri toplama: 28–29 Eylül 2026)". Raporda elle yazılacak (bir tablo çıktısı değil). |
| 1.1 Gözlem ve değişken sayısı | ✅ | `R/01` (ham: 27.232 × 90), `R/02` (temiz: 16.303 × 10) | Raporda ham ve temiz sayıları ayrı ayrı vermek gerekir |
| 1.1 Sayısal ve kategorik değişkenlerin tanımı | ✅ | `T/variable_description.csv` | Açıklamalar İngilizce; rapor diline göre çevirmen gerekebilir |
| 1.1 Sayısal Y'nin belirtilmesi | ✅ | `T/variable_description.csv`, `N/02` | — |
| 1.1 İkili Y nasıl oluşturuldu + eşik gerekçesi | ✅ | `R/02` (1.5), `N/02_temizleme.md` §1.5 | Gerekçeyi kendi cümlelerinle yazman gerekiyor (notlarda fikirler var) |
| 1.1 Değişken açıklama tablosu | ✅ | `T/variable_description.csv` | — |
| **1.2** Dosya formatı, R fonksiyonu, gözlem, değişken sayısı + kod | ✅ | `R/01_import_explore.R`, `N/01_inceleme.md` | — |
| **1.3** head(), dim(), str(), summary() | ✅ | `R/01` | summary() 90 sütunda çok uzun; raporda sadece ilgili kısmı ya da özetini ver |
| 1.3 Yanlış tipler, eksikler, tutarsız kategoriler, olağandışı değerler, giriş hataları + açıklama | ✅ | `R/01` (A–E), `T/01_problem_summary.csv`, `N/01` | — |
| **1.4** Her sorun için düzeltme + gerekçe + kod | ✅ | `R/02` (Adım 1–9), `T/02_cleaning_log.csv`, `N/02` | — |
| **1.5** Orijinal Y, eşik, gerekçe, R ile oluşturma, sayı ve %, doğrulama | ✅ | `R/02` (1.5), `T/02_high_price_distribution.csv`, `N/02` | — (medyan 4.457,5 TL; 8.162 / 8.141) |
| **1.6** str(), summary(), dim() + son sayılar + "hazır mı" açıklaması | ✅ | `R/02` (1.6), `N/02` §1.6 | — |

## PART 2 — Doğrusal regresyon

| Madde | Durum | Nerede | Eksik / zayıf |
|---|---|---|---|
| **2.1** 1. Y ve X | ✅ | `R/03_simple_linear.R`, `N/03` | — |
| 2. Neden seçildi | ✅ | `R/03` (Item 2: korelasyon r = 0,5319 ve kişi sayısına göre medyan fiyat tablosu), `N/03` Madde 2 | — |
| 3. lm() | ✅ | `R/03` | — |
| 4. F testi | ✅ | `R/03`, `T/03_simple_linear.csv` | — |
| 5. t testi / p | ✅ | `R/03`, `T/03` | — |
| 6. B yorumu | ✅ | `R/03`, `N/03` | — |
| 7. Denklem | ✅ | `R/03`, `N/03` | — |
| 8. R² ve düzeltilmiş R² | ✅ | `R/03`, `T/03` | — |
| 9. Tahmin değerleri | ✅ | `R/03`, `T/03_simple_linear_predictions.csv` | — |
| 10. Yorum | ✅ (taslak) | `N/03` | Metni sen yazacaksın |
| Tablo: B, SE, t, p, F + p, R², düz. R² | ✅ | `T/03_simple_linear.csv` | — |
| En az bir tahmin örneği | ✅ | `T/03_simple_linear_predictions.csv` (2 kişi 3.887,92; 4 kişi 5.986,55 TL) | — |
| **2.2 Step 1** Y ve X; factor; referanslar; model; F testi; anlamlılık; anlamlı/anlamsız listesi; katsayı yorumları | ✅ | `R/04_multiple_linear.R`, `T/04_table1_initial_model.csv`, `N/04` | — |
| **Step 2** Anlamsızları çıkar, yeniden kur; 3+ kategorikte bütün olarak değerlendir | ✅ | `R/04` (eleme döngüsü + car::Anova), `T/04_revision_log.csv` | Hiç değişken çıkarılmadı (hepsi anlamlı). Revizyon tablosu boş. Raporda "Step 2 uygulandı, çıkarılacak değişken bulunmadı" diye açıkça yazılmalı. |
| **Step 3** Son model; F; anlamlı katsayıların yorumu; denklem; R², düz. R²; başlangıçtan farkı | ✅ | `R/04`, `T/04_table2_final_model.csv`, `T/04_model_comparison.csv`, `N/04` | Son model = başlangıç modeli → "fark yok" açıklanmalı |
| **Special Rule** | ✅ | `R/04` (SPECIAL RULE CHECK), `N/04` | Son modelde iki tür de var → son modelden 1 sayısal + 1 kategorik yorumlanacak (notlarda hazır) |
| Tablo 1 ve Tablo 2 | ✅ | `T/04_table1_initial_model.csv`, `T/04_table2_final_model.csv` | Tablo 2'de Private room (p = 0,090) ve Shared room (p = 0,167) kuklaları var; room_type bütün olarak anlamlı olduğu için doğru. **Tablo altı notu eklendi** (CSV'nin son satırı + konsol çıktısı; `N/04`). Raporda kendi ifadenle tablonun altına yaz. |
| Explain: hangi değişkenler çıkarıldı, neden, hangileri kaldı, yorumlar, açıklama gücü | ✅ (taslak) | `N/04` "Explain maddeleri" | — |

## PART 3 — İkili lojistik regresyon

| Madde | Durum | Nerede | Eksik / zayıf |
|---|---|---|---|
| Aynı ikili Y bütün modellerde; price X olarak yok | ✅ | `R/05_logistic_models.R` | Doğrulandı (formüllerde price yok) |
| **3.1 Model 1** 1–6 (model, anlamlılık, B, Exp(B), denklem, olasılıklar) | ✅ | `R/05`, `T/05_model1.csv`, `T/05_model1_predicted_probabilities.csv`, `N/05` | — |
| 3.1 7–9 (uyum, accuracy, olasılık eğrisi) | ✅ | `R/06`, `T/06_logistic_summary.csv`, `F/06_model1_probability_curve.png` | HL'de 10 yerine 6 grup oluştu (df = 4) → raporda belirt |
| 3.1 10 Yorum | ✅ (taslak) | `N/05`, `N/06` | — |
| **3.2 Model 2** referans, model, anlamlılık, B/Exp(B), uyum, accuracy, yorum | ✅ | `R/05`, `T/05_model2.csv`, `R/06`, `N/05` | HL uygulanamaz (4.1'e bkz.) |
| **3.3 Model 3** factor, referans, model, katsayılar, Exp(B), uyum, accuracy, yorum + her kategorinin odds'u ref'e göre | ✅ | `R/05`, `T/05_model3.csv`, `R/06`, `N/05` | HL uygulanamaz (4.1'e bkz.) |
| **3.4 Model 4** X'ler, model, anlamlılık, sayısal ve kategorik yorum, Exp(B), uyum, accuracy, genel yorum | ✅ | `R/05`, `T/05_model4.csv`, `R/06`, `N/05` | — |

## PART 4 — Lojistik model değerlendirme

| Madde | Durum | Nerede | Eksik / zayıf |
|---|---|---|---|
| **4.1** HL — her 4 model | ⚠️ | `R/06`, `T/06_logistic_summary.csv`, `N/06` | Model 1 ve 4: raporlandı. **Model 2 ve 3: uygulanamaz** (sadece 2 / 4 farklı olasılık; doymuş model, gözlenen = beklenen). Yönerge "her model için" diyor → raporda gerekçe mutlaka açıklanmalı. Hocaya sormak da bir seçenek. |
| 4.1 McFadden, Cox & Snell, Nagelkerke — her 4 model | ✅ | `T/06_logistic_summary.csv` | — |
| 4.1 Değerlerin anlamı + pseudo R² ≠ doğrusal R² | ✅ (taslak) | `R/06` (Cox & Snell maksimumu = 0,7500), `N/06` | — |
| **4.2** Tahmini olasılıklar, 0,50 eşiği, karışıklık matrisi (yönergedeki düzen), accuracy, sınıf dağılımına göre yorum | ✅ | `R/06`, `T/06_logistic_summary.csv`, `N/06` | Matrisler yönerge düzeninde konsolda yazdırılıyor; ayrı bir tablo dosyası yok (TN/FP/FN/TP özet tabloda) |
| **4.3** 4 model için olasılık grafiği; X ekseni sayısal X, Y ekseni olasılık, lojistik eğri; yorum | ⚠️ | `F/06_model1…`, `F/06_model2…`, `F/06_model3…`, `F/06_model4…`, `N/06` | Model 1 ve 4: tam karşılandı. **Model 2 ve 3'te sayısal X yok** → eğri çizilemez; kategori başına nokta grafiği yapıldı (yönergenin yorum cümlesi "kategorik değişken referanstan diğer kategoriye geçince" diyerek bunu öngörüyor). Raporda kısa bir açıklama yeterli. |

## PART 5 — Rapor yapısı

| Bölüm | Durum | Malzeme | Eksik |
|---|---|---|---|
| 1. Introduction | ❌ | `N/00_rapor_haritasi.md` | Metin yazılmadı (senin işin) |
| 2. Dataset Description | ❌ | `T/variable_description.csv`, `N/01`, `N/02` | Metin yazılmadı; kaynak bilgisi elle eklenecek |
| 3. Data Exploration and Preprocessing | ❌ | `T/01_problem_summary.csv`, `T/02_cleaning_log.csv`, `N/01`, `N/02` | Metin yazılmadı |
| 4.1 Simple Linear Regression | ❌ | `T/03_*`, `N/03` | Metin yazılmadı |
| 4.2 Multiple Linear Regression | ❌ | `T/04_*`, `N/04` | Metin yazılmadı |
| 5. Binary Logistic Regression Results | ❌ | `T/05_*`, `T/06_logistic_summary.csv`, `F/06_*`, `N/05`, `N/06` | Metin yazılmadı |
| 6. Conclusion | ❌ | `N/03`–`N/06` yorum fikirleri | Metin yazılmadı |
| 7. Appendix – R Codes | ✅ | `output/appendix_R_codes.R` | — (1.322 satır, yorumsuz; yalnızca bölüm başlıkları var; başlıklar dışında 6 bölümün her biri ilgili scriptle bire bir aynı) |

---

## Fazlalık kontrolü (yönergede doğrudan istenmeyenler)

**Kararınla kaldırılanlar:**
- `R/04` car::Anova sonuçlarının bütün değişkenler için yazdırılması → artık **yalnızca room_type** yazdırılıyor
  (diğer değişkenlerin Anova p'leri Step 2 eleme kuralı için arka planda hesaplanmaya devam ediyor; tek dereceli
  değişkenlerde t testiyle aynı oldukları için sonuç değişmez).
- `R/05` Model 4 için bütün değişkenlerin car::Anova testleri → artık **yalnızca room_type** (LR χ²(3) = 187,03).
- Elle kontrol satırları: `R/03` "Manual check" (denklemle tahmin), `R/05` Model 1 tablosundaki `manual_check` sütunu,
  `R/05` Model 2 "Odds ratio check". (İkili Y doğrulaması — `R/02` 1.5 — duruyor.)

**Kararınla kalanlar:**
1. `R/01` price için IQR (Q3 + 1,5×IQR) uç değer sayımı.
2. `T/01_problem_summary.csv`, `T/02_cleaning_log.csv`, `T/02_high_price_distribution.csv`, `R/02` 1.1 şart kontrol tablosu.
3. `T/04_model_comparison.csv` (basit regresyon R²'si ile karşılaştırma dahil), `T/04_revision_log.csv` (boş).
4. `T/03_simple_linear_predictions.csv`, `T/05_model1_predicted_probabilities.csv` (logit ve odds sütunları dahil).
5. `R/05` Model 2 ve 3 için kategori başına olasılık/odds tabloları; Model 1 için bütün ilanların olasılık özeti.
6. `output/05_logistic_models.rds` (teknik: 06'nın modelleri yeniden kurmaması için).
7. Grafiklerde 0,50 eşik çizgisi, Model 1'de nokta + etiket + denklem altyazısı, Model 2'de birleştirici çizgi.
8. Notlardaki ek yorumlar (residual standard error, HL'nin büyük örneklemde hassaslığı, FP/FN hata yapısı).

**Karar 2 ile eklenen betimleyici çıktılar** (notlardaki sayıların kodda karşılığı olsun diye):
- `R/03` korelasyon (r = 0,5319) ve kişi sayısına göre medyan fiyat tablosu.
- `R/04` oda tipine göre ortalama fiyat (ve ortalama yatak odası) tablosu.
- `R/06` Cox & Snell R² maksimumu (0,7500).
- Ek olarak, aynı gerekçeyle (listede 4 sayı vardı, bunlar da notlarda script dışı hesaplanmıştı):
  `R/06` accommodates dağılımı (2 kişilik = 5.743 ilan, %35,23 — HL'de 6 grup oluşmasının açıklaması) ve
  `R/05` Model 4'te number_of_reviews / availability_365 için +100 birim odds oranları (0,7104 ve 1,0541).
  İstemezsen kaldırırım; notlardaki ilgili cümleler o zaman tekrar "elle hesaplandı" durumuna düşer.

> Yönergenin "YAPMA" listesindeki hiçbir şey projede yok (train/test, ROC/AUC, VIF, karar ağacı, stepwise AIC,
> etkileşim, ısı haritası vb.).

---

## Tutarlılık kontrolü

| Kontrol | Sonuç |
|---|---|
| Bütün analiz scriptleri aynı temiz veriyi kullanıyor mu? | ✅ `R/03`, `R/04`, `R/05`, `R/06` → `data/clean_listings.csv`. Dört lojistik modelde `nobs` = 16.303. `R/01` ve `R/02` ham veriyi okur (olması gereken). Scriptler tekrar çalıştırılınca temiz veri bire bir aynı çıkıyor (md5 değişmedi). |
| Referans kategoriler doğrusal ve lojistikte aynı mı? | ✅ `R/02`, `R/04`, `R/05`, `R/06`: host_is_superhost = No, shared_bath = No, room_type = Entire home/apt (her scriptte aynı `levels = c(...)`). |
| price lojistik modellerde X olarak kullanılmış mı? | ✅ Hayır. Model formüllerindeki değişkenler programla listelendi: price hiçbirinde yok. |
| Notlardaki sayılar tablolarla eşleşiyor mu? | ✅ Notlardaki tablo sayıları (B, SE, t/z, p, Exp(B), R², pseudo R², TN/FP/FN/TP, accuracy, satır sayıları, medyan) `output/tables` ile karşılaştırıldı; eşleşiyor. 7c filtresinden önceki eski sayılar (16.331, 4.449 vb.) notlarda kalmadı (4.449 sadece "medyan değişti" açıklamasında, bilerek). |
| Script çıktısında olmayan sayılar | ✅ Giderildi: notlardaki bütün sayıların kaynağı artık scriptlerin çıktısı (r, medyan fiyatlar, oda tipine göre ortalamalar, Cox & Snell maksimumu, accommodates dağılımı, +100 birim odds oranları). Notlarda hangi script çıktısından geldiği yazıyor. |

## Çalıştırma kontrolü
- Kararlar uygulandıktan sonra 01 → 06 her biri ayrı ve temiz bir R oturumunda (`Rscript --vanilla`) yeniden çalıştırıldı:
  **hepsi exit 0, 0 hata, 0 uyarı**. Temiz veri (`data/clean_listings.csv`) bire bir aynı çıktı.
- `output/appendix_R_codes.R` scriptlerden yeniden oluşturuldu (6 bölümün her biri ilgili scriptle bire bir aynı) ve
  tek oturumda baştan sona çalıştırıldı: **0 hata, 0 uyarı**.
- Konsolda görünen tek ek mesaj `tidyverse` yüklenirken çıkan "Conflicts: dplyr::filter() masks stats::filter()"
  bilgisi → uyarı değil; dplyr'in `filter`/`lag` fonksiyonlarının R'ın temel `stats` paketindekileri gölgelediğini söyler.
  Projede sorun yaratmaz.
- `R/06`'da `hoslem.test()` Model 1 için "The data did not allow for the requested number of bins" uyarısı üretir;
  script bu uyarıyı **bilerek yakalayıp** tabloya not olarak yazar (6/10 grup). Bu yüzden konsolda uyarı görünmez.
