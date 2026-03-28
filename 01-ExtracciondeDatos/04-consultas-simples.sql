--consultas  Simples 
USE Northwind;

--Seleccionar cada una de las tablas de base de datos Northwind

SELECT *
FROM Customers;
GO

SELECT * 
FROM Employees;
GO

SELECT * 
FROM Orders;
GO

SELECT * 
FROM OrderDetails;
GO

SELECT * 
FROM Shippers;
GO

SELECT * 
FROM Suppliers;
GO

SELECT * 
FROM Products;
GO


--Proyecccion de la atabla

SELECT ProductName, Unit, Price
FROM Products;

--Alias de columnas
SELECT ProductName AS NombreProducto, 
Unit 'Unidades Medida', 
Price AS [Precio Unitario]
FROM Products;
GO

--campo calculado y alias de tabla
SELECT 
	OrderID As [NUMERO DE ORDEN], 
	Products.ProductID AS [NUMERO DE PRODUCTO], 
	ProductName AS 'NOMBRE DE PRODUCTO', 
	Quantity AS CANTIDAD, 
	Price AS PRECIO, 
	(Quantity * Price) AS SUBTOTAL
FROM OrderDetails
INNER JOIN
Products
ON Products.ProductID = OrderDetails.ProductID;
GO

--le ponemos alias en nombre de las tablas
SELECT 
	OrderID As [NUMERO DE ORDEN], 
	pr.ProductID AS [NUMERO DE PRODUCTO], 
	ProductName AS 'NOMBRE DE PRODUCTO', 
	Quantity AS CANTIDAD, 
	Price AS PRECIO, 
	(Quantity * Price) AS SUBTOTAL
FROM OrderDetails AS od
INNER JOIN
Products pr
ON pr.ProductID = od.ProductID;
GO

--operadores relacionales (<, >, <=, >=, = != o <>)
--Mostrar tod los productos mayores a 20

SELECT 
	ProductName AS [Nombre Producto],
	Unit AS [Descripcion],
	Price As [Precio]
FROM Products --no se utiliza alias porque se utiliza solo una tabla
WHERE Price > 20;  --primero se ve la tabla, despues donde y altimo filtra

--Seleccionar todos los clientes que no sean de Mexico
SELECT *
FROM Customers
WHERE Country <> 'Mexico';
GO

--sELECCIONAR TODAS AQUELLAS ORDENES REALIZADAS EN 1997
SELECT 
	OrderID AS [Numero DE Orden], 
	OrderDate AS [Fecha De Orden],
	YEAR (OrderDate) AS [Anio con Year], --year es en todos (estandar) y datepart es solo de sqlserver
	DATEPART (YEAR, OrderDate) AS [Anio con DATEPART]
FROM Orders
WHERE YEAR(OrderDate) = 1997;

--operadores logicos (AND, OR NOT) SI SE QUIERE QUE SE HAGA PRIMERO ES PONER ENTRE PARENTESIS
-- PRIORIDAD NOT, DE AHI AND Y ULTIMO OR

SELECT 8
FROM Products;