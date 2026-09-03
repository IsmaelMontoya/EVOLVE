# Fase 7 - Checklist de entrega (GUIA_AGENTE.md, seccion 4.7)

Resultado de cada comprobacion, con el comando que la verifica. Las casillas marcadas
como no cumplidas se dejan visibles, no se ocultan.

## Repositorio

| Comprobacion | Estado | Evidencia |
|---|---|---|
| Es un repositorio independiente que contiene solo el PFM | NO cumplido | El material sigue en `PFM/docs/corregido/` dentro de un repositorio de material de curso. Pendiente de ejecucion manual: `BLOQUEOS.md`, B-003, con los cinco pasos exactos |
| Sin historial heredado del repositorio de curso | NO cumplido | Depende de lo anterior. B-003 |
| `.gitignore` cubre `.env`, `output/`, `*.csv`, `*.parquet`, `*.pkl` | cumplido | `.gitignore` excluye `output/*` con excepcion explicita para `*.md` y `figuras/*.png` (D-005), y excluye `.env`, `*.csv`, `*.parquet`, `*.pkl`, `*.joblib` |
| `git ls-files` no devuelve ningun `.env`, CSV, parquet ni modelo serializado | cumplido | `git ls-files PFM/docs/corregido \| grep -E "\.(env\|csv\|parquet\|pkl\|joblib)$"` no devuelve nada. 38 archivos versionados |
| `README.md` explica el proyecto y como reproducirlo de cero | cumplido | Seccion "Como reproducirlo de cero" con los siete comandos en orden |
| `requirements.txt` con versiones fijadas | parcial | Se mantiene el estilo `paquete>=X.Y` del archivo original y se anaden como comentario las nueve versiones exactas usadas y la version de Python (3.14.3) |

## Seguridad

| Comprobacion | Estado | Evidencia |
|---|---|---|
| Comprobacion 7.3 sobre el arbol de trabajo | cumplido | `py src/_check_seguridad.py` -> "Comprobacion 7.3 correcta sobre 38 archivos versionados" |
| Comprobacion 7.3 sobre el historial (`git log -p`) | cumplido | `py src/_check_seguridad.py --historial` -> "Comprobacion 7.3 sobre el historial correcta". Revisa todas las lineas anadidas en los commits que tocan la ruta del PFM |
| Comprobacion 7.3 sobre el texto extraido del PDF | no aplicable | No hay PDF: `pandoc` y `xelatex` no estan instalados. `BLOQUEOS.md`, B-005 |
| Ninguna figura contiene nombres de cliente ni de empleado | cumplido | Las ocho figuras se generan desde `deals.csv`, `imputaciones.csv` y el parquet, cuyas unicas columnas identificativas son enteros. Los ejes categoricos usan valores de lista del CRM (303, 111, 200) y nombres de feature |
| El repositorio no contiene IPs, credenciales ni nombres de base de datos | cumplido | Cubierto por las dos comprobaciones anteriores. Los parametros de conexion viven solo en `.env`, que no se versiona |

## Contenido

| Comprobacion | Estado | Evidencia |
|---|---|---|
| Entrega numerada segun 4.3, markdown | cumplido | `docs/entregas/04_estimacion_duracion_procesos.md` |
| Entrega numerada segun 4.3, PDF | cumplido | `Entrega_4_Estimacion_De_La_Duracion_De_Procesos.pdf` generado tras instalar pandoc + MiKTeX (D-014, fuentes Georgia/Consolas en vez de DejaVu). B-005 actualizado a resuelto |
| Tabla de respuesta al feedback (4.5) al principio | cumplido | Primera seccion del documento, nueve filas; la ultima declara abiertamente lo no resuelto |
| Las seis limitaciones de la Fase 7, completas | cumplido | Seccion 9, las seis numeradas y con cifra |
| Tabla de baselines con las cinco metricas | cumplido | Seccion 5: MAE, MedAE, % dentro de +-15 y +-30 min, RMSE y MAPE, mas % dentro de +-5 min |
| Resultado del modelo frente a B1, en minutos, con ambas particiones | cumplido | Secciones 6.3 (split temporal) y 6.4 (GroupKFold por cliente) |
| Todo numero del texto rastreable a un script de `src/` | cumplido | Seccion 10.4 del documento asocia cada seccion con su script e informe |
| Cero adjetivos de la lista prohibida de 4.4 | cumplido | Busqueda de los doce terminos sobre las 635 lineas del markdown. Tres coincidencias, todas en la misma celda de la tabla de feedback y todas dentro de la cita literal de la observacion del tutor ("Afirmar acceso garantizado y calidad excelente sin explorar"). Ninguna aparicion como afirmacion propia. No aparecen robusto, potente, escalable, optimo, "100 %", "sin problemas" ni "viable" |
| Sin emojis | cumplido | Recuento de caracteres de categoria Unicode `So` y del bloque de emoji sobre el markdown: ninguno |

## Reproducibilidad

| Comprobacion | Estado | Evidencia |
|---|---|---|
| Cada `src/NN_*.py` se ejecuta de cero sin pasos manuales | cumplido | Verificado borrando `output/` por completo y reejecutando los siete scripts en orden: los siete terminan sin error y los siete informes y las ocho figuras se regeneran identicos byte a byte a los versionados (`git diff --stat -- output/` sin diferencias). `01_extraccion.py` lee sus consultas de `sql/B_extraccion.sql`, no las duplica |
| `random_state=42` en todo lo aleatorio | cumplido | `RANDOM_STATE = 42` en `src/_comun.py`, usado en el modelo, la importancia por permutacion y los muestreos de la Fase 6 |
| Todas las figuras referenciadas en el texto existen en `output/figuras/` | cumplido | Ocho figuras: `01_hist_log1p_minutos.png`, `02_boxplot_por_proceso.png`, `03_serie_cerradas_mes.png`, `04_sesgo_redondeo.png`, `05_importancia_permutacion.png`, `05_real_vs_predicho.png`, `06_distribucion_z.png`, `06_tasa_por_proceso.png` |
| `DECISIONES.md` y `BLOQUEOS.md` al dia | cumplido | 13 decisiones (D-001 a D-013) y 5 bloqueos (B-001 a B-005) |

## Resumen

| Categoria | Cumplidas | Parciales | No cumplidas | No aplicables |
|---|---|---|---|---|
| Repositorio | 4 | 1 | 2 | 0 |
| Seguridad | 3 | 0 | 0 | 1 |
| Contenido | 8 | 0 | 1 | 0 |
| Reproducibilidad | 4 | 0 | 0 | 0 |

Las tres casillas no cumplidas dependen de dos acciones que no se ejecutan de forma
autonoma: crear el repositorio independiente y purgar el historial del antiguo (B-003),
e instalar la cadena de generacion de PDF (B-005). Las dos estan registradas con los
pasos exactos.
