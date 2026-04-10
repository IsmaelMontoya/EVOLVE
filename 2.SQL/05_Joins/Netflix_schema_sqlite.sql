PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS Actuaciones;
DROP TABLE IF EXISTS Episodios;
DROP TABLE IF EXISTS Actores;
DROP TABLE IF EXISTS Series;

CREATE TABLE IF NOT EXISTS Series (
    serie_id INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo TEXT NOT NULL,
    descripcion TEXT,
    año_lanzamiento INTEGER,
    genero TEXT
);

CREATE TABLE IF NOT EXISTS Episodios (
    episodio_id INTEGER PRIMARY KEY AUTOINCREMENT,
    serie_id INTEGER,
    titulo TEXT NOT NULL,
    duracion INTEGER,
    rating_imdb REAL,
    temporada INTEGER,
    descripcion TEXT,
    fecha_estreno TEXT,
    FOREIGN KEY (serie_id) REFERENCES Series(serie_id)
);

CREATE TABLE IF NOT EXISTS Actores (
    actor_id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    fecha_nacimiento TEXT
);

CREATE TABLE IF NOT EXISTS Actuaciones (
    actor_id INTEGER,
    serie_id INTEGER,
    personaje TEXT,
    PRIMARY KEY (actor_id, serie_id),
    FOREIGN KEY (actor_id) REFERENCES Actores(actor_id),
    FOREIGN KEY (serie_id) REFERENCES Series(serie_id)
);
