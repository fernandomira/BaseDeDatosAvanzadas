#Store Procedure: usp_insertarVentaSimplificada

## Fundamentos

¿Qué es un Store Procedure?
Es un bloque de código SQL guardado dentro de la base de datos (un objeto de la BD) que puede ejecutarse cuando se necesite.  
Es similar a una función o método en programación.

Ventajas:
1. Reutilización de código  
2. Mejor rendimiento  
3. Mayor seguridad (evita inyección SQL)  
4. Centralización de la lógica del negocio  
5. Menos tráfico entre la aplicación y el servidor  

---

Requerimientos del ejercicio

1. Manejo de errores y transacciones.  
2. Insertar una venta, que incluya la fecha actual y el cliente que la realizó (verificar si el cliente existe).  
3. Registrar el detalle con un solo producto (verificar si el producto existe).  
   - Obtener el precio actual del producto para insertarlo en el detalle.  
   - Verificar que el producto tenga suficiente existencia.  
4. Actualizar la existencia con la cantidad vendida.  

---

Tablas simplificadas utilizadas

- Cliente  
  - id_Cliente (PK, referencia a Customers.CustomerID)  
  - nombre, Pais, Ciudad

- Producto  
  - id (PK, referencia a Products.ProductID)  
  - nombre, precio, existencia

- Venta  
  - id_Venta (PK)  
  - Fecha, id_Cliente (FK a Cliente)

- DetalleVenta  
  - id_Detalle (PK)  
  - id_Venta (FK a Venta)  
  - idProducto (FK a Producto)  
  - PrecioVenta, Cantidad

---

Script de creación de tablas

```sql
USE Northwind1;
GO

-- Tabla Cliente simplificada
CREATE TABLE Cliente (
    id_Cliente NCHAR(5) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    Pais NVARCHAR(50) NOT NULL,
    Ciudad NVARCHAR(50) NOT NULL,
    CONSTRAINT FKClienteCustomers FOREIGN KEY (id_Cliente)
        REFERENCES Customers(CustomerID)
);
GO

-- Tabla Producto referenciada a Products
CREATE TABLE Producto (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    precio MONEY NOT NULL,
    existencia INT NOT NULL,
    CONSTRAINT FKProductoProducts FOREIGN KEY (id)
        REFERENCES Products(ProductID)
);
GO

-- Tabla Venta
CREATE TABLE Venta (
    id_Venta INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATETIME DEFAULT GETDATE(),
    id_Cliente NCHAR(5) NOT NULL,
    CONSTRAINT FKVentaCliente FOREIGN KEY (id_Cliente)
        REFERENCES Cliente(id_Cliente)
);
GO

-- Tabla DetalleVenta
CREATE TABLE DetalleVenta (
    id_Detalle INT IDENTITY(1,1) PRIMARY KEY,
    id_Venta INT NOT NULL,
    idProducto INT NOT NULL,
    PrecioVenta MONEY NOT NULL,
    Cantidad INT NOT NULL,
    CONSTRAINT FKDetalleVentaVenta FOREIGN KEY (id_Venta)
        REFERENCES Venta(id_Venta),
    CONSTRAINT FKDetalleVentaProducto FOREIGN KEY (idProducto)
        REFERENCES Producto(id)
);
GO
```

---

Script de llenado de datos

```sql
-- Tabla Cliente Referenciada con datos de Customers
INSERT INTO Cliente (id_Cliente, nombre, Pais, Ciudad)
SELECT TOP 5 CustomerID, CompanyName, Country, City
FROM Customers
ORDER BY CustomerID;

-- Tabla Producto Referenciada con datos de Products
INSERT INTO Producto (nombre, precio, existencia)
SELECT TOP 5 ProductName, UnitPrice, UnitsInStock
FROM Products
ORDER BY ProductID;

-- Insertar ventas de prueba
INSERT INTO Venta (id_Cliente, Fecha)
VALUES 
('ALFKI', GETDATE()),   -- Cliente Alfreds Futterkiste
('ANATR', GETDATE());   -- Cliente Ana Trujillo

-- Insertar detalles de ventas de prueba
INSERT INTO DetalleVenta (id_Venta, idProducto, PrecioVenta, Cantidad)
VALUES
(1, 1, 18.00, 3),   -- Venta 1, Producto 1
(1, 2, 19.00, 2),   -- Venta 1, Producto 2
(2, 3, 10.00, 4);   -- Venta 2, Producto 3
```

---

Código del Store Procedure

```sql
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
        PRINT 'Venta registrada correctamente en tablas simplificadas';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
```

---

Ejemplo de ejecución

```sql
EXEC usp_insertarVentaSimplificada 
    @idCliente = 'ALFKI',
    @idProducto = 1,
    @Cantidad = 2;
```

---

 Explicación del funcionamiento

- Cliente está referenciado a la tabla original Customers.  
- Producto está referenciado a la tabla original Products.  
- Venta se relaciona con Cliente.  
- DetalleVenta se relaciona con Venta y Producto.  

El procedimiento:
1. Valida que el cliente y producto existan en las tablas simplificadas.  
2. Obtiene precio y existencia del producto.  
3. Si hay stock suficiente, inserta la venta en Venta.  
4. Inserta el detalle en DetalleVenta.  
5. Actualiza la existencia en Producto.  
6. Usa transacciones para garantizar consistencia: si algo falla, hace ROLLBACK.  

---

Consulta para ver resultados

```sql
SELECT v.id_Venta, v.Fecha, c.nombre AS Cliente, c.Pais, c.Ciudad,
       p.nombre AS Producto, dv.PrecioVenta, dv.Cantidad
FROM Venta v
INNER JOIN Cliente c ON v.idCliente = c.idCliente
INNER JOIN DetalleVenta dv ON v.idVenta = dv.idVenta
INNER JOIN Producto p ON dv.idProducto = p.id;
```
