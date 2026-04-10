/* =======================================================================================
   CREACIÓN DE TABLAS EN SQLITE - Clase completa 2h45'
   Data Science & AI Master
   =======================================================================================
   
   ÍNDICE DE CONTENIDOS:

    0:00–0:45 Bloque 1: Conceptos + Ejemplo 1 (Data Warehouse)
    0:45–1:05 Bloque 2: Ejercicio 1 (Plataforma cursos)
    1:05–1:30 Bloque 3: Concepto M2M + Ejemplo 2 (Películas)
    1:30–1:45 Descanso
    1:45–2:10 Bloque 4: Ejercicio 2 (Libros y Autores M2M)
    2:10–2:30 Bloque 5: Temas avanzados (DEFAULT, CHECK, etc.)
    2:30–2:50 Bloque 6: Ejercicio 3 (Hospital - Avanzado)
    2:50–3:00 Cierre: Resumen + Q&A
   
 */


/* =======================================================================================
   SECCIÓN 1: CONCEPTOS FUNDAMENTALES
   ========================================================================================
   
   TIPOS DE DATOS EN SQLite:
   - INTEGER: números enteros (-9223372036854775808 a 9223372036854775807)
   - REAL: números decimales (punto flotante)
   - TEXT: textos/cadenas de caracteres
   - BLOB: datos binarios
   - NULL: valor vacío/ausente
   - NUMERIC: almacena exactamente el tipo que le das (mejor para dinero)
   
   CONSTRAINTS (RESTRICCIONES):
   - PRIMARY KEY: identificador único de cada fila (no nulos, únicos)
   - FOREIGN KEY: referencia a otra tabla (clave ajena)
   - NOT NULL: no puede estar vacío
   - UNIQUE: debe ser único (pero puede haber NULL)
   - CHECK: valida una condición
   - DEFAULT: valor por defecto si no se especifica
   
   TIPOS DE RELACIONES:
   - 1 a 1 (One-to-One): Un cliente tiene una dirección, una dirección pertenece a un cliente
   - 1 a N (One-to-Many): Un cliente puede hacer muchas compras, una compra es de un cliente
   - M a N (Many-to-Many): Un cliente puede comprar muchos productos, un producto lo compran muchos clientes
                            → Requiere tabla intermedia/puente
 */


/* =======================================================================================
   SECCIÓN 2: EJEMPLO 1 RESUELTO - DATA WAREHOUSE SIMPLE
   ========================================================================================
   Modelo: Cliente → Compra → Producto (ventas)
   Tipo de relaciones: 1 a N (cliente a ventas), 1 a N (producto a ventas)
 */

-- Tabla de clientes (DIMENSIÓN: información descriptiva)
DROP TABLE IF EXISTS dim_client;
CREATE TABLE dim_client (
    id_client INTEGER PRIMARY KEY,          -- Clave primaria: identificador único
    name TEXT NOT NULL,                     -- NOT NULL: siempre debe tener valor
    email TEXT UNIQUE NOT NULL,             -- UNIQUE: cada email aparece una sola vez
    country TEXT,                           -- Campo opcional
    created_date DATE NOT NULL              -- Fecha de registro
);

-- Tabla de productos (DIMENSIÓN: información descriptiva)
DROP TABLE IF EXISTS dim_product;
CREATE TABLE dim_product (
    id_product INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    price REAL NOT NULL                    -- REAL para números decimales (precio)
);

-- Tabla de ventas (HECHOS: eventos/transacciones numéricas)
DROP TABLE IF EXISTS fact_sales;
CREATE TABLE fact_sales (
    id_sale INTEGER PRIMARY KEY,
    id_client INTEGER NOT NULL,            -- FK: Referencia a dim_client
    id_product INTEGER NOT NULL,           -- FK: Referencia a dim_product
    quantity INTEGER NOT NULL,
    total REAL NOT NULL,
    sale_date DATE NOT NULL,
    -- Definimos las Foreign Keys (restricciones de integridad referencial)
    FOREIGN KEY (id_client) REFERENCES dim_client(id_client),
    FOREIGN KEY (id_product) REFERENCES dim_product(id_product)
);

