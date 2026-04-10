-- Agregacion II - KPI Lab en SQL (Northwind)
-- Tickets, revenue, % share y metricas por pais/cliente y por periodo (mes/semana)

-- Agenda
-- 0:00-0:10 Que es un KPI en SQL + sanity checks
-- 0:10-0:30 KPI Set 1 (solo Orders)
-- 0:30-0:55 KPI Set 2 (periodo)
-- 0:55-1:15 KPI Set 3 (flags con CASE)
-- 1:15-1:30 Descanso
-- 1:30-2:00 KPI Set 4 (1 join)
-- 2:00-2:35 KPI Set 5 (2-3 joins)
-- 2:35-2:55 Mini-dashboard final
-- 2:55-3:00 Cierre


-- 0:00-0:10 | KPI en SQL + sanity checks

-- Sanity check 1:
-- Esta query devuelve el volumen base del año 2022.
-- Sirve para validar numerador/denominador antes de bajar a segmentos.
SELECT COUNT(*) AS total_orders_2022,
       COUNT(CustomerID) AS orders_with_customer_2022,
       COUNT(ShippedDate) AS shipped_orders_2022,
       ROUND(SUM(Freight), 2) AS total_freight_2022
FROM Orders
WHERE strftime('%Y',OrderDate)='2022';

-- Sanity check 2:
-- Comprobamos consistencia de agregacion:
-- total de pedidos 2022 debe coincidir con la suma de tickets por pais.
WITH by_country AS (
  SELECT ShipCountry,
         COUNT(*) AS tickets
  FROM Orders
  WHERE strftime('%Y',OrderDate)='2022'
  GROUP BY ShipCountry
)
SELECT (SELECT COUNT(*) FROM Orders WHERE strftime('%Y',OrderDate)='2022') AS total_tickets_2022,
       (SELECT SUM(tickets) FROM by_country) AS sum_country_tickets_2022;

-- Ejercicio 0:
-- En Orders + [Order Details], calcula para 2022:
-- - lineas totales de detalle
-- - lineas con descuento (Discount > 0)
-- - porcentaje de lineas con descuento


-- 0:10-0:30 | KPI Set 1 (solo Orders)

-- KPI: tickets por pais (grano = pais).
SELECT ShipCountry,
       COUNT(*) AS tickets
FROM Orders
WHERE strftime('%Y',OrderDate)='2022'
GROUP BY ShipCountry
ORDER BY tickets DESC
LIMIT 12;

-- Ejercicio 1:
-- Top 10 ciudades de envio (ShipCity) por tickets en 2022.
-- Incluye freight_total y freight_avg.
SELECT ShipCountry,
       COUNT(*) AS tickets,
       SUM(Freight) AS freight_total,
       ROUND(AVG(Freight),2) AS freight_avg
FROM Orders
WHERE strftime('%Y',OrderDate)='2022'
GROUP BY ShipCountry
ORDER BY tickets DESC
LIMIT 12;

-- Mismo patron con otra dimension (ShipRegion) y otra metrica (avg freight).
SELECT ShipRegion,
       COUNT(*) AS tickets,
       ROUND(AVG(Freight), 2) AS avg_freight
FROM Orders
WHERE strftime('%Y',OrderDate)='2022'

  AND ShipRegion IS NOT NULL
GROUP BY ShipRegion
ORDER BY avg_freight DESC;

-- Ejercicio 1B:
-- En lugar de region, calcula estos KPI por EmployeeID en 2022.


-- 0:30-0:55 | KPI Set 2 (periodo)

-- KPI temporal mensual (grano = mes):
-- util para ver tendencia y estacionalidad.
SELECT strftime('%Y-%m',OrderDate) AS year_month,
       COUNT(*) AS tickets,
       ROUND(SUM(Freight), 2) AS freight_total
FROM Orders
WHERE strftime('%Y',OrderDate)='2022'
GROUP BY year_month
ORDER BY year_month;

-- Ejercicio 2:
-- Revenue por mes en 2022 usando Orders + [Order Details].
-- Revenue = SUM(UnitPrice * Quantity * (1 - Discount)).

