-- Agregacion II - KPI Lab en SQL (Northwind)
-- Enunciados y soluciones

-- =============================================================
-- Ejercicio 0
-- Enunciado:
-- En Orders + [Order Details], calcula para 2022:
-- - lineas totales de detalle
-- - lineas con descuento (Discount > 0)
-- - porcentaje de lineas con descuento
-- Solucion:
SELECT COUNT(*) AS total_detail_lines,
       SUM(CASE WHEN od.Discount > 0 THEN 1 ELSE 0 END) AS discounted_lines,
       ROUND(100.0 * SUM(CASE WHEN od.Discount > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS discounted_lines_pct
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE strftime('%Y',o.OrderDate)='2022';


-- =============================================================
-- Ejercicio 1
-- Enunciado:
-- Top 10 ciudades de envio (ShipCity) por tickets en 2022.
-- Incluye freight_total y freight_avg.
-- Solucion:
SELECT ShipCity,
       COUNT(*) AS tickets,
       ROUND(SUM(Freight), 2) AS freight_total,
       ROUND(AVG(Freight), 2) AS freight_avg
FROM Orders
WHERE strftime('%Y',OrderDate)='2022'
GROUP BY ShipCity
ORDER BY tickets DESC, freight_total DESC
LIMIT 10;


-- =============================================================
-- Ejercicio 1B
-- Enunciado:
-- En lugar de region, calcula estos KPI por EmployeeID en 2022.
-- Solucion:
SELECT EmployeeID,
       COUNT(*) AS tickets,
       ROUND(SUM(Freight), 2) AS freight_total,
       ROUND(AVG(Freight), 2) AS freight_avg
FROM Orders
WHERE strftime('%Y',OrderDate)='2022'
GROUP BY EmployeeID
ORDER BY tickets DESC, freight_total DESC;


-- =============================================================
-- Ejercicio 2
-- Enunciado:
-- Revenue por mes en 2022 usando Orders + [Order Details].
-- Revenue = SUM(UnitPrice * Quantity * (1 - Discount)).
-- Solucion:
SELECT strftime('%Y-%m',o.OrderDate) AS year_month,
       ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS revenue
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE strftime('%Y',o.OrderDate)='2022'
GROUP BY year_month
ORDER BY year_month;


-- =============================================================
-- Ejercicio 2B
-- Enunciado:
-- Top 3 semanas de 2022 por revenue.
-- Usa strftime('%Y-W%W', OrderDate).
-- Solucion:
SELECT strftime('%Y-W%W',o.OrderDate) AS year_week,
       ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS revenue
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE strftime('%Y',o.OrderDate)='2022'
GROUP BY year_week
ORDER BY revenue DESC
LIMIT 3;


-- =============================================================
-- Ejercicio 2C
-- Enunciado:
-- Top 5 semanas de 2022 por tickets,
-- pero solo semanas con freight_total >= 2000.
-- Solucion:
SELECT strftime('%Y-W%W',OrderDate) AS year_week,
       COUNT(*) AS tickets,
       ROUND(SUM(Freight), 2) AS freight_total
FROM Orders
WHERE strftime('%Y',OrderDate)='2022'
GROUP BY year_week
HAVING SUM(Freight) >= 2000
ORDER BY tickets DESC, freight_total DESC
LIMIT 5;


-- =============================================================
-- Ejercicio 3
-- Enunciado:
-- Calcula % late por ShipCountry en 2022.
-- Devuelve: ShipCountry, late_orders, shipped_orders, late_pct.
-- Solucion:
SELECT ShipCountry,
       SUM(CASE WHEN ShippedDate IS NOT NULL
                  AND RequiredDate IS NOT NULL
                  AND date(ShippedDate) > date(RequiredDate)
                THEN 1 ELSE 0 END) AS late_orders,
       SUM(CASE WHEN ShippedDate IS NOT NULL
                  AND RequiredDate IS NOT NULL
                THEN 1 ELSE 0 END) AS shipped_orders,
       ROUND(100.0 * SUM(CASE WHEN ShippedDate IS NOT NULL
                                AND RequiredDate IS NOT NULL
                                AND date(ShippedDate) > date(RequiredDate)
                              THEN 1 ELSE 0 END)
             / NULLIF(SUM(CASE WHEN ShippedDate IS NOT NULL
                                 AND RequiredDate IS NOT NULL
                               THEN 1 ELSE 0 END), 0), 2) AS late_pct
FROM Orders
WHERE strftime('%Y',OrderDate)='2022'
GROUP BY ShipCountry
HAVING shipped_orders > 0
ORDER BY late_pct DESC, shipped_orders DESC;


-- =============================================================
-- Ejercicio 3B
-- Enunciado:
-- Calcula pending_orders por ShipCountry (todo el historico)
-- y muestra solo paises con al menos 2 pendientes.
-- Solucion:
SELECT ShipCountry,
       COUNT(*) AS pending_orders
FROM Orders
WHERE ShippedDate IS NULL
GROUP BY ShipCountry
HAVING COUNT(*) >= 2
ORDER BY pending_orders DESC, ShipCountry;


-- =============================================================
-- Ejercicio 4
-- Enunciado:
-- Top 10 shippers por numero de pedidos en 2022.
-- Usa Orders + Shippers.
-- Solucion:
SELECT s.ShipperID,
       s.CompanyName AS shipper_name,
       COUNT(*) AS tickets
FROM Orders o
JOIN Shippers s ON o.ShipVia = s.ShipperID
WHERE strftime('%Y',o.OrderDate)='2022'
GROUP BY s.ShipperID, s.CompanyName
ORDER BY tickets DESC, shipper_name
LIMIT 10;


-- =============================================================
-- Ejercicio 4B
-- Enunciado:
-- Top 10 clientes por freight_total en 2022.
-- Usa Orders + Customers.
-- Solucion:
SELECT c.CustomerID,
       c.CompanyName,
       COUNT(*) AS tickets,
       ROUND(SUM(o.Freight), 2) AS freight_total
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE strftime('%Y',o.OrderDate)='2022'
GROUP BY c.CustomerID, c.CompanyName
ORDER BY freight_total DESC, tickets DESC
LIMIT 10;


-- =============================================================
-- Ejercicio 5
-- Enunciado:
-- Top 10 productos por revenue en 2022.
-- Revenue = SUM(UnitPrice * Quantity * (1 - Discount)).
-- Solucion:
SELECT p.ProductID,
       p.ProductName,
       ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS revenue
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE strftime('%Y',o.OrderDate)='2022'
GROUP BY p.ProductID, p.ProductName
ORDER BY revenue DESC
LIMIT 10;


-- =============================================================
-- Ejercicio 5B
-- Enunciado:
-- Top 5 suppliers por revenue en 2022.
-- Usa Orders + [Order Details] + Products + Suppliers.
-- Solucion:
SELECT s.SupplierID,
       s.CompanyName AS supplier_name,
       SUM(od.Quantity) AS units_sold,
       ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS revenue
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Suppliers s ON p.SupplierID = s.SupplierID
WHERE strftime('%Y',o.OrderDate)='2022'
GROUP BY s.SupplierID, s.CompanyName
ORDER BY revenue DESC
LIMIT 5;


-- =============================================================
-- Ejercicio 6
-- Enunciado:
-- Toma las 4 queries del mini-dashboard y:
-- - renombra columnas a un estandar BI (kpi_name, dimension_1, metric_1...)
-- - deja orden estable del output
-- - añade filtro para ShipCountry IN ('USA','Germany','France') donde aplique

-- Solucion 6.1: country_kpis estandarizado
SELECT 'country_kpis' AS kpi_name,
       o.ShipCountry AS dimension_1,
       '2022' AS dimension_2,
       COUNT(*) AS metric_1_tickets,
       ROUND(SUM(o.Freight), 2) AS metric_2_freight_total,
       ROUND(100.0 * SUM(CASE WHEN o.ShippedDate IS NOT NULL AND date(o.ShippedDate) > date(o.RequiredDate) THEN 1 ELSE 0 END)
             / NULLIF(SUM(CASE WHEN o.ShippedDate IS NOT NULL THEN 1 ELSE 0 END), 0), 2) AS metric_3_late_pct
FROM Orders o
WHERE strftime('%Y',o.OrderDate)='2022'
  AND o.ShipCountry IN ('USA','Germany','France')
GROUP BY o.ShipCountry
ORDER BY dimension_1;

-- Solucion 6.2: monthly_kpis estandarizado (evita doble conteo de freight)
WITH order_value AS (
  SELECT o.OrderID,
         strftime('%Y-%m',o.OrderDate) AS year_month,
         o.ShipCountry,
         SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS revenue,
         MAX(o.Freight) AS freight_per_order
  FROM Orders o
  JOIN [Order Details] od ON o.OrderID = od.OrderID
  WHERE strftime('%Y',o.OrderDate)='2022'
    AND o.ShipCountry IN ('USA','Germany','France')
  GROUP BY o.OrderID, year_month, o.ShipCountry
)
SELECT 'monthly_kpis' AS kpi_name,
       year_month AS dimension_1,
       'USA|Germany|France' AS dimension_2,
       COUNT(*) AS metric_1_tickets,
       ROUND(SUM(revenue), 2) AS metric_2_revenue,
       ROUND(SUM(freight_per_order), 2) AS metric_3_freight_total
FROM order_value
GROUP BY year_month
ORDER BY dimension_1;

-- Solucion 6.3: customer_top estandarizado
SELECT 'customer_top' AS kpi_name,
       c.CustomerID AS dimension_1,
       c.CompanyName AS dimension_2,
       COUNT(*) AS metric_1_tickets,
       ROUND(SUM(o.Freight), 2) AS metric_2_freight_total,
       ROUND(AVG(o.Freight), 2) AS metric_3_freight_avg
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE strftime('%Y',o.OrderDate)='2022'
  AND o.ShipCountry IN ('USA','Germany','France')
GROUP BY c.CustomerID, c.CompanyName
ORDER BY metric_1_tickets DESC, dimension_1
LIMIT 20;

-- Solucion 6.4: product_top estandarizado
SELECT 'product_top' AS kpi_name,
       p.ProductID AS dimension_1,
       p.ProductName AS dimension_2,
       SUM(od.Quantity) AS metric_1_units_sold,
       ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS metric_2_revenue,
       COUNT(DISTINCT o.OrderID) AS metric_3_distinct_orders
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE strftime('%Y',o.OrderDate)='2022'
  AND o.ShipCountry IN ('USA','Germany','France')
GROUP BY p.ProductID, p.ProductName
ORDER BY metric_2_revenue DESC, dimension_1
LIMIT 20;
