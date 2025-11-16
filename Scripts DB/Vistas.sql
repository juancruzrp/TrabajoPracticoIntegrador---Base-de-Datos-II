use FerreteriaDB
GO

---- Lista de historial de ventas por cliente  ----

CREATE VIEW VW_HistorialVentasPorCliente AS
SELECT 
    c.IDCliente,
    c.DNI,
    CONCAT(c.Nombre,+' ,',+c.Apellido) AS 'Nombre Completo',
    ISNULL(c.Mail,c.Telefono) AS Contacto,
    COUNT(v.IDVenta) AS ComprasRealizadas,
    SUM(v.Total) AS MontoTotalGastado,
    MIN(v.Fecha) AS PrimerCompra,
    MAX(v.Fecha) AS UltimaCompra
FROM Clientes c
LEFT JOIN Ventas v ON c.IDCliente = v.IDCliente
GROUP BY c.IDCliente, c.DNI, c.Apellido, c.Nombre, c.Mail, c.Telefono;
GO


---- Lista de rentabilidad por producto ----

CREATE VIEW Vista_RentabilidadPorProducto
AS
WITH CostoPromedioProducto AS (
    SELECT
        dc.IDProducto,
        AVG(dc.PrecioUnitario) AS CostoUnitarioPromedio
    FROM Detalle_Compras dc
    GROUP BY dc.IDProducto
)
SELECT
    p.IDProducto,
    p.Nombre AS NombreProducto,
    c.Nombre AS CategoriaProducto,
    ISNULL(SUM(dv.Cantidad), 0) AS CantidadTotalVendida,
    ISNULL(cpp.CostoUnitarioPromedio, 0.00) AS CostoUnitarioPromedio,
    ISNULL(AVG(dv.PrecioUnitario), 0.00) AS PrecioVentaUnitarioPromedio,
    ISNULL(SUM(dv.Cantidad * dv.PrecioUnitario), 0.00) AS IngresosTotalesPorProducto,
    ISNULL(SUM(dv.Cantidad * ISNULL(cpp.CostoUnitarioPromedio, 0.00)), 0.00) AS CostoTotalDeVentasPorProducto,
    ISNULL(SUM(dv.Cantidad * (dv.PrecioUnitario - ISNULL(cpp.CostoUnitarioPromedio, 0.00))), 0.00) AS GananciaBrutaPorProducto
FROM Productos p
INNER JOIN Categorias c ON p.IDCategoria = c.IDCategoria
LEFT JOIN Detalle_Ventas dv ON p.IDProducto = dv.IDProducto 
LEFT JOIN CostoPromedioProducto cpp ON p.IDProducto = cpp.IDProducto
GROUP BY
    p.IDProducto,
    p.Nombre,
    c.Nombre,
    cpp.CostoUnitarioPromedio 
GO


---- Listas de compras por fecha ----

CREATE VIEW vw_ComprasPorFecha
AS
SELECT 
    c.fecha,
    COUNT(dc.IDProducto) AS cantidadProductos,
    c.IDProveedor,
    SUM(dc.cantidad * dc.PrecioUnitario) AS montoTotal
FROM Compras AS c
INNER JOIN Detalle_Compras AS dc 
    ON c.IDCompra = dc.IDCompra
GROUP BY 
    c.fecha,
    c.IDProveedor;
GO

