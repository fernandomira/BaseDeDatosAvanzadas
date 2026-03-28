2create database bdsubqueries;

USE bdsubqueries;

CREATE TABLE clientes (
	id_cliente int not null identity (1,1) primary key, 
	nombre varchar (50) not null,
	ciudad varchar (50) not null, 
);

CREATE TABLE pedidos (
	id_pedidos int not null identity (1,1) primary key,
	id_cliente int not null,
	totoal money not null, 
	fecha date not null
	constraint fk_pedidos_clientes
	FOREIGN KEY (id_cliente)
	REFERENCES CLIENTES (id_cliente)
	ON DELETE CASCADE 
	);

	
INSERT INTO clientes (nombre, ciudad) VALUES
('Ana', 'CDMX'),
('Luis', 'Guadalajara'),
('Marta', 'CDMX'),
('Pedro', 'Monterrey'),
('Sofia', 'Puebla'),
('Carlos', 'CDMX'), 
('Artemio', 'Pachuca'), 
('Roberto', 'Veracruz');

INSERT INTO pedidos (id_cliente, totoal, fecha) VALUES
(1, 1000.00, '2024-01-10'),
(1, 500.00,  '2024-02-10'),
(2, 300.00,  '2024-01-05'),
(3, 1500.00, '2024-03-01'),
(3, 700.00,  '2024-03-15'),
(1, 1200.00, '2024-04-01'),
(2, 800.00,  '2024-02-20'),
(3, 400.00,  '2024-04-10');


--subconsultas 

select 
	MAX(totoal)
from pedidos;

--Consultas principal 
select *
from pedidos
where totoal = (
	SELECT MAX(totoal) FROM pedidos 
	);


	SELECT TOP 1 * FROM
	pedidos
	ORDER BY totoal desc;

--SELECCCIONAR EL CLIENTE QUE HIZO EL PEDIDO MAS CARO
--SUBCONSULTA
SELECT id_cliente
FROM pedidos 
WHERE totoal = (SELECT MAX(totoal) from pedidos);

--CONSULTA PRINCIPAL 
SELECT top 1 *
FROM pedidos
WHERE id_cliente = (
	SELECT id_cliente
	FROM pedidos 
	WHERE totoal = (SELECT MAX(totoal) from pedidos)
);


SELECT top 1 P.id_pedidos, c.nombre,  p.totoal, p.fecha
FROM pedidos as p
INNER JOIN 
clientes AS c
ON p.id_cliente = c.id_cliente
order by totoal desc


--seleccionar los pedidos mayores al promedio
SELECT AVG(totoal)
FROM pedidos;

SELECT * 
FROM pedidos
WHERE totoal > (
	SELECT AVG(totoal)
	FROM pedidos
);


--mostrar el cliente con menor id
SELECT MIN(id_cliente)
FROM pedidos;

SELECT 
    p.id_pedidos,
    c.nombre,
    p.totoal,
    p.fecha
FROM pedidos AS p
INNER JOIN clientes AS c
    ON p.id_cliente = c.id_cliente
WHERE p.id_cliente = (
    SELECT MIN(id_cliente)
    FROM pedidos
);

--mostrar el ultimo pedido realizado 

SELECT MAX (fecha)
FROM pedidos;

SELECT p.id_cliente, p.fecha, c.nombre, p.totoal
FROM pedidos AS p
INNER JOIN 
clientes as c
ON p.id_cliente = c.id_cliente
WHERE fecha = (SELECT MAX (fecha)
FROM pedidos
);


--mostrar el pedido con el total mas bajo
SELECT min(totoal)
FROM pedidos;

SELECT *
FROM pedidos
WHERE totoal = (
SELECT min(totoal)
FROM pedidos
);


--SELCIIONAR LOS PEDIDOS CON EL NOM BRE DLE CLINETECUYO OTOTAOLO DEL LA CARG(FREIGHT0 SEA
--MAYOR AL PROMEDIO GENERAL DE FREIGHT

SELECT AVG(Freight)
FROM Orders;

select 
	o.orderid,
	c.companyName,
	o.Freight
from orders as o
inner join 
customers as c
on o.customerid = c.customerId, 
WHERE o.Freight > (
SELECT AVG(Freight)
FROM Orders)
ORDER BY Freight DESC


--Clientes que han hecho pedidos 

SELECT id_cliente 
FROM pedidos;

SELECT *
FROM clientes
WHERE id_cliente in (
SELECT id_cliente 
FROM pedidos
);

SELECT DISTINCT c.id_cliente, c.nombre, c.ciudad
FROM clientes as c
INNER JOIN pedidos AS p 
ON c.id_cliente = p.id_cliente;

--seleccionar los clientes de la cdmx que han hecho pedidos

SELECT id_cliente
FROM clientes;

SELECT *
FROM clientes
WHERE ciudad = 'CDMX'
AND id_cliente IN (
	SELECT id_cliente
	FROM clientes
);