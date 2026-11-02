-- Cơ sở dữ liệu Quản Lý Sinh Viên
-- SQL Server (T-SQL). Schema and sample attribute names follow the supplied PDF.

-- Database creation / schema
CREATE TABLE KHOA (
    MAKHOA       varchar(4)   NOT NULL,
    TENKHOA      varchar(100) NOT NULL,
    NAMTHANHLAP  int          NOT NULL,
    CONSTRAINT PK_KHOA PRIMARY KEY (MAKHOA),
    CONSTRAINT UQ_KHOA_TENKHOA UNIQUE (TENKHOA)
);

CREATE TABLE SVIEN (
    MASV    varchar(8)   NOT NULL,
    TENSV   varchar(100) NOT NULL,
    NAM     int          NOT NULL,
    MAKHOA  varchar(4)   NOT NULL,
    CONSTRAINT PK_SVIEN PRIMARY KEY (MASV),
    CONSTRAINT CK_SVIEN_NAM CHECK (NAM BETWEEN 1 AND 4),
    CONSTRAINT FK_SVIEN_KHOA FOREIGN KEY (MAKHOA) REFERENCES KHOA (MAKHOA)
);

CREATE TABLE MHOC (
    MAMH    varchar(6)   NOT NULL,
    MAKHOA  varchar(4)   NOT NULL,
    TENMH   varchar(100) NOT NULL,
    TINCHI  int          NOT NULL,
    CONSTRAINT PK_MHOC PRIMARY KEY (MAMH),
    CONSTRAINT UQ_MHOC_TENMH UNIQUE (TENMH),
    CONSTRAINT CK_MHOC_TINCHI CHECK (TINCHI > 0),
    CONSTRAINT FK_MHOC_KHOA FOREIGN KEY (MAKHOA) REFERENCES KHOA (MAKHOA)
);

CREATE TABLE DKIEN (
    MAMH        varchar(6) NOT NULL,
    MAMH_TRUOC  varchar(6) NOT NULL,
    CONSTRAINT PK_DKIEN PRIMARY KEY (MAMH, MAMH_TRUOC),
    CONSTRAINT CK_DKIEN_KHAC_MON CHECK (MAMH <> MAMH_TRUOC),
    CONSTRAINT FK_DKIEN_MHOC FOREIGN KEY (MAMH) REFERENCES MHOC (MAMH),
    CONSTRAINT FK_DKIEN_TIENQUYET FOREIGN KEY (MAMH_TRUOC) REFERENCES MHOC (MAMH)
);

CREATE TABLE HPHAN (
    MAHP   int         NOT NULL,
    MAMH   varchar(6)  NOT NULL,
    HOCKY  int         NOT NULL,
    NAM    int         NOT NULL,
    GV     varchar(50) NOT NULL,
    CONSTRAINT PK_HPHAN PRIMARY KEY (MAHP),
    CONSTRAINT FK_HPHAN_MHOC FOREIGN KEY (MAMH) REFERENCES MHOC (MAMH)
);

CREATE TABLE KETQUA (
    MASV   varchar(8) NOT NULL,
    MAHP   int        NOT NULL,
    DIEM   decimal(4,1) NOT NULL,
    CONSTRAINT PK_KETQUA PRIMARY KEY (MASV, MAHP),
    CONSTRAINT CK_KETQUA_DIEM CHECK (DIEM BETWEEN 0 AND 10),
    CONSTRAINT FK_KETQUA_SVIEN FOREIGN KEY (MASV) REFERENCES SVIEN (MASV),
    CONSTRAINT FK_KETQUA_HPHAN FOREIGN KEY (MAHP) REFERENCES HPHAN (MAHP)
);

-- Enforce that a student can enroll only in a section for a course
-- managed by the student's own department.
GO
CREATE TRIGGER TR_KETQUA_CUNG_KHOA
ON KETQUA
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN SVIEN AS s ON s.MASV = i.MASV
        JOIN HPHAN AS h ON h.MAHP = i.MAHP
        JOIN MHOC AS m ON m.MAMH = h.MAMH
        WHERE s.MAKHOA <> m.MAKHOA
    )
    BEGIN
        THROW 50001, N'Sinh viên chỉ được đăng ký học phần thuộc khoa của mình.', 1;
    END;
END;
GO

