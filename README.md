 Hospital-Management-System-HYS
SQL Server ile geliştirilmiş Hastane Yönetim Sistemi (HYS). İçerisinde ilişkisel veritabanı tasarımı, trigger, stored procedure, view ve fatura hesaplama modülleri bulunmaktadır.
 HYS – Hastane Yönetim Sistemi (SQL Server)

Bu proje, Microsoft SQL Server üzerinde geliştirilmiş tam kapsamlı bir **Hastane Yönetim Sistemi (HYS)** veritabanıdır.  
Sistem; klinik, doktor, hasta, randevu, reçete, tahlil ve faturalandırma gibi hastane operasyonlarının tamamını yönetebilecek şekilde tasarlanmıştır.

---

 Özellikler (Highlights)

- **İlişkisel Veritabanı Tasarımı**
  - Klinik, doktor, hasta, ilaç, randevu, reçete, tahlil ve fatura modülleri
  - Primary Key & Foreign Key ilişkileri
  - Veri bütünlüğü için UNIQUE ve CHECK kuralları

- **İş Kuralları**
  - Aynı doktora aynı saatte ikinci randevuyu engelleyen **AFTER TRIGGER**
  - Fatura toplamını otomatik hesaplayan **Stored Procedure**
  - Test verileri için hazır INSERT komutları

- **Raporlama**
  - Hastanın geçmiş tüm randevu, klinik ve fatura bilgilerini birleştiren **View (vw_HastaGecmisi)**

- **Performans**
  - Sık kullanılan alanlar için doğru index yapısı
  - Atomic işlemler için veri tutarlılığı

---

 Proje Dosyaları

 Dosya         Açıklama 
 **HYS.bak** : Veritabanının tam yedek dosyası 
 **HYS_Proje.sql** : Tüm tablo, trigger, view ve procedurlerin olduğu tam SQL proje dosyası 
 **README.md** :Projenin açıklama ve dokümantasyon dosyası 

---

 Veritabanı Mimarisi

 Tablolar
- Klinik  
- SigortaSirketi  
- Doktor  
- Hasta  
- Ilac  
- Randevu  
- Recete  
- ReceteKalem  
- Tahlil  
- Fatura  
- FaturaKalem  

 Trigger
- **TR_Randevu_DoktorCakisma**  
  → Aynı doktora aynı tarih/saatte ikinci randevuyu engeller.

 Stored Procedure
- **FaturaToplamGuncelle**  
  → FaturaKalem tablosundaki tutarları toplayıp Fatura tablosuna yazar.

 View
- **vw_HastaGecmisi**  
  → Hasta geçmişi (randevular + klinik + fatura) tek sorguda.

---

 Test Verileri

HYS_Proje.sql dosyasında örnek veriler bulunmaktadır.  
Bunlar:

- Klinikler  
- Doktorlar  
- Hastalar  
- Deneme randevuları  

Eğitim ve test amaçlıdır.

---

Kurulum ve Çalıştırma

 Veritabanı Yedeğini (HYS.bak) Geri Yüklemek
SQL Server Management Studio →  
**Databases** → Sağ tık → **Restore Database**

1. Source → Device
2. HYS.bak dosyasını seç
3. Restore işlemini başlat

### 2️⃣ SQL Kodlarını Manuel Oluşturmak
`HYS_Proje.sql` dosyasını SSMS üzerinde çalıştırabilirsiniz.

---

 Amaç

Bu proje;  
SQL Server, veri modelleme, trigger, stored procedure ve view gibi kurumsal seviye veritabanı becerilerini göstermek isteyen adaylar için hazırlanmıştır.

---

 Geliştirici

Günernur DEMİR
Düzce Üniversitesi Bilgisayar Mühendisliği Öğrencisi  


---

Projeyi beğendiysen ⭐ yıldız bırakmayı unutma!  

