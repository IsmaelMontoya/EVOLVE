USE classicmodels;

/* ============================================================
   SQL Analitico I (MySQL 8+)
   Tema: Subqueries + CTEs + OFFSET + refactor de queries largas
   Dataset: classicmodels
   ============================================================ */

-- Agenda (3h con 15 min de descanso)
-- 0:00-0:20 Setup MySQL + DBeaver + warm-up de tablas
-- 0:20-1:00 Subqueries en WHERE (IN, EXISTS)
-- 1:00-1:15 Subqueries en FROM (derived tables)
-- 1:15-1:30 Descanso
-- 1:30-2:05 CTEs (WITH) + refactor
-- 2:05-2:25 OFFSET (paginacion)
-- 2:25-3:00 Caso final integrador


/* ============================================================
   0) Setup y warm-up
   ============================================================ */

-- Verifica conexion y base activa
SELECT DATABASE() AS active_database;
SHOW TABLES;

SELECT * FROM customers LIMIT 5;
SELECT * FROM orders LIMIT 5;
SELECT * FROM products LIMIT 5;
SELECT * FROM payments LIMIT 5;

-- Ejercicio 1:
-- Comprueba que customers, orders, products y payments tienen datos.
-- Devuelve tabla + n_filas en una sola consulta (UNION ALL).

select 'customers' as Tabla, count(*) as n_rows 
from customers as c
union all 
select 'orders' as Tabla, count(*) as n_rows 
from orders as o
union all 
select 'orderdetails' as Tabla, count(*) as n_rows 
from orderdetails as od
union all 
select 'payments' as Tabla, count(*) as n_rows 
from payments as p;

-- Ejercicio 2:
-- Escribe 3 consultas separadas para:
-- A) Top 5 clientes por total pagado (customerNumber, customerName, total_paid)
SELECT 
    c.customerNumber,
    c.customerName,
    SUM(p.amount) AS total_paid
FROM customers c
JOIN payments p 
    ON c.customerNumber = p.customerNumber
GROUP BY 
    c.customerNumber,
    c.customerName
ORDER BY 
    total_paid DESC
LIMIT 5;

-- B) Top 3 productos por cantidad vendida (productCode, productName, units_sold)
SELECT 
    p.productCode,
    p.productName,
    SUM(od.quantityOrdered) AS units_sold
FROM orderdetails od
JOIN products p 
    ON od.productCode = p.productCode
GROUP BY 
    p.productCode, 
    p.productName
ORDER BY 
    units_sold DESC
LIMIT 3;

-- C) Oficina con mayor número de pedidos (officeCode, city, country, n_orders)
SELECT 
    o.officeCode,
    o.city,
    o.country,
    COUNT(ord.orderNumber) AS n_orders
FROM offices o
JOIN employees e 
    ON o.officeCode = e.officeCode
JOIN customers c 
    ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN orders ord 
    ON c.customerNumber = ord.customerNumber
GROUP BY 
    o.officeCode,
    o.city,
    o.country
ORDER BY 
    n_orders DESC
LIMIT 1;


/* ============================================================
   1) Subqueries en WHERE (IN, EXISTS)
   ============================================================ */

-- Ejemplo 1A: clientes que han hecho pedidos
SELECT
    c.customerNumber,
    c.customerName
FROM customers c
WHERE c.customerNumber IN (
    SELECT o.customerNumber
    FROM orders o
)
ORDER BY c.customerName;

-- Ejemplo 1B: misma logica con EXISTS
SELECT
    c.customerNumber,
    c.customerName
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customerNumber = c.customerNumber
)
ORDER BY c.customerName;

-- Ejercicio 3:
-- Empleados que gestionan al menos un cliente.
-- Pista: customers.salesRepEmployeeNumber -> employees.employeeNumber.
SELECT 
	e.employeeNumber AS idEmpleado,
	e.firstName AS nombreEmpleado
FROM employees e
#Exists es mejor qu IN por que a veces deja de buscar con al primera coincidencia
WHERE EXISTS(
	#No usamos distinct por que en el in no coge duplicados
	SELECT 1 
	FROM customers c
	WHERE c.salesRepEmployeeNumber = e.employeeNumber
)
ORDER BY idEmpleado;

