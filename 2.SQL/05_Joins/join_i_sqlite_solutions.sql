/* ============================================================
   SQL Clase 8 - JOINs I (SQLite)
   Soluciones
   ============================================================ */

-- ============================================================
-- Ejercicio 0
-- Cuenta filas por tabla (Series, Episodios, Actores, Actuaciones)
-- en una sola consulta con UNION ALL.
SELECT 'Series' AS tabla, COUNT(*) AS n_filas FROM Series
UNION ALL
SELECT 'Episodios' AS tabla, COUNT(*) AS n_filas FROM Episodios
UNION ALL
SELECT 'Actores' AS tabla, COUNT(*) AS n_filas FROM Actores
UNION ALL
SELECT 'Actuaciones' AS tabla, COUNT(*) AS n_filas FROM Actuaciones;


-- ============================================================
-- Ejercicio 1
-- Lista solo actuaciones de series de genero 'Drama'.
-- Devuelve: serie, actor, personaje.
SELECT
    s.titulo AS serie,
    a.nombre AS actor,
    ac.personaje
FROM Series s
JOIN Actuaciones ac ON s.serie_id = ac.serie_id
JOIN Actores a ON a.actor_id = ac.actor_id
WHERE s.genero = 'Drama'
ORDER BY s.titulo, a.nombre;

-- Ejercicio 1B
-- Top 10 series por numero de actuaciones (no episodios).
SELECT
    s.serie_id,
    s.titulo AS serie,
    COUNT(*) AS n_actuaciones
FROM Series s
JOIN Actuaciones ac ON s.serie_id = ac.serie_id
GROUP BY s.serie_id, s.titulo
ORDER BY n_actuaciones DESC, s.titulo
LIMIT 10;


-- ============================================================
-- Ejercicio 2
-- Series sin episodios (episodio_id IS NULL).
SELECT
    s.serie_id,
    s.titulo AS serie
FROM Series s
LEFT JOIN Episodios e ON s.serie_id = e.serie_id
WHERE e.episodio_id IS NULL
ORDER BY s.titulo;

-- Ejercicio 2B
-- Actores sin actuaciones.
SELECT
    a.actor_id,
    a.nombre AS actor
FROM Actores a
LEFT JOIN Actuaciones ac ON a.actor_id = ac.actor_id
WHERE ac.actor_id IS NULL
ORDER BY a.nombre;

-- Ejercicio 2C
-- Series con n_actores (incluyendo 0).
SELECT
    s.serie_id,
    s.titulo AS serie,
    COUNT(ac.actor_id) AS n_actores
FROM Series s
LEFT JOIN Actuaciones ac ON s.serie_id = ac.serie_id
GROUP BY s.serie_id, s.titulo
ORDER BY n_actores DESC, s.titulo;


-- ============================================================
-- Ejercicio 3
-- Compara COUNT(*) de cartesian (Series x Episodios)
-- contra COUNT(*) del join correcto y explica la diferencia.
SELECT COUNT(*) AS filas_cartesian
FROM Series s
CROSS JOIN Episodios e;

SELECT COUNT(*) AS filas_join_correcto
FROM Series s
JOIN Episodios e ON s.serie_id = e.serie_id;

SELECT COUNT(*) AS episodios_total
FROM Episodios;


-- ============================================================
-- Ejercicio 4
-- Compara cuantas filas devuelve UNION ALL vs UNION
-- (con COUNT(*) sobre subconsulta)
SELECT COUNT(*) AS filas_union_all
FROM (
    SELECT genero FROM Series WHERE genero IN ('Drama', 'Comedia')
    UNION ALL
    SELECT genero FROM Series WHERE genero = 'Drama'
) t;

SELECT COUNT(*) AS filas_union
FROM (
    SELECT genero FROM Series WHERE genero IN ('Drama', 'Comedia')
    UNION
    SELECT genero FROM Series WHERE genero = 'Drama'
) t;

-- Ejercicio 4B
-- Feed combinado con item_tipo e item_titulo.
SELECT 'SERIE' AS item_tipo, titulo AS item_titulo
FROM Series
UNION ALL
SELECT 'EPISODIO' AS item_tipo, titulo AS item_titulo
FROM Episodios;


-- ============================================================
-- Ejercicio 5
-- Top 10 episodios mas recientes con año_estreno.
SELECT
    e.episodio_id,
    e.titulo,
    e.fecha_estreno,
    strftime('%Y', e.fecha_estreno) AS año_estreno
FROM Episodios e
WHERE e.fecha_estreno IS NOT NULL
ORDER BY e.fecha_estreno DESC
LIMIT 10;

-- Ejercicio 5B
-- Episodios por año (top 5 años).
SELECT
    strftime('%Y', e.fecha_estreno) AS año_estreno,
    COUNT(*) AS n_episodios
FROM Episodios e
WHERE e.fecha_estreno IS NOT NULL
GROUP BY año_estreno
ORDER BY n_episodios DESC, año_estreno DESC
LIMIT 5;


-- ============================================================
-- Ejercicio 6
-- Promedio rating por serie + bucket.
SELECT
    s.serie_id,
    s.titulo AS serie,
    ROUND(AVG(e.rating_imdb), 2) AS rating_promedio,
    CASE
        WHEN AVG(e.rating_imdb) >= 9 THEN 'excelente'
        WHEN AVG(e.rating_imdb) >= 8 THEN 'buena'
        ELSE 'regular'
    END AS rating_categoria
FROM Series s
JOIN Episodios e ON s.serie_id = e.serie_id
GROUP BY s.serie_id, s.titulo
ORDER BY rating_promedio DESC, s.titulo;

-- Ejercicio 6B
-- Etiqueta por año de lanzamiento.
SELECT
    s.serie_id,
    s.titulo,
    s.año_lanzamiento,
    CASE
        WHEN s.año_lanzamiento < 2010 THEN 'Clasica'
        WHEN s.año_lanzamiento <= 2018 THEN 'Moderna'
        ELSE 'Nueva'
    END AS etiqueta_lanzamiento
FROM Series s
ORDER BY s.año_lanzamiento, s.titulo;


-- ============================================================
-- Ejercicio 7
-- serie, n_episodios, n_actores, rating_promedio, episodio_mas_reciente
-- para las 10 series con mayor n_episodios.
SELECT
    s.titulo AS serie,
    COUNT(DISTINCT e.episodio_id) AS n_episodios,
    COUNT(DISTINCT ac.actor_id) AS n_actores,
    ROUND(AVG(e.rating_imdb), 2) AS rating_promedio,
    MAX(e.fecha_estreno) AS episodio_mas_reciente
FROM Series s
LEFT JOIN Episodios e ON s.serie_id = e.serie_id
LEFT JOIN Actuaciones ac ON s.serie_id = ac.serie_id
GROUP BY s.serie_id, s.titulo
ORDER BY n_episodios DESC, rating_promedio DESC
LIMIT 10;

-- Ejercicio 7B
-- Ranking de actores por numero de series y episodios en los que participan.
SELECT
    a.actor_id,
    a.nombre AS actor,
    COUNT(DISTINCT ac.serie_id) AS n_series,
    COUNT(DISTINCT e.episodio_id) AS n_episodios_en_sus_series
FROM Actores a
JOIN Actuaciones ac ON a.actor_id = ac.actor_id
LEFT JOIN Episodios e ON ac.serie_id = e.serie_id
GROUP BY a.actor_id, a.nombre
ORDER BY n_series DESC, n_episodios_en_sus_series DESC, a.nombre;
