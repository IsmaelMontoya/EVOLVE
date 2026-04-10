-- =============================================================
-- SQL Core I (3h total, 15m break)
-- Foco: SELECT + filtros + CASE
-- Modalidad: practica intensiva
-- Base: northwind.db (SQLite)
-- =============================================================

-- -----------------------------------------------------------------
-- GUIA DE TIEMPOS (180 min totales)
-- 0:00-0:15  Setup + warm-up
-- 0:15-0:45  SELECT + WHERE + ORDER BY + LIMIT
-- 0:45-1:15  Filtros avanzados (IN/BETWEEN/LIKE/NULL)
-- 1:15-1:30  DESCANSO (15 min)
-- 1:30-2:00  Calidad de datos (DISTINCT/COUNT/COALESCE)
-- 2:00-2:30  Texto/fechas + CASE
-- 2:30-2:55  Mini-caso end-to-end (sin GROUP BY/JOIN)
-- 2:55-3:00  Cierre + receta SQL
-- -----------------------------------------------------------------


-- =============================================================
-- 0:00-0:15 | Setup + warm-up
-- Objetivo: confirmar entorno y tomar ritmo rapido.
-- =============================================================

-- Demo 0.1: ver objetos disponibles.
SELECT name
FROM sqlite_master
WHERE type IN ('table', 'view')
ORDER BY name;

-- Demo 0.2: primeras 8 ordenes recientes.
SELECT OrderID, CustomerID, OrderDate, ShipCountry, Freight
FROM Orders
ORDER BY OrderDate DESC
LIMIT 8;

-- Ejercicio W1 (3 min):
-- Muestra 5 clientes de USA ordenados alfabeticamente por CompanyName.
-- Plantilla:
-- SELECT ...
-- FROM Customers
-- WHERE ...
-- ORDER BY ...
-- LIMIT ...;


-- Ejercicio W2 (3 min):
-- Muestra 10 productos mas caros (ProductName, UnitPrice).



-- =============================================================
-- 0:15-0:45 | SELECT + WHERE + ORDER BY + LIMIT
-- Objetivo: dominar la base de consulta en una sola tabla.
-- =============================================================

-- Ejemplo 1:
-- Productos activos con precio intermedio y stock sano.
SELECT ProductID,
       ProductName,
       UnitPrice,
       UnitsInStock,
       Discontinued
FROM Products
WHERE Discontinued = '0'
  AND UnitPrice BETWEEN 15 AND 40
  AND UnitsInStock > 20
ORDER BY UnitPrice DESC, ProductName
LIMIT 20;

-- Ejercicio 1 (8 min):
-- Productos baratos y con poco stock:
-- UnitPrice < 12, UnitsInStock <= 15, solo activos.
-- Mostrar ProductID, ProductName, UnitPrice, UnitsInStock.


-- Ejercicio 2 (8 min):
-- Ordenes en USA o Mexico durante 2023, con Freight > 50.
-- Mostrar OrderID, OrderDate, ShipCountry, Freight.


-- Ejercicio 3 (7 min):
-- Empleados de USA o UK contratados entre 2013 y 2019.
-- Mostrar EmployeeID, FirstName, LastName, Country, HireDate.



-- =============================================================
-- 0:45-1:15 | Filtros avanzados
-- IN / BETWEEN / LIKE / NULL / precedencia AND-OR
-- =============================================================

-- Ejemplo 2:
-- Filtro combinado con texto y nulos.
SELECT OrderID,
       ShipName,
       ShipCountry,
       ShipPostalCode,
       OrderDate
FROM Orders
WHERE ShipCountry IN ('USA', 'Germany', 'Brazil')
  AND (ShipPostalCode LIKE '9%' OR ShipPostalCode IS NULL)
  AND ShipName LIKE '%Market%'
ORDER BY OrderDate DESC
LIMIT 25;

-- Ejercicio 4 (8 min):
-- Ordenes de Germany con ShipPostalCode empezando por 5.
-- Mostrar OrderID, OrderDate, ShipPostalCode, Freight.


-- Ejercicio 5 (8 min):
-- Clientes con Region NULL o Fax NULL.
-- Mostrar CustomerID, CompanyName, Region, Fax.


-- Ejercicio 6 (9 min):
-- Ordenes "problematicas":
-- ShippedDate NULL o enviadas tarde (ShippedDate > RequiredDate).
-- Mostrar OrderID, OrderDate, RequiredDate, ShippedDate.



-- =============================================================
-- 1:15-1:30 | DESCANSO
-- =============================================================


-- =============================================================
-- 1:30-2:00 | Calidad de datos + NULL
-- DISTINCT / COUNT / COALESCE (sin GROUP BY)
-- =============================================================

-- Ejemplo 3.1: cuantos clientes tienen region informada.
SELECT COUNT(*) AS total_clientes,
       COUNT(Region) AS con_region,
       COUNT(*) - COUNT(Region) AS sin_region
FROM Customers;

-- Ejemplo 3.2: limpieza visual de Region.
SELECT CustomerID,
       CompanyName,
       COALESCE(Region, '(sin region)') AS region_limpia,
       Country
FROM Customers
ORDER BY CompanyName
LIMIT 20;

-- Ejercicio 7 (8 min):
-- Cuantos clientes no tienen fax informado (NULL o vacio).


