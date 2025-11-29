----------------------------------------------------
-- HASTANE YÖNETÝM SÝSTEMÝ (HYS) - SQL PROJESÝ
-- Oluþturan: Güner
-- Ýçerik: Tablolar, Trigger, Procedure, View, Test Verileri
----------------------------------------------------

----------------------------------------------------
-- 0) VERÝTABANI OLUÞTURMA
----------------------------------------------------
IF DB_ID('HYS') IS NULL
    CREATE DATABASE HYS;
GO

USE HYS;
GO

----------------------------------------------------
-- 1) TABLOLAR
----------------------------------------------------

-- 1.1 Klinik
IF OBJECT_ID('Klinik') IS NOT NULL DROP TABLE Klinik;
CREATE TABLE Klinik (
    KlinikID INT IDENTITY PRIMARY KEY,
    KlinikAdi NVARCHAR(100) NOT NULL
);

-- 1.2 SigortaSirketi
IF OBJECT_ID('SigortaSirketi') IS NOT NULL DROP TABLE SigortaSirketi;
CREATE TABLE SigortaSirketi (
    SigortaSirketiID INT IDENTITY PRIMARY KEY,
    Ad NVARCHAR(100) NOT NULL
);

-- 1.3 Doktor
IF OBJECT_ID('Doktor') IS NOT NULL DROP TABLE Doktor;
CREATE TABLE Doktor (
    DoktorID INT IDENTITY PRIMARY KEY,
    AdSoyad NVARCHAR(100) NOT NULL,
    Unvan NVARCHAR(50),
    KlinikID INT FOREIGN KEY REFERENCES Klinik(KlinikID)
);

-- 1.4 Hasta
IF OBJECT_ID('Hasta') IS NOT NULL DROP TABLE Hasta;
CREATE TABLE Hasta (
    HastaID INT IDENTITY PRIMARY KEY,
    AdSoyad NVARCHAR(100),
    TcNo CHAR(11) UNIQUE,
    DogumTarihi DATE,
    Telefon NVARCHAR(20),
    SigortaSirketiID INT FOREIGN KEY REFERENCES SigortaSirketi(SigortaSirketiID),
    SigortaNo NVARCHAR(50)
);

-- 1.5 Ilac
IF OBJECT_ID('Ilac') IS NOT NULL DROP TABLE Ilac;
CREATE TABLE Ilac (
    IlacID INT IDENTITY PRIMARY KEY,
    IlacAdi NVARCHAR(100),
    BirimFiyat DECIMAL(10,2) CHECK (BirimFiyat >= 0)
);

-- 1.6 Randevu
IF OBJECT_ID('Randevu') IS NOT NULL DROP TABLE Randevu;
CREATE TABLE Randevu (
    RandevuID INT IDENTITY PRIMARY KEY,
    HastaID INT FOREIGN KEY REFERENCES Hasta(HastaID),
    DoktorID INT FOREIGN KEY REFERENCES Doktor(DoktorID),
    RandevuTarihi DATETIME2 NOT NULL,
    Durum NVARCHAR(20) CHECK (Durum IN ('Planlandý','Gerçekleþti','Ýptal')),
    Aciklama NVARCHAR(250)
);

-- 1.7 Recete
IF OBJECT_ID('Recete') IS NOT NULL DROP TABLE Recete;
CREATE TABLE Recete (
    ReceteID INT IDENTITY PRIMARY KEY,
    HastaID INT FOREIGN KEY REFERENCES Hasta(HastaID),
    DoktorID INT FOREIGN KEY REFERENCES Doktor(DoktorID),
    RandevuID INT FOREIGN KEY REFERENCES Randevu(RandevuID),
    Tarih DATETIME2 DEFAULT SYSUTCDATETIME()
);

-- 1.8 ReceteKalem
IF OBJECT_ID('ReceteKalem') IS NOT NULL DROP TABLE ReceteKalem;
CREATE TABLE ReceteKalem (
    ReceteKalemID INT IDENTITY PRIMARY KEY,
    ReceteID INT FOREIGN KEY REFERENCES Recete(ReceteID),
    IlacID INT FOREIGN KEY REFERENCES Ilac(IlacID),
    Adet INT CHECK (Adet > 0),
    KullanýmNotu NVARCHAR(200)
);