-- Insertamos datos de ejemplo
INSERT INTO dim_client (id_client, name, email, country, created_date)
VALUES 
    (1, 'Ibai Llanos',          'ibai.llanos@gmail.com',          'España',   '2023-01-15'),
    (2, 'Juan Alberto García',  'juan.alberto@gmail.com',         'España',   '2023-02-10'),
    (3, 'Elena Rodríguez',      'elena.rodriguez@gmail.com',      'España',   '2023-03-05');

INSERT INTO dim_product (id_product, name, category, price)
VALUES 
    (1, 'MacBook Pro 16" M3',   'Tecnología', 2500.00),
    (2, 'Tesla Model Y',        'Automóviles', 65000.00),
    (3, 'AirPods Pro',          'Tecnología',  249.00),
    (4, 'iPad Air',             'Tecnología',  799.00);

INSERT INTO fact_sales (id_sale, id_client, id_product, quantity, total, sale_date)
VALUES 
    (1, 1, 2, 1, 65000.00, '2024-03-01'),
    (2, 2, 1, 1,  2500.00, '2024-03-02'),
    (3, 1, 3, 2,   498.00, '2024-03-05'),
    (4, 3, 4, 1,   799.00, '2024-03-10'),
    (5, 2, 3, 1,   249.00, '2024-03-15');

-- Veamos los datos creados
SELECT * FROM dim_client;
SELECT * FROM dim_product;
SELECT * FROM fact_sales;


/* =======================================================================================
   SECCIÓN 3: EJERCICIO 1 SIN RESOLVER - COMPARTIR PANTALLA
   ========================================================================================
   
   ENUNCIADO:
   Tienes que crear un modelo para una plataforma de cursos online.
   
   Necesitas:
   1. Tabla de ESTUDIANTES:
      - id_student (clave primaria, autoincrement)
      - name (texto, no nulo)
      - email (texto, único, no nulo)
      - phone (texto, opcional)
      - enrollment_date (fecha, no nulo)
   
   2. Tabla de CURSOS:
      - id_course (clave primaria, autoincrement)
      - title (texto, no nulo)
      - description (texto, opcional)
      - instructor (texto, no nulo)
      - duration_hours (número, no nulo)
      - price (número decimal, no nulo)
   
   3. Tabla de INSCRIPCIONES (relación 1 a N: estudiante inscrito en muchos cursos):
      - id_enrollment (clave primaria, autoincrement)
      - id_student (clave ajena a students)
      - id_course (clave ajena a courses)
      - enrollment_date (fecha, no nulo)
      - grade (número decimal, opcional - calificación)
   
   TAREAS:
   a) Crea las 3 tablas con los constraints especificados
   b) Inserta 2 estudiantes, 3 cursos y 3 inscripciones
   c) Verifica con SELECT * de cada tabla
   
   PISTA: Usa INTEGER PRIMARY KEY AUTOINCREMENT para las claves primarias.
           Una inscripción conecta un estudiante con un curso.
 */

-- [ESCRIBE TU CÓDIGO AQUÍ]
-- ...


/* =======================================================================================
   SECCIÓN 4: EJEMPLO 2 RESUELTO - RELACIÓN MANY-TO-MANY
   ========================================================================================
   
   Caso: Una película tiene muchos actores, un actor actúa en muchas películas
   Solución: Tabla intermedia "movie_actor" que conecta ambas tablas
   
   Estructura:
   movies ─────┐  
                ├─── movie_actor (tabla puente/intermedia) 
   actors ─────┘
 */

-- Tabla de actores (DIMENSIÓN)
DROP TABLE IF EXISTS actors;
CREATE TABLE actors (
    id_actor INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    birth_year INTEGER
);

-- Tabla de películas (DIMENSIÓN)
DROP TABLE IF EXISTS movies;
CREATE TABLE movies (
    id_movie INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    release_year INTEGER NOT NULL,
    rating TEXT,                           -- 'PG-13', 'R', 'PG', etc.
    imdb_rating REAL
);

-- Tabla intermedia (HECHOS: relación M2M)
-- Esta tabla define quién actúa en qué película
DROP TABLE IF EXISTS movie_actor;
CREATE TABLE movie_actor (
    id_movie_actor INTEGER PRIMARY KEY AUTOINCREMENT,
    id_movie INTEGER NOT NULL,
    id_actor INTEGER NOT NULL,
    role_name TEXT,                        -- Personaje que interpreta
    FOREIGN KEY (id_movie) REFERENCES movies(id_movie),
    FOREIGN KEY (id_actor) REFERENCES actors(id_actor)
);

