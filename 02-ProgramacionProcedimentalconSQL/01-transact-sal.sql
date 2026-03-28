USE Northwind1
GO

/*=====================Variables=====================*/
DECLARE @Edad INT
SET @Edad = 42 

SELECT @Edad AS Edad
PRINT CONCAT ('la edad es:  ',' ',@Edad)

/*====================Ejercicios con variables=============================*/

/*
1.Declarar una variable precio
2. Asignarle el valor de 150 
3. Calcular el IVA del 16%
4. Mostrar el total
*/

DECLARE @Precio MONEY = 150 -- Se le asigna un valor inicial 
DECLARE	@Total MONEY 

SET @Total = @Precio * 1.16
SELECT @Total As [Total]

/*====================IF/ELSE=============================*/

DECLARE @Edad2 INT
SET @Edad2 = 18

IF @Edad2 >= 18
BEGIN
	PRINT 'Es mayor de Edad'
	PRINT 'Felicidades'
END
ELSE 
	PRINT 'Es menor'

/*====================EJERCICIO IF/ELSE=============================*/

/*
	1. Crear una variable calificacion
	2. Evaluar si es mayor a 70 imprimir "Aprovado", si no "Reprobado"

*/

DECLARE @Calificacion INT = 72


IF @Calificacion >= 70
 PRINT 'Aprovado'

ELSE 
	PRINT 'REPROVADO'

---segundo ejercicio

DECLARE @contador INT;
DECLARE @contador2 INT = 1;
SET @contador = 1;

WHILE @contador <= 5
BEGIN 
	WHILE @contador2
	BEGIN
	PRINT CONCAT(@contador, '-', @contador2);
	SET @contador2 + 1
	END;
	SET @contador2 = 1
	SET @contador = @contador + 1;
END:
GO

--Imprime los numeros del 10 al 1 
DECLARE @i INT 10;
WHILE @i = 1
BEGIN 
	WHILE @i >= 1
	BEGIN
	PRINT @i;
	SET @i = @i - 1
	END;
	GO
	
/*====================STORED PROCEDURE=============================*/
CREATE PROCEDURE usp_mensaje_saludar
AS
BEGIN
	PRINT ('Hola Mundo Transact-SQL');
END;
GO

CREATE OR ALTER PROCEDURE usp_mensaje_saludar
AS 
BEGIN 
	PRINT ('Hola Mundo Transact-SQL-2');
END;
GO

/*====================EJERCICIOS=============================*/

-- VAMOS A CREAR UN STORE PROCEDURE QUE IMPRIMA LA FECHA ACTUAL
CREATE PROCEDURE usp_fecha_mostrar
AS 
BEGIN
	DECLARE @FechaActual DATETIME 
	SET @FechaActual = GETDATE();

	PRINT 'La fecha actual es ' + CONVERT(VARCHAR(30), @FechaActual, 120);
END;
GO

EXEC usp_mensaje_fecha;
GO



	
-- TODO: CICLO WHILE 