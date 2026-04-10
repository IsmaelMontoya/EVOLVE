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
    (2, 'Juan Alberto García',  'juan.alberto@gmail.com',         NULL,   '2023-02-10'),
    (3, 'Elena Rodríguez',      'elena.rodriguez@gmail.com',      'España',   '2023-03-05')
;

INSERT INTO dim_product (id_product, name, category, price)
VALUES 
    (1, 'MacBook Pro 16" M3',   'Tecnología', 2500.00),
    (2, 'Tesla Model Y',        'Automóviles', 65000.00),
    (3, 'AirPods Pro',          'Tecnología',  249.00),
    (4, 'iPad Air',             'Tecnología',  799.00)
;

INSERT INTO fact_sales (id_sale, id_client, id_product, quantity, total, sale_date)
VALUES 
    (1, 1, 2, 1, 65000.00, '2024-03-01'),
    (2, 2, 1, 1,  2500.00, '2024-03-02'),
    (3, 1, 3, 2,   498.00, '2024-03-05'),
    (4, 3, 4, 1,   799.00, '2024-03-10'),
    (5, 2, 3, 1,   249.00, '2024-03-15')
;

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

/* =======================================================================================
   SOLUCIÓN EJERCICIO 1: PLATAFORMA DE CURSOS ONLINE
   ========================================================================================
 */

-- Tabla de estudiantes
CREATE TABLE students (
    id_student INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    enrollment_date DATE NOT NULL
);

-- Tabla de cursos
CREATE TABLE courses (
    id_course INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    instructor TEXT NOT NULL,
    duration_hours INTEGER NOT NULL,
    price REAL NOT NULL
);

-- Tabla de inscripciones (relación 1 a N)
CREATE TABLE enrollments (
    id_enrollment INTEGER PRIMARY KEY AUTOINCREMENT,
    id_student INTEGER NOT NULL,
    id_course INTEGER NOT NULL,
    enrollment_date DATE NOT NULL,
    grade REAL,
    FOREIGN KEY (id_student) REFERENCES students(id_student),
    FOREIGN KEY (id_course) REFERENCES courses(id_course)
);

-- Insertar estudiantes
INSERT INTO students (name, email, phone, enrollment_date)
VALUES 
    ('Ana Martínez',    'ana@ejemplo.com',    '666123456', '2024-01-10'),
    ('Carlos López',    'carlos@ejemplo.com', '666789012', '2024-02-15');

-- Insertar cursos
INSERT INTO courses (title, description, instructor, duration_hours, price)
VALUES 
    ('Python para Data Science',        'Aprende Python desde cero',           'Juan Pérez',    40, 199.99),
    ('SQL Avanzado',                    'SQL para análisis de datos',          'María García',  30, 149.99),
    ('Machine Learning con Scikit-learn', 'Modelos de ML en Python',           'Luis Fernández', 50, 299.99);

-- Insertar inscripciones
INSERT INTO enrollments (id_student, id_course, enrollment_date, grade)
VALUES 
    (1, 1, '2024-01-10', 9.5),
    (2, 2, '2024-02-15', 8.7),
    (1, 3, '2024-01-20', NULL);  -- NULL porque aún no ha terminado el curso

-- Verificar datos
SELECT 'Estudiantes:' AS seccion;
SELECT * FROM students;

SELECT 'Cursos:' AS seccion;
SELECT * FROM courses;

SELECT 'Inscripciones:' AS seccion;
SELECT * FROM enrollments;


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
    ('Ryan', 'Gosling', NULL);

-- Insertar películas
INSERT INTO movies (title, release_year, rating, imdb_rating)
VALUES 
    ('Zoolander', 2001, 'PG-13', NULL),
    ('Oppenheimer', 2023, NULL, 8.4),
    ('Barbie', 2023, 'PG-13', 7.0);