-- Insertar actores
INSERT INTO actors (first_name, last_name, birth_year)
VALUES 
    ('Ben', 'Stiller', 1965),
    ('Owen', 'Wilson', 1966),
    ('Cillian', 'Murphy', 1976),
    ('Robert', 'Downey Jr.', 1965),
    ('Margot', 'Robbie', 1990),
    ('Ryan', 'Gosling', 1984);

-- Insertar películas
INSERT INTO movies (title, release_year, rating, imdb_rating)
VALUES 
    ('Zoolander', 2001, 'PG-13', 6.5),
    ('Oppenheimer', 2023, 'R', 8.4),
    ('Barbie', 2023, 'PG-13', 7.0);

-- Insertar relaciones (quién actúa en qué película)
INSERT INTO movie_actor (id_movie, id_actor, role_name)
VALUES 
    (1, 1, 'Derek Zoolander'),        -- Ben Stiller en Zoolander
    (1, 2, 'Hansel'),                 -- Owen Wilson en Zoolander
    (2, 3, 'J. Robert Oppenheimer'),  -- Cillian Murphy en Oppenheimer
    (3, 5, 'Barbie'),                 -- Margot Robbie en Barbie
    (3, 6, 'Ken');                    -- Ryan Gosling en Barbie

-- Ver los datos
SELECT * FROM actors;
SELECT * FROM movies;
SELECT * FROM movie_actor;

-- Consulta útil: Ver qué actores están en cada película
SELECT 
    m.title,
    a.first_name || ' ' || a.last_name AS actor_name,
    ma.role_name
FROM movie_actor ma
JOIN movies m ON ma.id_movie = m.id_movie
JOIN actors a ON ma.id_actor = a.id_actor
ORDER BY m.title;


/* =======================================================================================
   SECCIÓN 5: EJERCICIO 2 SIN RESOLVER - COMPARTIR PANTALLA
   ========================================================================================
   
   ENUNCIADO:
   Diseña un modelo para una tienda online con gestión de autores y libros.
   
   Contexto: Un libro puede tener múltiples autores (coautores),
             un autor puede escribir múltiples libros.
             Esto es una relación MANY-TO-MANY.
   
   Necesitas crear:
   1. Tabla AUTHORS:
      - id_author (PK autoincrement)
      - name (texto, no nulo)
      - nationality (texto, opcional)
      - birth_year (número, opcional)
   
   2. Tabla BOOKS:
      - id_book (PK autoincrement)
      - title (texto, no nulo)
      - publication_year (número, no nulo)
      - genre (texto, no nulo)
      - price (decimal, no nulo)
      - stock (número, no nulo - cantidad disponible)
   
   3. Tabla BOOK_AUTHOR (tabla intermedia):
      - id_book_author (PK autoincrement)
      - id_book (FK a books)
      - id_author (FK a authors)
      - author_order (número - 1 para primer autor, 2 para segundo, etc.)
   
   TAREAS:
   a) Crea las 3 tablas
   b) Inserta 3 autores, 2 libros:
      - Libro 1: "El Quijote" con Cervantes
      - Libro 2: "Cien años de soledad" con García Márquez
   c) Usa INSERT para las relaciones book_author
   d) Verifica con SELECTs
   
   RETO (opcional): Escribe un SELECT que muestre cada libro con sus autores
 */

-- [ESCRIBE TU CÓDIGO AQUÍ]
-- ...


/* =======================================================================================
   SECCIÓN 6: TEMAS AVANZADOS - CONSTRAINTS Y CARACTERÍSTICAS ESPECIALES
   ========================================================================================
 */

-- Ejemplo con más constraints: DEFAULT, CHECK
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    id_employee INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    salary REAL NOT NULL,
    department TEXT NOT NULL,
    hire_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT 1,           -- DEFAULT: valor por defecto (1 = true)
    
    -- CHECK: valida que la condición sea verdadera
    CHECK (salary > 0),                    -- El salario debe ser positivo
    CHECK (department IN ('HR', 'IT', 'Sales', 'Finance'))  -- Departamentos permitidos
);

INSERT INTO employees (name, email, salary, department, hire_date)
VALUES 
    ('Carlos López',    'carlos@company.com',    3500, 'IT', '2023-06-01'),
    ('María García',    'maria@company.com',     4000, 'Finance', '2023-07-15');

SELECT * FROM employees;