CREATE TRIGGER TR_SVIEN_DOI_KHOA
ON SVIEN
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(MAKHOA) AND EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN KETQUA AS kq ON kq.MASV = i.MASV
        JOIN HPHAN AS h ON h.MAHP = kq.MAHP
        JOIN MHOC AS m ON m.MAMH = h.MAMH
        WHERE i.MAKHOA <> m.MAKHOA
    )
    BEGIN
        THROW 50002, N'Không thể đổi khoa sinh viên khi kết quả hiện có thuộc khoa khác.', 1;
    END;
END;
GO

CREATE TRIGGER TR_MHOC_DOI_KHOA
ON MHOC
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(MAKHOA) AND EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN HPHAN AS h ON h.MAMH = i.MAMH
        JOIN KETQUA AS kq ON kq.MAHP = h.MAHP
        JOIN SVIEN AS s ON s.MASV = kq.MASV
        WHERE i.MAKHOA <> s.MAKHOA
    )
    BEGIN
        THROW 50003, N'Không thể đổi khoa phụ trách khi kết quả hiện có thuộc khoa khác.', 1;
    END;
END;
GO

-- Question 1: Sinh viên thuộc khoa Toán (MAKHOA = 'TOAN')
SELECT s.TENSV
FROM SVIEN AS s
WHERE s.MAKHOA = 'TOAN'
ORDER BY s.TENSV;

-- Question 2: Tên môn học và số tín chỉ
SELECT m.TENMH, m.TINCHI
FROM MHOC AS m
ORDER BY m.TENMH;

-- Question 3: Kết quả học tập của MASV được ghi trong đề là 'K26.008'
SELECT m.TENMH, h.MAHP, h.HOCKY, h.NAM, kq.DIEM
FROM KETQUA AS kq
JOIN HPHAN AS h ON h.MAHP = kq.MAHP
JOIN MHOC AS m ON m.MAMH = h.MAMH
WHERE kq.MASV = 'K26.008'
ORDER BY h.NAM, h.HOCKY, m.TENMH;

-- Question 4: Sinh viên và mã môn học có điểm cuối khóa trên 7
SELECT s.TENSV, m.MAMH, kq.DIEM
FROM KETQUA AS kq
JOIN SVIEN AS s ON s.MASV = kq.MASV
JOIN HPHAN AS h ON h.MAHP = kq.MAHP
JOIN MHOC AS m ON m.MAMH = h.MAMH
WHERE kq.DIEM > 7
ORDER BY s.TENSV, m.MAMH;

-- Question 5: Sinh viên thuộc khoa phụ trách môn 'Toán rời rạc'
SELECT s.TENSV
FROM SVIEN AS s
WHERE s.MAKHOA = (
    SELECT m.MAKHOA
    FROM MHOC AS m
    WHERE m.TENMH = N'Toán rời rạc'
)
ORDER BY s.TENSV;

-- Question 6: Kết quả của sinh viên trong học kỳ 1 năm 1996
SELECT s.TENSV, m.TENMH, kq.DIEM
FROM KETQUA AS kq
JOIN SVIEN AS s ON s.MASV = kq.MASV
JOIN HPHAN AS h ON h.MAHP = kq.MAHP
JOIN MHOC AS m ON m.MAMH = h.MAMH
WHERE h.HOCKY = 1
  AND h.NAM = 1996
ORDER BY s.TENSV, m.TENMH;

-- Question 7: Môn học phải học trước môn 'Cơ sở dữ liệu'
SELECT truoc.TENMH AS TEN_MON_HOC_TRUOC
FROM MHOC AS sau
JOIN DKIEN AS d ON d.MAMH = sau.MAMH
JOIN MHOC AS truoc ON truoc.MAMH = d.MAMH_TRUOC
WHERE sau.TENMH = N'Cơ sở dữ liệu'
ORDER BY truoc.TENMH;

-- Question 8: Môn học phải học ngay sau môn 'Cơ sở dữ liệu'
SELECT sau.TENMH AS TEN_MON_HOC_HOC_SAU
FROM MHOC AS truoc
JOIN DKIEN AS d ON d.MAMH_TRUOC = truoc.MAMH
JOIN MHOC AS sau ON sau.MAMH = d.MAMH
WHERE truoc.TENMH = N'Cơ sở dữ liệu'
ORDER BY sau.TENMH;

-- Question 9: Môn tiên quyết và môn học (môn học có số tín chỉ <= 4)
SELECT truoc.TENMH AS TEN_MON_HOC_TRUOC,
       sau.TENMH AS TEN_MON_HOC
