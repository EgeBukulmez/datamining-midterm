# 00 — Rapor Haritası (Yönerge Part 5)

> Her rapor bölümü için hangi tablo, grafik, not ve kodun kullanılacağı.
> `T/` = `output/tables/`, `F/` = `output/figures/`, `N/` = `notlar/`, `R/` = scriptler
> Rapor metnini sen yazacaksın; notlar sadece taslak fikir içerir.

| Rapor bölümü | Yönerge | Tablolar | Grafikler | Notlar | Kod (Ek'teki bölüm) |
|---|---|---|---|---|---|
| **1. Introduction** — veri seti ve projenin amacı | 1.1, Part 5 | — | — | `CLAUDE.md` §5 (kaynak, tarih), `N/02` §1.5 (high_price'ın anlamı) | — |
| **2. Dataset Description** | 1.1, 1.2 | `T/variable_description.csv` (değişken açıklama tablosu), `T/02_high_price_distribution.csv` | — | `N/01` §1.2, `N/02` §1.5 ve §1.1 şart tablosu | Bölüm 1 (yükleme), Bölüm 2 (1.5) |
| — Kaynak | 1.1 | — | — | `CLAUDE.md` §5, `N/01` §1.2: Inside Airbnb, Istanbul, `listings.csv.gz`, 25 Eylül 2026 tarihli veri yayını (veri toplama: 28–29 Eylül 2026), insideairbnb.com/get-the-data, CC lisansı | — |
| — Gözlem / değişken sayısı | 1.1, 1.2 | `T/02_cleaning_log.csv` (27.232 → 16.303) | — | `N/01` (27.232 × 90), `N/02` (16.303 × 10) | Bölüm 1, 2 |
| — Sayısal Y | 1.1 | `T/variable_description.csv` | — | `N/02` | — |
| — İkili Y oluşturma + eşik gerekçesi | 1.1, 1.5 | `T/02_high_price_distribution.csv` | — | `N/02` §1.5 (medyan 4.457,5 TL, gerekçe fikirleri, doğrulama) | Bölüm 2 (1.5) |
| **3. Data Exploration and Preprocessing** | 1.3–1.6 | | | | |
| — İlk inceleme (head/dim/str/summary) | 1.3 | — (konsol çıktısı; seçilmiş kısımları kopyala) | — | `N/01` "1.3 İlk inceleme" | Bölüm 1 |
| — Tespit edilen sorunlar | 1.3 | `T/01_problem_summary.csv` | — | `N/01` A–E | Bölüm 1 |
| — Temizleme işlemleri | 1.4 | `T/02_cleaning_log.csv` (adım adım satır sayıları) | — | `N/02` Adım 1–9 (her işlemin gerekçesi) | Bölüm 2 |
| — Değişken dönüşümleri | 1.4 | `T/variable_description.csv` ("source" sütunu) | — | `N/02` Adım 2 (price), 6 (bathrooms, shared_bath), 9 (factor) | Bölüm 2 |
| — Son kontrol | 1.6 | — (str/summary/dim konsol çıktısı) | — | `N/02` §1.6 ("regresyona hazır mı") | Bölüm 2 (1.6) |
| **4.1 Simple Linear Regression** | 2.1 | `T/03_simple_linear.csv` (B, SE, t, p, F, R², düz. R²), `T/03_simple_linear_predictions.csv` | — | `N/03` Madde 1–10 | Bölüm 3 |
| **4.2 Multiple Linear Regression** | 2.2 | | | | |
| — Başlangıç modeli + anlamlılık | Step 1 | `T/04_table1_initial_model.csv` (**Tablo 1**) | — | `N/04` Step 1 (referanslar, room_type bütün olarak) | Bölüm 4 |
| — Revizyon süreci | Step 2 | `T/04_revision_log.csv` (boş — hiç değişken çıkarılmadı) | — | `N/04` Step 2 | Bölüm 4 |
| — Son model | Step 3 | `T/04_table2_final_model.csv` (**Tablo 2**; son satır = tablo altı notu), `T/04_model_comparison.csv` | — | `N/04` Step 3 (denklem, F, R²) | Bölüm 4 |
| — Sayısal ve kategorik katsayıların yorumu | Step 3, Special Rule | Tablo 2 | — | `N/04` "Katsayıların yorumu", "Special Rule kontrolü" | Bölüm 4 |
| — R² ve düz. R² | Step 3 | `T/04_model_comparison.csv`, `T/03_simple_linear.csv` (karşılaştırma) | — | `N/04` Step 3, "Explain maddeleri" | Bölüm 4 |
| **5. Binary Logistic Regression Results** | 3.1–4.3 | | | | |
| — Model 1 (sayısal X) | 3.1, 4.1–4.3 | `T/05_model1.csv`, `T/05_model1_predicted_probabilities.csv`, `T/06_logistic_summary.csv` (satır 1) | `F/06_model1_probability_curve.png` | `N/05` Model 1 (denklem, olasılıklar), `N/06` (HL 6 grup, pseudo R², matris, grafik) | Bölüm 5, 6 |
| — Model 2 (iki kategorili X) | 3.2, 4.1–4.3 | `T/05_model2.csv`, `T/06_logistic_summary.csv` (satır 2) | `F/06_model2_probability.png` | `N/05` Model 2, `N/06` (HL uygulanamaz gerekçesi) | Bölüm 5, 6 |
| — Model 3 (3+ kategorili X) | 3.3, 4.1–4.3 | `T/05_model3.csv`, `T/06_logistic_summary.csv` (satır 3) | `F/06_model3_probability.png` | `N/05` Model 3 (her kategorinin odds'u), `N/06` | Bölüm 5, 6 |
| — Model 4 (karma) | 3.4, 4.1–4.3 | `T/05_model4.csv`, `T/06_logistic_summary.csv` (satır 4) | `F/06_model4_probability_curves.png` | `N/05` Model 4 (sayısal/kategorik yorum), `N/06` (sabitleme kuralı) | Bölüm 5, 6 |
| — Karışıklık matrisleri | 4.2 | `T/06_logistic_summary.csv` (TN, FP, FN, TP) — yönerge düzenindeki 2×2 tabloyu buradan kur | — | `N/06` §4.2 (okuma, taban orana göre yorum) | Bölüm 6 |
| — Odds / olasılık açıklaması | 3.x | — | — | `N/05` "Önce temel" bölümü | — |
| **6. Conclusion** | Part 5 | `T/04_table2_final_model.csv`, `T/06_logistic_summary.csv` | — | `N/03` Madde 10, `N/04` Explain, `N/05` Madde 9, `N/06` özet | — |
| **7. Appendix – R Codes** | Part 5 | — | — | — | `output/appendix_R_codes.R` (Bölüm 1–6, her başlıkta yönerge maddesi) |

## Raporda mutlaka açıklanması gereken noktalar (kontrol listesinden)
1. **2.2 Step 2:** hiçbir değişken çıkarılmadı → "son model = başlangıç modeli" ve nedeni.
2. **Tablo 2:** Private room / Shared room kuklaları tek başına anlamsız ama room_type bütün olarak anlamlı → tablo altına not.
3. **4.1 HL:** Model 2 ve 3'te uygulanamaz (gerekçe `N/06`); Model 1'de 10 yerine 6 grup oluştu.
4. **4.3:** Model 2 ve 3'te sayısal X olmadığı için eğri yerine kategori başına olasılık grafiği.
5. **Veri tarihi:** "25 Eylül 2026 tarihli veri yayını (veri toplama: 28–29 Eylül 2026)" — Dataset Description'da bu ifadeyle yaz.
6. **p değerleri:** R'da 0 veya `<2e-16` görünenler raporda "p < 0,001" (tablolardaki `p_report` sütunu).
