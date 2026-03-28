USE Northwind1;
GO

USE Northwind1;
GO

SELECT * FROM Products;
GO

-- EJERCICIO:
-- CREAR UN STORE PROCEDURE QUE REGISTRE UNA VENTA
-- 1. MANEJO DE ERRORES Y TRANSACCIONES
-- 2. INSERTAR VENTA, QUE INCLUYA LA FECHA ACTUAL Y 
-- EL CLIENTE QUE LA REALIZO, (VERIFICAR SI EL CLIENTE EXISTE)
-- 3. REGISTRAR EL DETALLE CON UN SOOLO PRODUCTO, (VERIFICAR SI EL PRODUCTO EXISTE)
-- DEBEN OBTENER EL PRECIO ACTUAL DEL PRODUCTO O PARA INSERTARLO EN DETALLE DE VENTA,
-- TAMBIEN SE DEBE VERIFIFCAR QUE EL PRODUCTO TENGA SUFICIENTE EXISTENCIA
-- 4. ACTUALIZAR LA EXISTENCIA CON LA CANTIDAD VENDIDA


-- Tabla Cliente simplificada
CREATE TABLE Cliente (
    id_Cliente NCHAR(5) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    Pais NVARCHAR(50) NOT NULL,
    Ciudad NVARCHAR(50) NOT NULL,
    CONSTRAINT FK_Cliente_Customers FOREIGN KEY (id_Cliente)
        REFERENCES Customers(CustomerID)
);
GO

SELECT *
FROM Cliente;
GO

-- Tabla Producto referenciada a Products
CREATE TABLE Producto (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    precio MONEY NOT NULL,
    existencia INT NOT NULL,
    CONSTRAINT FK_Producto_Products FOREIGN KEY (id)
        REFERENCES Products(ProductID)
);
GO

SELECT *
FROM Producto;
GO

-- Tabla Venta
CREATE TABLE Venta (
    id_Venta INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATETIME DEFAULT GETDATE(),
    id_Cliente NCHAR(5) NOT NULL,
    CONSTRAINT FK_Venta_Cliente FOREIGN KEY (id_Cliente)
        REFERENCES Cliente(id_Cliente)
);
GO

SELECT *
FROM Venta;
GO

-- Tabla DetalleVenta
CREATE TABLE DetalleVenta (
    id_Detalle INT IDENTITY(1,1) PRIMARY KEY,
    id_Venta INT NOT NULL,
    idProducto INT NOT NULL,
    PrecioVenta MONEY NOT NULL,
    Cantidad INT NOT NULL,
    CONSTRAINT FK_DetalleVenta_Venta FOREIGN KEY (id_Venta)
        REFERENCES Venta(id_Venta),
    CONSTRAINT FK_DetalleVenta_Producto FOREIGN KEY (idProducto)
        REFERENCES Producto(id)
);
GO

SELECT *
FROM DetalleVenta;
GO


-- Cliente esta llenado con los datos relacionados de Customers 
INSERT INTO Cliente (id_Cliente, nombre, Pais, Ciudad)
SELECT TOP 5 CustomerID, CompanyName, Country, City
FROM Customers
ORDER BY CustomerID;
GO

-- Producto esta llenada con los primeros 5 datos de la tabla referenciada de Products
INSERT INTO Producto (nombre, precio, existencia)
SELECT TOP 5 ProductName, UnitPrice, UnitsInStock
FROM Products
ORDER BY ProductID;
GO

-- Venta se encuentra llanda con datos de prueba de Cliente
INSERT INTO Venta (id_Cliente, Fecha)
VALUES 
('ALFKI', GETDATE()), 
('ANATR', GETDATE());  
GO

-- Se encuentra relacinada con los datos de la tabla referenciada que es Products
-- a su vez es relacion con una venta y un producto
INSERT INTO DetalleVenta (id_Venta, idProducto, PrecioVenta, Cantidad)
VALUES
(1, 1, 18.00, 3),   -- Numero de la venta 1, y es el producto 1
(1, 2, 19.00, 2),   -- Numero de la venta 1, y es el producto 2
(2, 3, 10.00, 4);   -- Numero de l aventa 2, y es el producto 3
GO


-- Creacion del Store PRocedure usp_insertarVentaSimplificada
CREATE OR ALTER PROCEDURE usp_insertarVentaSimplificada
    @idCliente NCHAR(5),
    @idProducto INT,
    @Cantidad INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Existencia INT;
    DECLARE @Precio MONEY;
    DECLARE @VentaID INT;

    BEGIN TRY
        -- Validar cliente
        IF NOT EXISTS (SELECT 1 FROM Cliente WHERE id_Cliente = @idCliente)
        BEGIN
            THROW 50001, 'El cliente no existe en la tabla Cliente', 1;
        END;

        -- Validar producto
        IF NOT EXISTS (SELECT 1 FROM Producto WHERE id = @idProducto)
        BEGIN
            THROW 50002, 'El producto no existe en la tabla Producto', 1;
        END;

        -- Obtener existencia y precio
        SELECT @Existencia = existencia, @Precio = precio
        FROM Producto
        WHERE id = @idProducto;

        IF @Existencia < @Cantidad
        BEGIN
            THROW 50003, 'No hay suficiente stock en Producto', 1;
        END;

        BEGIN TRANSACTION;

        -- Insertar venta
        INSERT INTO Venta (id_Cliente, Fecha)
        VALUES (@idCliente, GETDATE());

        SET @VentaID = SCOPE_IDENTITY();

        -- Insertar detalle
        INSERT INTO DetalleVenta (id_Venta, idProducto, PrecioVenta, Cantidad)
        VALUES (@VentaID, @idProducto, @Precio, @Cantidad);

        -- Actualizar stock
        UPDATE Producto
        SET existencia = existencia - @Cantidad
        WHERE id = @idProducto;

        COMMIT;
        PRINT 'Venta registrada correctamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- ejecucion del Store Procedure 
EXEC usp_insertarVentaSimplificada 
    @idCliente = 'ALFKI', @idProducto = 1, @Cantidad = 2;      

    --ejecucion con prueba dde error  (se espera un ERROR (ya que se puso una cantidad mayor de los productos del stock))
    EXEC usp_insertarVentaSimplificada 
    @idCliente = 'ALFKI', @idProducto = 1, @Cantidad = 38;  -- el Producto es Chai y la cantidad de stock es 37