-- Variante: identificar el mes pico por volumen.
SELECT strftime('%Y-%m',OrderDate) AS year_month,
       COUNT(*) AS tickets
FROM Orders
WHERE strftime('%Y',OrderDate)='2022'
GROUP BY year_month
ORDER BY tickets DESC
LIMIT 1;

-- Ejercicio 2B:
-- Top 3 semanas de 2022 por revenue.
-- Usa strftime('%Y-W%W', OrderDate).

-- Version semanal (grano = semana), para comparar con el analisis mensual.
SELECT strftime('%Y-W%W',OrderDate) AS year_week,
       COUNT(*) AS tickets,
       ROUND(SUM(Freight), 2) AS freight_total
FROM Orders
WHERE strftime('%Y',OrderDate)='2022'
GROUP BY year_week
ORDER BY tickets DESC
LIMIT 10;

-- Ejercicio 2C:
-- Top 5 semanas de 2022 por tickets,
-- pero solo semanas con freight_total >= 2000.


-- 0:55-1:15 | KPI Set 3 (flags con CASE)

-- KPI de puntualidad:
-- 1) Subquery crea un flag por pedido (late / on_time)
-- 2) Query externa agrega por flag y calcula % share.
SELECT delivery_status,
       COUNT(*) AS shipped_orders,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*)
                                 FROM Orders
                                 WHERE strftime('%Y',OrderDate)='2022'
                                   AND ShippedDate IS NOT NULL
                                   AND RequiredDate IS NOT NULL), 2) AS pct_share
FROM (
  SELECT CASE
           WHEN date(ShippedDate) > date(RequiredDate) THEN 'late'
           ELSE 'on_time'
         END AS delivery_status
  FROM Orders
  WHERE strftime('%Y',OrderDate)='2022'
    AND ShippedDate IS NOT NULL
    AND RequiredDate IS NOT NULL
) t
GROUP BY delivery_status
ORDER BY shipped_orders DESC;

-- Ejercicio 3:
-- Calcula % late por ShipCountry en 2022.
-- Devuelve: ShipCountry, late_orders, shipped_orders, late_pct.

-- KPI de backlog:
-- pedidos no enviados (ShippedDate IS NULL) por transportista.
SELECT s.CompanyName AS shipper_name,
       COUNT(*) AS pending_orders
FROM Orders o
JOIN Shippers s ON o.ShipVia = s.ShipperID
WHERE o.ShippedDate IS NULL
GROUP BY s.ShipperID, s.CompanyName
ORDER BY pending_orders DESC;

-- Ejercicio 3B:
-- Calcula pending_orders por ShipCountry (todo el historico)
-- y muestra solo paises con al menos 2 pendientes.


-- 1:15-1:30 | Descanso


-- 1:30-2:00 | KPI Set 4 (1 join)

-- KPI comercial por cliente:
-- Orders aporta fact table y Customers aporta etiqueta de negocio.
SELECT c.CustomerID,
       c.CompanyName,
       COUNT(*) AS tickets
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE strftime('%Y',o.OrderDate)='2022'
GROUP BY c.CustomerID, c.CompanyName
ORDER BY tickets DESC
LIMIT 15;

-- Ejercicio 4:
-- Top 10 shippers por numero de pedidos en 2022.
-- Usa Orders + Shippers.

-- KPI logistico por shipper con doble metrica (tickets + freight_total).
SELECT s.ShipperID,
       s.CompanyName AS shipper_name,
       COUNT(*) AS tickets,
       ROUND(SUM(o.Freight), 2) AS freight_total
FROM Orders o
JOIN Shippers s ON o.ShipVia = s.ShipperID
WHERE strftime('%Y',o.OrderDate)='2022'
GROUP BY s.ShipperID, s.CompanyName
ORDER BY tickets DESC;

-- Ejercicio 4B:
-- Top 10 clientes por freight_total en 2022.
-- Usa Orders + Customers.


-- 2:00-2:35 | KPI Set 5 (2-3 joins)

