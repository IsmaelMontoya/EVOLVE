-- =============================================================
-- SQL Core I - Solucionario
-- Base: northwind.db (SQLite)
-- Incluye las soluciones de W1, W2 y ejercicios 1-14.
-- =============================================================

-- -------------------------------------------------------------
-- Warm-up
-- -------------------------------------------------------------

-- Solucion W1
SELECT CustomerID, CompanyName, City, Country
FROM Customers
WHERE Country = 'USA'
ORDER BY CompanyName
LIMIT 5;

-- Solucion W2
SELECT ProductName, UnitPrice
FROM Products
ORDER BY UnitPrice DESC
LIMIT 10;


-- -------------------------------------------------------------
-- Bloque SELECT + WHERE + ORDER BY + LIMIT
-- -------------------------------------------------------------

-- Solucion 1
SELECT ProductID, ProductName, UnitPrice, UnitsInStock
FROM Products
WHERE UnitPrice < 12
  AND UnitsInStock <= 15
  AND Discontinued = '0'
ORDER BY UnitPrice ASC, UnitsInStock ASC;

-- Solucion 2
SELECT OrderID, OrderDate, ShipCountry, Freight
FROM Orders
WHERE ShipCountry IN ('USA', 'Mexico')
  AND OrderDate >= '2023-01-01'
  AND OrderDate < '2024-01-01'
  AND Freight > 50
ORDER BY Freight DESC
LIMIT 30;

-- Solucion 3
SELECT EmployeeID, FirstName, LastName, Country, HireDate
FROM Employees
WHERE Country IN ('USA', 'UK')
  AND HireDate BETWEEN '2013-01-01' AND '2019-12-31'
ORDER BY HireDate;


-- -------------------------------------------------------------
-- Bloque filtros avanzados
-- -------------------------------------------------------------

-- Solucion 4
SELECT OrderID, OrderDate, ShipPostalCode, Freight
FROM Orders
WHERE ShipCountry = 'Germany'
  AND ShipPostalCode LIKE '5%'
ORDER BY OrderDate DESC;

-- Solucion 5
SELECT CustomerID, CompanyName, Region, Fax
FROM Customers
WHERE Region IS NULL
   OR Fax IS NULL
ORDER BY CompanyName;

-- Solucion 6
SELECT OrderID, OrderDate, RequiredDate, ShippedDate
FROM Orders
WHERE ShippedDate IS NULL
   OR date(ShippedDate) > date(RequiredDate)
ORDER BY OrderDate DESC
LIMIT 40;


-- -------------------------------------------------------------
-- Bloque calidad de datos + NULL
-- -------------------------------------------------------------

-- Solucion 7
SELECT COUNT(*) AS sin_fax
FROM Customers
WHERE COALESCE(TRIM(Fax), '') = '';

-- Solucion 8
SELECT DISTINCT COALESCE(Country, '(desconocido)') AS country_limpio
FROM Customers
ORDER BY country_limpio;

-- Solucion 9
SELECT COUNT(*) AS total_ordenes,
       COUNT(ShipPostalCode) AS con_postal,
       COUNT(*) - COUNT(ShipPostalCode) AS sin_postal
FROM Orders;


-- -------------------------------------------------------------
-- Bloque texto/fechas + CASE
-- -------------------------------------------------------------

-- Solucion 10
SELECT OrderID,
       OrderDate,
       strftime('%Y', OrderDate) AS anio,
       strftime('%m', OrderDate) AS mes,
       strftime('%d', OrderDate) AS dia
FROM Orders
WHERE OrderDate >= '2023-01-01'
  AND OrderDate < '2024-01-01'
ORDER BY OrderDate DESC
LIMIT 25;

-- Solucion 11
SELECT ProductName,
       UnitPrice,
       CASE
         WHEN UnitPrice < 15 THEN 'economico'
         WHEN UnitPrice <= 40 THEN 'medio'
         ELSE 'premium'
       END AS bucket_precio
FROM Products
ORDER BY UnitPrice DESC;

-- Solucion 12
SELECT ProductName,
       UnitsInStock,
       ReorderLevel,
       CASE
         WHEN UnitsInStock = 0 THEN 'rotura'
         WHEN UnitsInStock <= ReorderLevel THEN 'reponer'
         ELSE 'ok'
       END AS flag_stock
FROM Products
ORDER BY UnitsInStock ASC, ReorderLevel DESC;


-- -------------------------------------------------------------
-- Mini-caso end-to-end
-- -------------------------------------------------------------

-- Solucion 13
SELECT ProductID,
       ProductName,
       UnitPrice,
       CASE
         WHEN UnitPrice > (SELECT AVG(UnitPrice) FROM Products) THEN 'arriba_media'
         ELSE 'abajo_media'
       END AS flag_precio
FROM Products
ORDER BY UnitPrice DESC;

-- Solucion 14
SELECT OrderID,
       Freight,
       RequiredDate,
       ShippedDate,
       CASE
         WHEN Freight >= 80 OR date(ShippedDate) > date(RequiredDate) THEN 'prioridad'
         ELSE 'normal'
       END AS prioridad
FROM Orders
WHERE OrderDate >= '2023-01-01'
  AND OrderDate < '2024-01-01'
ORDER BY Freight DESC, OrderDate DESC
LIMIT 40;

-- Fin del solucionario.
