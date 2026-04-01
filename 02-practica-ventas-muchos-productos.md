# Store Procedure: usp_insertarVentaMultiple

## 📌 Descripción
Este Store Procedure permite registrar una venta con múltiples productos en una sola ejecución, utilizando un tipo de dato tabla (TVP).

---

## ⚙️ Tecnologías utilizadas
- SQL Server
- Table-Valued Parameters (TVP)
- Transacciones (BEGIN TRANSACTION / COMMIT / ROLLBACK)
- Manejo de errores (TRY...CATCH)

---

##  ¿Qué es un Store Procedure?
Es un conjunto de instrucciones SQL almacenadas en la base de datos que se pueden ejecutar cuando se necesiten.

---

## ✅ Ventajas
- Reutilización de código  
- Mejor rendimiento  
- Seguridad (evita inyección SQL)  
- Centraliza lógica de negocio  

---

## Estructura utilizada

### Tipo de tabla
```sql
CREATE TYPE DetalleVentaType AS TABLE
(
    idProducto INT,
    Cantidad INT
);
```
### Store PRcedure
```sql
CREATE PROCEDURE usp_insertarVentaMultiple
    @idCliente NCHAR(5),
    @Detalles DetalleVentaType READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @VentaID INT;

    BEGIN TRY
        -- Validar cliente
        IF NOT EXISTS (SELECT 1 FROM Cliente WHERE id_Cliente = @idCliente)
            THROW 50001, 'Cliente no existe', 1;

        -- Validar stock
        IF EXISTS (
            SELECT 1
            FROM @Detalles d
            JOIN Producto p ON p.id = d.idProducto
            WHERE p.existencia < d.Cantidad
        )
            THROW 50002, 'Stock insuficiente', 1;

        BEGIN TRANSACTION;

        -- Insertar venta
        INSERT INTO Venta (id_Cliente, Fecha)
        VALUES (@idCliente, GETDATE());

        SET @VentaID = SCOPE_IDENTITY();

        -- Insertar detalle
        INSERT INTO DetalleVenta (id_Venta, idProducto, PrecioVenta, Cantidad)
        SELECT 
            @VentaID,
            p.id,
            p.precio,
            d.Cantidad
        FROM @Detalles d
        JOIN Producto p ON p.id = d.idProducto;

        -- Actualizar stock
        UPDATE p
        SET existencia = existencia - d.Cantidad
        FROM Producto p
        JOIN @Detalles d ON p.id = d.idProducto;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        THROW;
    END CATCH
END;
```

### Ejemplo de ejecucion

```sql
DECLARE @Detalles DetalleVentaType;

INSERT INTO @Detalles VALUES (1,2), (2,1);

EXEC usp_insertarVentaMultiple 
    @idCliente = 'ALFKI',
    @Detalles = @Detalles;
```