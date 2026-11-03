# 01 — Veri Yükleme ve İlk İnceleme (Yönerge 1.2, 1.3)

> Kod: `R/01_import_explore.R` · Özet tablo: `output/tables/01_problem_summary.csv`
> Bu aşamada veride **hiçbir şey değiştirilmedi**; sadece sorunlar tespit edildi.
> Aşağıdakiler rapor paragrafı değil, kendi metnini yazman için taslak notlardır.

## 1.2 Veri yükleme

- **Veri seti:** Inside Airbnb — Istanbul, `listings.csv.gz` (Detailed Listings), **25 Eylül 2026 tarihli veri yayını (veri toplama: 28–29 Eylül 2026)**. Kaynak: https://insideairbnb.com/get-the-data/ (Creative Commons).
  - Verideki `last_scraped` sütunu 28–29 Eylül 2026 → yayın tarihi ile toplama tarihi farklı; raporda ikisini birlikte yaz.
- **Dosya formatı:** CSV (virgülle ayrılmış metin), gzip ile sıkıştırılmış (`.csv.gz`).
- **Kullanılan fonksiyon:** `readr::read_csv()`. .gz dosyasını açmadan doğrudan okur.
  - `guess_max = 30000` → sütun tiplerini tahmin ederken bütün satırlara bakar (daha güvenilir tip tahmini).
  - Okuma sırasında **0 ayrıştırma (parsing) hatası** çıktı → dosya sorunsuz okundu.
- **Gözlem sayısı:** 27.232 (her satır bir Airbnb ilanı).
- **Değişken sayısı:** 90.
- Tip dağılımı: 47 sayısal, 20 metin (character), 17 mantıksal (logical), 6 tarih (Date).

## 1.3 İlk inceleme — dört fonksiyon ne gösterdi

- `head()` → ilk 6 satır; her satırın bir ilan olduğunu, `price`'ın `"$4,736.32"` gibi metin olduğunu görüyoruz.
- `dim()` → 27232 × 90.
- `str()` → her değişkenin tipi. Sorunlu tipler buradan yakalandı (aşağıda A).
- `summary()` → sayısal değişkenlerde min/çeyrekler/medyan/ortalama/maks ve NA sayısı.
  Uç değerler ve eksikler buradan yakalandı (aşağıda B, D).

## A) Yanlış veri tipleri

- **`price` metin (character).** Değerler `$` işareti ve binlik virgülü içeriyor (`"$4,736.32"`).
  Sayıya çevrilmeden regresyonda kullanılamaz.
  - Dikkat: işaret `$` ama değerler aslında **Türk Lirası** (Inside Airbnb yerel para birimini bu biçimde yazıyor).
    Medyan ~3.710 olması da TL olduğunu destekliyor.
- **13 sütun tamamen boş** (bütün değerler NA). `read_csv()` tip tahmin edemediği için `logical` okumuş:
  `bathrooms`, `instant_bookable`, `host_since`, `host_response_time`, `host_response_rate`,
  `host_acceptance_rate`, `host_total_listings_count`, `neighbourhood`, `neighbourhood_group_cleansed`,
  `calendar_updated`, `neighborhood_overview`, `host_thumbnail_url`, `host_neighbourhood`.
  → Bilgi taşımıyorlar.
- **Banyo sayısı sayısal sütunda değil.** `bathrooms` boş; bilgi sadece `bathrooms_text` metninde
  (`"1.5 shared baths"`). Kullanılacaksa metinden sayı çıkarılmalı.
