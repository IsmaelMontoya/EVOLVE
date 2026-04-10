-- SQL Agregacion I - Enunciados y soluciones
-- Sakila (SQLite)

-- =============================================================
-- Ejercicio 0
-- Enunciado:
-- Cuenta pagos totales y pagos con customer_id en payment.
-- Solucion:
SELECT COUNT(*) AS total_payments,
       COUNT(customer_id) AS payments_with_customer_id
FROM payment;


-- =============================================================
-- Ejercicio 1
-- Enunciado:
-- Calcula n_payments, revenue y avg_ticket por staff_id.
-- Solucion:
SELECT staff_id,
       COUNT(*) AS n_payments,
       ROUND(SUM(amount), 2) AS revenue,
       ROUND(AVG(amount), 2) AS avg_ticket
FROM payment
GROUP BY staff_id
ORDER BY revenue DESC;

-- Ejercicio 1B (opcional)
-- Enunciado:
-- Repite por store_id (usando payment + customer).
-- Solucion:
SELECT c.store_id,
       COUNT(*) AS n_payments,
       ROUND(SUM(p.amount), 2) AS revenue,
       ROUND(AVG(p.amount), 2) AS avg_ticket
FROM payment p
JOIN customer c ON p.customer_id = c.customer_id
GROUP BY c.store_id
ORDER BY revenue DESC;


-- =============================================================
-- Ejercicio 2
-- Enunciado:
-- Top 10 dias por revenue usando date(payment_date).
-- Incluye revenue y n_payments.
-- Solucion:
SELECT date(payment_date) AS payment_day,
       COUNT(*) AS n_payments,
       ROUND(SUM(amount), 2) AS revenue
FROM payment
GROUP BY date(payment_date)
ORDER BY revenue DESC
LIMIT 10;


-- =============================================================
-- Ejercicio 3
-- Enunciado:
-- Muestra peliculas con >= 30 alquileres.
-- Usa rental + inventory + film.
-- Solucion:
SELECT f.film_id,
       f.title,
       COUNT(*) AS n_rentals
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY f.film_id, f.title
HAVING COUNT(*) >= 30
ORDER BY n_rentals DESC, f.film_id;


-- =============================================================
-- Ejercicio 4
-- Enunciado:
-- Crea bucket por hora con strftime('%H', payment_date):
-- morning / afternoon / evening.
-- Devuelve n_payments y revenue por bucket.
-- Solucion:
SELECT CASE
         WHEN CAST(strftime('%H', payment_date) AS INTEGER) BETWEEN 6 AND 11 THEN 'morning'
         WHEN CAST(strftime('%H', payment_date) AS INTEGER) BETWEEN 12 AND 17 THEN 'afternoon'
         ELSE 'evening'
       END AS hour_bucket,
       COUNT(*) AS n_payments,
       ROUND(SUM(amount), 2) AS revenue
FROM payment
GROUP BY hour_bucket
ORDER BY revenue DESC;


-- =============================================================
-- Ejercicio 5
-- Enunciado:
-- Top 5 categorias por revenue en 2005.
-- Añade HAVING para dejar solo categorias con >= 900 pagos.
-- Solucion:
SELECT c.name AS category_name,
       COUNT(*) AS n_payments,
       ROUND(SUM(p.amount), 2) AS revenue
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE strftime('%Y', p.payment_date) = '2005'
GROUP BY c.category_id, c.name
HAVING COUNT(*) >= 900
ORDER BY revenue DESC
LIMIT 5;


-- =============================================================
-- Ejercicio 6
-- Enunciado:
-- Compara COUNT(*) vs COUNT(DISTINCT rental_id)
-- entre la query base y la query con join a film_actor.
-- Explica por que aparece duplicacion.
-- Solucion (base):
SELECT COUNT(*) AS base_rows,
       COUNT(DISTINCT rental_id) AS base_distinct_rentals,
       ROUND(SUM(amount), 2) AS base_revenue
FROM payment;

-- Solucion (con join que duplica):
SELECT COUNT(*) AS joined_rows,
       COUNT(DISTINCT p.rental_id) AS joined_distinct_rentals,
       ROUND(SUM(p.amount), 2) AS joined_revenue
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_actor fa ON i.film_id = fa.film_id;

-- Explicacion breve:
-- El join a film_actor genera varias filas por rental (una por actor de la pelicula).
-- COUNT(*) y SUM(amount) crecen artificialmente. COUNT(DISTINCT rental_id) no.


-- =============================================================
-- Ejercicio 6B (opcional)
-- Enunciado:
-- Corrige la metrica para que el revenue coincida con payment
-- aun usando joins, sin eliminar la tabla film_actor del FROM.
-- Solucion:
SELECT ROUND(SUM(p.amount), 2) AS corrected_revenue
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN (
  SELECT DISTINCT film_id
  FROM film_actor
) fa ON i.film_id = fa.film_id;

-- Comprobacion opcional:
-- SELECT ROUND(SUM(amount), 2) AS base_revenue FROM payment;