-- Ejercicio 8 (8 min):
-- Lista de paises distintos de clientes (sin duplicados).
-- Reemplaza NULL por '(desconocido)'.


-- Ejercicio 9 (9 min):
-- Compara conteos en Orders:
-- total filas, filas con ShipPostalCode informado, filas sin ShipPostalCode.



-- =============================================================
-- 2:00-2:30 | Texto/fechas + CASE
-- Buckets y flags de negocio en una sola tabla.
-- =============================================================

-- Ejemplo 4:
-- Clasificar freight y estado de entrega.
SELECT OrderID,
       OrderDate,
       RequiredDate,
       ShippedDate,
       Freight,
       strftime('%Y-%m', OrderDate) AS year_month,
       CASE
         WHEN Freight < 30 THEN 'freight_bajo'
         WHEN Freight <= 80 THEN 'freight_medio'
         ELSE 'freight_alto'
       END AS freight_bucket,
       CASE
         WHEN ShippedDate IS NULL THEN 'pendiente'
         WHEN date(ShippedDate) > date(RequiredDate) THEN 'tarde'
         ELSE 'a_tiempo'
       END AS entrega_flag
FROM Orders
WHERE OrderDate >= '2023-01-01'
ORDER BY OrderDate DESC
LIMIT 30;

-- Ejercicio 10 (8 min):
-- Extrae anio, mes y dia de OrderDate en 2023.
-- Mostrar OrderID, OrderDate, anio, mes, dia.


-- Ejercicio 11 (10 min):
-- Bucket de precio de productos:
-- < 15 -> economico
-- 15 a 40 -> medio
-- > 40 -> premium
-- Mostrar ProductName, UnitPrice, bucket_precio.


-- Ejercicio 12 (12 min):
-- Crear bandera de inventario:
-- UnitsInStock = 0 -> rotura
-- UnitsInStock <= ReorderLevel -> reponer
-- otro caso -> ok
-- Mostrar ProductName, UnitsInStock, ReorderLevel, flag_stock.



-- =============================================================
-- 2:30-2:55 | Mini-caso end-to-end (sin GROUP BY/JOIN)
-- Caso: priorizar seguimiento logistico y surtido.
-- =============================================================

-- Ejemplo 5 (logistica):
-- Ordenes 2023 con freight por encima de la media 2023.
SELECT OrderID,
       CustomerID,
       ShipCountry,
       OrderDate,
       Freight,
       ROUND((SELECT AVG(Freight)
              FROM Orders
              WHERE OrderDate >= '2023-01-01'
                AND OrderDate < '2024-01-01'), 2) AS avg_freight_2023,
       CASE
         WHEN Freight > (SELECT AVG(Freight)
                         FROM Orders
                         WHERE OrderDate >= '2023-01-01'
                           AND OrderDate < '2024-01-01')
           THEN 'sobre_media'
         ELSE 'normal'
       END AS flag_coste
FROM Orders
WHERE OrderDate >= '2023-01-01'
  AND OrderDate < '2024-01-01'
  AND ShipCountry IN ('USA', 'Germany', 'France')
ORDER BY Freight DESC
LIMIT 30;

-- Ejercicio 13 (12 min):
-- En Products, etiqueta cada producto contra la media global de precio:
-- UnitPrice > media -> arriba_media
-- si no -> abajo_media
-- Mostrar ProductID, ProductName, UnitPrice, flag_precio.


-- Ejercicio 14 (13 min):
-- Detecta ordenes "atencion" en 2023 con estas reglas:
-- - freight_alto si Freight >= 80
-- - entrega_tarde si ShippedDate > RequiredDate
-- - prioridad si se cumple alguna de las dos
-- Mostrar OrderID, Freight, RequiredDate, ShippedDate, prioridad.



-- =============================================================
-- 2:55-3:00 | Cierre
-- Receta SQL Core I (sin agregacion por grupos ni joins)
-- =============================================================

-- 1) SELECT columnas
-- 2) FROM tabla
-- 3) WHERE filtros
-- 4) ORDER BY
-- 5) LIMIT
-- 6) CASE para reglas
-- 7) COALESCE para nulos
-- 8) DISTINCT / COUNT para chequeos de calidad


-- =============================================================
-- BONUS OPCIONAL (10-20 min) | Si sobra tiempo
-- GROUP BY + JOIN (muy basico)
-- =============================================================

-- Bonus demo 1: contar pedidos por pais de envio en 2023.
SELECT ShipCountry,
       COUNT(*) AS total_pedidos
FROM Orders
WHERE OrderDate >= '2023-01-01'
  AND OrderDate < '2024-01-01'
GROUP BY ShipCountry
ORDER BY total_pedidos DESC
LIMIT 10;

-- Bonus ejercicio A (5-8 min):
-- Mostrar los 5 clientes con mas pedidos en 2023.
-- Pistas: tabla Orders, GROUP BY CustomerID, ORDER BY COUNT(*) DESC.

-- Bonus demo 2: join simple entre Orders y Customers.
SELECT o.OrderID,
       o.OrderDate,
       o.ShipCountry,
       c.CompanyName
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE o.OrderDate >= '2023-01-01'
ORDER BY o.OrderDate DESC
LIMIT 15;

-- Bonus ejercicio B (5-8 min):
-- Mostrar pedidos de 2023 con nombre de cliente y freight > 100.
-- Salida: OrderID, OrderDate, CompanyName, Freight.
