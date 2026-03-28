-- Store Procedure 

CREATE DATABASE bdstored;
GO
USE bdstored;
GO

CREATE OR ALTER PROC spu_persona_saludar
    @nombre VARCHAR(50) --Parametro de entrada
AS
BEGIN 
    PRINT 'HOla ' + @nombre;
END;

EXEC spu_persona_saludar 'Arcadio';
EXEC spu_persona_saludar 'Roberta';
EXEC spu_persona_saludar 'Monico';
EXEC spu_persona_saludar 'LUISA';
GO

SELECT CustomerID, CompanyName, City, Country
INTO customers
FROM
Northwind1.dbo.Customers;
GO

-- Relizar un store que permita recibir un parametro de un cliente en particular y 
-- los muestre 
CREATE OR ALTER PROC spu_cliente_consultarporid
    @Id CHAR(10)
AS
BEGIN 
    SELECT CustomerID AS [NUMERO], 
    CompanyName AS [CLIENTE],
    City AS [CIUDAD], 
    Country AS [PAIS]
    FROM customers
    WHERE CustomerID = @Id;
END;
GO

EXEC spu_cliente_consultarporid 'ANTON';
GO

--SEGUNDO EJERCICIO 
SELECT * FROM customers
WHERE EXISTS (SELECT 1
FROM customers
WHERE CustomerID = 'ANTONT')

DECLARE @valor int 

SET @valor = (SELECT 1
FROM customers
WHERE CustomerID = 'ANTON');

IF @valor = 1
BEGIN 
    PRINT 'EXISTE' 
END 
ELSE 
BEGIN 
    PRINT 'NO EXISTE'
END
GO

-- TERCER EJERCICIO STORE PROCEDURE
CREATE OR ALTER PROC spu_cliente_consultarporid2
    @id CHAR(10)
AS
BEGIN

    IF LEN(@id ) > 5
        BEGIN
        RAISERROR('EL ID DEL CLIENTE DEBE SER MENOR O IGUAL A 5', 16, 1);
        --THROW 5001 'EL NUMERO DE CLIENTE DEBE SER MENOR O IGUAL A 5 ', 1
        RETURN 
        END;

    IF EXISTS (SELECT 1 FROM customers WHERE CustomerID = @id)
    BEGIN 
        SELECT 
            CustomerID AS [NUMERO], 
            CompanyName AS [CLIENTE],
            City AS [CIUDAD], 
            Country AS [PAIS]
        FROM Customers
        WHERE CustomerID = @id;

        RETURN;
    END
    PRINT 'EL CLIENTE NO EXISTE'
END;

EXEC spu_cliente_consultarporid2  @id = 'ANTON';

--OTRO MODO DE HACERLO
DECLARE @id2 AS CHAR(10)= (SELECT customerId FROM customers WHERE customerid = 'ANTON');

EXEC spu_cliente_consultarporid2 @id2;

--OTRA MANERA
DECLARE @id3 CHAR (10);

SELECT @ID3 (SELECT customerId FROM customers WHERE customerid = 'ANTON');

EXEC spu_cliente_consultarporid2 @id3;
GO


--Parametros OUTPUT
CREATE OR ALTER PROC spu_operacion_sumar
    @a INT,
    @b AS INT,
    @resultado INT OUTPUT
AS
BEGIN
    SET @resultado = @a + @b;
END;

--Utilizar la variable de salida

DECLARE @res INT;
EXEC spu_operacion_sumar 4,5, @res OUTPUT;
SELECT @res AS [SUMA];
GO

--Crear un store procedure con parametros de entrada y salida 
--para calcular el area de un triangulo 

CREATE OR ALTER PROC spu_calcular_areatriangulo
    @area int,
    @base INT,
    @altura INT
AS
BEGIN 
    SET @area = (@base * @altura) / 2;
END
GO



/*=============================== LOGICA DENTRO DEL SP ==========================*/

--CREAR UN SP QUE EVALUE LA EDAD DE UNA PERSONA
CREATE OR ALTER PROC usp_Persona_EvaluarEdad
@edad INT
AS
BEGIN
IF @edad >=18 AND @edad<=45
BEGIN
PRINT('Eres un adulto sin pension')
 PRINT('Ya merito')
 END
 ELSE
