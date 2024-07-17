/**
        +--------------------------+
        |        DBI202_LAB        | 
        |          LAB03           |
        |       Ho Nhat Minh       |
        |         FX03283          |
        +--------------------------+
**/

USE DBI202_LAB
GO
-- Câu 1. Hiển thị danh sách các khách hàng có điện thoại là 8457895 gồm mã khách hàng, tên khách hàng, địa chỉ, điện thoại, và địa chỉ E-mail.
SELECT MAKH, TENKH, DIACHI, DT, EMAIL
FROM KHACHHANG
WHERE DT = '8457895'

-- Câu 2. Hiển thị danh sách các vật tư là “DA”
-- (bao gồm các loại đá) có giá mua dưới 30000 
-- gồm mã vật tư, tên vật tư, đơn vị tính và giá mua .
SELECT MAVT, TENVT, DVT, GIAMUA
FROM VATTU
WHERE TENVT LIKE 'DA%'

-- Câu 3. Tạo query để lấy ra các thông tin gồm 
-- Mã hoá đơn, ngày lập hoá đơn, tên khách hàng, 
-- địa chỉ khách hàng và số điện thoại, 
-- sắp xếp theo thứ tự ngày tạo hóa đơn giảm dần
SELECT MAHD, NGAY, TENKH, DIACHI, DT
FROM HOADON HD, KHACHHANG KH
WHERE HD.MAKH = KH.MAKH
ORDER BY NGAY DESC

-- Câu 4. Lấy Ra danh sách những khách hàng mua hàng trong tháng 6/2000 gồm các thông tin mã khách hàng, địa chỉ, số điện thoại.
SELECT KH.MAKH, DIACHI, DT
FROM KHACHHANG KH, HOADON HD
WHERE KH.MAKH = HD.MAKH
    AND YEAR(NGAY) = 2000 AND MONTH(NGAY) = 6

-- Câu 5. Tạo query để lấy ra các chi tiết hoá đơn gồm các thông tin mã hóa đơn, ,mã vật tư, tên vật tư, giá bán, giá mua, số lượng , trị giá mua
-- (giá mua * số lượng), trị giá bán
-- (giá bán * số lượng), tiền lời
-- (trị giá bán – trị giá mua) mà có giá bán lớn hơn hoặc bằng giá mua.
SELECT MAHD, CTHD.MAVT, TENVT, GIABAN, GIAMUA, SL,
    (GIAMUA * SL) AS TriGiaMua,
    (GIABAN * SL) AS TriGiaBan,
    ((GIABAN * SL) - (GIAMUA * SL)) AS TienLoi
FROM CHITIETHOADON CTHD, VATTU VT
WHERE CTHD.MAVT = VT.MAVT

-- Câu 6. Lấy ra hoá đơn có tổng trị giá nhỏ nhất trong số các hóa đơn năm 2000, gồm các thông tin:
-- Số hoá đơn, ngày, mã khách hàng, tên khách hàng, địa chỉ khách hàng, tổng trị giá của hoá đơn.
SELECT HD.MAHD, NGAY, HD.MAKH, TENKH, DIACHI, SUM(SL * GIABAN) AS TongGiaTri
FROM HOADON HD, KHACHHANG KH, CHITIETHOADON CTHD
WHERE HD.MAKH = KH.MAKH AND CTHD.MAHD = HD.MAHD
GROUP BY HD.MAHD, NGAY, HD.MAKH, TENKH, DIACHI
HAVING SUM(SL * GIABAN) = (SELECT MIN(TongGiaTri)
FROM (SELECT SUM(SL * GIABAN) AS TongGiaTri
    FROM CHITIETHOADON
    GROUP BY MAHD) AS TEMP)

-- Câu 7. Lấy ra các thông tin về các khách hàng mua ít loại mặt hàng nhất.
WITH
    TEMP
    AS
    (
        SELECT KH.MAKH, TENKH, DIACHI, DT, EMAIL, COUNT(CTHD.MAVT) AS 'SL Mat Hang'
        FROM KHACHHANG KH LEFT JOIN HOADON HD
            ON KH.MAKH = HD.MAKH
            LEFT JOIN CHITIETHOADON CTHD
            ON CTHD.MAHD = HD.MAHD
        GROUP BY KH.MAKH, TENKH, DIACHI, DT, EMAIL
    )
SELECT *
FROM TEMP
WHERE [SL Mat Hang] = (SELECT MIN([SL Mat Hang])
FROM TEMP)

-- Câu 8. Lấy ra vật tư có giá mua thấp nhất
SELECT *
FROM VATTU
WHERE GIAMUA = (SELECT MIN(GIAMUA)
FROM VATTU)

-- Câu 9. Lấy ra vật tư có giá bán cao nhất trong số các vật tư được bán trong năm 2000.
WITH
    TEMP
    AS
    (
        SELECT VT.MAVT, TENVT, DVT, GIAMUA, SLTON, GIABAN
        FROM VATTU VT, CHITIETHOADON CTHD, HOADON HD
        WHERE VT.MAVT = CTHD.MAVT AND HD.MAHD = CTHD.MAHD
            AND YEAR(NGAY) = 2000
    )
SELECT *
FROM TEMP
WHERE GIABAN = (SELECT MAX(GIABAN)
FROM TEMP)

-- Câu 10. Cho biết mỗi vật tư đã được bán tổng số bao nhiêu đơn vị (chiếc, cái,… )
SELECT VT.MAVT, TENVT, SUM(SL) AS 'Tong so don vi da ban'
FROM VATTU VT LEFT JOIN CHITIETHOADON CTHD
    ON VT.MAVT = CTHD.MAVT
GROUP BY VT.MAVT, TENVT