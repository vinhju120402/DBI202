/**
        +--------------------------+
        |        DBI202_LAB        | 
        |          LAB04           |
        |       Ho Nhat Minh       |
        |         FX03283          |
        +--------------------------+
**/
USE DBI202_LAB
GO


-- 1. Viết câu lệnh tạo SP có tên sp_Cau1 cập nhật thông tin TONGGT trong bảng HOADON theo dữ liệu thực tế trong bảng CHITIETHOADON.
IF EXISTS(SELECT *
FROM SYS.objects
WHERE NAME = 'sp_Cau1')
DROP PROCEDURE sp_Cau1
GO

CREATE PROCEDURE sp_Cau1
AS
DECLARE @row INT
DECLARE @max INT

SET @row = 1
SET @max = (SELECT COUNT(*)
FROM HOADON)

BEGIN
    WHILE @row <= @max
    BEGIN
        UPDATE HOADON
        SET TONGGT = (
            SELECT SUM(SL * GIABAN)
        FROM CHITIETHOADON CTHD
        WHERE HOADON.MAHD = CTHD.MAHD
        )
        WHERE @row = (SELECT ROW_NUMBER() OVER(ORDER BY MAHD))
        SET @row = @row + 1
    END
END
GO

exec sp_Cau1
select *
from HOADON
-- 2.Viết câu lệnh tạo hàm (function) có tên fc_Cau3 có kiểu dữ liệu trả về là INT, nhập vào 1 mã khách hàng rồi đếm xem khách hàng này đã mua tổng cộng bao nhiêu tiền. Kết quả trả về của hàm là số tiền mà khách hàng đã mua.
IF EXISTS(SELECT *
FROM SYS.objects
WHERE NAME = 'fc_Cau3')
DROP FUNCTION fc_Cau3
GO

CREATE FUNCTION fc_Cau3 (@MAKH NVARCHAR(5))
RETURNS MONEY AS
BEGIN
    DECLARE @RESULT MONEY;
    WITH
        TEMP
        AS
        (
            SELECT SUM(SL * GIABAN) AS tongTien
            FROM CHITIETHOADON CTHD, HOADON HD
            WHERE CTHD.MAHD = HD.MAHD AND MAKH = @MAKH
            GROUP BY MAKH
        )
    SELECT @RESULT = tongtien
    FROM TEMP;
    RETURN @RESULT;
END
GO

SELECT MAKH, TENKH, DBO.fc_Cau3(MAKH)
FROM KHACHHANG

-- 3.Viết câu lệnh tạo hàm fc_cau4 có kiểu dữ liệu trả về là NVARCHAR(5), tìm xem vật tư nào là vật tư bán được nhiều tiền nhất. Kết quả trả về cho hàm là mã của vật tư này. Trong trường hợp có nhiều vật tư cùng bán được số tiền nhiều nhất như nhau, chỉ cần trả về mã của một trong số các vật tư này.
IF EXISTS(SELECT *
FROM SYS.objects
WHERE NAME = 'fc_Cau4')
DROP FUNCTION fc_Cau4
GO

CREATE FUNCTION fc_Cau4()
RETURNS NVARCHAR(5) AS
BEGIN
    DECLARE @RESULT NVARCHAR(5)
    ;WITH
        TEMP
        AS
        (
            SELECT MAVT, (GIABAN * SL) AS TONGBAN
            FROM CHITIETHOADON
        )
    SELECT @RESULT = MAVT
    FROM TEMP
    WHERE TONGBAN = (SELECT MAX(TONGBAN)
    FROM TEMP)
    RETURN @RESULT
END
GO

-- 4. Viết câu lệnh tạo SP có sp_Cau5, có hai tham số kiểu output là @MaVT NVARCHAR(5) và @TenVT NVARCHAR(30) để trả về mã và tên của vật tư bán được nhiều tiền nhất. Trong trường hợp có nhiều vật tư cùng bán được số tiền nhiều nhất như nhau, chỉ cần trả về mã và tên của một trong số các vật tư này.
IF EXISTS (SELECT *
FROM sys.objects
WHERE NAME ='sp_Cau5')
DROP PROCEDURE sp_Cau5
GO

