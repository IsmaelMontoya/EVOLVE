# Prompt para Claude Code (VS Code, con acceso a la BD de Bitrix)

Fase 0-B — extracción y exportación del dataset. Copia todo lo que hay debajo de la línea.

---

Necesito **extraer y exportar a CSV** un dataset desde la base de datos de Bitrix para
mi proyecto fin de máster. Solo lectura: únicamente `SELECT`, no modifiques nada.

## Contexto

El trabajo de la asesoría está organizado en **negociaciones** (deals) de Bitrix,
repartidas en pipelines (categorías). Cada negociación es una ejecución concreta de un
proceso para un cliente: presentar un modelo 303 de un trimestre, cerrar una
contabilidad, etc.

El tiempo se imputa en **tareas** que cuelgan de la negociación mediante el campo
`UF_CRM_TASK`, cuyos valores tienen la forma `D_<id_deal>`. La cadena es:

```
b_tasks_elapsed_time → tarea → (UF_CRM_TASK = 'D_<id_deal>') → negociación → pipeline
```

Los deals tienen campos personalizados de lista, entre ellos **modelo presentado** y
**año / ejercicio**, que acabo de rellenar. Son las variables de tipo de proceso y de
período.

**La unidad de observación es la negociación**, no la tarea. La variable objetivo es el
tiempo total imputado en la negociación.

Ventana: **desde 2025-01-01**.

## Reglas obligatorias de seguridad

Los CSV los voy a analizar fuera de aquí. Por tanto:

- **Prohibido** exportar: nombres de empresa, NIF/CIF, nombres de contacto, direcciones,
  teléfonos, emails, nombres de empleado, títulos de tarea, y **el campo
  `COMMENT_TEXT` de las imputaciones** (puede contener datos de cliente).
- Identifica clientes y empleados **solo por su ID numérico** (`COMPANY_ID`, `USER_ID`).
- Los nombres de pipeline, etapa y valores de listas (303, 111, "Contabilidad externa"…)
  SÍ los quiero: son categorías de proceso, no datos personales.
- No escribas credenciales, IPs, hostnames ni nombres de base de datos en ningún
  archivo de salida ni en ningún comentario.

## Paso 1 — Localizar los campos

Antes de exportar, identifica en `b_user_field` (`ENTITY_ID = 'CRM_DEAL'`):

- el campo **modelo presentado**
- el campo **año / ejercicio**
- si existe, un campo de **trimestre / período**
- si existe, un campo de **tipo de renta**

Para los campos de tipo lista (`enumeration`), resuelve el ID a su texto usando
`b_user_field_enum` — **no exportes los IDs numéricos de enum**, exporta el valor
legible.

Dime qué nombres técnicos (`UF_CRM_...`) has encontrado para cada uno.

## Paso 2 — Exportar `deals.csv`

Una fila por **negociación** de cualquier pipeline creada o cerrada desde 2025-01-01.
Columnas:

| Columna | Contenido |
|---|---|
| `deal_id` | ID de la negociación |
| `pipeline_id` | `CATEGORY_ID` |
| `pipeline` | nombre del pipeline (`(cat N)` si no tiene nombre) |
| `proceso` | valor legible de *modelo presentado* (vacío si no aplica) |
| `ejercicio` | valor del campo año / ejercicio |
| `periodo` | trimestre o período si existe ese campo |
| `tipo_renta` | valor del campo de tipo de renta si existe |
| `cliente_id` | `COMPANY_ID` (solo el número) |
| `responsable_id` | `ASSIGNED_BY_ID` |
| `etapa_id` | `STAGE_ID` |
| `etapa` | nombre de la etapa |
| `semantica` | S = ganada, F = perdida, vacío = en curso |
| `cerrada` | `CLOSED` (Y/N) |
| `fecha_creacion` | `DATE_CREATE`, formato `YYYY-MM-DD` |
| `fecha_cierre` | `CLOSEDATE`, formato `YYYY-MM-DD` |
| `n_tareas` | tareas distintas con tiempo imputado en esta negociación |
| `n_imputaciones` | número de imputaciones |
| `n_empleados` | empleados distintos que han imputado |
| `minutos_total` | **suma de `SECONDS`/60 — esta es la variable objetivo** |
| `minutos_max_imputacion` | la imputación individual más grande, en minutos |
| `fecha_primera_imputacion` | `YYYY-MM-DD` |
| `fecha_ultima_imputacion` | `YYYY-MM-DD` |

Incluye **también** las negociaciones **sin** tiempo imputado, con `n_tareas`,
`n_imputaciones`, `n_empleados` y `minutos_total` a 0. Necesito saber cuántas hay: es
un dato de calidad, no ruido a filtrar.

## Paso 3 — Exportar `imputaciones.csv`

Una fila por imputación (`b_tasks_elapsed_time`) desde 2025-01-01, **solo** de las que
cuelgan de una negociación. Columnas:

`imputacion_id`, `deal_id`, `task_id`, `user_id`, `segundos`,
`fecha` (`CREATED_DATE` como `YYYY-MM-DD`)

Nada más. Sin `COMMENT_TEXT`, sin título de tarea.

## Paso 4 — Exportar `no_asignado.csv`

Resumen agregado del tiempo que **no** cuelga de ninguna negociación, por mes:

`anio_mes`, `n_imputaciones`, `horas`

Sin IDs. Solo quiero saber el volumen de trabajo que quedaría invisible al modelo.

## Paso 5 — Escribir un informe corto

Un archivo `RESUMEN_extraccion.md` con:

1. Los nombres técnicos de los campos que has localizado en el paso 1.
2. Número de filas de cada CSV.
3. Tabla: por pipeline → negociaciones totales, cuántas cerradas, cuántas con tiempo
   imputado, horas totales.
4. Tabla: para el pipeline de Modelos de impuestos → por valor de *proceso*,
   número de negociaciones cerradas con tiempo, y mediana de `minutos_total`.
5. Porcentaje de horas que no cuelgan de ninguna negociación.
6. Sección **"Avisos"**: campos que esperaba y no existen, valores de lista raros o
   vacíos, negociaciones con `minutos_total` sospechosamente alto o a 0, y cualquier
   cosa que contradiga lo que he descrito arriba.

## Formato y ubicación

- Todos los archivos en `PFM/docs/corregido/output/`
- CSV con separador `,`, codificación UTF-8, primera fila de cabeceras, fechas
  `YYYY-MM-DD`, decimales con punto.
- Guarda las consultas SQL usadas en `PFM/docs/corregido/sql/B_extraccion.sql`.

No interpretes los resultados, no propongas modelos y no entrenes nada. Solo extrae,
exporta y reporta.
