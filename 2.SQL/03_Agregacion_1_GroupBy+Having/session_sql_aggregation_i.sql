-- SQL Agregacion I
-- Sakila (SQLite)

-- Agenda (3h + 15' descanso)
-- 0:00-0:10 Setup + warm-up
-- 0:10-0:35 GROUP BY basico
-- 0:35-0:55 Top-N
-- 0:55-1:15 HAVING
-- 1:15-1:30 Descanso
-- 1:30-1:55 Segmentacion con CASE + GROUP BY
-- 1:55-2:20 Metrica canonica + joins minimos
-- 2:20-2:50 Debugging de agregaciones
-- 2:50-3:00 Cierre


-- 0:00-0:10 Setup + warm-up

SELECT COUNT(*) AS total_payments,
       COUNT(customer_id) AS payments_with_customer_id,
       COUNT(rental_id) AS payments_with_rental_id
FROM payment;

-- Ejercicio 0:
-- Cuenta pagos totales y pagos con customer_id en payment.


-- 0:10-0:35 GROUP BY basico (COUNT/SUM/AVG)

SELECT customer_id,
       COUNT(*) AS n_payments,
       ROUND(SUM(amount), 2) AS revenue,
       ROUND(AVG(amount), 2) AS avg_ticket
FROM payment
GROUP BY customer_id
ORDER BY revenue DESC
LIMIT 15;

-- Ejercicio 1:
-- Calcula n_payments, revenue y avg_ticket por staff_id.
-- Si terminais rapido, repetidlo por store_id (usando payment + customer).


-- 0:35-0:55 Top-N (ORDER BY + LIMIT)

SELECT p.customer_id,
       c.first_name,
       c.last_name,
       COUNT(*) AS n_payments,
       ROUND(SUM(p.amount), 2) AS revenue
FROM payment p
JOIN customer c ON p.customer_id = c.customer_id
GROUP BY p.customer_id, c.first_name, c.last_name
ORDER BY revenue DESC
LIMIT 10;

-- Ejercicio 2:
-- Top 10 dias por revenue usando date(payment_date).
-- Incluye revenue y n_payments.


-- 0:55-1:15 HAVING (filtrar grupos)

SELECT customer_id,
       COUNT(*) AS n_payments,
       ROUND(SUM(amount), 2) AS revenue
FROM payment
GROUP BY customer_id
HAVING SUM(amount) >= 180 OR COUNT(*) >= 40
ORDER BY revenue DESC;

-- Ejercicio 3:
-- Muestra peliculas con >= 30 alquileres.
-- Usa rental + inventory + film.


-- 1:15-1:30 Descanso


-- 1:30-1:55 Segmentacion con CASE + GROUP BY

SELECT CASE
         WHEN amount < 3 THEN 'low'
         WHEN amount <= 6 THEN 'med'
         ELSE 'high'
       END AS amount_bucket,
       COUNT(*) AS n_payments,
       ROUND(SUM(amount), 2) AS revenue,
       ROUND(AVG(amount), 2) AS avg_amount
FROM payment
GROUP BY amount_bucket
ORDER BY revenue DESC;

-- Ejercicio 4:
-- Crea bucket por hora con strftime('%H', payment_date):
-- morning / afternoon / evening.
-- Devuelve n_payments y revenue por bucket.


-- 1:55-2:20 Metrica canonica + joins minimos

SELECT c.name AS category_name,
       COUNT(*) AS n_payments,
       ROUND(SUM(p.amount), 2) AS revenue,
       ROUND(AVG(p.amount), 2) AS avg_ticket
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.category_id, c.name
ORDER BY revenue DESC;

-- Ejercicio 5:
-- Top 5 categorias por revenue en 2005.
-- Añade HAVING para dejar solo categorias con >= 900 pagos.


-- 2:20-2:50 Debugging de agregaciones

SELECT COUNT(*) AS base_rows,
       COUNT(DISTINCT rental_id) AS base_distinct_rentals,
       ROUND(SUM(amount), 2) AS base_revenue
FROM payment;

SELECT COUNT(*) AS joined_rows,
       COUNT(DISTINCT p.rental_id) AS joined_distinct_rentals,
       ROUND(SUM(p.amount), 2) AS joined_revenue
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_actor fa ON i.film_id = fa.film_id;

-- Ejercicio 6:
-- Compara COUNT(*) vs COUNT(DISTINCT rental_id)
-- entre la query base y la query con join a film_actor.
-- Explica por que aparece duplicacion.

-- Ejercicio 6B (si sobra tiempo):
-- Corrige la metrica para que el revenue coincida con payment
-- aun usando joins, sin eliminar la tabla film_actor del FROM.


-- 2:50-3:00 Cierre
-- Receta: FROM -> JOIN -> WHERE -> GROUP BY -> HAVING -> ORDER BY -> LIMIT
