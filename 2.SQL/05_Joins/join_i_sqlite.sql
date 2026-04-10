/* ============================================================
   SQL Clase 8 - JOINs I (SQLite) + bloque extra de funciones
   Dataset: NetflixDB
   ============================================================ */

-- Agenda (3h + 15 min descanso)
-- 0:00-0:10  Setup y warm-up
-- 0:10-0:40  INNER JOIN (claves + alias)
-- 0:40-1:05  LEFT JOIN (tabla base + nulos)
-- 1:05-1:15  Cartesian product + sanity checks
-- 1:15-1:30  Descanso
-- 1:30-1:55  UNION / UNION ALL
-- 1:55-2:20  Fechas (DATEDIFF en SQLite)
-- 2:20-2:45  Texto + CAST + CASE
-- 2:45-2:55  Mini reto integrador
-- 2:55-3:00  Cierre


/* ============================================================
   0) Setup y warm-up
   ============================================================ */

SELECT * FROM Series LIMIT 5;
SELECT * FROM Episodios LIMIT 5;
SELECT * FROM Actores LIMIT 5;
SELECT * FROM Actuaciones LIMIT 5;

-- Claves del modelo:
-- Series(serie_id) 1----N Episodios(serie_id)
-- Series(serie_id) N----N Actores(actor_id) via Actuaciones

-- Ejercicio 0:
-- Cuenta filas por tabla (Series, Episodios, Actores, Actuaciones)
-- en una sola consulta con UNION ALL.


/* ============================================================
   1) INNER JOIN (solo coincidencias)
   ============================================================ */

-- Ejemplo 1A: episodios con su serie
SELECT
    s.serie_id,
    s.titulo AS serie,
    e.episodio_id,
    e.titulo AS episodio,
    e.temporada
FROM Series s
INNER JOIN Episodios e
    ON s.serie_id = e.serie_id
ORDER BY s.titulo, e.temporada, e.episodio_id;

-- Ejemplo 1B: actor + serie + personaje (N-N)
SELECT
    a.nombre AS actor,
    s.titulo AS serie,
    ac.personaje
FROM Actores a
INNER JOIN Actuaciones ac
    ON a.actor_id = ac.actor_id
INNER JOIN Series s
    ON ac.serie_id = s.serie_id
ORDER BY s.titulo, a.nombre;

-- Ejercicio 1:
-- Lista solo actuaciones de series de genero 'Drama'.
-- Devuelve: serie, actor, personaje.

-- Ejercicio 1B:
-- Top 10 series por numero de actuaciones (no episodios).


/* ============================================================
   2) LEFT JOIN (mantener filas de la tabla base)
   ============================================================ */

-- Ejemplo 2A: todas las series, tengan o no episodios
SELECT
    s.serie_id,
    s.titulo AS serie,
    e.episodio_id,
    e.titulo AS episodio
FROM Series s
LEFT JOIN Episodios e
    ON s.serie_id = e.serie_id
ORDER BY s.titulo, e.episodio_id;

-- Ejemplo 2B: todas las series con contador de episodios
SELECT
    s.serie_id,
    s.titulo AS serie,
    COUNT(e.episodio_id) AS n_episodios
FROM Series s
LEFT JOIN Episodios e
    ON s.serie_id = e.serie_id
GROUP BY s.serie_id, s.titulo
ORDER BY n_episodios DESC, s.titulo;

-- Ejercicio 2:
-- Series sin episodios (episodio_id IS NULL).

-- Ejercicio 2B:
-- Actores sin actuaciones.

-- Ejercicio 2C:
-- Muestra todas las series con n_actores (incluso 0 actores)
-- usando LEFT JOIN con Actuaciones.


/* ============================================================
   3) Evitar cartesian + sanity checks
   ============================================================ */

-- Ejemplo 3A (MAL): cartesian (comentado)
-- SELECT *
-- FROM Series s
-- JOIN Episodios e;

-- Ejemplo 3B (BIEN): join por clave
SELECT
    s.titulo AS serie,
    e.titulo AS episodio
FROM Series s
JOIN Episodios e
    ON s.serie_id = e.serie_id
LIMIT 20;

-- Sanity check 1: filas esperadas
SELECT COUNT(*) AS episodios_total FROM Episodios;

SELECT COUNT(*) AS filas_join_series_episodios
FROM Series s
JOIN Episodios e
    ON s.serie_id = e.serie_id;

-- Sanity check 2: N-N (una fila por actor-serie)
SELECT COUNT(*) AS actuaciones_total FROM Actuaciones;

SELECT COUNT(*) AS filas_join_actor_serie
FROM Actores a
JOIN Actuaciones ac ON a.actor_id = ac.actor_id
JOIN Series s ON s.serie_id = ac.serie_id;