CREATE PROCEDURE sp_Cau5
    (@MaVT NVARCHAR(5) OUTPUT,
    @TenVT NVARCHAR(30) OUTPUT)
AS
BEGIN
    ;WITH
        TEMP
        AS
        (
            SELECT MAVT, SUM(SL * GIABAN) AS TONGTIEN
            FROM CHITIETHOADON
            GROUP BY MAVT
        )
    SELECT @MaVT = (SELECT MAVT
        FROM TEMP
        WHERE TONGTIEN = (SELECT MAX(TONGTIEN)
        FROM TEMP))

    SELECT @TenVT = (SELECT TENVT
        FROM VATTU
        WHERE MAVT = @MaVT)
END
GO


DECLARE @mavt nvarchar (5),@tenvt nvarchar (30)
EXEC sp_Cau5 @mavt OUTPUT, @tenvt OUTPUT
SELECT @mavt AS MAVT, @tenvt AS TENVT
GO

-- --5. Viết câu lệnh
-- tạo trigger có tên tg_Cau6 để đảm bảo ràng
-- buộc:
-- nếu cập nhật giá mua của vật tư
-- (trong bảng VATTU) thì chỉ có thể cập nhật tăng, không được cập nhật giảm giá.
CREATE TRIGGER tg_Cau6 ON VATTU
AFTER UPDATE
AS BEGIN
    IF EXISTS(
        SELECT inserted.GIAMUA
    FROM inserted, deleted
    WHERE inserted.MAVT = deleted.MAVT
        AND inserted.GIAMUA < deleted.GIAMUA
    )
    RAISERROR ('Gia mua chi duoc cap nhat tang, khong duoc cap nhat giam', 16, 1)
    ROLLBACK TRANSACTION
    RETURN
END
GO

-- 6. Viết câu lệnh tạo trigger có tên tg_Cau7 để đảm bảo ràng buộc: khi thêm một hóa đơn vào CSDL, cần đảm bảo khách hàng đã mua hóa đơn này đã có trong bảng KHACHHANG. Trường hợp khách hàng chưa có trong bảng khách hàng, hãy thêm thông tin khách hàng vào bảng KHACHHANG trước. Trong đó, KHACHHANG sẽ có tên và mã số giống nhau, chính là mã số khách hàng trong thông tin hóa đơn. Các thông tin còn lại của khách hàng lấy giá trị NULL.
IF EXISTS(SELECT *
FROM SYS.objects
WHERE NAME = 'tr_Cau7')
DROP TRIGGER tr_Cau7
GO

ALTER TABLE HOADON DROP CONSTRAINT FK__HOADON__MAKH__4222D4EF;
GO

CREATE TRIGGER tr_Cau7 ON HOADON
AFTER INSERT
AS BEGIN
    DECLARE @maKH NVARCHAR(5);
    SELECT @maKH = MAKH
    FROM inserted;
    IF NOT EXISTS(SELECT *
    FROM KHACHHANG
    WHERE MAKH = @maKH)
    BEGIN
        INSERT INTO KHACHHANG
            (MAKH, TENKH)
        VALUES
            (@maKH, @maKH)
    END

END
GO

-- 7.Hãy viết một Transaction, đảm bảo thực hiện việc xóa thông tin về một hóa đơn sẽ xóa đồng thời thông tin về hóa đơn này trong cả hai bảng CHITIETHOADON và HOADON.
BEGIN TRAN
DECLARE @MaHD NVARCHAR(10) = 'HD001'

DELETE FROM CHITIETHOADON WHERE MAHD = @MaHD
DELETE FROM HOADON WHERE MAHD = @MaHD;
COMMIT TRAN