-- Insertar relaciones (quién actúa en qué película)
INSERT INTO movie_actor (id_movie, id_actor, role_name)
VALUES 
    (1, 1, 'Derek Zoolander'),        -- Ben Stiller en Zoolander
    (1, 2, NULL),                 -- Owen Wilson en Zoolander
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
    CONCAT(a.first_name, ' ', a.last_name) AS actor_name, -- Concat equivalent to ||
    ma.role_name,
    m.imdb_rating
FROM movie_actor AS ma
JOIN movies AS m ON ma.id_movie = m.id_movie
JOIN actors AS a ON ma.id_actor = a.id_actor
ORDER BY m.imdb_rating DESC
--LIMIT 3
;

DROP TABLE IF EXISTS dnis;
CREATE TABLE dnis (
    numero CHAR(9) PRIMARY KEY,
    nombre VARCHAR NOT NULL,
    apellido VARCHAR NOT NULL,
    direccion VARCHAR NOT NULL
);

INSERT INTO dnis (numero, nombre, apellido, direccion)
VALUES 
    ('12345678A', 'Juan', 'Gómez', "Calle de la gominola, casa de la piruleta"),
    ('87654321B', 'Pepe', 'Pérez', "Gran Via 1"),
    ('12343212C', 'María', "O'neil", "Velázquez 7");

SELECT 
	* 
FROM dnis
;

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


/* =======================================================================================
   SOLUCIÓN EJERCICIO 2: TIENDA ONLINE CON LIBROS Y AUTORES
   ========================================================================================
 */

-- Tabla de autores
CREATE TABLE authors (
    id_author INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    nationality TEXT,
    birth_year INTEGER
);

-- Tabla de libros
CREATE TABLE books (
    id_book INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    publication_year INTEGER NOT NULL,
    genre TEXT NOT NULL,
    price REAL NOT NULL,
    stock INTEGER NOT NULL
);

DROP TABLE IF EXISTS book_author ; 
-- Tabla intermedia (relación M2M)
CREATE TABLE book_author(
    id_book INTEGER NOT NULL,
    id_author INTEGER NOT NULL,
    author_order INTEGER,  -- 1 para primer autor, 2 para segundo, etc.
    PRIMARY KEY (id_book, id_author),
    FOREIGN KEY(id_book) REFERENCES books(id_book),
    FOREIGN KEY(id_author) REFERENCES authors(id_author)
);

-- Insertar autores
INSERT INTO authors (name, nationality, birth_year)
VALUES 
    ('Miguel de Cervantes',     'España',           1547),
    ('Gabriel García Márquez',  'Colombia',         1927),
    ('Jorge Luis Borges',       'Argentina',        1899);

-- Insertar libros
INSERT INTO books (title, publication_year, genre, price, stock)
VALUES 
    ('El Quijote',              1605, 'Novela',          15.99, 45),
    ('Cien años de soledad',    1967, 'Realismo mágico', 18.50, 32);

-- Insertar relaciones autor-libro
INSERT INTO book_author (id_book, id_author, author_order)
VALUES 
    (1, 1, 1),  -- El Quijote es de Cervantes (primer/único autor)
    (2, 2, 1);  -- Cien años de soledad es de García Márquez (primer/único autor)

-- Verificar datos
SELECT 'Autores:' AS seccion;
SELECT * FROM authors;

SELECT 'Libros:' AS seccion;
SELECT * FROM books;

SELECT 'Relaciones Libro-Autor:' AS seccion;
SELECT * FROM book_author;

-- RETO RESUELTO: Mostrar cada libro con sus autores
SELECT 
    b.title AS 'Título del Libro',
    a.name AS 'Autor',
    b.publication_year AS 'Año',
    b.genre AS 'Género',
    b.price AS 'Precio',
    b.stock AS 'Stock disponible'
FROM book_author AS ba
JOIN books AS b ON ba.id_book = b.id_book
JOIN authors AS a ON ba.id_author = a.id_author
ORDER BY b.title, ba.author_order;



