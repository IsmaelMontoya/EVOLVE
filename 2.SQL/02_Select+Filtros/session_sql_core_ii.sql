-- SQL Core II
-- Northwind (SQLite)

-- Agenda SQL Core II (3h + 15' descanso)
-- 0:00-0:10 Warm-up
-- 0:10-0:40 Texto I: normalizar strings
-- 0:40-1:05 Texto II: extraccion y limpieza
-- 1:05-1:15 NULL bien
-- 1:15-1:30 Descanso
-- 1:30-2:05 Fechas: comparar y derivar campos
-- 2:05-2:35 CAST + CASE avanzado
-- 2:35-2:55 JOIN + GROUP BY basicos
-- 2:55-3:00 Cierre rapido



-- 0:00-0:10 Warm-up

SELECT OrderID,
       CustomerID,
       OrderDate,
       ShipCountry,
       Freight
FROM Orders
WHERE ShipCountry IN ('USA', 'Germany')
  AND OrderDate >= '2023-01-01'
ORDER BY OrderDate DESC
LIMIT 10;

-- Ejercicio W:
-- En Products, devuelve 10 productos activos (Discontinued = '0')
-- de precio alto, ordenados por UnitPrice DESC.


-- 0:10-0:40 Texto I: normalizar strings

SELECT SupplierID,
       UPPER(TRIM(CompanyName)) AS supplier_clean,
       LOWER(TRIM(COALESCE(ContactName, '(sin_contacto)'))) AS contact_clean,
       CONCAT(TRIM(COALESCE(City, '')), ', ', TRIM(COALESCE(Country, ''))) AS city_country,
       LENGTH(TRIM(CompanyName)) AS supplier_len
FROM Suppliers
ORDER BY supplier_len DESC, SupplierID
LIMIT 20;

-- Ejercicio 1:
-- En Employees crea:
-- - employee_tag: apellido en mayusculas + nombre en minusculas
-- - location_label: city y country concatenados con CONCAT()
-- Ordena por longitud de employee_tag.


-- 0:40-1:05 Texto II: extraccion y limpieza

SELECT
  SUBSTR('Nicolas', 1, 1)  AS ex1,  -- 'N'
  SUBSTR('Nicolas', 2, 3)  AS ex2,  -- 'ico'
  SUBSTR('Nicolas', 4)     AS ex3,  -- 'olas'
  SUBSTR('Nicolas', -2, 2) AS ex4;  -- 'as'

SELECT
  INSTR('Ana Perez', ' ')  AS ex1,  -- 4 (posición del primer espacio)
  INSTR('Ana Perez', 'P')  AS ex2,  -- 5
  INSTR('Ana Perez', 'ez') AS ex3,  -- 8
  INSTR('Madonna',  ' ')   AS ex4;  -- 0 (no hay espacio)

SELECT
  'Ana Perez' AS name,
  SUBSTR('Ana Perez', 1, 1) AS first_initial,
  CASE
    WHEN INSTR('Ana Perez', ' ') > 0
    THEN SUBSTR('Ana Perez', INSTR('Ana Perez', ' ') + 1, 1)
    ELSE ''
  END AS last_initial;



SELECT CustomerID,
       ContactName,
       PostalCode,
       UPPER(
         CONCAT(
           SUBSTR(TRIM(ContactName), 1, 1),
           CASE
             WHEN INSTR(TRIM(ContactName), ' ') > 0
               THEN SUBSTR(TRIM(ContactName), INSTR(TRIM(ContactName), ' ') + 1, 1)
             ELSE ''
           END
         )
       ) AS initials,
       SUBSTR(COALESCE(PostalCode, ''), 1, 3) AS postal_prefix,
       REPLACE(REPLACE(REPLACE(COALESCE(PostalCode, ''), '-', ''), ' ', ''), '.', '') AS postal_compact
FROM Customers
ORDER BY CustomerID
LIMIT 25;

-- Ejercicio 2:
-- En Suppliers crea phone_compact limpiando simbolos de Phone,
-- extrae country_prefix (2 primeros chars de Country)
-- y detecta telefonos sospechosos por longitud corta.

select phone from Suppliers;

-- Ejercicio 2B:
-- En Employees, crea extension_prefix y extension_len,
-- y lista solo extensiones con menos de 4 digitos.


-- 1:05-1:15 NULL bien

SELECT SupplierID,
       CompanyName,
       Fax,
       HomePage,
       COALESCE(NULLIF(TRIM(Fax), ''), '(sin_fax)') AS fax_fill,
       COALESCE(NULLIF(TRIM(HomePage), ''), '(sin_web)') AS homepage_fill
FROM Suppliers
ORDER BY SupplierID
LIMIT 20;

SELECT COUNT(*) AS total_suppliers,
       SUM(CASE WHEN NULLIF(TRIM(Fax), '') IS NULL THEN 1 ELSE 0 END) AS fax_null,
       SUM(CASE WHEN NULLIF(TRIM(HomePage), '') IS NULL THEN 1 ELSE 0 END) AS homepage_null
FROM Suppliers;

-- Ejercicio 3:
-- En Customers, rellena Region y PostalCode con COALESCE/NULLIF
-- y calcula cuantos nulos quedan en cada campo.


-- 1:15-1:30 Descanso


-- 1:30-2:05 Fechas: comparar y derivar campos

SELECT OrderID,
       OrderDate,
       RequiredDate,
       ShippedDate,
       strftime('%Y-%m', OrderDate) AS year_month,
       CAST(strftime('%m', OrderDate) AS INTEGER) AS order_month,
       CAST(julianday(ShippedDate) - julianday(OrderDate) AS INTEGER) AS days_to_ship,
       CASE
         WHEN ShippedDate IS NULL THEN 'pendiente'
         WHEN date(ShippedDate) > date(RequiredDate) THEN 'tarde'
         ELSE 'a_tiempo'
       END AS delivery_status
FROM Orders
WHERE OrderDate >= '2022-01-01'
ORDER BY OrderDate DESC
LIMIT 40;

-- Ejercicio 4:
-- En Orders (solo 2023) crea delivery_status y days_late
-- (dias de retraso sobre RequiredDate, 0 si no llega tarde).
-- Filtra solo pedidos tarde y ordena por days_late DESC.

-- Ejercicio 4B:
-- En Employees, deriva hire_year, hire_month y age_at_hire
-- usando HireDate y BirthDate.


-- 2:05-2:35 CAST + CASE avanzado

SELECT ProductID,
       ProductName,
       CAST(UnitPrice AS REAL) AS unit_price,
       CAST(UnitsInStock AS INTEGER) AS units_in_stock,
       CAST(UnitPrice AS REAL) * CAST(UnitsInStock AS REAL) AS inventory_value,
       CASE
         WHEN CAST(UnitPrice AS REAL) < 15 THEN 'economico'
         WHEN CAST(UnitPrice AS REAL) <= 40 THEN 'medio'
         ELSE 'premium'
       END AS price_bucket,
       CASE
         WHEN CAST(UnitsInStock AS INTEGER) = 0 THEN 'rotura'
         WHEN CAST(UnitsInStock AS INTEGER) <= CAST(ReorderLevel AS INTEGER) THEN 'reponer'
         ELSE 'ok'
       END AS stock_flag
FROM Products
ORDER BY inventory_value DESC
LIMIT 30;

-- Ejercicio 5:
-- En Orders crea un output con:
-- freight_bucket, year_month, postal_quality_flag y priority_flag.
-- Reglas: bucket de Freight (bajo/medio/alto),
-- calidad postal (missing/short/ok), prioridad (alta/media/baja).

-- Ejercicio 5B:
-- En [Order Details], crea discount_pct con CAST,
-- y un discount_bucket (sin_descuento/bajo/medio/alto).


-- 2:35-2:55 JOIN + GROUP BY basicos

SELECT ShipCountry,
       COUNT(*) AS total_orders
FROM Orders
WHERE OrderDate >= '2023-01-01'
  AND OrderDate < '2024-01-01'
GROUP BY ShipCountry
ORDER BY total_orders DESC
LIMIT 10;

-- Ejercicio A:
-- Top 5 CustomerID con mas pedidos en 2023 (solo Orders).

SELECT o.OrderID,
       o.OrderDate,
       c.CompanyName,
       o.ShipCountry,
       o.Freight
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE o.OrderDate >= '2023-01-01'
ORDER BY o.OrderDate DESC
LIMIT 20;

-- Ejercicio B:
-- Pedidos de 2023 con CompanyName y Freight > 100.

SELECT o.OrderID,
       o.OrderDate,
       c.CompanyName,
       s.CompanyName AS shipper_name,
       o.Freight
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
LEFT JOIN Shippers s ON o.ShipVia = s.ShipperID
WHERE o.OrderDate >= '2023-01-01'
ORDER BY o.OrderDate DESC
LIMIT 20;

-- Ejercicio C:
-- Une Orders + [Order Details] + Products y saca
-- top 10 productos por cantidad total vendida en 2023.