-- Ejemplo con NUMERIC para dinero (más preciso que REAL)
DROP TABLE IF EXISTS invoices;
CREATE TABLE invoices (
    id_invoice INTEGER PRIMARY KEY AUTOINCREMENT,
    invoice_number TEXT UNIQUE NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,        -- Total de 10 dígitos, 2 decimales
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,  -- Fecha actual por defecto
    due_date DATE NOT NULL,
    paid BOOLEAN DEFAULT 0
);

INSERT INTO invoices (invoice_number, amount, issue_date, due_date)
VALUES ('INV-2024-001', 1500.50, '2024-01-15', '2024-02-15');

SELECT * FROM invoices;

-- AUTOINCREMENT vs sin él
-- SQLite gestiona automáticamente si usas INTEGER PRIMARY KEY
-- AUTOINCREMENT es opcional pero garantiza que no se reutilicen IDs
DROP TABLE IF EXISTS test_users;
CREATE TABLE test_users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,  -- Automático: 1,2,3...
    username TEXT UNIQUE NOT NULL
);

INSERT INTO test_users (username) VALUES ('alice');
INSERT INTO test_users (username) VALUES ('bob');
INSERT INTO test_users (username) VALUES ('charlie');

SELECT * FROM test_users;


/* =======================================================================================
   SECCIÓN 7: EJERCICIO 3 SIN RESOLVER - COMPARTIR PANTALLA
   ========================================================================================
   
   ENUNCIADO - NIVEL AVANZADO:
   Debes crear un modelo de base de datos para un hospital.
   
   Contexto: 
   - Los pacientes se registran en el hospital
   - Los médicos trabajan en diferentes departamentos
   - Un paciente puede tener múltiples citas con diferentes médicos
   - Una cita pertenece a UN paciente y UN médico (relación 1 a N desde paciente y médico)
   
   Necesitas:
   1. Tabla PATIENTS:
      - id_patient (PK autoincrement)
      - name (texto, no nulo)
      - email (texto, único)
      - phone (texto, no nulo)
      - birth_date (fecha, no nulo)
      - registration_date (fecha, default actual)
   
   2. Tabla DOCTORS:
      - id_doctor (PK autoincrement)
      - name (texto, no nulo)
      - speciality (texto, no nulo)
      - department (texto, no nulo)
      - years_experience (número)
      - Constraint CHECK: years_experience >= 0
   
   3. Tabla APPOINTMENTS:
      - id_appointment (PK autoincrement)
      - id_patient (FK a patients)
      - id_doctor (FK a doctors)
      - appointment_date (fecha, no nulo)
      - reason (texto, no nulo)
      - status (texto, DEFAULT 'scheduled')
      - Constraint CHECK: status IN ('scheduled', 'completed', 'cancelled')
   
   TAREAS:
   a) Crea las 3 tablas con todos los constraints
   b) Inserta 2 pacientes, 2 médicos
   c) Inserta 3 citas válidas (que respeten las FKs)
   d) Verifica con SELECT
   
   RETO (opcional): 
   - Escribe un SELECT que muestre todas las citas con nombre del paciente y médico
   - Usa JOINs: citas → pacientes y citas → médicos
 */

-- [ESCRIBE TU CÓDIGO AQUÍ]
-- ...


/* =======================================================================================
   RESUMEN DE MEJORES PRÁCTICAS
   ========================================================================================
   
   ✅ HAGA:
   1. Nombres en minúsculas con guiones bajos: dim_client, fact_sales, id_employee
   2. Use PRIMARY KEY para cada tabla
   3. Defina FOREIGN KEYs para mantener integridad referencial
   4. Use NOT NULL en columnas que siempre deben tener valor
   5. Use UNIQUE para campos que no pueden repetirse (email, id)
   6. Use DEFAULT para valores que casi siempre son iguales
   7. Use CHECK para validar que los datos tengan sentido
   8. Use NUMERIC para dinero (no REAL)
   9. Documente el propósito de cada tabla (comentarios)
   
   ❌ NO HAGA:
   1. Dejar columnas sin restricciones si deberían tenerlas
   2. Mezclar mayúsculas y minúsculas (inconsistente)
   3. Foreign Keys sin referencias válidas (integridad rota)
   4. Nombres confusos: x, dat, info, etc.
   5. Olvidar crear tablas intermedia para relaciones M2M
   
 */
