/*
    Bài 4: Ngân hàng
    Mô hình dữ liệu quan hệ cho chi nhánh, nhân viên, khách hàng và giao dịch
*/

CREATE TABLE CHI_NHANH (
    MaChiNhanh      INT PRIMARY KEY,
    TenChiNhanh     NVARCHAR(150) NOT NULL,
    DiaChi          NVARCHAR(200),
    SoDienThoai     NVARCHAR(20)
);
GO

CREATE TABLE NHAN_VIEN (
    MaNV            INT PRIMARY KEY,
    MaChiNhanh      INT NOT NULL,
    HoTen           NVARCHAR(100) NOT NULL,
    DiaChi          NVARCHAR(200),
    SoDienThoai     NVARCHAR(20),
    Email           NVARCHAR(100),
    NgayBatDau      DATE,
    LoaiNhanVien    NVARCHAR(50),
    CONSTRAINT FK_NV_CHINHANH FOREIGN KEY (MaChiNhanh) REFERENCES CHI_NHANH(MaChiNhanh)
);
GO

CREATE TABLE KHACH_HANG (
    MaKhachHang     INT PRIMARY KEY,
    LoaiKhachHang   NVARCHAR(20) NOT NULL CHECK (LoaiKhachHang IN ('CA_NHAN', 'DOANH_NGHIEP'))
);
GO

CREATE TABLE KHACH_HANG_CA_NHAN (
    MaKhachHang     INT PRIMARY KEY,
    CMND            NVARCHAR(20),
    HoTen           NVARCHAR(100),
    Email           NVARCHAR(100),
    SoDienThoai     NVARCHAR(20),
    DiaChi          NVARCHAR(200),
    CONSTRAINT FK_KH_CN_KH FOREIGN KEY (MaKhachHang) REFERENCES KHACH_HANG(MaKhachHang)
);
GO

CREATE TABLE KHACH_HANG_DOANH_NGHIEP (
    MaKhachHang     INT PRIMARY KEY,
    MaDoanhNghiep   NVARCHAR(20),
    TenDoanhNghiep  NVARCHAR(150),
    TenNguoiDaiDien NVARCHAR(100),
    SoDienThoai     NVARCHAR(20),
    DiaChi          NVARCHAR(200),
    CONSTRAINT FK_KH_DN_KH FOREIGN KEY (MaKhachHang) REFERENCES KHACH_HANG(MaKhachHang)
);
GO

CREATE TABLE TAI_KHOAN_TIET_KIEM (
    MaTaiKhoan      INT PRIMARY KEY,
    MaKhachHang     INT NOT NULL,
    MaChiNhanh      INT NOT NULL,
    NgayMo          DATE,
    NgayDaoHan      DATE,
    VonBanDau       DECIMAL(18,2),
    SoDuHienTai     DECIMAL(18,2),
    KyHan           INT,
    LaiSuat         DECIMAL(8,4),
    PhuongThucTraLai NVARCHAR(50),
    CONSTRAINT FK_TK_KH FOREIGN KEY (MaKhachHang) REFERENCES KHACH_HANG(MaKhachHang),
    CONSTRAINT FK_TK_CHI_NHANH FOREIGN KEY (MaChiNhanh) REFERENCES CHI_NHANH(MaChiNhanh)
);
GO

CREATE TABLE GIAO_DICH (
    MaGiaoDich      INT PRIMARY KEY,
    MaChiNhanh      INT NOT NULL,
    ThoiGian        DATETIME NOT NULL,
    LoaiGiaoDich    NVARCHAR(80),
    SoTien          DECIMAL(18,2),
    MaNVGiaoDich    INT NOT NULL,
    MaNVPheDuyet    INT NOT NULL,
    MaTaiKhoan      INT,
    CONSTRAINT FK_GD_CHINHANH FOREIGN KEY (MaChiNhanh) REFERENCES CHI_NHANH(MaChiNhanh),
    CONSTRAINT FK_GD_NVGD FOREIGN KEY (MaNVGiaoDich) REFERENCES NHAN_VIEN(MaNV),
    CONSTRAINT FK_GD_NVPD FOREIGN KEY (MaNVPheDuyet) REFERENCES NHAN_VIEN(MaNV),
    CONSTRAINT FK_GD_TK FOREIGN KEY (MaTaiKhoan) REFERENCES TAI_KHOAN_TIET_KIEM(MaTaiKhoan)
);
GO

/*
    Ghi chú:
    - Một nhân viên chỉ làm việc tại một chi nhánh, do đó MaChiNhanh nằm trong NHAN_VIEN.
    - KHACH_HANG là thực thể tổng quát: cá nhân và doanh nghiệp có các thuộc tính khác nhau.
    - Mỗi tài khoản tiết kiệm thuộc về một khách hàng và được mở tại một chi nhánh.
    - GIAO_DICH lưu lại cuộc giao dịch, chi nhánh, thời gian, loại, số tiền và hai vai trò nhân viên.
*/