-- Ejercicio 4:
-- Clientes que no han realizado pagos.
-- Hazlo con NOT EXISTS.
SELECT
	customerNumber AS id,
	customerName AS nombre
FROM customers c
WHERE NOT EXISTS(
	SELECT 1
	FROM payments p
	WHERE p.customerNumber = c.customerNumber
)
ORDER BY customerNumber;





/* ============================================================
   2) Subqueries en FROM (derived table)
   ============================================================ */

-- Ejemplo 2A: total pagado por cliente
SELECT
    c.customerNumber,
    c.customerName,
    pt.total_paid
FROM customers c
JOIN (
    SELECT
        p.customerNumber,
        SUM(p.amount) AS total_paid
    FROM payments p
    GROUP BY p.customerNumber
) pt
    ON c.customerNumber = pt.customerNumber
ORDER BY pt.total_paid DESC, c.customerName;

-- Ejercicio 5:
-- Top 10 productos por cantidad vendida (units_sold).
-- Pista:
-- 1) agrega en orderdetails por productCode
-- 2) une con products para mostrar nombre


/* ============================================================
   3) CTEs (WITH) + refactor
   ============================================================ */

-- Ejemplo 3A: revenue por cliente con CTE + join a customers
WITH revenue_by_customer AS (
    SELECT
        o.customerNumber,
        SUM(od.quantityOrdered * od.priceEach) AS revenue
    FROM orders o
    JOIN orderdetails od
        ON od.orderNumber = o.orderNumber
    GROUP BY o.customerNumber
)
SELECT
    c.customerNumber,
    c.customerName,
    COALESCE(r.revenue, 0) AS revenue
FROM customers c
LEFT JOIN revenue_by_customer r
    ON r.customerNumber = c.customerNumber
ORDER BY revenue DESC, c.customerName;

-- Ejemplo 3B: misma idea, pero en dos pasos para mejor legibilidad
WITH line_revenue AS (
    SELECT
        od.orderNumber,
        od.productCode,
        od.quantityOrdered * od.priceEach AS line_amount
    FROM orderdetails od
),
revenue_by_order AS (
    SELECT
        lr.orderNumber,
        SUM(lr.line_amount) AS order_revenue
    FROM line_revenue lr
    GROUP BY lr.orderNumber
)
SELECT
    o.orderNumber,
    o.customerNumber,
    rbo.order_revenue
FROM orders o
JOIN revenue_by_order rbo
    ON rbo.orderNumber = o.orderNumber
ORDER BY rbo.order_revenue DESC, o.orderNumber;

-- Ejercicio 6:
-- Ranking de comerciales por numero de clientes (de mayor a menor).
-- Pista: CTE con COUNT(*) por salesRepEmployeeNumber.

-- Ejercicio 7:
-- Oficinas con mas clientes.
-- Pista: offices -> employees -> customers.


/* ============================================================
   4) OFFSET (paginacion)
   ============================================================ */

-- Ejemplo 4A: pagina 1 (10 filas)
SELECT
    c.customerNumber,
    c.customerName
FROM customers c
ORDER BY c.customerName
LIMIT 10 OFFSET 0;

-- Ejemplo 4B: pagina 2 (10 filas)
SELECT
    c.customerNumber,
    c.customerName
FROM customers c
ORDER BY c.customerName
LIMIT 10 OFFSET 10;

-- Ejercicio 8:
-- Devuelve la segunda pagina de productos (10 filas por pagina)
-- ordenados por buyPrice DESC y productCode.


/* ============================================================
   5) Caso final integrador
   ============================================================ */

-- Ejercicio 9:
-- Construye un resumen por oficina con:
-- oficina, n_clientes, n_pedidos, total_pagado, pago_medio
-- Recomendacion: resolver con CTEs separados y luego unirlos.
-- Importante: evita duplicaciones por joins N-1/N-N.

-- Entrega sugerida:
-- officeCode, city, country, n_clientes, n_pedidos, total_pagado, pago_medio
-- ordenado por total_pagado DESC.


/* ============================================================
   Checklist rapido para debug
   ============================================================ */
-- 1) Define grano (una fila por cliente, pedido, oficina, etc.).
-- 2) Verifica claves en ON antes de agregar.
-- 3) Compara COUNT(*) antes y despues del join.
-- 4) Si hay duplicados, agrega antes de unir (subquery/CTE).
