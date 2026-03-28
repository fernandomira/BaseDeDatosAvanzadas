# Fundamentoss Programables

1. Que es la parte programable de T-SQL?

Es todo lo que permite:

- Usar variables
- Control de flujos 
- Crear procedimientos Almacenados (store Procedure)
- Manejar Errores
- Crear transacciones
- Disparadores (Triggers)


Nota: Es convertir SQL en un lenguaje casi como C/Java pero dentro del engine

2. Variables
Una variable almacena un valor temporal 

'''sql
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
'''

3. IF/ELSE

Permite ejecutar codigo segun una condicion 

'''sql
DECLARE @Edad2 INT
SET @Edad2 = 18

IF @Edad2 >= 18
BEGIN
	PRINT 'Es mayor de Edad'
	PRINT 'Felicidades'
END
ELSE 
	PRINT 'Es menor'
'''

4. WHILE
'''sql
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

'''

## Procedimientos Almacenados (Store Procedure)

5. ✌️¿Que es un Store PRocedure?

Es un bloque de codigo guardado en una base de datos que se 
pueede ejecutar cuando se necisite

'''sql
CREATE PROCEDURE nombre usp_objeto_accion
{Parameters}
AS 
BEGIN 
 -- Body
END;

CREATE PROC nombre usp_objeto_accion
{Parameters}
AS 
BEGIN 
 -- Body
END;

CREATE OR ALTER nombre usp_objeto_accion
{Parameters}
AS 
BEGIN 
 -- Body
END;
'''

