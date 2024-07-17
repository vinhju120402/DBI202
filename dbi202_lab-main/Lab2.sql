/**
        +--------------------------+
        |        DBI202_LAB        | 
        |          LAB02           |
        |       Ho Nhat Minh       |
        |         FX03283          |
        +--------------------------+
**/

-- Tạo Database
DROP DATABASE IF EXISTS DBI202_LAB
GO

CREATE DATABASE DBI202_LAB
GO

-- I. Tạo các bảng và ràng buộc
-- Bảng KHACHANG
CREATE TABLE KHACHHANG
(
    MAKH NVARCHAR(5) NOT NULL PRIMARY KEY,
    TENKH NVARCHAR(30) NOT NULL,
    DIACHI NVARCHAR(300),
    DT VARCHAR(10),
    EMAIL VARCHAR(30)
)
-- Ràng buộc cần có trong bảng: TENKH not null, 
-- DT có thể từ 7 đến 10 chữ số. 
ALTER TABLE KHACHHANG
ADD CONSTRAINT chk_khachhang_dt CHECK (LEN(DT) BETWEEN 7 AND 10)

-- Bảng VATTU
CREATE TABLE VATTU
(
    MAVT NVARCHAR(5) NOT NULL PRIMARY KEY,
    TENVT NVARCHAR(30) NOT NULL,
    DVT NVARCHAR(20),
    GIAMUA MONEY,
    SLTON INT
)
-- Ràng buộc cần có trong bảng:
-- TENVT not null, GIAMUA >0, SLTON >=0.
ALTER TABLE VATTU
ADD CONSTRAINT chk_vattu_giamua CHECK (GIAMUA > 0)

ALTER TABLE VATTU
ADD CONSTRAINT chk_vattu_slton CHECK (SLTON >= 0)

-- Bảng HOADON
CREATE TABLE HOADON
(
    MAHD NVARCHAR(10) NOT NULL PRIMARY KEY,
    NGAY DATETIME,
    MAKH NVARCHAR(5),
    TONGGT MONEY
)
-- Ràng buộc cần có trong bảng: MAKH là khóa ngoại tham chiếu tới MAKH trong bảng KHACHHANG.
ALTER TABLE HOADON
ADD FOREIGN KEY (MAKH) REFERENCES KHACHHANG(MAKH)

-- Bảng CHITIETHOADON\
DROP TABLE CHITIETHOADON
CREATE TABLE CHITIETHOADON
(
    MAHD NVARCHAR(10),
    MAVT NVARCHAR(5),
    SL INT,
    KHUYENMAI DECIMAL,
    GIABAN MONEY
        PRIMARY KEY (MAHD, MAVT)
)
-- Ràng buộc cần có trong bảng MAHD là khóa ngoại tham chiếu tới MAHD trong bảng HOADON, MAVT là khóa ngoại tham chiếu tới MAVT trong bảng VATTU. Giá trị nhập vào cho trường SL phải lớn hơn 0
ALTER TABLE CHITIETHOADON
ADD FOREIGN KEY (MAHD) REFERENCES HOADON(MAHD)

ALTER TABLE CHITIETHOADON
ADD FOREIGN KEY (MAVT) REFERENCES VATTU(MAVT)

ALTER TABLE CHITIETHOADON
ADD CONSTRAINT chk_chitiethoadon_sl CHECK (SL > 0)

-- II. Nhập dữ liệu vào bảng
-- Bảng VATTU
INSERT VATTU
    (MAVT, TENVT, DVT, GIAMUA, SLTON)
VALUES
    ('VT01', 'XI MANG', 'BAO', 50000, 5000),
    ('VT02', 'CAT', 'KHOI', 45000, 50000),
    ('VT03', 'GACH ONG', 'VIEN', 120, 800000),
    ('VT04', 'GACH THE', 'VIEN', 110, 800000),
    ('VT05', 'DA LON', 'KHOI', 25000, 100000),
    ('VT06', 'DA NHO', 'KHOI', 33000, 100000),
    ('VT07', 'LAM GIO', 'CAI', 15000, 50000);

-- Bảng KHACHHANG
INSERT KHACHHANG
    (MAKH, TENKH, DIACHI, DT, EMAIL)
VALUES
    ('KH01', 'NGUYEN THI BE', 'TAN BINH', '8457895', 'bnt@yahoo.com
'),
    ('KH02', 'LE HOANG NAM', 'BINH CHANH', '9878987', 'namlehoang @abc.com.vn'),
    ('KH03', 'TRAN THI CHIEU', 'TAN BINH', '8457895', NULL),
    ('KH04', 'MAI THI QUE ANH', 'BINH CHANH', NULL, NULL),
    ('KH05', 'LE VAN SANG', 'QUAN 10', NULL, 'sanglv@hcm.vnn.vn'),
    ('KH06', 'TRAN HOANG KHAI', 'TAN BINH', '8457897', NULL)

-- Bảng HOADON
INSERT HOADON
    (MAHD, NGAY, MAKH, TONGTG)
VALUES
    ('HD001', '2000-05-12', 'KH01', 82000),
    ('HD002', '2000-05-25', 'KH02', 150),
    ('HD003', '2000-05-25', 'KH01', 55000),
    ('HD004', '2000-05-25', 'KH04', 270),
    ('HD005', '2000-05-26', 'KH04', 82000),
    ('HD006', '2000-05-02', 'KH03', 120),
    ('HD007', '2000-06-22', 'KH04', 125),
    ('HD008', '2000-06-25', 'KH03', 102000),
    ('HD009', '2000-08-15', 'KH04', 48000),
    ('HD010', '2000-09-30', 'KH01', 57000);

-- Bảng CHITIETHOADON
INSERT CHITIETHOADON
    (MAHD, MAVT, SL, GIABAN)
VALUES
    ('HD001', 'VT01', 5, 52000),
    ('HD001', 'VT05', 10, 30000),
    ('HD002', 'VT03', 10000, 150),
    ('HD003', 'VT02', 20, 55000),
    ('HD004', 'VT03', 50000, 150),
    ('HD004', 'VT04', 20000, 120),
    ('HD005', 'VT05', 10, 30000),
    ('HD005', 'VT06', 15, 35000),
    ('HD005', 'VT07', 20, 17000),
    ('HD006', 'VT04', 10000, 120),
    ('HD007', 'VT04', 20000, 125),
    ('HD008', 'VT01', 100, 55000),
    ('HD008', 'VT02', 20, 47000),
    ('HD009', 'VT02', 25, 48000),
    ('HD010', 'VT01', 25, 57000)

SELECT *
FROM CHITIETHOADON