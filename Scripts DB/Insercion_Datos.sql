INSERT INTO Clientes (DNI, Nombre, Apellido, Telefono, Mail, Direccion, FechaAlta)
VALUES
(30123456, 'Juan', 'Gómez', '1122334455', 'juan@gmail.com', 'Av. Siempre Viva 123', '2024-01-10'),
(28987654, 'María', 'Pérez', '1133445566', 'maria@gmail.com', 'San Martín 456', '2024-01-15'),
(32567890, 'Carlos', 'López', '1144556677', 'carlos@gmail.com', 'Belgrano 789', '2024-02-01'),
(31234567, 'Ana', 'Rodríguez', '1155667788', 'ana@gmail.com', 'Rivadavia 321', '2024-02-18'),
(30111222, 'Pedro', 'Suárez', '1177889900', 'pedro@gmail.com', 'Mitre 654', '2024-03-05'),
(29876543, 'Lucía', 'Martínez', '1166778899', 'lucia@gmail.com', 'Sarmiento 987', '2024-03-20'),
(33445566, 'Diego', 'Fernández', '1188990011', 'diego@gmail.com', 'Urquiza 100', '2024-04-01'),
(35566778, 'Sofía', 'Ramírez', '1199001122', 'sofia@gmail.com', 'Alsina 555', '2024-04-15');


INSERT INTO Proveedores (Nombre, Direccion, Telefono, Mail, FechaAlta)
VALUES
('Proveedor Norte', 'Av. Norte 1000', '1122003300', 'norte@prov.com', '2024-01-05'),
('Proveeduría Central', 'Calle Central 500', '1133112200', 'central@prov.com', '2024-02-12'),
('Distribuidora Sur', 'Ruta 2 Km 50', '1144221133', 'sur@prov.com', '2024-02-25'),
('Mayorista Tools', 'Belgrano 987', '1155332244', 'tools@prov.com', '2024-03-01'),
('Proveeduría Industrial', 'Mitre 200', '1166443355', 'indus@prov.com', '2024-03-10'),
('FerreMax', 'Rivadavia 300', '1177554466', 'ferremax@prov.com', '2024-03-20'),
('Distribuidora Oeste', 'San Juan 150', '1188665577', 'oeste@prov.com', '2024-03-28'),
('Ferretería Proveedora', 'Av. Libertad 80', '1199776688', 'libertad@prov.com', '2024-04-02');


INSERT INTO Categorias (Nombre, Descripcion)
VALUES
('Herramientas Manuales', 'Llaves, martillos, pinzas'),
('Electricidad', 'Cables, llaves térmicas'),
('Pinturería', 'Pinturas y accesorios'),
('Construcción', 'Cemento, cal, arena'),
('Ferretería General', 'Artículos varios'),
('Plomería', 'Caños, conexiones'),
('Jardinería', 'Palas, mangueras'),
('Medición', 'Cintas métricas, niveles');


INSERT INTO Marcas (Nombre)
VALUES
('Stanley'),
('Bosch'),
('Black & Decker'),
('Dewalt'),
('Truper'),
('Makita'),
('Fischer'),
('3M');


INSERT INTO Productos (Nombre, Descripcion, Precio, Stock, StockMinimo, IDCategoria, IDProveedor, IDMarca)
VALUES
('Martillo Uña', 'Martillo de acero', 4500, 20, 10 , 1, 1, 1),
('Pinza Universal', 'Pinza 8 pulgadas', 3500, 15, 10, 1, 1, 1),
('Taladro Bosch', 'Taladro percutor 600W', 55000, 10, 5, 2, 2, 2),
('Pintura Blanca 4L', 'Pintura látex interior', 12000, 12, 10, 3, 3, 8),
('Cemento x 25kg', 'Bolsa cemento Avellaneda', 3800, 50, 15, 4, 4, 7),
('Llave Termomagnética', 'Llave 20A', 2500, 30, 8, 2, 5, 8),
('Cinta Métrica 5m', 'Truper profesional', 2700, 25, 15, 8, 6, 5),
('Amoladora 850W', 'Amoladora Makita', 65000, 8, 5, 2, 7, 6);


INSERT INTO Compras (Fecha, IDProveedor, Total)
VALUES
('2024-04-01', 1, 25000),
('2024-04-05', 2, 55000),
('2024-04-10', 3, 32000),
('2024-04-12', 4, 46000),
('2024-04-15', 5, 30000),
('2024-04-18', 6, 28000),
('2024-04-20', 7, 35000),
('2024-04-22', 8, 42000);


INSERT INTO Detalle_Compras (IDCompra, IDProducto, Cantidad, PrecioUnitario)
VALUES
(1, 1, 10, 2000),
(1, 2, 5, 1500),
(2, 3, 3, 40000),
(3, 4, 4, 9000),
(4, 5, 20, 2000),
(5, 6, 15, 1800),
(6, 7, 10, 2200),
(7, 8, 2, 50000);


INSERT INTO Ventas (Fecha, IDCliente, Total)
VALUES
('2024-05-01', 1, 7500),
('2024-05-03', 2, 35000),
('2024-05-05', 3, 12000),
('2024-05-06', 4, 65000),
('2024-05-08', 5, 28000),
('2024-05-10', 6, 18000),
('2024-05-12', 7, 22000),
('2024-05-15', 8, 33000);


INSERT INTO Detalle_Ventas (IDVenta, IDProducto, Cantidad, PrecioUnitario)
VALUES
(1, 1, 2, 4500),
(2, 3, 1, 55000),
(3, 4, 1, 12000),
(4, 8, 1, 65000),
(5, 5, 5, 3800),
(6, 7, 2, 2700),
(7, 2, 3, 3500),
(8, 6, 4, 2500);
