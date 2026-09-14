# Registro de bloqueos

Una entrada por cada punto en el que el dato no existe, el gate no se cumple o
la realidad contradice lo previsto en la guia.

No inventes el dato. No lo aproximes sin decirlo. No pases de fase fingiendo
que el gate se cumplio.

Numeracion correlativa B-001, B-002...

---

## B-000 · Plantilla (no borrar)

**Esperado:**
**Encontrado:**
**Probado:**
**Accion tomada:**
**Fase:**
**Estado:** abierto / resuelto / asumido como limitacion

---

## B-001 · La tabla puente `b_utm_task` no existe

**Esperado:** tabla `b_utm_task` con el enlace tarea -> CRM (GUIA_AGENTE.md, 2.2).
**Encontrado:** no existe. El esquema tiene `b_utm_tasks_task` (130.134 filas), con las
mismas columnas (`ID`, `VALUE_ID`, `FIELD_ID`, `VALUE`, ...). El campo `UF_CRM_TASK` de
`TASKS_TASK` es `FIELD_ID = 6`.
**Probado:** listado de `information_schema.TABLES` con patrones `b_utm%`, `%tasks%`,
`b_uts%`. Reparto de prefijos en `b_utm_tasks_task`: D 54.479, CO 47.054, C 1.489,
L 499, resto 553.
**Accion tomada:** se usa `b_utm_tasks_task` con `FIELD_ID = 6` en todas las consultas.
Los valores UF de negociación se leen de `b_uts_crm_deal`, confirmada por
`information_schema` (32.914 filas).
**Fase:** 1
**Estado:** resuelto

## B-002 · El motor no admite CTE ni funciones de ventana

**Esperado:** MariaDB / MySQL con soporte de `WITH` y `OVER ()`.
**Encontrado:** `SELECT VERSION()` devuelve 5.7. `WITH` produce error 1064.
**Probado:** primera versión de `sql/B_extraccion.sql` escrita con CTE; falla en la
primera consulta.
**Accion tomada:** todas las consultas reescritas con tablas derivadas. Sin cambio de
semántica: los recuentos de `deals.csv` (30.836 filas) e `imputaciones.csv` (66.690
filas) coinciden con los agregados de descubrimiento.
**Fase:** 1
**Estado:** resuelto

## B-003 · Extracción a repositorio independiente (PARTE 4.2) — no ejecutada

**Esperado:** el PFM vive en un repositorio propio, sin historial heredado.
**Encontrado:** hoy vive en `PFM/docs/corregido/` dentro de un repositorio de material
de curso. La corrección del tutor exige repositorio dedicado.
**Probado:** nada. Es una acción de cara al exterior (creación de repositorio remoto,
purga de historial y rotación de credenciales) que requiere confirmación explícita del
usuario y no se ejecuta de forma autónoma.
**Accion tomada:** pendiente de ejecución manual. Pasos exactos:

1. Crear un repositorio nuevo y vacío, dedicado solo al PFM.
2. Copiar el contenido de `PFM/docs/corregido/` a la raíz del nuevo repositorio
   (sin `output/` ni `.env`).
3. `git init` y primer commit limpio. No importar el historial del repositorio actual.
4. En el repositorio actual, purgar del historial las versiones antiguas de las
   entregas 2 y 3 que contienen IPs y nombres de base de datos
   (`git filter-repo` o BFG).
5. Rotar las credenciales de acceso a la base de datos si siguen activas.

**Fase:** 7
**Estado:** abierto — requiere acción del usuario

## B-004 · El modelo no alcanza el umbral de mejora del Gate 5

