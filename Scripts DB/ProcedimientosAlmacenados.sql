USE FerreteriaDB;
GO

---- Registrar Compra ----

CREATE TYPE TipoProductosCompra AS TABLE
(
    IDProducto INT,
    Cantidad INT,
    PrecioUnitario DECIMAL(10,2)
);
GO

CREATE PROCEDURE RegistrarCompra
    @IDProveedor INT,
    @Fecha DATE = NULL,
    @ProductosCompra AS dbo.TipoProductosCompra READONLY
AS
BEGIN
    SET NOCOUNT ON;

    IF @Fecha IS NULL
        SET @Fecha = GETDATE();

    DECLARE @IDCompra INT;
    DECLARE @TotalCompraCalculado DECIMAL(10,2);
    DECLARE @MensajeError NVARCHAR(MAX)

    BEGIN TRY
        BEGIN TRANSACTION;

        -- ********* VALIDACIONES *********
        IF NOT EXISTS (SELECT 1 FROM @ProductosCompra)
        BEGIN
            SET @MensajeError = 'No se han proporcionado productos para registrar la compra. La compra no puede estar vacia.';
            RAISERROR(@MensajeError, 16, 1);
        END

        IF NOT EXISTS (SELECT 1 FROM Proveedores WHERE IDProveedor = @IDProveedor)
        BEGIN
            SET @MensajeError = 'El ID de proveedor proporcionado (' + CAST(@IDProveedor AS NVARCHAR(10)) + ') no existe.';
            RAISERROR(@MensajeError, 16, 1);
        END

        IF EXISTS (SELECT pc.IDProducto
                   FROM @ProductosCompra pc
                   LEFT JOIN Productos p ON pc.IDProducto = p.IDProducto
                   WHERE p.IDProducto IS NULL)
        BEGIN
            SELECT @MensajeError = STRING_AGG('IDProducto: ' + CAST(pc.IDProducto AS NVARCHAR(10)), ', ')
            FROM @ProductosCompra pc
            LEFT JOIN Productos p ON pc.IDProducto = p.IDProducto
            WHERE p.IDProducto IS NULL;
            SET @MensajeError = 'Uno o mas productos en la lista no existen: ' + @MensajeError + '.';
            RAISERROR(@MensajeError, 16, 1);
        END

        IF EXISTS (SELECT 1 FROM @ProductosCompra WHERE Cantidad <= 0 OR PrecioUnitario <= 0)
        BEGIN
            SET @MensajeError = 'La cantidad y el precio unitario de los productos deben ser mayores a cero.';
            RAISERROR(@MensajeError, 16, 1);
        END

        -- ********* REGISTRO DE COMPRA *********
        SELECT @TotalCompraCalculado = SUM(pc.Cantidad * pc.PrecioUnitario)
        FROM @ProductosCompra pc;

        IF @TotalCompraCalculado IS NULL
        BEGIN
            SET @TotalCompraCalculado = 0;
        END

        INSERT INTO Compras (Fecha, IDProveedor, Total)
        VALUES (@Fecha, @IDProveedor, @TotalCompraCalculado);

        SET @IDCompra = SCOPE_IDENTITY();

        INSERT INTO Detalle_Compras (IDCompra, IDProducto, Cantidad, PrecioUnitario)
        SELECT @IDCompra, pc.IDProducto, pc.Cantidad, pc.PrecioUnitario
        FROM @ProductosCompra pc;

        UPDATE p
        SET Stock = p.Stock + pc.Cantidad
        FROM Productos p
        INNER JOIN @ProductosCompra pc ON p.IDProducto = pc.IDProducto;

        COMMIT TRANSACTION;

        -- Mensaje 
        SET @MensajeError = 'Compra registrada exitosamente. ID de Compra: ' + CAST(@IDCompra AS NVARCHAR(10)) + '. Total: ' + FORMAT(@TotalCompraCalculado, 'C', 'es-ES');
        PRINT @MensajeError;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Capturarerror
        DECLARE @ErrorMessageCATCH NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @ErrorSeverityCATCH INT = ERROR_SEVERITY();
        DECLARE @ErrorStateCATCH INT = ERROR_STATE();

        IF @ErrorMessageCATCH LIKE '%No se han proporcionado productos%' OR
           @ErrorMessageCATCH LIKE '%El ID de proveedor proporcionado no existe%' OR
           @ErrorMessageCATCH LIKE '%Uno o mas productos en la lista no existen%' OR
           @ErrorMessageCATCH LIKE '%La cantidad y el precio unitario de los productos deben ser mayores a cero%'
        BEGIN
            SET @MensajeError = @ErrorMessageCATCH;
        END
        ELSE
        BEGIN
            SET @MensajeError = 'Error inesperado al registrar la compra. Detalles: ' + @ErrorMessageCATCH;
        END

        RAISERROR(@MensajeError, @ErrorSeverityCATCH, @ErrorStateCATCH);
    END CATCH
