-- SQL Core II - Enunciados y soluciones
-- Northwind (SQLite)

-- =============================================================
-- Ejercicio W
-- Enunciado:
-- En Products, devuelve 10 productos activos (Discontinued = '0')
-- de precio alto, ordenados por UnitPrice DESC.
-- Solucion:
SELECT ProductID,
       ProductName,
       UnitPrice,
       Discontinued
FROM Products
WHERE Discontinued = '0'
ORDER BY UnitPrice DESC
LIMIT 10;


-- =============================================================
-- Ejercicio 1
-- Enunciado:
-- En Employees crea:
-- - employee_tag: apellido en mayusculas + nombre en minusculas
-- - location_label: city y country concatenados con CONCAT()
-- Ordena por longitud de employee_tag.
-- Solucion:
SELECT EmployeeID,
       CONCAT(UPPER(TRIM(LastName)), ' ', LOWER(TRIM(FirstName))) AS employee_tag,
       CONCAT(TRIM(COALESCE(City, '')), ', ', TRIM(COALESCE(Country, ''))) AS location_label,
       LENGTH(CONCAT(UPPER(TRIM(LastName)), ' ', LOWER(TRIM(FirstName)))) AS tag_len
FROM Employees
ORDER BY tag_len DESC, EmployeeID;


-- =============================================================
-- Ejercicio 2
-- Enunciado:
-- En Suppliers crea phone_compact limpiando simbolos de Phone,
-- extrae country_prefix (2 primeros chars de Country)
-- y detecta telefonos sospechosos por longitud corta.
-- Solucion:
SELECT SupplierID,
       CompanyName,
       Phone,
       REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(Phone, ''), '(', ''), ')', ''), '-', ''), ' ', ''), '.', '') AS phone_compact,
       UPPER(SUBSTR(COALESCE(Country, ''), 1, 2)) AS country_prefix,
       LENGTH(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(Phone, ''), '(', ''), ')', ''), '-', ''), ' ', ''), '.', '')) AS phone_len,
       CASE
         WHEN LENGTH(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(Phone, ''), '(', ''), ')', ''), '-', ''), ' ', ''), '.', '')) < 8
           THEN 'sospechoso'
         ELSE 'ok'
       END AS phone_quality
FROM Suppliers
ORDER BY phone_len ASC, SupplierID;


-- =============================================================
-- Ejercicio 2B
-- Enunciado:
-- En Employees, crea extension_prefix y extension_len,
-- y lista solo extensiones con menos de 4 digitos.
-- Solucion:
SELECT EmployeeID,
       FirstName,
       LastName,
       Extension,
       SUBSTR(COALESCE(Extension, ''), 1, 2) AS extension_prefix,
       LENGTH(COALESCE(Extension, '')) AS extension_len
FROM Employees
WHERE LENGTH(COALESCE(Extension, '')) < 4
ORDER BY extension_len ASC, EmployeeID;


-- =============================================================
-- Ejercicio 3
-- Enunciado:
-- En Customers, rellena Region y PostalCode con COALESCE/NULLIF
-- y calcula cuantos nulos quedan en cada campo.
-- Solucion (vista de detalle):
SELECT CustomerID,
       CompanyName,
       COALESCE(NULLIF(TRIM(Region), ''), '(sin_region)') AS region_fill,
       COALESCE(NULLIF(TRIM(PostalCode), ''), '(sin_postal)') AS postal_fill
FROM Customers
ORDER BY CustomerID
LIMIT 30;

-- Solucion (conteo de nulos tras NULLIF):
SELECT COUNT(*) AS total_customers,
       SUM(CASE WHEN NULLIF(TRIM(Region), '') IS NULL THEN 1 ELSE 0 END) AS region_null,
       SUM(CASE WHEN NULLIF(TRIM(PostalCode), '') IS NULL THEN 1 ELSE 0 END) AS postalcode_null
FROM Customers;


-- =============================================================
-- Ejercicio 4
-- Enunciado:
-- En Orders (solo 2023) crea delivery_status y days_late
-- (dias de retraso sobre RequiredDate, 0 si no llega tarde).
-- Filtra solo pedidos tarde y ordena por days_late DESC.
-- Solucion:
SELECT OrderID,
       CustomerID,
       OrderDate,
       RequiredDate,
       ShippedDate,
       CASE
         WHEN ShippedDate IS NULL THEN 'pendiente'
         WHEN date(ShippedDate) > date(RequiredDate) THEN 'tarde'
         ELSE 'a_tiempo'
       END AS delivery_status,
       CASE
         WHEN ShippedDate IS NULL THEN 0
         WHEN date(ShippedDate) > date(RequiredDate)
           THEN CAST(julianday(date(ShippedDate)) - julianday(date(RequiredDate)) AS INTEGER)
         ELSE 0
       END AS days_late
