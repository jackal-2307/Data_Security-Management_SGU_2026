/*
    Bài 1: Bệnh viện
    Mô hình dữ liệu quan hệ tương ứng với yêu cầu ERD
    Không thực thi trên môi trường hiện tại vì SQL Server chưa được cài đặt.
*/

USE master;
GO

/*
    Tạo cơ sở dữ liệu mẫu nếu cần.
    Chú ý: trong môi trường thực tế, nên tạo database riêng trước khi chạy tập tin này.
    CREATE DATABASE HospitalDB;
    GO
    USE HospitalDB;
    GO
*/

CREATE TABLE NHANVIEN (
    MaNV            INT PRIMARY KEY,
    HoTen           NVARCHAR(100) NOT NULL,
    DiaChi          NVARCHAR(200),
    NgaySinh        DATE,
    SoDienThoai     NVARCHAR(20)
);
GO

CREATE TABLE Y_SI (
    MaNV            INT PRIMARY KEY,
    ChuyenNganh     NVARCHAR(100),
    CONSTRAINT FK_YSI_NHANVIEN FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV)
);
GO

CREATE TABLE Y_TA (
    MaNV                    INT PRIMARY KEY,
    MaChungChiTotNghiep     NVARCHAR(50),
    MaKhuDieuTri            INT NULL,
    CONSTRAINT FK_YTA_NHANVIEN FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV)
);
GO

CREATE TABLE NHANVIEN_VANPHONG (
    MaNV            INT PRIMARY KEY,
    LoaiCongViec    NVARCHAR(100),
    CONSTRAINT FK_NVVP_NHANVIEN FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV)
);
GO

CREATE TABLE KYTHUATVIEN (
    MaNV            INT PRIMARY KEY,
    KyNang          NVARCHAR(200),
    CONSTRAINT FK_KTV_NHANVIEN FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV)
);
GO

CREATE TABLE KHU_DIEU_TRI (
    MaKhuDieuTri    INT PRIMARY KEY,
    TenKhu          NVARCHAR(100) NOT NULL,
    DiaDiem         NVARCHAR(150),
    YTaTruongMaNV   INT NULL,
    CONSTRAINT FK_KDT_YTA FOREIGN KEY (YTaTruongMaNV) REFERENCES Y_TA(MaNV)
);
GO

ALTER TABLE Y_TA
ADD CONSTRAINT FK_YTA_KHU_DIEU_TRI
FOREIGN KEY (MaKhuDieuTri) REFERENCES KHU_DIEU_TRI(MaKhuDieuTri);
GO

CREATE TABLE PHONG_THI_NGHIEM (
    MaPhong         INT PRIMARY KEY,
    TenPhong        NVARCHAR(100) NOT NULL,
    DiaDiem         NVARCHAR(150)
);
GO

CREATE TABLE PHAN_CONG_KTV_PHONG (
    MaNV            INT NOT NULL,
    MaPhong         INT NOT NULL,
    PRIMARY KEY (MaNV, MaPhong),
    CONSTRAINT FK_PCKTVP_KTV FOREIGN KEY (MaNV) REFERENCES KYTHUATVIEN(MaNV),
    CONSTRAINT FK_PCKTVP_PHONG FOREIGN KEY (MaPhong) REFERENCES PHONG_THI_NGHIEM(MaPhong)
);
GO

CREATE TABLE BENHNHAN (
    MaBN            INT PRIMARY KEY,
    DiaChi          NVARCHAR(200),
    NgayNhapVien    DATE
);
GO

CREATE TABLE DIEU_TRI (
    MaYSI           INT NOT NULL,
    MaBN            INT NOT NULL,
    PRIMARY KEY (MaYSI, MaBN),
    CONSTRAINT FK_DT_YSI FOREIGN KEY (MaYSI) REFERENCES Y_SI(MaNV),
    CONSTRAINT FK_DT_BN FOREIGN KEY (MaBN) REFERENCES BENHNHAN(MaBN)
);
GO

/*
    Ghi chú:
    - Quan hệ giữa Y_TA và KHU_DIEU_TRI là 1-n: mỗi y tá thuộc 1 khu điều trị,
      nhưng một khu có nhiều y tá. Điều này được mô hình hóa qua MaKhuDieuTri trong Y_TA.
    - Y tá trưởng được lưu trong KHU_DIEU_TRI.
    - Quan hệ giữa Y_SI và BENHNHAN là N-N nên dùng bảng DIEU_TRI.
    - Quan hệ giữa KYTHUATVIEN và PHONG_THI_NGHIEM là N-N nên dùng bảng PHAN_CONG_KTV_PHONG.
*/