- `host_is_superhost` ve `host_identity_verified` ham dosyada `t/f` olarak yazılı;
  `read_csv()` bunları **otomatik olarak doğru tipe (logical: TRUE/FALSE) çevirdi** → tip sorunu yok.
  (CLAUDE.md'de "metin" denmişti; kontrol edince öyle olmadığı görüldü.)
  Modelde kullanılacaksa ileride factor'e çevrilmesi yeterli.

## B) Eksik değerler

- 39 değişkende eksik var; 13'ü %100 boş (yukarıda).
- **`price`: 2.679 eksik (%9,8).** Bağımlı değişken eksikse o satır modelde kullanılamaz.
- **`review_scores_rating` ve `reviews_per_month`: 9.661 eksik (%35,5).**
  - Kontrol: 9.661 ilanın `number_of_reviews` değeri 0 ve eksik puanların **hepsi** bu ilanlar.
  - Yani bu bir hata değil, "hiç yorum almamış ilanın puanı olmaz" durumu (yapısal eksiklik).
  - Karar gerekiyor (aşağıda).
- `beds`: 413 eksik (%1,5), `bathrooms_text`: 111 (%0,4), `bedrooms`: 23 (%0,1) → az.
- `has_availability`: 457, `license`: 9.529, `host_about` / `host_location` vb. → modelde aday değiller.

## C) Tutarsız / sorunlu kategorik değerler

- **`room_type`:** 4 kategori, yazım tutarsızlığı yok. Ama iki kategori çok küçük:
  Entire home/apt 18.362 · Private room 8.440 · **Hotel room 272 · Shared room 158**.
  Küçük kategorilerin katsayıları daha belirsiz (büyük standart hata) çıkar.
- **`host_is_superhost`:** iki kategori, temiz: FALSE 21.257 · TRUE 5.975. Eksik yok.
- **`neighbourhood_cleansed`:** 39 ilçe, fazladan boşluk/yazım farkı yok.
  Ama ilçe boyutları çok dengesiz (Beyoğlu 7.447 … Sultangazi 17). 39 kategori modele 38 kukla değişken demek.
- **`bathrooms_text`:** 60 farklı değer; tek metinde iki bilgi var (banyo sayısı + paylaşımlı/özel).
  157 değerde sayı yok: `Half-bath` (88), `Private half-bath` (40), `Shared half-bath` (27), `No bathroom` (2).
  → Sayıya çevirirken bunlar için kural gerekir (half-bath = 0,5 gibi).
- **`property_type`:** 88 kategori, 63'ünde 30'dan az ilan → modelde doğrudan kullanmaya uygun değil.
- **`license`:** 5.081 farklı serbest metin (`34-1476`, `Exempt`, `Non-real estate listing` …) → kullanılamaz.

## D) Olağandışı sayısal değerler

- **`price` çok sağa çarpık:**
  - Medyan 3.710 TL, %75'lik dilim 6.075, %99'luk dilim ~38.318, **maksimum ~4,99 milyon TL**.
  - Kutu grafiği kuralı (Q3 + 1,5×IQR = 11.733 TL) üstünde **1.656 ilan** var; 100.000 TL üstü 43 ilan.
  - Ortalama, uç değerler yüzünden medyandan çok yüksek → doğrusal regresyonu ciddi etkiler.
  - Uç değer kuralı **senin kararın** (aşağıda).
- **`minimum_nights`:** en sık ikinci değer **100 (9.087 ilan)**; ayrıca 101 (395), 365 (179); 14 ilanda > 365, maks 1.000.
  - 100 gece minimum = muhtemelen **aylık/uzun dönem kiralık**. Bu ilanların "gecelik fiyatı" günlük konaklamayla
    aynı anlamı taşımayabilir.
- **`bedrooms` maks 50, `beds` maks 67** (%99'luk dilimler 5 ve 9) → 37 ilanda bedrooms ≥ 20 veya beds ≥ 30.
- **`maximum_nights` maks 7.000** (Airbnb üst sınırı 1.125).
- `number_of_reviews` maks 1.862 (çarpık ama mümkün), `accommodates` 1–16 (Airbnb sınırı 16, normal).

## E) Olası veri giriş hataları

- `review_scores_rating = 0`: **1 ilan** (puan ölçeği 1–5, 0 geçersiz).
- `bedrooms > accommodates`: **241 ilan** (ör. 5 yatak odası, 2 misafir) → mantıksız.
- `beds > 2 × accommodates`: **177 ilan** (ör. 8 yatak, 2 misafir) → mantıksız.
- `maximum_nights > 1125`: **5 ilan**.
- "Entire home/apt" olup **0 banyo**: 89 ilan → büyük ihtimalle eksik giriş.
- Tekrarlanan `id`: **0** → mükerrer kayıt yok.
- `bedrooms = 0`: 1.039 ilan → hata olmayabilir (stüdyo daire); not olarak dursun.

## Rapor için akılda tutulacaklar

- Yönerge 1.3 "sorunları açıkla" diyor → her sorunun **neden** sorun olduğunu yaz (ör. metin fiyatla hesap yapılamaz,
  uç değerler doğrusal regresyonda katsayıları çeker vb.).
- Yönerge 1.4'te her sorun için ne yapıldığı ayrıca açıklanacak; bu dosyadaki sıra (A–E) oraya da iskelet olabilir.
- `output/tables/01_problem_summary.csv` → raporda "Tespit edilen sorunlar" tablosu olarak kullanılabilir.
