/*
    Bài 3: Ship movement / port / country / ocean
    Mô hình dữ liệu quan hệ cho lược đồ ERD về tàu thuyền
*/

CREATE TABLE SHIP_TYPE (
    ShipTypeID      INT PRIMARY KEY,
    TypeName        NVARCHAR(100) NOT NULL
);
GO

CREATE TABLE COUNTRY (
    CountryID       INT PRIMARY KEY,
    CountryName     NVARCHAR(100) NOT NULL
);
GO

CREATE TABLE OCEAN (
    OceanID         INT PRIMARY KEY,
    OceanName       NVARCHAR(100) NOT NULL
);
GO

CREATE TABLE PORT (
    PortID          INT PRIMARY KEY,
    PortName        NVARCHAR(100) NOT NULL,
    CountryID       INT,
    OceanID         INT,
    CONSTRAINT FK_PORT_COUNTRY FOREIGN KEY (CountryID) REFERENCES COUNTRY(CountryID),
    CONSTRAINT FK_PORT_OCEAN FOREIGN KEY (OceanID) REFERENCES OCEAN(OceanID)
);
GO

CREATE TABLE SHIP (
    ShipID          INT PRIMARY KEY,
    ShipName        NVARCHAR(100) NOT NULL,
    Owner           NVARCHAR(100),
    ShipTypeID      INT,
    HomePortID      INT,
    CONSTRAINT FK_SHIP_TYPE FOREIGN KEY (ShipTypeID) REFERENCES SHIP_TYPE(ShipTypeID),
    CONSTRAINT FK_SHIP_HOMEPORT FOREIGN KEY (HomePortID) REFERENCES PORT(PortID)
);
GO

CREATE TABLE SHIP_MOVEMENT (
    ShipID          INT NOT NULL,
    MoveDate        DATE NOT NULL,
    MoveTime        TIME NOT NULL,
    Longitude       DECIMAL(9,6),
    Latitude        DECIMAL(9,6),
    PRIMARY KEY (ShipID, MoveDate, MoveTime),
    CONSTRAINT FK_SHIP_MOVEMENT_SHIP FOREIGN KEY (ShipID) REFERENCES SHIP(ShipID)
);
GO

CREATE TABLE VISITS (
    ShipID          INT NOT NULL,
    PortID          INT NOT NULL,
    StartDate       DATE NOT NULL,
    EndDate         DATE,
    PRIMARY KEY (ShipID, PortID, StartDate),
    CONSTRAINT FK_VISITS_SHIP FOREIGN KEY (ShipID) REFERENCES SHIP(ShipID),
    CONSTRAINT FK_VISITS_PORT FOREIGN KEY (PortID) REFERENCES PORT(PortID)
);
GO

/*
    Ghi chú:
    - SHIP_MOVEMENT là thực thể yếu (weak entity) phụ thuộc vào SHIP.
    - Khóa chính gồm ShipID + MoveDate + MoveTime là mô hình hợp lý nếu các mốc thời gian
      này đủ phân biệt các hành trình của cùng một tàu.
    - VISITS là quan hệ nhiều-nhiều giữa SHIP và PORT, kèm thuộc tính StartDate và EndDate.
*/