END;
GO

---- Registrar Venta ----

CREATE TYPE TipoProductosVenta AS TABLE
(
    IDProducto INT,
    Cantidad INT,
    PrecioUnitario DECIMAL(10,2) 
);
GO

CREATE PROCEDURE RegistrarVenta
    @IDCliente INT,
    @Fecha DATE = NULL,
    @ProductosVenta AS dbo.TipoProductosVenta READONLY
AS
BEGIN
    SET NOCOUNT ON; 
    IF @Fecha IS NULL
        SET @Fecha = GETDATE();

    DECLARE @IDVenta INT;
    DECLARE @TotalVentaCalculado DECIMAL(10,2);
    DECLARE @MensajeError NVARCHAR(MAX); 

    BEGIN TRY
        BEGIN TRANSACTION; 

        -- ********* VALIDACIONES *********

        IF NOT EXISTS (SELECT 1 FROM @ProductosVenta)
        BEGIN
            SET @MensajeError = 'No se han proporcionado productos para registrar la venta. La venta no puede estar vacia.';
            RAISERROR(@MensajeError, 16, 1);
        END
 
        IF NOT EXISTS (SELECT 1 FROM Clientes WHERE IDCliente = @IDCliente)
        BEGIN
            SET @MensajeError = 'El ID de cliente proporcionado (' + CAST(@IDCliente AS NVARCHAR(10)) + ') no existe.';
            RAISERROR(@MensajeError, 16, 1);
        END

        IF EXISTS (SELECT pv.IDProducto
                   FROM @ProductosVenta pv
                   LEFT JOIN Productos p ON pv.IDProducto = p.IDProducto
                   WHERE p.IDProducto IS NULL)
        BEGIN
            SELECT @MensajeError = STRING_AGG('IDProducto: ' + CAST(pv.IDProducto AS NVARCHAR(10)), ', ')
            FROM @ProductosVenta pv
            LEFT JOIN Productos p ON pv.IDProducto = p.IDProducto
            WHERE p.IDProducto IS NULL;
            SET @MensajeError = 'Uno o mas productos en la lista no existen: ' + @MensajeError + '.';
            RAISERROR(@MensajeError, 16, 1);
        END

        IF EXISTS (SELECT 1 FROM @ProductosVenta WHERE Cantidad <= 0 OR PrecioUnitario <= 0)
        BEGIN
            SET @MensajeError = 'La cantidad y el precio unitario de los productos deben ser mayores a cero.';
            RAISERROR(@MensajeError, 16, 1);
        END

        IF EXISTS (SELECT 1
                   FROM @ProductosVenta pv
                   INNER JOIN Productos p ON pv.IDProducto = p.IDProducto
                   WHERE pv.Cantidad > p.Stock)
        BEGIN
            SELECT @MensajeError = STRING_AGG('Producto ID ' + CAST(pv.IDProducto AS NVARCHAR(10)) + ' (Stock disponible: ' + CAST(p.Stock AS NVARCHAR(10)) + ', Solicitado: ' + CAST(pv.Cantidad AS NVARCHAR(10)) + ')', '; ')
            FROM @ProductosVenta pv
            INNER JOIN Productos p ON pv.IDProducto = p.IDProducto
            WHERE pv.Cantidad > p.Stock;
            SET @MensajeError = 'No hay suficiente stock para los siguientes productos: ' + @MensajeError;
            RAISERROR(@MensajeError, 16, 1);
        END

        -- ********* REGISTRO DE VENTA *********
        SELECT @TotalVentaCalculado = SUM(pv.Cantidad * pv.PrecioUnitario)
        FROM @ProductosVenta pv;

        IF @TotalVentaCalculado IS NULL
        BEGIN
            SET @TotalVentaCalculado = 0;
        END

        INSERT INTO Ventas (Fecha, IDCliente, Total)
        VALUES (@Fecha, @IDCliente, @TotalVentaCalculado);

        SET @IDVenta = SCOPE_IDENTITY();

        INSERT INTO Detalle_Ventas (IDVenta, IDProducto, Cantidad, PrecioUnitario)
        SELECT @IDVenta, pv.IDProducto, pv.Cantidad, pv.PrecioUnitario
        FROM @ProductosVenta pv;

        UPDATE p
        SET Stock = p.Stock - pv.Cantidad
        FROM Productos p
        INNER JOIN @ProductosVenta pv ON p.IDProducto = pv.IDProducto;

        COMMIT TRANSACTION;

        SET @MensajeError = 'Venta registrada exitosamente. ID de Venta: ' + CAST(@IDVenta AS NVARCHAR(10)) + '. Total: ' + FORMAT(@TotalVentaCalculado, 'C', 'es-ES');
        PRINT @MensajeError;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessageCATCH NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @ErrorSeverityCATCH INT = ERROR_SEVERITY();
        DECLARE @ErrorStateCATCH INT = ERROR_STATE();

        IF @ErrorMessageCATCH LIKE '%No se han proporcionado productos%' OR
           @ErrorMessageCATCH LIKE '%El ID de cliente proporcionado no existe%' OR
           @ErrorMessageCATCH LIKE '%Uno o mas productos en la lista no existen%' OR
           @ErrorMessageCATCH LIKE '%La cantidad y el precio unitario de los productos deben ser mayores a cero%' OR
           @ErrorMessageCATCH LIKE '%No hay suficiente stock%'
        BEGIN
            SET @MensajeError = @ErrorMessageCATCH; 
        END
        ELSE
        BEGIN
            SET @MensajeError = 'Error inesperado al registrar la venta. Detalles: ' + @ErrorMessageCATCH;
        END

        RAISERROR(@MensajeError, @ErrorSeverityCATCH, @ErrorStateCATCH);
    END CATCH