PRINT('Eres menor de Edad')
END;
GO

EXEC usp_Persona_EvaluarEdad 22;
EXEC usp_Persona_EvaluarEdad @edad = 50;
GO


-- Otro ejercicio 
CREATE OR ALTER PROC usp_Valores_Imprimir
    @n AS INT
AS
BEGIN

    IF @n<=0
    BEGIN
        PRINT ('ERROR: VALOR DE N NO VALIDO')
        RETURN;
        END
        
    
    DECLARE @i AS INT;
    SET @i = 1;

    WHILE (@i<=@n)
    BEGIN
        PRINT CONCAT ('Este es el numero: ',@i);
        SET @i = @i + 1;
    END
END;
GO

-- Ejecutar 
EXEC usp_Valores_Imprimir 10;
GO


--OTRO
CREATE OR ALTER PROC usp_Valores_Tabla
    @n AS INT
AS
BEGIN

    IF @n<=0
    BEGIN
        PRINT ('ERROR: VALOR DE N NO VALIDO')
        RETURN;
        END
        
    
    DECLARE @i AS INT;
    DECLARE @j INT = 1;
    SET @i = 1;

    WHILE (@i<=@n)
    BEGIN
        WHILE (@j<=10)
        BEGIN
            PRINT CONCAT(@i, '*', @j, '=', @i*@j);
            SET @j = @j +1;
        END
        PRINT (CHAR(13) + CHAR(10))
        SET @i = @i +1;
        SET @j = 1;
    END
END;
GO

EXEC usp_Valores_Tabla 5;
GO

/*=============================== CASE ==========================*/

--Sirve para evaluar condiciones como un switch o if multiple

 CREATE OR ALTER PROC usp_Calificacion_Evaluar

    @calificacion INT
AS
BEGIN
    SELECT 
    CASE 
        WHEN @calificacion >= 90 THEN 'EXELENTE'
        WHEN @calificacion >= 70 THEN 'APROVADO'
        WHEN @calificacion >= 60 THEN 'REGULAR'
        ELSE 'NO ACREDITADO'
    END AS Resultado

END;
GO

EXEC usp_Calificacion_Evaluar 89;
GO

USE Northwind1;

SELECT 
    ProductName,
    unitPrice,
    CASE
        WHEN UnitPrice>=200 THEN 'CARO'
        WHEN UnitPrice>100 THEN 'MEDIO'
        ELSE 'BARATO'
    END AS [CATEGORIA]
FROM Products;
GO

--OTRO EJERCICIO CON CASE EN CUANTO A  ORDEN DE DINERO
CREATE OR ALTER PROC usp_comision_ventas
    @idCliente nchar(10)
AS
BEGIN
    IF LEN(@idCliente) > 5
    BEGIN
        PRINT('El tamaño del id del cliente debe ser de 5');
        RETURN;
    END;

    IF NOT EXISTS(SELECT 1 FROM Customers WHERE CustomerID = @idCliente)
    BEGIN 
        PRINT('Cliente no existe');
        RETURN;
    END;

    DECLARE @comision DECIMAL(10,2);
    DECLARE @total MONEY;

    -- SUM para acumular todas las ventas del cliente
    SET @total = (
        SELECT SUM(UnitPrice * Quantity) 
        FROM [Order Details] AS od
        INNER JOIN Orders AS o ON o.OrderID = od.OrderID
        WHERE o.CustomerID = @idCliente
    );

    SET @comision =
        CASE 
            WHEN @total >= 19000 THEN 5000
            WHEN @total >= 15000 THEN 2000
            WHEN @total >= 10000 THEN 1000
            ELSE 500
        END;

    PRINT CONCAT(
        'TOTAL VENTAS: ', @total, CHAR(13) + CHAR(10),
        'Comision: ', @comision, CHAR(13) + CHAR(10),
        'Ventas más comision: ', @total + @comision
    );
END;
GO

--EJECUTAR
EXEC usp_comision_ventas 'SEVES';
GO


SELECT o.CustomerID, SUM(od.Quantity * od.UnitPrice) AS [Total]
FROM [Order Details] AS od
INNER JOIN Orders AS o
ON o.OrderID = od.OrderID
GROUP BY o.CustomerID
GO


