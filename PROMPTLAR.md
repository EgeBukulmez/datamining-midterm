# Claude Code Promptları — sırayla ver

Her promptu ayrı ayrı ver. Bir sonrakine geçmeden önce çıktıyı oku, kodu RStudio'da kendin çalıştır,
anlamadığın yeri sor. ⚠️ işaretli yerlerde karar senin.

---

## Prompt 0 — Kurulum kontrolü
```
CLAUDE.md ve HOCA_YONERGE.md dosyalarını baştan sona oku. Ardından:
1. R'ın kurulu olup olmadığını ve sürümünü kontrol et (Rscript --version).
2. tidyverse, ResourceSelection, DescTools ve car paketlerinin kurulu olup olmadığını kontrol et.
   Eksik varsa hangi komutla kuracağımı söyle, kendin kurma.
3. CLAUDE.md'deki klasör yapısını oluştur ve data/listings.csv.gz dosyasının yerinde olduğunu doğrula.
4. Yönergeyi kendi cümlelerinle 10 maddede özetle ki aynı şeyi anladığımızdan emin olalım.
Henüz analiz yapma.
```

## Prompt 1 — Veri yükleme ve ilk inceleme (Yönerge 1.2, 1.3)
```
R/01_import_explore.R dosyasını yaz.
- Veriyi read_csv() ile yükle; dosya formatını, kullanılan fonksiyonu, gözlem ve değişken sayısını raporla (1.2).
- head(), dim(), str(), summary() ile incele (1.3).
- Şu sorunları tespit eden kod ekle ve sonuçlarını göster: yanlış veri tipleri, eksik değerler,
  tutarsız kategorik değerler, olağandışı sayısal değerler, olası veri giriş hataları.
- Bulduğun her sorunu kısa bir tabloyla özetle (sorun, değişken, kaç satır, örnek).
- Bu aşamada hiçbir şeyi düzeltme.
- notlar/01_inceleme.md dosyasına bulguları Türkçe madde madde yaz.
Sonunda bana hangi değişkenleri modelde kullanmayı düşünebileceğimi aday olarak listele, seçimi bana bırak.
```

## ⚠️ Karar noktası 1 — Prompt 2'den önce kendin karar ver
- Hangi sayısal X'ler? (en az 4 sayısal değişken veri setinde olacak)
- İki kategorili X: `host_is_superhost` mi?
- 3+ kategorili X: `room_type` mu, gruplanmış ilçe mi?
- Fiyat uç değerleri: hangi kural? (ör. %1–%99 dışını çıkarmak, belirli bir TL üst sınırı…)
- `minimum_nights` = 100 olan ilanlar: çıkarılsın mı?
- Yorumu olmayan ilanlardaki eksik puan: satırı çıkarmak mı, puanı kullanmamak mı?
- Y = `price` mı, `log(price)` mı?

## Prompt 2 — Temizleme (Yönerge 1.4)
```
R/02_cleaning.R dosyasını yaz. Kararlarım şunlar:
- Kullanılacak değişkenler: [BURAYA YAZ]
- Fiyat uç değer kuralı: [BURAYA YAZ]
- minimum_nights = 100: [BURAYA YAZ]
- Eksik puanlar: [BURAYA YAZ]
- Y: [price / log(price)]
Bu kararlara göre yönerge 1.4'teki işlemleri uygula: tip dönüşümleri, kategorik değişkenleri yeniden kodlama,
gereken yeni değişkenleri oluşturma, eksik değerleri ele alma.
Her işlemden önce ve sonra kaç satır kaldığını yazdır. Her değişikliğin yanına neden yapıldığını yorum olarak yaz.
Henüz ikili Y'yi oluşturma. notlar/02_temizleme.md'ye yapılan her işlemi ve gerekçesini Türkçe yaz.
```

## ⚠️ Karar noktası 2 — İkili Y eşiği
Medyan mı, anlamlı bir TL değeri mi? Gerekçeni kendin yaz (yönerge 1.5 bunu istiyor).

## Prompt 3 — İkili Y ve son kontrol (Yönerge 1.5, 1.6)
```
02_cleaning.R dosyasına devam et:
- [EŞİK] eşiğini kullanarak price'tan ikili bir değişken oluştur (0 = referans sonuç, 1 = hedef sonuç).
- Her kategorideki gözlem sayısını ve yüzdesini raporla.
- Değişkenin doğru oluşturulduğunu doğrula (ör. çapraz kontrol: her gruptaki price min/max değerleri).
- Son kontrolü str(), summary(), dim() ile yap (1.6) ve son gözlem/değişken sayısını raporla.
- Temiz veriyi data/clean_listings.csv olarak kaydet.
- Yönergedeki 1.1 şartlarını (≥100 gözlem, ≥4 sayısal, ≥3 kategorik, iki kategorili X, 3+ kategorili X)
  tek tek kontrol eden bir tablo yazdır.
- Değişken açıklama tablosunu (1.1) output/tables/variable_description.csv olarak hazırla.
```