-- 1.9 Tahlil
IF OBJECT_ID('Tahlil') IS NOT NULL DROP TABLE Tahlil;
CREATE TABLE Tahlil (
    TahlilID INT IDENTITY PRIMARY KEY,
    HastaID INT FOREIGN KEY REFERENCES Hasta(HastaID),
    DoktorID INT FOREIGN KEY REFERENCES Doktor(DoktorID),
    RandevuID INT FOREIGN KEY REFERENCES Randevu(RandevuID),
    TahlilTuru NVARCHAR(100) NOT NULL,
    Sonuc NVARCHAR(500),
    Tarih DATETIME2 DEFAULT SYSUTCDATETIME()
);

-- 1.10 Fatura
IF OBJECT_ID('Fatura') IS NOT NULL DROP TABLE Fatura;
CREATE TABLE Fatura (
    FaturaID INT IDENTITY PRIMARY KEY,
    HastaID INT FOREIGN KEY REFERENCES Hasta(HastaID),
    FaturaTarihi DATETIME2 DEFAULT SYSUTCDATETIME(),
    ToplamTutar DECIMAL(10,2) DEFAULT 0,
    Odendi BIT DEFAULT 0
);

-- 1.11 FaturaKalem
IF OBJECT_ID('FaturaKalem') IS NOT NULL DROP TABLE FaturaKalem;
CREATE TABLE FaturaKalem (
    FaturaKalemID INT IDENTITY PRIMARY KEY,
    FaturaID INT FOREIGN KEY REFERENCES Fatura(FaturaID),
    Aciklama NVARCHAR(200),
    Tutar DECIMAL(10,2)
);

----------------------------------------------------
-- 2) TRIGGER
----------------------------------------------------
IF OBJECT_ID('TR_Randevu_DoktorCakisma', 'TR') IS NOT NULL
    DROP TRIGGER TR_Randevu_DoktorCakisma;
GO

CREATE TRIGGER TR_Randevu_DoktorCakisma
ON Randevu
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Randevu R
        JOIN inserted I 
          ON R.DoktorID = I.DoktorID
         AND R.RandevuTarihi = I.RandevuTarihi
         AND R.RandevuID <> I.RandevuID
        WHERE R.Durum <> 'Ýptal'
          AND I.Durum <> 'Ýptal'
    )
    BEGIN
        RAISERROR('Ayný doktora ayný saatte iki randevu verilemez.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

----------------------------------------------------
-- 3) STORED PROCEDURE
----------------------------------------------------
IF OBJECT_ID('FaturaToplamGuncelle', 'P') IS NOT NULL
    DROP PROCEDURE FaturaToplamGuncelle;
GO

CREATE PROCEDURE FaturaToplamGuncelle
    @FaturaID INT
AS
BEGIN
    DECLARE @Toplam DECIMAL(10,2);

    SELECT @Toplam = SUM(Tutar)
    FROM FaturaKalem
    WHERE FaturaID = @FaturaID;

    UPDATE Fatura
    SET ToplamTutar = ISNULL(@Toplam,0)
    WHERE FaturaID = @FaturaID;
END;
GO

----------------------------------------------------
-- 4) VIEW
----------------------------------------------------
IF OBJECT_ID('vw_HastaGecmisi', 'V') IS NOT NULL
    DROP VIEW vw_HastaGecmisi;
GO

CREATE VIEW vw_HastaGecmisi
AS
SELECT 
    H.HastaID,
    H.AdSoyad,
    R.RandevuTarihi,
    D.AdSoyad AS DoktorAdSoyad,
    K.KlinikAdi,
    F.ToplamTutar,
    F.Odendi
FROM Hasta H
LEFT JOIN Randevu R ON R.HastaID = H.HastaID
LEFT JOIN Doktor D ON D.DoktorID = R.DoktorID
LEFT JOIN Klinik K ON K.KlinikID = D.KlinikID
LEFT JOIN Fatura F ON F.HastaID = H.HastaID;
GO

----------------------------------------------------
-- 5) TEST VERÝLERÝ
----------------------------------------------------
INSERT INTO Klinik (KlinikAdi) VALUES ('Dahiliye'), ('Kardiyoloji');
INSERT INTO SigortaSirketi (Ad) VALUES ('SGK'), ('Özel Sigorta');

INSERT INTO Doktor (AdSoyad, Unvan, KlinikID) VALUES
('Dr. Ahmet Demir','Uzman Doktor',1),
('Dr. Ayþe Yýlmaz','Prof. Dr.',2);

INSERT INTO Hasta (AdSoyad, TcNo, DogumTarihi, Telefon, SigortaSirketiID, SigortaNo)
VALUES ('Güner Yýlmaz','12345678901','2002-12-13','05550000000',1,'SGK-001');

----------------------------------------------------
-- PROJE TAMAMLANDI
----------------------------------------------------