-- KPI de producto (volumen):
-- Orders + Order Details + Products para obtener unidades vendidas por SKU.
SELECT p.ProductID,
       p.ProductName,
       SUM(od.Quantity) AS units_sold
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE strftime('%Y',o.OrderDate)='2022'
GROUP BY p.ProductID, p.ProductName
ORDER BY units_sold DESC
LIMIT 15;

-- Ejercicio 5:
-- Top 10 productos por revenue en 2022.
-- Revenue = SUM(UnitPrice * Quantity * (1 - Discount)).

-- KPI de categoria (valor):
-- anadimos Categories para subir el nivel de agregacion.
SELECT c.CategoryName,
       ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS revenue
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE strftime('%Y',o.OrderDate)='2022'
GROUP BY c.CategoryID, c.CategoryName
ORDER BY revenue DESC;

-- Ejercicio 5B:
-- Top 5 suppliers por revenue en 2022.
-- Usa Orders + [Order Details] + Products + Suppliers.


-- 2:35-2:55 | Mini-dashboard final (queries listas para BI)

-- country_kpis
-- Tabla final de pais con volumen, coste logistico y puntualidad.
SELECT o.ShipCountry AS ship_country,
       COUNT(*) AS tickets,
       ROUND(SUM(o.Freight), 2) AS freight_total,
       ROUND(AVG(o.Freight), 2) AS freight_avg,
       ROUND(100.0 * SUM(CASE WHEN o.ShippedDate IS NOT NULL AND date(o.ShippedDate) > date(o.RequiredDate) THEN 1 ELSE 0 END)
             / NULLIF(SUM(CASE WHEN o.ShippedDate IS NOT NULL THEN 1 ELSE 0 END), 0), 2) AS late_pct
FROM Orders o
WHERE strftime('%Y',o.OrderDate)='2022'
GROUP BY o.ShipCountry
ORDER BY tickets DESC;

-- monthly_kpis
-- CTE order_value evita doble conteo de freight:
-- primero calcula revenue y freight a nivel OrderID (1 fila por pedido),
-- luego agrega por mes.
WITH order_value AS (
  SELECT o.OrderID,
         strftime('%Y-%m',o.OrderDate) AS year_month,
         SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS revenue,
         MAX(o.Freight) AS freight_per_order
  FROM Orders o
  JOIN [Order Details] od ON o.OrderID = od.OrderID
  WHERE strftime('%Y',o.OrderDate)='2022'
  GROUP BY o.OrderID, year_month
)
SELECT year_month,
       COUNT(*) AS tickets,
       ROUND(SUM(revenue), 2) AS revenue,
       ROUND(SUM(freight_per_order), 2) AS freight_total
FROM order_value
GROUP BY year_month
ORDER BY year_month;

-- customer_top
-- Ranking de clientes por tickets y coste logistico.
SELECT c.CustomerID AS customer_id,
       c.CompanyName AS customer_name,
       COUNT(*) AS tickets,
       ROUND(SUM(o.Freight), 2) AS freight_total
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE strftime('%Y',o.OrderDate)='2022'
GROUP BY c.CustomerID, c.CompanyName
ORDER BY tickets DESC
LIMIT 20;

-- product_top
-- Ranking de productos por revenue y unidades.
SELECT p.ProductID AS product_id,
       p.ProductName AS product_name,
       SUM(od.Quantity) AS units_sold,
       ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS revenue
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE strftime('%Y',o.OrderDate)='2022'
GROUP BY p.ProductID, p.ProductName
ORDER BY revenue DESC
LIMIT 20;

-- Ejercicio 6:
-- Toma las 4 queries del mini-dashboard y:
-- - renombra columnas a un estandar BI (kpi_name, dimension_1, metric_1...)
-- - deja orden estable del output
-- - añade filtro para ShipCountry IN ('USA','Germany','France') donde aplique


-- 2:55-3:00 | Cierre
-- Plantilla KPI: FROM base -> filtros -> joins minimos -> GROUP BY -> HAVING -> ORDER BY -> LIMIT
