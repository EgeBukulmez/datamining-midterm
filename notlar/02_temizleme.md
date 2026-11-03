# 02 — Veri Temizleme (1.4), İkili Y (1.5), Son Kontrol (1.6)

> Kod: `R/02_cleaning.R` · Temiz veri: `data/clean_listings.csv`
> Tablolar: `output/tables/02_cleaning_log.csv`, `02_high_price_distribution.csv`, `variable_description.csv`
> Ham dosya (`data/listings.csv.gz`) değiştirilmedi; bütün işlemler R kodunda.
> Aşağıdakiler rapor paragrafı değil, kendi metnini yazman için taslak notlardır.

## Özet: satır sayıları (Yönerge 1.4)

| Adım | İşlem | Önce | Sonra | Çıkarılan |
|---|---|---:|---:|---:|
| 1 | Sadece kullanılacak değişkenleri tut (sütun işlemi) | 27.232 | 27.232 | 0 |
| 2 | `price` metinden sayıya | — | — | — |
| 3 | `price` eksik olanları çıkar | 27.232 | 24.553 | 2.679 |
| 4 | `price` %1–%99 persentil dışını çıkar | 24.553 | 24.065 | 488 |
| 5 | `minimum_nights > 30` olanları çıkar | 24.065 | 16.493 | 7.572 |
| 6 | `bathrooms_text` → `bathrooms` (sayı) ve `shared_bath` (Yes/No) | — | — | — |
| 7a | `bedrooms > accommodates` olanları çıkar | 16.493 | 16.454 | 39 |
| 7b | Entire home/apt + 0 banyo olanları çıkar | 16.454 | 16.399 | 55 |
| 7c | `bathrooms > accommodates` olanları çıkar | 16.399 | 16.371 | 28 |
| 8 | `bedrooms` / `bathrooms` eksik olanları çıkar | 16.371 | 16.303 | 68 |
| 9 | Kategorik değişkenleri factor'e çevir | — | — | — |