-- Ejercicio 3:
-- Compara COUNT(*) de cartesian (Series x Episodios)
-- contra COUNT(*) del join correcto y explica la diferencia.


/* ============================================================
   4) UNION y UNION ALL
   ============================================================ */

-- Ejemplo 4A: UNION ALL conserva duplicados
SELECT genero
FROM Series
WHERE genero IN ('Drama', 'Comedia')
UNION ALL
SELECT genero
FROM Series
WHERE genero = 'Drama';

-- Ejemplo 4B: UNION elimina duplicados
SELECT genero
FROM Series
WHERE genero IN ('Drama', 'Comedia')
UNION
SELECT genero
FROM Series
WHERE genero = 'Drama';

-- Ejercicio 4:
-- Compara cuantas filas devuelve UNION ALL vs UNION
-- con el ejemplo anterior (envuelve cada uno en una subconsulta y usa COUNT(*)).

-- Ejercicio 4B:
-- Crea un feed combinado (UNION ALL) con 2 columnas:
-- item_tipo ('SERIE' o 'EPISODIO') y item_titulo,
-- usando Series y Episodios.


/* ============================================================
   5) Fechas (DATEDIFF en SQLite)
   ============================================================ */

-- En SQLite no hay DATEDIFF nativo.
-- Equivalente: julianday(fecha_fin) - julianday(fecha_inicio)

-- Ejemplo 5A: dias desde estreno por episodio
SELECT
    e.episodio_id,
    e.titulo,
    e.fecha_estreno,
    CAST(julianday('now') - julianday(e.fecha_estreno) AS INTEGER) AS dias_desde_estreno
FROM Episodios e
WHERE e.fecha_estreno IS NOT NULL
ORDER BY dias_desde_estreno DESC
LIMIT 15;

-- Ejemplo 5B: serie con episodio mas antiguo
SELECT
    s.titulo AS serie,
    e.titulo AS episodio,
    e.fecha_estreno,
    ROUND((julianday('now') - julianday(e.fecha_estreno)) / 365.25, 1) AS años_desde_estreno
FROM Episodios e
JOIN Series s ON s.serie_id = e.serie_id
WHERE e.fecha_estreno IS NOT NULL
ORDER BY e.fecha_estreno ASC
LIMIT 1;

-- Ejercicio 5:
-- Top 10 episodios mas recientes (fecha_estreno DESC)
-- con columna año_estreno = strftime('%Y', fecha_estreno).

-- Ejercicio 5B:
-- Cuenta episodios por año de estreno y muestra top 5 años.


/* ============================================================
   6) Texto + CAST + CASE
   ============================================================ */

-- Ejemplo 6A: limpieza y derivadas de texto
SELECT
    s.serie_id,
    s.titulo,
    UPPER(s.titulo) AS titulo_upper,
    LOWER(s.genero) AS genero_lower,
    LENGTH(s.titulo) AS titulo_len,
    SUBSTR(s.titulo, 1, 3) AS titulo_prefix
FROM Series s
ORDER BY s.titulo;

-- Ejemplo 6B: CAST + CASE con rating de episodios
SELECT
    e.episodio_id,
    e.titulo,
    e.rating_imdb,
    CAST(e.rating_imdb AS INTEGER) AS rating_entero,
    CASE
        WHEN e.rating_imdb >= 9 THEN 'Top'
        WHEN e.rating_imdb >= 8 THEN 'Alto'
        ELSE 'Medio/Bajo'
    END AS rating_bucket
FROM Episodios e
ORDER BY e.rating_imdb DESC, e.episodio_id
LIMIT 20;

-- Ejercicio 6:
-- Para cada serie, calcula promedio rating_imdb de sus episodios
-- y clasifica con CASE: excelente (>=9), buena (>=8), regular (<8).

-- Ejercicio 6B:
-- Muestra titulo_serie y etiqueta_lanzamiento:
-- 'Clasica' (<2010), 'Moderna' (2010-2018), 'Nueva' (>2018)
-- usando año_lanzamiento.


/* ============================================================
   7) Mini reto integrador
   ============================================================ */

-- Ejercicio 7:
-- Construye una salida final con:
-- serie, n_episodios, n_actores, rating_promedio, episodio_mas_reciente
-- para las 10 series con mayor n_episodios.
-- (JOINs + GROUP BY + funciones de fecha)

-- Ejercicio 7B (si sobra tiempo):
-- Crea un ranking de actores por numero de series y numero de episodios
-- en los que participan (actuaciones + episodios por serie).


/* ============================================================
   Receta rapida
   1) Define grano y tabla base
   2) JOIN con ON usando claves
   3) Valida LEFT vs INNER
   4) Revisa conteos (sanity)
   5) Deriva columnas (fecha/texto/case) al final
   ============================================================ */
