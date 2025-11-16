CREATE DATABASE FerreteriaDB;
GO

USE FerreteriaDB;
GO

-- CLIENTES
CREATE TABLE Clientes (
    IDCliente INT IDENTITY(1,1) PRIMARY KEY,
    DNI BIGINT NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    Telefono VARCHAR(20),
    Mail VARCHAR(100),
    Direccion VARCHAR(150),
    FechaAlta DATE NOT NULL,
    Activo BIT DEFAULT 1
);
GO

-- PROVEEDORES
CREATE TABLE Proveedores (
    IDProveedor INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Direccion VARCHAR(150),
    Telefono VARCHAR(20),
    Mail VARCHAR(100),
    FechaAlta DATE NOT NULL,
    Activo BIT DEFAULT 1
);
GO

-- CATEGORIAS
CREATE TABLE Categorias (
    IDCategoria INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(255)
);
GO

-- PRODUCTOS
CREATE TABLE Productos (
    IDProducto INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(255),
    Precio DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL,
    IDCategoria INT NOT NULL,
    IDProveedor INT NOT NULL,
    FOREIGN KEY (IDCategoria) REFERENCES Categorias(IDCategoria),
    FOREIGN KEY (IDProveedor) REFERENCES Proveedores(IDProveedor)
);
GO

-- COMPRAS
CREATE TABLE Compras (
    IDCompra INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE NOT NULL,
    IDProveedor INT NOT NULL,
    Total DECIMAL(10,2),
    FOREIGN KEY (IDProveedor) REFERENCES Proveedores(IDProveedor)
);
GO

-- DETALLE COMPRAS
CREATE TABLE Detalle_Compras (
    IDDetalleCompra INT IDENTITY(1,1) PRIMARY KEY,
    IDCompra INT NOT NULL,
    IDProducto INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (IDCompra) REFERENCES Compras(IDCompra),
    FOREIGN KEY (IDProducto) REFERENCES Productos(IDProducto)
);
GO

-- VENTAS
CREATE TABLE Ventas (
    IDVenta INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE NOT NULL,
    IDCliente INT NOT NULL,
    Total DECIMAL(10,2),
    FOREIGN KEY (IDCliente) REFERENCES Clientes(IDCliente)
);
GO

-- DETALLE VENTAS
CREATE TABLE Detalle_Ventas (
    IDDetalleVenta INT IDENTITY(1,1) PRIMARY KEY,
    IDVenta INT NOT NULL,
    IDProducto INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (IDVenta) REFERENCES Ventas(IDVenta),
    FOREIGN KEY (IDProducto) REFERENCES Productos(IDProducto)
);
GO