FROM DKIEN AS d
JOIN MHOC AS sau ON sau.MAMH = d.MAMH
JOIN MHOC AS truoc ON truoc.MAMH = d.MAMH_TRUOC
WHERE sau.TINCHI <= 4
ORDER BY sau.TENMH, truoc.TENMH;

-- Question 10: Điểm môn 'Cơ sở dữ liệu', học kỳ 1 năm 1996
SELECT s.MASV, s.TENSV, kq.DIEM
FROM KETQUA AS kq
JOIN SVIEN AS s ON s.MASV = kq.MASV
JOIN HPHAN AS h ON h.MAHP = kq.MAHP
JOIN MHOC AS m ON m.MAMH = h.MAMH
WHERE m.TENMH = N'Cơ sở dữ liệu'
  AND h.HOCKY = 1
  AND h.NAM = 1996
ORDER BY kq.DIEM DESC, s.TENSV ASC;

-- Question 11: Số sinh viên đăng ký từng học phần (kể cả học phần chưa có đăng ký)
SELECT h.MAHP, h.MAMH, COUNT(kq.MASV) AS SO_LUONG_SINH_VIEN
FROM HPHAN AS h
LEFT JOIN KETQUA AS kq ON kq.MAHP = h.MAHP
GROUP BY h.MAHP, h.MAMH
ORDER BY h.MAHP;

-- Question 12: Điểm trung bình của từng sinh viên theo học kỳ và năm học
SELECT s.MASV, s.TENSV, h.HOCKY, h.NAM,
       AVG(CAST(kq.DIEM AS decimal(5,2))) AS DIEM_TRUNG_BINH
FROM SVIEN AS s
JOIN KETQUA AS kq ON kq.MASV = s.MASV
JOIN HPHAN AS h ON h.MAHP = kq.MAHP
GROUP BY s.MASV, s.TENSV, h.HOCKY, h.NAM
ORDER BY h.NAM, h.HOCKY, s.TENSV;

-- Question 13: Sinh viên đạt điểm cao nhất trong toàn bộ các kết quả
SELECT s.MASV, s.TENSV
FROM SVIEN AS s
JOIN KETQUA AS kq ON kq.MASV = s.MASV
WHERE kq.DIEM = (SELECT MAX(DIEM) FROM KETQUA)
ORDER BY s.TENSV;

-- Question 14: Sinh viên đạt điểm cao nhất môn 'Cơ sở dữ liệu',
--              học kỳ 1 năm 1996 (trả mọi trường hợp đồng hạng)
SELECT s.MASV, s.TENSV, kq.DIEM
FROM KETQUA AS kq
JOIN SVIEN AS s ON s.MASV = kq.MASV
JOIN HPHAN AS h ON h.MAHP = kq.MAHP
JOIN MHOC AS m ON m.MAMH = h.MAMH
WHERE m.TENMH = N'Cơ sở dữ liệu'
  AND h.HOCKY = 1
  AND h.NAM = 1996
  AND kq.DIEM = (
      SELECT MAX(kq2.DIEM)
      FROM KETQUA AS kq2
      JOIN HPHAN AS h2 ON h2.MAHP = kq2.MAHP
      JOIN MHOC AS m2 ON m2.MAMH = h2.MAMH
      WHERE m2.TENMH = N'Cơ sở dữ liệu'
        AND h2.HOCKY = 1
        AND h2.NAM = 1996
  )
ORDER BY s.TENSV;

-- Question 15: Sinh viên có điểm trung bình cao nhất học kỳ 1 năm 1996
WITH DIEM_TB AS (
    SELECT s.MASV, s.TENSV, AVG(CAST(kq.DIEM AS decimal(5,2))) AS DIEM_TRUNG_BINH
    FROM SVIEN AS s
    JOIN KETQUA AS kq ON kq.MASV = s.MASV
    JOIN HPHAN AS h ON h.MAHP = kq.MAHP
    WHERE h.HOCKY = 1
      AND h.NAM = 1996
    GROUP BY s.MASV, s.TENSV
)
SELECT MASV, TENSV, DIEM_TRUNG_BINH
FROM DIEM_TB
WHERE DIEM_TRUNG_BINH = (SELECT MAX(DIEM_TRUNG_BINH) FROM DIEM_TB)
ORDER BY TENSV;