**Esperado:** MAE de M2 al menos un 10 % mejor que el de B1 en el test temporal.
**Encontrado:** M2 obtiene 15,50 min frente a los 16,37 min de B1, una mejora del
5,31 %. El criterio secundario sí se cumple: M2 mejora a B1 en 4 de 4 folds de
GroupKFold, con ganancias entre 1,66 % y 2,77 %.
**Probado:** el bucle de mejora agotó los 5 intentos previstos (agrupar procesos poco
frecuentes, features de carga de campaña, ajuste de hiperparámetros, target encoding
por cliente ajustado por fold, recorte de cola al P99 solo en train). La mejor variante
en validación interna fue el ajuste de hiperparámetros (MAE de validación 11,26 min
frente a los 11,53 min de B1, un 2,28 %). El target encoding por cliente empeoró la
validación en un 5,31 %.
**Accion tomada:** se para el bucle según el criterio declarado antes de abrirlo y se
documenta el resultado negativo en `output/05_modelos.md`, sección 9, con las tres
cifras que lo explican (ratio P99/mediana = 30,8; deriva del P99 de 143,7 a 189,9 min
entre train y test; 11,71 % de horas sin negociación y 21,74 % de negociaciones
cerradas con 0 minutos). No se ha tocado el test, ni filtrado casos difíciles, ni
reajustado el baseline. El proyecto continúa a la Fase 6 con este modelo.
**Fase:** 5
**Estado:** asumido como limitación

## B-005 · No hay cadena de generación de PDF en esta máquina

**Esperado:** generar `Entrega_4_Estimacion_De_La_Duracion_De_Procesos.pdf` desde el
markdown, según el procedimiento de la sección 4.6 de la guía.
**Encontrado:** no están instalados `pandoc`, `xelatex`, `pdflatex`, `wkhtmltopdf`,
`libreoffice`/`soffice` ni el módulo `weasyprint`.
**Probado:** `Get-Command` sobre los seis ejecutables e `import weasyprint`; los siete
fallan.
**Accion tomada:** no se bloquea el proyecto. El markdown queda terminado en
`docs/entregas/04_estimacion_duracion_procesos.md` y es la fuente de verdad. No se ha
sustituido `pandoc` por otro conversor improvisado, porque produciría un documento con
otro formato y la convención de la sección 4.3 pide que el PDF se genere desde el
markdown con ese procedimiento. Comando exacto a ejecutar cuando se instale la cadena,
desde `PFM/docs/corregido/`:

```
pandoc docs/entregas/04_estimacion_duracion_procesos.md \
  -o Entrega_4_Estimacion_De_La_Duracion_De_Procesos.pdf \
  --pdf-engine=xelatex \
  --toc \
  -V lang=es \
  -V geometry:margin=2.5cm \
  -V mainfont="DejaVu Serif" \
  -V monofont="DejaVu Sans Mono"
```

Después de generarlo hay que extraer su texto y pasarle la comprobación de la sección
7.3, como indica 4.6.

**Actualización:** instalados `pandoc` (winget, `JohnMacFarlane.Pandoc`) y `MiKTeX`
(winget, `MiKTeX.MiKTeX`). Al ejecutar el comando de 4.6 con las fuentes DejaVu,
`xelatex` no las encuentra instaladas en el sistema (D-014): se sustituyen por
`mainfont="Georgia"` y `monofont="Consolas"`, ambas preinstaladas en Windows. PDF
generado: `Entrega_4_Estimacion_De_La_Duracion_De_Procesos.pdf` (15 páginas). Texto
extraído y pasado por la comprobación 7.3: 0 IPs, 0 coincidencias de credenciales.
**Fase:** 7
**Estado:** resuelto

## B-006 · Validación ciega con experto sin respuesta

**Esperado:** contraste del marcado de anomalías contra el criterio de un experto.
**Encontrado:** el archivo `output/validacion_experto.csv` está generado con los 40
casos (20 marcados y 20 normales, mezclados con `random_state=42`, sin la columna de
predicción ni la de z), pero los veredictos están vacíos.
**Probado:** nada más. Depende de una persona, no de los datos.
**Accion tomada:** el experto devolvió `output/validacion_experto_relleno.csv` con los
40 veredictos. Acuerdo del 52,6 % sobre los 38 casos usables (2 `no_se` descartados),
precisión 42,1 %, recall 53,3 %. Los 18 desacuerdos se concentran en dos causas
medidas: 11 casos donde el modelo marca exceso y el experto lo considera razonable por
complejidad del caso (sin feature disponible que la capture antes de ejecutar el
proceso), y 7 casos muy cortos donde el experto marca infraimputación y la definición
en minutos no puede marcar por defecto por construcción (confirma D-013). Detalle
completo en `output/06_anomalias.md`, sección 5.1.
**Fase:** 6
**Estado:** resuelto