END;
GO


---- Actualizar precio de productos por proveedor, y marca si se ingresa ----

CREATE PROCEDURE SP_ActualizarPreciosPorProveedorYMarca
    @IDProveedor INT,
    @PorcentajeCambio DECIMAL(5,2),
    @IDMarca INT = NULL
AS
BEGIN    
    DECLARE @FilasAfectadas INT

    BEGIN TRY        
        -- Validar que el proveedor exista
        IF (SELECT COUNT(*) FROM Proveedores WHERE IDProveedor = @IDProveedor) = 0
        BEGIN
            RAISERROR('El proveedor no existe.', 16, 1)            
        END

        -- Validar que el porcentaje sea distinto de 0
        
        IF @PorcentajeCambio = 0 OR @PorcentajeCambio <= -90 OR @PorcentajeCambio >= 100
        BEGIN
            RAISERROR('El porcentaje debe ser distinto de 0, mayor a -90 y menor a 100.', 16, 1)            
        END

        -- Validar que el proveedor tenga productos
        IF (SELECT COUNT(*) FROM Productos WHERE IDProveedor = @IDProveedor) = 0
        BEGIN
            RAISERROR('El proveedor no tiene productos.', 16, 1)            
        END

        -- Validar que la marca exista, si se especifico
        IF @IDMarca IS NOT NULL
        BEGIN
            IF (SELECT COUNT(*) FROM Marcas WHERE IDMarca = @IDMarca) = 0
            BEGIN
                RAISERROR('La marca no existe.', 16, 1);                
            END

            IF (SELECT COUNT(*) FROM Productos WHERE IDProveedor = @IDProveedor AND IDMarca = @IDMarca) = 0
            BEGIN
                RAISERROR('El proveedor no tiene productos de esa marca.', 16, 1)                
            END
        END           

        -- Actualizar precios
        UPDATE Productos
        SET Precio = ROUND(Precio * (1 + @PorcentajeCambio / 100.0), 2)
        WHERE IDProveedor = @IDProveedor AND (@IDMarca IS NULL OR IDMarca = @IDMarca)

        SET @FilasAfectadas = @@ROWCOUNT
                
            PRINT 'Se actualizaron los precios de ' + CAST(@FilasAfectadas AS NVARCHAR(10)) + ' productos.'    
    END TRY 

    BEGIN CATCH
        THROW
    END CATCH
END