## Prompt 4 — Basit doğrusal regresyon (Yönerge 2.1)
```
R/03_simple_linear.R dosyasını yaz. Y ~ [SAYISAL X] modelini kur.
Yönerge 2.1'deki 10 maddeyi sırayla karşıla. output/tables/ altına
B, SE, t, p, F ve p'si, R², düzeltilmiş R² içeren tabloyu kaydet.
Tahmini regresyon denklemini yazdır, en az bir tahmin örneği hesapla.
notlar/03_basit_regresyon.md'ye her sayının ne anlama geldiğini Türkçe madde madde yaz.
```

## Prompt 5 — Çoklu doğrusal regresyon (Yönerge 2.2)
```
R/04_multiple_linear.R dosyasını yaz.
Step 1: Başlangıç modelini [SAYISAL X'LER] + [İKİ KATEGORİLİ X] + [3+ KATEGORİLİ X] ile kur.
Faktörleri ve referans kategorileri açıkça belirt. F testini ve her değişkenin anlamlılığını raporla.
3+ kategorili değişkenin anlamlılığını car::Anova ile bütün olarak test et.
Step 2: Anlamsız değişkenleri birer birer (en yüksek p'den başlayarak) çıkar ve her adımı kaydet;
tüm değişkenler anlamlı olana kadar devam et.
Step 3: Son modeli raporla: denklem, R², düzeltilmiş R², başlangıç modelinden farkı.
Yönergedeki "Special Rule"u kontrol et: son modelde yalnızca bir tür X kaldıysa diğer türden
başlangıç modelindeki bir katsayının yorumunu da hazırla.
Tablo 1 ve Tablo 2'yi output/tables/ altına kaydet.
notlar/04_coklu_regresyon.md'ye sayısal ve kategorik katsayıların nasıl yorumlanacağını Türkçe yaz.
```

## Prompt 6 — Lojistik modeller (Yönerge 3.1–3.4)
```
R/05_logistic_models.R dosyasını yaz. İkili Y ile 4 model kur:
Model 1: [SAYISAL X], Model 2: [İKİ KATEGORİLİ X], Model 3: [3+ KATEGORİLİ X],
Model 4: [SAYISAL + KATEGORİK X'LER].
Her model için yönergedeki maddeleri sırayla karşıla: referans kategori, B, Exp(B), anlamlılık.
Model 1 için tahmini lojistik denklemi yaz ve örnek tahmini olasılıklar hesapla.
Orijinal price'ı hiçbir modelde bağımsız değişken olarak kullanma.
Sonuçları output/tables/ altına kaydet. notlar/05_lojistik.md'ye Exp(B) yorumlarını Türkçe yaz.
Model uyumu ve accuracy'yi bu adımda yapma (Prompt 7'de yapılacak).
```

## Prompt 7 — Lojistik model değerlendirme ve grafikler (Yönerge 4.1–4.3)
```
R/06_logistic_evaluation.R dosyasını yaz. 4 modelin her biri için:
- Hosmer–Lemeshow testi (ResourceSelection), McFadden, Cox & Snell, Nagelkerke pseudo R² (DescTools).
- 0.50 eşiğiyle karışıklık matrisi (yönergedeki düzende: satır = gerçek, sütun = tahmin) ve accuracy.
- İkili Y'nin sınıf dağılımını yazdır ve accuracy'yi buna göre yorumla.
- Olasılık grafiği (yönerge 4.3): X ekseninde bağımsız değişken, Y ekseninde tahmini olasılık.
  Kategorik modellerde kategori bazında tahmini olasılık; Model 4'te sayısal X ekseni + kategoriler ayrı eğri.
Bütün sonuçları tek bir özet tabloda birleştir (output/tables/logistic_summary.csv).
Grafikleri output/figures/ altına .png olarak kaydet.
notlar/06_degerlendirme.md'ye pseudo R²'lerin neden doğrusal R² gibi yorumlanmadığını Türkçe yaz.
```

## Prompt 8 — Son kontrol (yönergeye uygunluk)
```
HOCA_YONERGE.md'yi baştan sona tekrar oku ve projeyi madde madde kontrol et.
Her yönerge maddesi için: karşılandı mı (✅/❌), hangi dosyada/çıktıda, eksik ne var.
Sonucu notlar/00_kontrol_listesi.md olarak kaydet.
Ayrıca yönergede istenmediği halde eklenmiş bir şey varsa listele.
Bütün R scriptlerini sırayla çalıştırıp hata vermediklerini doğrula.
Son olarak rapor ekine (Appendix – R Codes) konacak şekilde bütün kodu tek bir dosyada birleştir:
output/appendix_R_codes.R
```

## Rapor
Raporu (Part 5'teki bölümler) **sen yazacaksın**. `notlar/` klasöründeki notlar, `output/tables` ve
`output/figures` hazır malzemen. Yazdıktan sonra Claude Code'a şunu diyebilirsin:
```
Yazdığım rapor metnini yönergeye ve çıktılara göre kontrol et: istatistiksel olarak yanlış bir yorum,
eksik bir yönerge maddesi veya tablolarla uyuşmayan bir sayı var mı? Metni yeniden yazma, sadece sorunları listele.
```