FROM Orders
WHERE OrderDate >= '2023-01-01'
  AND OrderDate < '2024-01-01'
  AND date(ShippedDate) > date(RequiredDate)
ORDER BY days_late DESC, OrderDate DESC;


-- =============================================================
-- Ejercicio 4B
-- Enunciado:
-- En Employees, deriva hire_year, hire_month y age_at_hire
-- usando HireDate y BirthDate.
-- Solucion:
SELECT EmployeeID,
       FirstName,
       LastName,
       HireDate,
       BirthDate,
       CAST(strftime('%Y', HireDate) AS INTEGER) AS hire_year,
       CAST(strftime('%m', HireDate) AS INTEGER) AS hire_month,
       (
         CAST(strftime('%Y', HireDate) AS INTEGER) - CAST(strftime('%Y', BirthDate) AS INTEGER)
         - (strftime('%m-%d', HireDate) < strftime('%m-%d', BirthDate))
       ) AS age_at_hire
FROM Employees
ORDER BY HireDate;


-- =============================================================
-- Ejercicio 5
-- Enunciado:
-- En Orders crea un output con:
-- freight_bucket, year_month, postal_quality_flag y priority_flag.
-- Reglas: bucket de Freight (bajo/medio/alto),
-- calidad postal (missing/short/ok), prioridad (alta/media/baja).
-- Solucion:
SELECT OrderID,
       CustomerID,
       ShipCountry,
       Freight,
       strftime('%Y-%m', OrderDate) AS year_month,
       CASE
         WHEN CAST(Freight AS REAL) < 30 THEN 'bajo'
         WHEN CAST(Freight AS REAL) <= 80 THEN 'medio'
         ELSE 'alto'
       END AS freight_bucket,
       CASE
         WHEN ShipPostalCode IS NULL OR TRIM(ShipPostalCode) = '' THEN 'missing'
         WHEN LENGTH(REPLACE(REPLACE(REPLACE(ShipPostalCode, '-', ''), ' ', ''), '.', '')) < 5 THEN 'short'
         ELSE 'ok'
       END AS postal_quality_flag,
       CASE
         WHEN CAST(Freight AS REAL) >= 100
              OR (ShippedDate IS NOT NULL AND date(ShippedDate) > date(RequiredDate))
           THEN 'alta'
         WHEN CAST(Freight AS REAL) >= 60 THEN 'media'
         ELSE 'baja'
       END AS priority_flag
FROM Orders
WHERE OrderDate >= '2023-01-01'
  AND OrderDate < '2024-01-01'
ORDER BY OrderDate DESC
LIMIT 80;


-- =============================================================
-- Ejercicio 5B
-- Enunciado:
-- En [Order Details], crea discount_pct con CAST,
-- y un discount_bucket (sin_descuento/bajo/medio/alto).
-- Solucion:
SELECT OrderID,
       ProductID,
       Discount,
       ROUND(CAST(Discount AS REAL) * 100, 2) AS discount_pct,
       CASE
         WHEN CAST(Discount AS REAL) = 0 THEN 'sin_descuento'
         WHEN CAST(Discount AS REAL) <= 0.05 THEN 'bajo'
         WHEN CAST(Discount AS REAL) <= 0.15 THEN 'medio'
         ELSE 'alto'
       END AS discount_bucket
FROM [Order Details]
ORDER BY discount_pct DESC, OrderID
LIMIT 80;


-- =============================================================
-- Ejercicio A
-- Enunciado:
-- Top 5 CustomerID con mas pedidos en 2023 (solo Orders).
-- Solucion:
SELECT CustomerID,
       COUNT(*) AS total_orders
FROM Orders
WHERE OrderDate >= '2023-01-01'
  AND OrderDate < '2024-01-01'
GROUP BY CustomerID
ORDER BY total_orders DESC, CustomerID
LIMIT 5;


-- =============================================================
-- Ejercicio B
-- Enunciado:
-- Pedidos de 2023 con CompanyName y Freight > 100.
-- Solucion:
SELECT o.OrderID,
       o.OrderDate,
       c.CompanyName,
       o.ShipCountry,
       o.Freight
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE o.OrderDate >= '2023-01-01'
  AND o.OrderDate < '2024-01-01'
  AND o.Freight > 100
ORDER BY o.Freight DESC, o.OrderDate DESC;


-- =============================================================
-- Ejercicio C
-- Enunciado:
-- Une Orders + [Order Details] + Products y saca
-- top 10 productos por cantidad total vendida en 2023.
-- Solucion:
SELECT p.ProductID,
       p.ProductName,
       SUM(od.Quantity) AS total_qty
FROM Orders o
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID
WHERE o.OrderDate >= '2023-01-01'
  AND o.OrderDate < '2024-01-01'
GROUP BY p.ProductID, p.ProductName
ORDER BY total_qty DESC, p.ProductID
LIMIT 10;