/*=============================== CRUD ==========================*/

USE bdstored;
GO

CREATE TABLE productos
(
    id int IDENTITY,
    nombre VARCHAR (50),
    precio DECIMAL (10,2)
);
GO


/*=============================== SP PARA INSERT ==========================*/
CREATE OR ALTER PROCEDURE usp_insertarCliente
@nombre VARCHAR (50),
@precio DECIMAL (10,2)
AS
BEGIN
    INSERT INTO productos (nombre, precio)
    VALUES (@nombre, @precio);

END;
GO

EXEC usp_insertarCliente 'Tonayan', 4500.13;
GO

SELECT * FROM productos;
GO

-- SP PARA UPDATE

CREATE OR ALTER PROCEDURE usp_Actualizar_precio
@id INT, 
@precio DECIMAL (10,2);
AS
BEGIN

    IF EXISTS (SELECT 1 FROM productos WHERE id = = @id)
    BEGIN
        UPDATE productos
        SET precio = @precio
        WHERE id = @id;
        RETURN;
    END

    PRINT 'EL ID DEL PRODUCTO NO EXISTE, NO SE REALIZO LA MODIFICACION';
    
END;
GO

EXEC usp_Actualizar_precio 1, 11233.01;
GO

-- SP PARA DELETE 

CREATE OR ALTER PROC usp_Eliminar_Producto
@id AS INT 
AS
BEGIN
    DELETE productos
    WHERE id = @id;
END;
GO

/*=============================== MANEJO DE ERRORES ==========================*/

-- SIN MANEJO DE ERRORES 
SELECT 10/0;
-- Esto genera un error o una excepcion y detiene la ejecucion

BEGIN TRY 
    SELECT 10/0;
END TRY
BEGIN CATCH 
    PRINT 'OCURRIO EL ERROR'
END CATCH 


BEGIN TRY
    SELECT 10/0
END TRY 
BEGIN CATCH
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
    PRINT 'NUMERO: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'LINEA: ' + CAST(ERROR_LINE() AS VARCHAR);
END CATCH;
GO

-- USO CON INSERT 

CREATE TABLE productos2
(
    id int PRIMARY KEY,
    nombre VARCHAR (50),
    precio DECIMAL (10,2)
);

DROP TABLE producto2
INSERT INTO productos2
VALUES (1, 'Pitufo', 359.0);

BEGIN TRY
    INSERT INTO productos2
    VALUES (1, 'quemadita', 65.0);
END TRY
BEGIN CATCH 
    PRINT 'Error al insertar: ' + ERROR_MESSAGE();
    PRINT 'Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Numero ' + CAST(ERROR_LINE() AS VARCHAR);

AND CATCH;
GO

SELECT * FROM productos2
GO

-- EJEMPLO DE USO DE UNA TRANSACCION 3/23/2026

BEGIN TRANSACCION;

INSERT INTO producto2
VALUES(2, 'Pitufina', 56.8);

ROLLBACK; -- CANCELA LA TRANSACCION, PERMITE QUE BD NO QUEDE INCONSISTENTE
COMMIT; -- CONFIRMA LA TRANSACCION, POR QUE TODO FUE ATOMICO O SE CUMPLIO 



/*=============================== USO DE TRANSACCIONES ==========================*/

-- EJERCICIO PARA VERIFICAR EN DENDE EL TRY CATH SE VUELVE PODEROSO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO productos2
    VALUES (3, 'CHARRO NEGRO', 123.0);

    INSERT INTO productos2
    VALUES (3, 'PANTERA ROSA', 345.6);

    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'SE HIZO UN ROLLBACK CON ERROR'
    PRINT 'ERROR: ' + ERROR_MESSAGE()
END CATCH;

-- VALIDAR SI UNA TRANSACCION ESTA ACTIVA

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO productos2
    VALUES (3, 'CHARRO NEGRO', 123.0);

    INSERT INTO productos2
    VALUES (3, 'PANTERA ROSA', 345.6);

    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRACOUNT > 0
    ROLLBACK;
    PRINT 'SE HIZO UN ROLLBACK CON ERROR'
    PRINT 'ERROR: ' + ERROR_MESSAGE()
END CATCH;
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

