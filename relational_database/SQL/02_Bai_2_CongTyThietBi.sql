/*
    Bài 2: Công ty thiết bị
    Mô hình dữ liệu quan hệ cho sản phẩm, hãng sản xuất và các loại sản phẩm
*/

CREATE TABLE HANGSANXUAT (
    MaHang          INT PRIMARY KEY,
    TenHang         NVARCHAR(100) NOT NULL,
    XuatXu          NVARCHAR(100)
);
GO

CREATE TABLE SANPHAM (
    MaSP            INT PRIMARY KEY,
    TenSP           NVARCHAR(150) NOT NULL,
    GiaNhap         DECIMAL(18,2),
    NgayNhap        DATE,
    GiaBan          DECIMAL(18,2),
    MoTa            NVARCHAR(500),
    MaHang          INT,
    CONSTRAINT FK_SP_HANG FOREIGN KEY (MaHang) REFERENCES HANGSANXUAT(MaHang)
);
GO

CREATE TABLE DIENTHOAI (
    MaSP            INT PRIMARY KEY,
    ManHinh         NVARCHAR(50),
    HeDieuHanh      NVARCHAR(50),
    CPU             NVARCHAR(100),
    BoNho           NVARCHAR(50),
    Camera          NVARCHAR(100),
    Pin             NVARCHAR(50),
    CONSTRAINT FK_DT_SP FOREIGN KEY (MaSP) REFERENCES SANPHAM(MaSP)
);
GO

CREATE TABLE MAYTINH (
    MaSP            INT PRIMARY KEY,
    ManHinh         NVARCHAR(50),
    HeDieuHanh      NVARCHAR(50),
    CPU             NVARCHAR(100),
    BoNho           NVARCHAR(50),
    TrongLuong      DECIMAL(8,2),
    CacCongKetNoi   NVARCHAR(200),
    CONSTRAINT FK_MT_SP FOREIGN KEY (MaSP) REFERENCES SANPHAM(MaSP)
);
GO

CREATE TABLE NHOMPHUKIEN (
    MaNhom          INT PRIMARY KEY,
    TenNhom         NVARCHAR(150) NOT NULL,
    SoLuongConLai   INT,
    MaHang          INT,
    CONSTRAINT FK_NPK_HANG FOREIGN KEY (MaHang) REFERENCES HANGSANXUAT(MaHang)
);
GO

CREATE TABLE PHUKIEN_HOTRO (
    MaNhom          INT NOT NULL,
    MaSP            INT NOT NULL,
    PRIMARY KEY (MaNhom, MaSP),
    CONSTRAINT FK_PHK_NHOM FOREIGN KEY (MaNhom) REFERENCES NHOMPHUKIEN(MaNhom),
    CONSTRAINT FK_PHK_SP FOREIGN KEY (MaSP) REFERENCES SANPHAM(MaSP)
);
GO

/*
    Ghi chú:
    - SANPHAM lưu thông tin chung của mọi sản phẩm.
    - DIENTHOAI và MAYTINH là các bảng kiểu chuyên biệt cho từng phân loại sản phẩm.
    - NHOMPHUKIEN lưu nhóm phụ kiện chia sẻ cùng mã số và số lượng còn lại.
    - Quan hệ hỗ trợ giữa phụ kiện và sản phẩm được biểu diễn bằng PHUKIEN_HOTRO.
*/