- **Sonuç:** 27.232 → **16.303 satır** (ham verinin %59,9'u), 90 → **10 sütun** (high_price dahil), kalan eksik değer: **0**.
- En büyük kayıp Adım 5'te (7.572 ilan) → İstanbul verisinde uzun dönem kiralık ilan çok fazla.

## Adım adım ne yapıldı, neden

### Adım 1 — Değişken seçimi
- Tutulanlar: `price` (Y), `accommodates`, `bedrooms`, `bathrooms_text` (geçici), `number_of_reviews`,
  `availability_365`, `host_is_superhost`, `room_type`, `minimum_nights` (geçici).
- Neden: diğer 81 sütun (URL'ler, metinler, 13 tamamen boş sütun, lisans, alt puanlar…) hiçbir modelde kullanılmıyor.
- Yan etki: 1.3'te bulunan bazı sorunlar bu adımla kendiliğinden çözüldü, çünkü ilgili sütunlar artık veride yok:
  boş sütunlar, `beds` uç değerleri ve eksikleri, `maximum_nights > 1125`, `review_scores_rating = 0` ve 9.661 eksik puan,
  `property_type` ve `license` karmaşası. Raporda "analizde kullanılmadığı için çıkarıldı" diye belirtilebilir.

### Adım 2 — `price` sayıya çevrildi (yanlış tip düzeltmesi)
- `"$4,736.32"` → `4736.32`. `parse_number()` `$` işaretini ve binlik virgülü atar.
- Neden: metinle ortalama, regresyon vb. hesaplanamaz. `$` sadece biçim; birim **TL**.

### Adım 3 — Eksik fiyatlar çıkarıldı (2.679 satır)
- Neden: `price` bağımlı değişken. Bağımlı değişkeni doldurmak (ortalama/medyan ile) yapay veri üretmek olur → silmek doğru yol.

### Adım 4 — Fiyat uç değerleri çıkarıldı (488 satır)
- Kural: %1 persentil (**417,28 TL**) altı ve %99 persentil (**38.317,80 TL**) üstü çıkarıldı.
- Persentiller eksik fiyatlar çıkarıldıktan **sonra** hesaplandı.
- Neden: dağılım aşırı sağa çarpık (maks ~4,99 milyon TL). En küçük kareler yöntemi uç değerlere çok duyarlı;
  birkaç aşırı değer regresyon doğrusunu kendine çeker.
- Temizlik sonrası fiyat: min 542 · medyan 4.457,5 · ortalama 5.680 · maks 38.286 TL. Hâlâ sağa çarpık ama aşırı uçlar yok.

### Adım 5 — Uzun dönem kiralıklar çıkarıldı (7.572 satır)
- Kural: `minimum_nights > 30` olan ilanlar çıkarıldı, sonra `minimum_nights` sütunu silindi.
- Neden: en az 1 ay kalınması gereken ilanlar aslında aylık kiralık; gecelik fiyatları kısa konaklamayla karşılaştırılamaz.
  1.3'te görülen "100 gece" yığılması (9.087 ilan) bu adımla temizlendi.
- Analizin kapsamı artık: **kısa dönem (≤ 30 gece) konaklama ilanları**. Raporda belirtmek önemli.

### Adım 6 — İki yeni değişken türetildi (`bathrooms_text`'ten)
- **`bathrooms` (sayısal):** ham `bathrooms` sütunu tamamen boştu, bilgi metindeydi.
  - Metinde sayı varsa o sayı: `"1.5 shared baths"` → 1,5.
  - `Half-bath`, `Private half-bath`, `Shared half-bath` → **0,5** (senin kararın).
  - `No bathroom` → 0 (metin zaten "sıfır" demek). Bu 2 ilan önceki adımlarda çıkmıştı, sonuca etkisi yok.
- **`shared_bath` (iki kategorili):** metinde "shared" geçiyorsa **Yes**, geçmiyorsa **No** (senin kararın).
  - Neden: yönerge 1.1 en az 3 kategorik değişken istiyor; bu 3. kategorik değişken.
  - Örnekler: `"1 shared bath"` → Yes, `"Shared half-bath"` → Yes, `"1 private bath"` → No, `"2 baths"` → No.
  - Etiketler `host_is_superhost` ile tutarlı olsun diye İngilizce "No/Yes" (Hayır/Evet) yazıldı.
- Kod her metin değerinin hangi sayıya ve Yes/No'ya çevrildiğini tablo olarak yazdırıyor → elle kontrol edilebilir.
- Sonra `bathrooms_text` silindi.

### Adım 7 — Veri giriş hataları çıkarıldı
- 7a: `bedrooms > accommodates` → **39 ilan** (ör. 5 yatak odası, 2 misafir).
- 7b: room_type = "Entire home/apt" ve banyo = 0 → **55 ilan**. Bütün bir ev/daire banyosuz olamaz.
- 7c: `bathrooms > accommodates` → **28 ilan** (senin kararın, 7a ile aynı mantık).
  - Ör. 2 kişilik "Private room" için 34 banyo. Muhtemelen otel/hostel binasının **toplam** banyo sayısı tek ilana yazılmış.
  - Bu kuraldan sonra banyo maksimumu 34 → 15'e indi (15 yatak odalı, 16 kişilik büyük bir ev; mantıklı).
- Not: 1.3'te bu sayılar daha büyüktü (241, 89); önceki filtreler bu ilanların çoğunu zaten çıkarmıştı.
- **Oda ilanlarında 0 banyo hata sayılmadı, bu ilanlar veride tutuldu (senin kararın).**
  - Temiz veride 0 banyolu **53 ilan** var, hepsi oda ilanı: 52 Private room, 1 Shared room
    (47'si "0 shared baths", 6'sı "0 baths").
  - Gerekçe: oda ilanlarında 0 banyo, **odaya ait banyo olmadığı ve ortak banyo kullanıldığı** anlamına geliyor;
    bu bir veri hatası değil.
  - 0 banyo yalnızca **"Entire home/apt"** ilanlarında hata kabul edildi (Adım 7b), çünkü bütün bir ev/daire
    kiralandığında misafirin kullanabileceği başka bir banyo yoktur.

### Adım 8 — Kalan eksikler çıkarıldı (68 satır)
- `bedrooms`: 5 eksik, `bathrooms` (ve dolayısıyla `shared_bath`): 63 eksik → toplam 68 satır.
- Neden: çok az (%0,4); doldurmak yerine silmek örneklemi neredeyse değiştirmiyor ve yapay değer üretmiyor.

### Adım 9 — Kategorik değişkenler factor'e çevrildi (yeniden kodlama)
- `host_is_superhost`: TRUE/FALSE → factor "No"/"Yes". Referans = **No**. Dağılım: No 10.827 · Yes 5.476.
- `room_type`: 4 kategori. Referans = **Entire home/apt**. Dağılım: Entire home/apt 11.777 · Private room 4.172 ·
  Hotel room 228 · Shared room 126.
- `shared_bath`: factor "No"/"Yes". Referans = **No** (özel banyo). Dağılım: No 15.645 · Yes 658 (%4).
  - Dikkat: "Yes" grubu küçük (658). Modelde kullanılırsa katsayısı biraz daha geniş belirsizlikle tahmin edilir.
- Neden factor: R regresyonda otomatik kukla (dummy) değişken üretir; katsayılar referansa göre yorumlanır.
- CSV factor bilgisini saklamaz → sonraki scriptlerde okurken referanslar yeniden ayarlanacak.

## 1.5 İkili bağımlı değişken: `high_price`

1. **Orijinal sayısal Y:** `price` (gecelik fiyat, TL).
2. **Eşik:** temiz verideki `price` medyanı = **4.457,5 TL**.
   - Banyo filtresi (7c) eklenince medyan 4.449 → 4.457,5 TL oldu; son veri üzerinde hesaplanan değer kullanıldı.
3. **Neden medyan (kendi cümlelerinle yazmak için fikirler):**
   - Veriyi iki eşit gruba böler → sınıflar dengeli (~%50/%50). Dengesiz sınıflarda "hep çoğunluk sınıfını tahmin et"
     bile yüksek accuracy verir; dengeli sınıflarda accuracy daha anlamlı yorumlanır (4.2 ile bağlantılı).
   - Keyfi bir TL değerine dayanmaz, veriden objektif olarak gelir.
   - Fiyat çarpık olduğu için ortalama (5.680) uç değerlerden etkilenir; medyan etkilenmez.
   - Yönerge 1.1 medyanı açıkça kabul edilebilir eşik olarak sayıyor.
   - Anlamı: "1 = İstanbul'daki kısa dönem ilanların üst yarısında fiyatı olan ilan".
4. **Kural:** `high_price = 1` eğer `price > 4457,5`; değilse `0`.
   - 0 = referans sonuç (düşük/orta fiyat), 1 = hedef sonuç (yüksek fiyat).
5. **Dağılım:**

   | high_price | Anlam | n | % |
   |---|---|---:|---:|
   | 0 | Düşük/orta fiyat (referans) | 8.162 | 50,06 |
   | 1 | Yüksek fiyat (hedef) | 8.141 | 49,94 |

   - Tam 50/50 değil çünkü fiyatı **tam medyana eşit** 11 ilan kurala göre 0 grubuna düştü ("büyüktür" kuralı).
6. **Doğrulama:**
   - Grup 0: fiyat 542 – 4.457,5 TL → hepsi medyan ve altı ✔
   - Grup 1: fiyat 4.458 – 38.286 TL → hepsi medyanın üstü ✔
   - Sadece 0 ve 1 değerleri var, eksik yok ✔
   - Kural bağımsız olarak yeniden hesaplandı ve her satırda oluşturulan değişkenle aynı çıktı ✔
- Hatırlatma: `price` lojistik modellerde **bağımsız değişken olarak kullanılmayacak** (yönerge 1.1).

## 1.6 Son kontrol

- `str()`: 6 sayısal (`price`, `accommodates`, `bedrooms`, `bathrooms`, `number_of_reviews`, `availability_365`),
  3 factor (`host_is_superhost`, `room_type`, `shared_bath`), 1 tamsayı 0/1 (`high_price`). Tipler doğru.
- `summary()`: hiçbir değişkende NA yok; değer aralıkları mantıklı (accommodates 1–16, bedrooms 0–15, bathrooms 0–15,
  availability 0–365).
- `dim()`: **16.303 gözlem × 10 değişken**.
- **Regresyona hazır mı?** Evet, gerekçeler:
  - Eksik değer yok, tipler doğru (sayısal değişkenler numeric, kategorikler factor, referanslar belirli).
  - Mantıksız girişler ve aşırı fiyatlar çıkarıldı.
  - Doğrusal regresyon için sayısal Y (`price`), lojistik için ondan türetilen ikili Y (`high_price`) hazır.
  - Gözlem sayısı çok yüksek (16.303) → katsayılar güvenilir tahmin edilir.
  - Hâlâ akılda tutulacak: `price` sağa çarpık (ortalama > medyan); `number_of_reviews` çok çarpık (medyan 9, maks 1.862);
    Hotel room (228), Shared room (126) ve shared_bath = Yes (658) grupları küçük.

## 1.1 Şartların kontrolü

| Şart | Bulunan | Sağlandı mı |
|---|---|---|
| ≥ 100 gözlem | 16.303 | ✔ |
| ≥ 4 sayısal değişken | 6 (price + 5 bağımsız) | ✔ |
| ≥ 3 kategorik değişken | 3 (host_is_superhost, room_type, shared_bath) | ✔ |
| ≥ 1 iki kategorili bağımsız | host_is_superhost, shared_bath | ✔ |
| ≥ 1 üç+ kategorili bağımsız | room_type (4 düzey) | ✔ |
| Sayısal bağımlı değişken | price | ✔ |
| Ondan türetilmiş ikili Y | high_price | ✔ |

- `high_price` de kategorik ama bağımlı değişken olduğu için 3 kategorik değişkene sayılmadı.
- Değişken açıklama tablosu: `output/tables/variable_description.csv` (değişken, tür, rol, açıklama, kaynak, aralık/düzeyler).
  Raporda "Dataset Description" bölümüne girecek; açıklamaları Türkçeye/kendi ifadene çevirebilirsin.
