use FerreteriaDB
GO

-- Registra los cambios en los productos --

--AUDITORIA DE PRODUCTOS(CAMBIOS)
CREATE TABLE AuditoriaProductos (
  IDAuditoria INT IDENTITY(1,1) PRIMARY KEY,
  IDProducto INT,
  FechaCambio DATETIME,
  CampoModificado VARCHAR(50),
  ValorAnterior VARCHAR(255),
  ValorNuevo VARCHAR(255)
  );
GO

CREATE TRIGGER Trigger_AuditoriaProductos
ON Productos
AFTER UPDATE
AS
BEGIN
  -- Auditoría de cambios en Nombre
  INSERT INTO AuditoriaProductos (IDProducto, FechaCambio, CampoModificado, ValorAnterior, ValorNuevo)
  SELECT 
    I.IDProducto,
    GETDATE(),
    'Nombre',
    D.Nombre,
    I.Nombre
  FROM INSERTED I
  INNER JOIN DELETED D ON I.IDProducto = D.IDProducto
  WHERE I.Nombre <> D.Nombre;

  -- Auditoría de cambios en Descripcion
  INSERT INTO AuditoriaProductos (IDProducto, FechaCambio, CampoModificado, ValorAnterior, ValorNuevo)
  SELECT 
    I.IDProducto,
    GETDATE(),
    'Descripcion',
    D.Descripcion,
    I.Descripcion
  FROM INSERTED I
  INNER JOIN DELETED D ON I.IDProducto = D.IDProducto
  WHERE I.Descripcion <> D.Descripcion;

  -- Auditoría de cambios en Precio
  INSERT INTO AuditoriaProductos (IDProducto, FechaCambio, CampoModificado, ValorAnterior, ValorNuevo)
  SELECT 
    I.IDProducto,
    GETDATE(),
    'Precio',
    CAST(D.Precio AS VARCHAR),
    CAST(I.Precio AS VARCHAR)
  FROM INSERTED I
  INNER JOIN DELETED D ON I.IDProducto = D.IDProducto
  WHERE I.Precio <> D.Precio;
  -- Auditoría de cambios en Marca
  INSERT INTO AuditoriaProductos (IDProducto, FechaCambio, CampoModificado, ValorAnterior, ValorNuevo)
  SELECT 
    I.IDProducto,
    GETDATE(),
    'Marca',
    D.IDMarca,
    I.IDMarca
  FROM INSERTED I
  INNER JOIN DELETED D ON I.IDProducto = D.IDProducto
  WHERE I.IDMarca <> D.IDMarca;
  -- Auditoría de cambios en Nombre
  INSERT INTO AuditoriaProductos (IDProducto, FechaCambio, CampoModificado, ValorAnterior, ValorNuevo)
  SELECT 
    I.IDProducto,
    GETDATE(),
    'Categoria',
    D.IDCategoria,
    I.IDCategoria
  FROM INSERTED I
  INNER JOIN DELETED D ON I.IDProducto = D.IDProducto
  WHERE I.IDCategoria <> D.IDCategoria;

  -- Auditoría de cambios en Stock
  INSERT INTO AuditoriaProductos (IDProducto, FechaCambio, CampoModificado, ValorAnterior, ValorNuevo)
  SELECT 
    I.IDProducto,
    GETDATE(),
    'Stock',
    CAST(D.Stock AS VARCHAR),
    CAST(I.Stock AS VARCHAR)
  FROM INSERTED I
  INNER JOIN DELETED D ON I.IDProducto = D.IDProducto
  WHERE I.Stock <> D.Stock;

  -- Auditoría de cambios en StockMinimo
  INSERT INTO AuditoriaProductos (IDProducto, FechaCambio, CampoModificado, ValorAnterior, ValorNuevo)
  SELECT 
    I.IDProducto,
    GETDATE(),
    'StockMinimo',
    CAST(D.StockMinimo AS VARCHAR),
    CAST(I.StockMinimo AS VARCHAR)
  FROM INSERTED I
  INNER JOIN DELETED D ON I.IDProducto = D.IDProducto
  WHERE I.StockMinimo <> D.StockMinimo;
END;
Go

---- Recalcular total en caso de eliminar un detalle de venta ----


CREATE TRIGGER restar_detalle_venta
ON Detalle_Ventas
INSTEAD OF DELETE
AS
BEGIN
    -- Validar que la venta tenga menos de 1 día
    IF EXISTS (
        SELECT 1
        FROM deleted d
        INNER JOIN Ventas v ON v.IDVenta = d.IDVenta
        WHERE DATEDIFF(DAY, v.fecha, GETDATE()) >= 1
    )
    BEGIN
        RAISERROR('No se puede eliminar un detalle de una venta con mas de un dia de antiguedad.', 16, 1);
        RETURN;
    END;

    -- Actualizar el total
    UPDATE V
    SET V.total = V.total - (d.PrecioUnitario * d.cantidad)
    FROM dbo.Ventas V
    INNER JOIN deleted d ON V.IDVenta = d.IDVenta;

    -- Eliminar el detalle
    DELETE FROM Detalle_Ventas
    WHERE IDDetalleVenta IN (SELECT IDDetalleVenta FROM deleted);
END;
GO