/* =======================================================================================
   SECCIÓN 6: TEMAS AVANZADOS - CONSTRAINTS Y CARACTERÍSTICAS ESPECIALES
   ========================================================================================
 */

-- Ejemplo con más constraints: DEFAULT, CHECK
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    id_employee INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR NOT NULL,
    email VARCHAR UNIQUE NOT NULL,
    salary FLOAT NOT NULL,
    department VARCHAR NOT NULL,
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
    invoice_number VARCHAR UNIQUE NOT NULL,
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
    username VARCHAR UNIQUE NOT NULL
);

INSERT INTO test_users (username) VALUES ('alice');
INSERT INTO test_users (username) VALUES ('bob');
INSERT INTO test_users (username) VALUES ('charlie'); 
INSERT INTO test_users (username) VALUES ('houston'); 
INSERT INTO test_users (username) VALUES ('veronica'); 


SELECT * FROM test_users;

DELETE 
FROM test_users
WHERE username = 'bob';

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

-- Tabla de pacientes
CREATE TABLE patients (
    id_patient INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR NOT NULL,
    email VARCHAR UNIQUE,
    phone VARCHAR NOT NULL,
    birth_date DATE NOT NULL,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE
); 

-- Tabla de médicos
CREATE TABLE doctors (
    id_doctor INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR NOT NULL,
    speciality VARCHAR NOT NULL,
    department VARCHAR NOT NULL,
    years_experience INTEGER,
    CHECK (years_experience >= 0)
);

-- Tabla de citas (relación entre pacientes y médicos)
CREATE TABLE appointments (
    id_patient INTEGER NOT NULL,
    id_doctor INTEGER NOT NULL,
    appointment_date DATE NOT NULL,
    reason VARCHAR NOT NULL,
    status VARCHAR DEFAULT 'scheduled',
    CHECK (status IN ('scheduled', 'completed', 'cancelled')),
    PRIMARY KEY (id_patient, id_doctor)
    FOREIGN KEY (id_patient) REFERENCES patients(id_patient),
    FOREIGN KEY (id_doctor) REFERENCES doctors(id_doctor)
);

-- Insertar pacientes
INSERT INTO patients (name, email, phone, birth_date, registration_date)
VALUES 
    ('Roberto Sanz',     'roberto@email.com',    '666111222', '1975-05-10', '2024-01-05'),
    ('Patricia Díaz',    'patricia@email.com',   '666333444', '1982-08-22', '2024-01-08');

-- Insertar médicos
INSERT INTO doctors (name, speciality, department, years_experience)
VALUES 
    ('Dr. Antonio Ruiz',    'Cardiología',      'Cardiología',          15),
    ('Dra. Sofía Martín',   'Medicina General', 'Medicina General',     8);

-- Insertar citas
INSERT INTO appointments (id_patient, id_doctor, appointment_date, reason, status)
VALUES 
    (1, 1, '2024-03-15', 'Revisión cardiaca anual', 'scheduled'),
    (2, 2, '2024-03-10', 'Dolor de garganta',            'scheduled'),
    (1, 2, '2024-02-20', 'Descanso médico',              'completed');

-- Verificar datos
SELECT 'Pacientes:' AS seccion;
SELECT * FROM patients;

SELECT 'Médicos:' AS seccion;
SELECT * FROM doctors;

SELECT 'Citas:' AS seccion;
SELECT * FROM appointments;

-- RETO RESUELTO: Mostrar citas con datos completos de paciente y médico
SELECT 
    p.name AS 'Paciente',
    d.name AS 'Médico',
    d.speciality AS 'Especialidad',
    a.appointment_date AS 'Fecha',
    a.reason AS 'Motivo',
    a.status AS 'Estado'
FROM appointments a
JOIN patients p ON a.id_patient = p.id_patient
JOIN doctors d ON a.id_doctor = d.id_doctor
ORDER BY a.appointment_date;

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
