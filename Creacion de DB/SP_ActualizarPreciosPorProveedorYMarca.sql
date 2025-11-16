CREATE PROCEDURE SP_ActualizarPreciosPorProveedorYMarca
    @IDProveedor INT,
    @PorcentajeCambio DECIMAL(5,2),
    @IDMarca INT = NULL
AS
BEGIN    
    DECLARE @FilasAfectadas INT

    BEGIN TRY        
        -- validar que el proveedor exista
        IF (SELECT COUNT(*) FROM Proveedores WHERE IDProveedor = @IDProveedor) = 0
        BEGIN
            RAISERROR('El proveedor no existe.', 16, 1)            
        END

        -- Validar que el porcentaje sea distinto de 0
        IF @PorcentajeCambio = 0
        BEGIN
            RAISERROR('El porcentaje no puede ser 0.', 16, 1)            
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