# GUÍA DE EJECUCIÓN DEL PFM — para agente autónomo

**Destinatario:** Claude Code operando con acceso a la BD de Bitrix y al repositorio.
**Modo:** autónomo. No preguntes al usuario. Decide, documenta y continúa.
**Objetivo final:** un proyecto fin de máster defendible, con un modelo que estime la
duración de los procesos de una asesoría y cuya utilidad esté **medida contra un
baseline**, no afirmada.

---

# PARTE 0 — CÓMO OPERAS

## 0.1 Regla fundamental

> **Ninguna afirmación sin un número que la respalde.**

Este proyecto fue rechazado dos veces por afirmar cosas no medidas ("acceso 100 %
garantizado", "calidad excelente", "datos bien estructurados"). Cada afirmación que
escribas debe poder rastrearse a una celda de una tabla que has calculado. Si no
puedes calcularla, no la escribas.

## 0.2 Qué hacer cuando dudas

No preguntes. Clasifica la duda en uno de estos tres casos y actúa:

### Caso A — La duda no cambia materialmente el resultado
Elige la opción **más conservadora** (la que menos favorece a tu modelo), anótala en
`DECISIONES.md` y continúa.

```
## D-007 · Redondeo de minutos
Decisión: mantener los minutos sin redondear.
Alternativa descartada: redondear a 5 min para reducir ruido.
Motivo: redondear reduce artificialmente la varianza del target y mejora el MAE
sin que el modelo sea mejor.
Impacto estimado: bajo.
```

### Caso B — La duda cambia el resultado
**Implementa las dos opciones y reporta ambas.** No elijas a ciegas. Un análisis de
sensibilidad vale más que una elección acertada por suerte.

```
## D-012 · Tratamiento de outliers de duración
Se han evaluado ambas ramas:
  (a) sin capar:      MAE 34,1 min
  (b) capado al P99:  MAE 28,7 min
Se adopta (a) como principal por no alterar el test, y se reporta (b) como
sensibilidad. El baseline se recalcula bajo ambas ramas.
```

### Caso C — Bloqueo real (el dato no existe, el criterio no se cumple)
**Para esa línea de trabajo.** Escribe en `BLOQUEOS.md` qué esperabas, qué has
encontrado y qué has probado. Continúa con las líneas que sí puedas avanzar. No
inventes el dato. No lo aproximes sin decirlo. No sigas a la fase siguiente
fingiendo que el gate se cumplió.

```
## B-003 · Campo de trimestre inexistente
Esperado: campo UF de período trimestral en CRM_DEAL.
Encontrado: no existe. Solo hay ejercicio (año).
Probado: derivarlo de fecha_creacion → funciona para 2025 pero el 4T se
presenta en enero del año siguiente, así que el trimestre natural no coincide
con el trimestre fiscal.
Acción tomada: se deriva trimestre_fiscal con la regla documentada en D-009 y
se marca la columna como `derivada`.
```

## 0.3 Criterios de parada

Cada fase tiene un **gate numérico** al final. No pases de fase sin evaluarlo y
escribir el resultado. Si el gate falla:

1. Regístralo en `BLOQUEOS.md`.
2. Aplica el plan de contingencia que la propia fase indica.
3. Si no hay contingencia posible, para y deja el proyecto en el último estado válido,
   con un informe de por qué.

**Nunca iteres sin criterio de parada.** Cada bucle de mejora que abras debe tener
declarado de antemano: qué métrica mira, qué umbral busca y cuántos intentos máximo.

## 0.4 Seguridad — no negociable

- **Solo `SELECT`** contra Bitrix. Ninguna escritura, ningún DDL.
- **Nunca** escribas IPs, hostnames, puertos, usuarios, contraseñas ni nombres de base
  de datos en ningún archivo del repositorio, ni en comentarios, ni en notebooks. Las
  credenciales van en `.env`, que está en `.gitignore`.
- **Nunca** exportes ni escribas: nombres de empresa, NIF/CIF, nombres de contacto,
  direcciones, teléfonos, emails, nombres de empleado, títulos de tarea, ni el campo
  `COMMENT_TEXT` de las imputaciones.
- Clientes y empleados se identifican **solo por ID numérico**.
- Sí puedes usar y publicar: nombres de pipeline, nombres de etapa y valores de listas
  (303, 111, "Contabilidad externa"…). Son categorías de proceso, no datos personales.
- Antes de cada commit, ejecuta la comprobación de la sección 7.3.

## 0.5 Higiene de trabajo

- Un commit por fase completada, con el informe de la fase incluido.
- Los scripts son numerados y **reejecutables de cero**: `python src/NN_nombre.py` debe
  reproducir su salida sin pasos manuales.
- Nada de notebooks como única fuente de verdad. Lógica en `src/`, notebooks solo para
  explorar y mostrar.
- Fija `random_state=42` en todo lo que tenga aleatoriedad.
- Al terminar una fase, el contexto de esa fase ya no hace falta: cierra y empieza la
  siguiente limpia, releyendo esta guía y los informes ya escritos.

---

# PARTE 1 — CONTEXTO DEL PROYECTO

## 1.1 Qué se construye

Un modelo que estima **cuántos minutos lleva ejecutar un proceso de asesoría**, a
partir de las características del proceso y del cliente, conocidas antes de empezarlo.

De ese mismo modelo salen dos usos:

| Uso | Momento | Cómo |
|---|---|---|
| **Planificación** | Antes de ejecutar | La predicción estima la carga |
| **Control / anomalías** | Al cerrar la campaña | El residuo estandarizado señala lo anómalo |

**La detección de anomalías no es un segundo modelo.** Es el residuo del primero. Si
el modelo estima 42 min y se han imputado 190, ese residuo es la señal. Cualquier
propuesta de entrenar un Isolation Forest aparte contradice el alcance acordado.

## 1.2 Por qué el proyecto está planteado así

Versiones anteriores fueron rechazadas por el tutor. Los motivos, y cómo los resuelve
este planteamiento:

| Crítica recibida | Cómo se resuelve |
|---|---|
| Abarcaba predicción + anomalías + segmentación a la vez | Una sola línea: duración. Anomalía = residuo |
| Extrapolar a 2027 con 19 meses de histórico | Ya no es un problema temporal: es regresión transversal |
| Unidad cliente × mes, muy pocos puntos por cliente | Unidad = negociación. Cada ejecución es una observación |
| Afirmaciones sin validar sobre calidad y acceso | Fase 1 mide la calidad antes de afirmar nada |
| No demostraba mejorar un análisis sencillo | Baseline obligatorio y comparación explícita |
| Sin plan anti-leakage | Split temporal + GroupKFold por cliente, especificados abajo |
| IPs y nombres de BD en el repositorio | Sección 0.4 |

## 1.3 Alcance

**MVP: pipeline "Modelos de impuestos".** Solo ese. Variable de tipo de proceso: el
campo *modelo presentado*.

Elegido porque tiene etiqueta nativa y limpia, seis campañas trimestrales en el
histórico (permite split temporal 2025 → 2026) y muchas repeticiones por clase.

| Ámbito | Estado |
|---|---|
| Modelos de impuestos | **MVP** |
| Contabilidad (Contable interno · Contabilidad externa · Cierres) | Extensión 1 — demuestra que el método se transfiere |
| Rentas | Extensión 2 — solo 2 campañas, no admite validación temporal |
| Resto de pipelines | Fuera |

**Principio de diseño:** el código no sabe con qué pipeline trabaja. Recibe un pipeline
y el nombre de la columna de tipo de proceso como parámetros. Si tienes que tocar la
lógica para pasar de impuestos a contabilidad, está mal escrita.

---

# PARTE 2 — MODELO DE DATOS

## 2.1 La cadena

```
b_tasks_elapsed_time          imputación de tiempo
        │  TASK_ID
        ▼
b_utm_task                     campo UF_CRM_TASK, VALUE = 'D_<id_deal>'
        │  SUBSTRING(VALUE, 3)
        ▼
b_crm_deal                     la negociación = una ejecución de un proceso
        │  CATEGORY_ID
        ▼
b_crm_deal_category            el pipeline
```

**La unidad de observación es la negociación.** No la tarea, no la imputación, no el
cliente × mes.

## 2.2 Tablas y campos

### `b_tasks_elapsed_time` — imputaciones de tiempo
| Campo | Uso |
|---|---|
| `ID` | identificador de la imputación |
| `TASK_ID` | enlace a la tarea |
| `USER_ID` | empleado que imputa |
| `SECONDS` | **base de la variable objetivo**. Filtrar `> 0` |
| `MINUTES` | redundante con SECONDS; no usar |
| `CREATED_DATE` | fecha de imputación — la que se usa para agrupar |
| `DATE_START` / `DATE_STOP` | poco fiables, son manuales. No usar sin validar |
| `COMMENT_TEXT` | **prohibido** exportar o leer al informe |

### `b_utm_task` — puente tarea ↔ CRM
| Campo | Uso |
|---|---|
| `VALUE_ID` | el `TASK_ID` |
| `FIELD_ID` | apunta al campo `UF_CRM_TASK` en `b_user_field` |
| `VALUE` | `'D_123'` = deal 123 · `'CO_45'` = company · `'C_9'` = contact |

Extracción del id de deal: `CAST(SUBSTRING(VALUE, 3) AS UNSIGNED)` filtrando
`VALUE LIKE 'D\_%'`.

Ojo: una tarea puede tener **varios** enlaces CRM. Si una tarea apunta a más de un
deal, no dupliques su tiempo — decide una regla (p. ej. descartar esas tareas) y
documéntala. Mide primero cuántas hay.

### `b_crm_deal` — negociaciones
| Campo | Uso |
|---|---|
| `ID` | `deal_id` |
| `CATEGORY_ID` | pipeline. **El embudo "General" es 0 y no está en `b_crm_deal_category`** |
| `STAGE_ID` | etapa; se cruza con `b_crm_status` |
| `CLOSED` | `'Y'` / `'N'` |
| `DATE_CREATE` | inicio del proceso |
| `CLOSEDATE` | fin del proceso |
| `COMPANY_ID` | `cliente_id` — **solo el número, nunca el nombre** |
| `ASSIGNED_BY_ID` | responsable |
| `UF_CRM_*` | campos personalizados: modelo presentado, ejercicio, etc. |

### `b_crm_deal_category` — pipelines
`ID`, `NAME`, `SORT`.

### `b_crm_status` — etapas
Filtrar `ENTITY_ID LIKE 'DEAL_STAGE%'`. Campos: `STATUS_ID`, `NAME`, `SORT`,
`SEMANTICS` (`S` = ganada, `F` = perdida, `NULL` = en curso).

### `b_user_field` / `b_user_field_enum` / `b_user_field_lang`
Definición de campos personalizados. Para `ENTITY_ID = 'CRM_DEAL'` localiza:

- **modelo presentado** → variable de tipo de proceso (el usuario la rellenó en 2026-08)
- **ejercicio / año** → período fiscal (también rellenada en 2026-08)
- **trimestre / período** → si existe
- **tipo de renta** → para la extensión 2

Los campos de tipo `enumeration` guardan el **ID del enum**, no el texto. Resuélvelo
siempre contra `b_user_field_enum` y trabaja con el **valor legible**. Nunca modeles
sobre IDs de enum: son opacos y cambian.

Los valores de los campos UF de deals viven en la tabla de user-types de la entidad
(típicamente `b_uts_crm_deal`). Localízala y confirma antes de asumirlo.

---

# PARTE 3 — FASES

Cada fase: entrada, trabajo, salida y **gate**.

---

## FASE 1 — Extracción

**Entrada:** acceso a Bitrix.
**Script:** `src/01_extraccion.py` · **SQL:** `sql/B_extraccion.sql`

### Trabajo

Localiza primero los campos UF del paso 2.2 y escribe sus nombres técnicos en
`output/RESUMEN_extraccion.md`. Después exporta:

**`output/deals.csv`** — una fila por negociación de cualquier pipeline, creada o
cerrada desde 2025-01-01:

```
deal_id, pipeline_id, pipeline, proceso, ejercicio, periodo, tipo_renta,
cliente_id, responsable_id, etapa_id, etapa, semantica, cerrada,
fecha_creacion, fecha_cierre,
n_tareas, n_imputaciones, n_empleados,
minutos_total, minutos_max_imputacion,
fecha_primera_imputacion, fecha_ultima_imputacion
```

Incluye **también** las negociaciones sin tiempo imputado, con los contadores a 0. Son
un dato de calidad, no ruido a filtrar.

**`output/imputaciones.csv`** — una fila por imputación con deal asociado:

```
imputacion_id, deal_id, task_id, user_id, segundos, fecha
```

Nada más. Sin comentarios, sin títulos.

**`output/no_asignado.csv`** — agregado mensual del tiempo sin negociación:

```
anio_mes, n_imputaciones, horas
```

### Gate 1

| Criterio | Umbral | Si falla |
|---|---|---|
| `deals.csv` tiene filas del pipeline de impuestos | > 0 | Bloqueo: revisar `CATEGORY_ID` y nombres reales |
| Negociaciones cerradas con `minutos_total > 0` en impuestos | ≥ 500 | Si 200–500: sigue pero declara la limitación. Si < 200: pasa el MVP a Contabilidad y regístralo |
| Valores distintos de `proceso` con ≥ 30 casos | ≥ 3 | Si no: agrupa modelos poco frecuentes en `OTROS` y sigue |
| Horas que no cuelgan de ninguna negociación | < 40 % | Si ≥ 40 %: sigue, pero es una limitación de sesgo de selección que va en la memoria |

---

## FASE 2 — Calidad y EDA

**Entrada:** los tres CSV.
**Script:** `src/02_eda.py` · **Informe:** `output/02_informe_calidad.md`

### Trabajo

Mide, no opines. Como mínimo:

1. **Cobertura**: negociaciones con tiempo vs sin tiempo, por pipeline y por año.
2. **Sesgo de redondeo del target** — sobre `imputaciones.csv`, reparto en múltiplos
   exactos de 60 / 30 / 15 / 5 minutos y valores no redondos, en n y en %.
   *Este número es el suelo del error alcanzable y va en la memoria como limitación.*
3. **Distribución de `minutos_total`** por proceso: n, mediana, P25, P75, P90, P99, máx,
   y ratio P99/mediana. Confirma la cola larga.
4. **Censura**: reparto por `semantica` y por `cerrada`. Cuántas se descartan.
5. **Estacionalidad**: negociaciones cerradas por trimestre natural, por proceso.
   Confirma que se ven las campañas.
6. **Concentración por empleado**: negociaciones por `user_id`; cuántos empleados con
   < 30 negociaciones.
7. **Multi-empleado**: % de negociaciones con más de un empleado imputando.
8. **Desfase**: días entre `fecha_creacion` y `fecha_cierre`, y entre primera y última
   imputación.
9. **Coherencia**: negociaciones con `minutos_total` a 0 pero cerradas; con duración
   superior a 8 h; con imputaciones fuera de la ventana del deal.
10. **Nulos** en cada columna, en %.

Figuras a `output/figuras/`: histograma de `log1p(minutos_total)`, boxplot por proceso,
serie temporal de negociaciones cerradas por mes, barras del sesgo de redondeo.

### Gate 2

| Criterio | Umbral | Si falla |
|---|---|---|
| Imputaciones no redondas | > 10 % | Si ≤ 10 %: el target es casi ordinal. Sigue, pero añade a la memoria que el techo del modelo está limitado por la granularidad de la imputación |
| Ratio P99 / mediana | se reporta siempre | Si > 10, confirma el uso de `log1p` y MAE |
| Al menos un proceso con ≥ 100 casos cerrados | sí | Si no: agrupa procesos hasta conseguirlo |

---

## FASE 3 — Dataset modelable

**Entrada:** CSV crudos + informe de calidad.
**Script:** `src/03_dataset.py` · **Salida:** `output/dataset_modelo.parquet` +
`output/03_diccionario_datos.md`

### Filtros de inclusión — documenta cuántas filas cae en cada uno

1. `pipeline == "<pipeline objetivo>"` (parámetro, por defecto Modelos de impuestos)
2. `cerrada == 'Y'`
3. `semantica == 'S'` (ganada). Las perdidas se excluyen y se cuenta cuántas son.
4. `minutos_total > 0`
5. `proceso` no vacío
6. Tarea con enlace a un único deal (ver 2.2)

**No elimines outliers del conjunto de test.** Si capas, capa solo en train y reporta
ambas ramas (Caso B de la sección 0.2).

### Variable objetivo

```python
y = np.log1p(df["minutos_total"])
```

Todas las métricas se reportan **en minutos**, deshaciendo la transformación:
`np.expm1(pred)`. Nunca reportes un MAE en escala logarítmica: no significa nada
para un asesor.

### Features — modelo de PLANIFICACIÓN (el principal)

Solo lo conocido **antes** de ejecutar el proceso.

| Feature | Tipo | Notas |
|---|---|---|
| `proceso` | categórica | modelo presentado |
| `ejercicio` | numérica | |
| `trimestre_fiscal` | categórica | derivar si no existe; documentar la regla |
| `mes_creacion` | categórica | 1–12 |
| `dias_desde_alta_cliente` | numérica | si hay fecha de alta |
| `n_procesos_previos_cliente` | numérica | **ver regla anti-leakage** |
| `mediana_min_cliente_hist` | numérica | **ver regla anti-leakage** |
| `mediana_min_proceso_hist` | numérica | **ver regla anti-leakage** |
| `n_deals_misma_campana` | numérica | carga de esa campaña |
| `es_primera_vez_cliente_proceso` | binaria | |

### 🔴 REGLA ANTI-LEAKAGE — la más importante del proyecto

Toda feature histórica (`*_hist`, `n_procesos_previos_*`) se calcula **usando
exclusivamente negociaciones cuya `fecha_cierre` sea anterior a la `fecha_creacion` de
la fila que se está construyendo.** Ventana expansiva, nunca el dataset completo.

```python
# CORRECTO — ventana expansiva
hist = df[(df.cliente_id == fila.cliente_id) &
          (df.fecha_cierre < fila.fecha_creacion)]
valor = hist.minutos_total.median()

# INCORRECTO — usa el futuro, invalida todo el proyecto
valor = df[df.cliente_id == fila.cliente_id].minutos_total.median()
```

Las filas sin historial suficiente reciben `NaN`, **no la media global** — rellenar con
la media global es leakage encubierto. Los modelos de árboles gestionan `NaN` de forma
nativa; úsalo.

Aplica lo mismo a cualquier target encoding: se ajusta dentro de cada fold de train,
nunca sobre el conjunto completo.

**Prohibido como feature**: `minutos_max_imputacion`, `n_imputaciones`, `n_tareas`,
`n_empleados`, `fecha_ultima_imputacion`, `fecha_cierre`. Todas se conocen solo
*después* de ejecutar el proceso. Usarlas es leakage directo y hace que el modelo
parezca excelente y sea inútil.

### Features — modelo de CONTROL (secundario)

El de planificación **más**:

| Feature | Notas |
|---|---|
| `responsable_id` | como categórica; agrupa en `OTROS` los que tengan < 30 casos |
| `n_empleados` | |

Se entrena y reporta **por separado**, con una nota explícita en la memoria: sirve para
detectar anomalías de proceso, no para evaluar personas. Si `responsable_id` resulta ser
la feature dominante, dilo en el informe — es un hallazgo, no algo que ocultar.

### Gate 3

| Criterio | Umbral | Si falla |
|---|---|---|
| Filas tras filtros | ≥ 300 | Si < 300, amplía a un segundo pipeline y regístralo |
| Ninguna feature prohibida en el dataset | obligatorio | Bloqueo duro |
| Test de leakage: correlación de cada feature con el target dentro de train > 0.95 | ninguna | Si alguna, revísala: casi seguro es leakage |

---

## FASE 4 — Baselines

**Entrada:** dataset.
**Script:** `src/04_baselines.py` · **Informe:** `output/04_baselines.md`

Esto es lo que el tutor pidió expresamente: demostrar que el modelo mejora un análisis
sencillo. Los baselines se calculan **antes** que el modelo, para no ajustar el listón.

| Id | Baseline | Definición |
|---|---|---|
| **B0** | Mediana global | la mediana de train para todo |
| **B1** | **Mediana por proceso** | **el baseline a batir** |
| **B2** | Mediana por proceso × ejercicio | |
| **B3** | Mediana por proceso ajustada por cliente | mediana del proceso × (mediana histórica del cliente / mediana global del cliente) |

Todos se ajustan **solo con train** y se evalúan en test. Un baseline que mire el test
no es un baseline.

### Métricas — siempre en minutos

- **MAE** — métrica principal
- **MedAE** — robusta a la cola
- **% de predicciones dentro de ±15 min** y **dentro de ±30 min** — la métrica que un
  asesor entiende; inclúyela siempre
- **RMSE** solo informativo. No la uses para decidir: la cola la domina
- **MAPE** solo informativo, y advierte de su inestabilidad con valores pequeños

### Gate 4

Tabla completa de los cuatro baselines con las cinco métricas, en `04_baselines.md`.
B1 queda fijado como referencia para el resto del proyecto.

---

## FASE 5 — Modelado

**Entrada:** dataset + baselines.
**Script:** `src/05_modelos.py` · **Informe:** `output/05_modelos.md`

### Particiones

**Split temporal principal** (el que se reporta como resultado):
- train: negociaciones cerradas en 2025
- test: negociaciones cerradas en 2026

**Validación interna** para hiperparámetros, dentro de train:
`GroupKFold(n_splits=4, groups=cliente_id)`.

El agrupamiento por cliente evita que el mismo cliente aparezca a ambos lados. Sin él,
el modelo memoriza clientes y el resultado no vale.

Reporta **las dos**: la temporal como resultado principal, la GroupKFold como
estabilidad. Si divergen mucho, dilo — significa deriva temporal, y es un hallazgo.

### Modelos, en este orden

| Id | Modelo | Para qué |
|---|---|---|
| **M1** | Regresión lineal sobre `log1p` con one-hot | interpretable, referencia |
| **M2** | `HistGradientBoostingRegressor` | el candidato principal |
| **M3** | M2 con `loss="quantile"`, q = 0.1 / 0.5 / 0.9 | rangos en vez de puntos |

M3 importa: para planificar, "entre 25 y 70 minutos" es más honesto y más útil que
"42 minutos". Y la anchura del intervalo es en sí misma información.

### Bucle de mejora — con criterio de parada declarado

```
mientras (mejora_MAE_sobre_B1 < 10 %) y (intentos < 5):
    prueba la siguiente idea de la lista
    registra intento, cambio y MAE en 05_modelos.md
```

Lista de ideas, en orden: agrupar procesos poco frecuentes → añadir features de carga
de campaña → ajustar `max_iter` / `learning_rate` / `max_leaf_nodes` → target encoding
por cliente ajustado por fold → recortar la cola solo en train.

**Máximo 5 intentos.** Si al quinto no llegas al 10 %, **para**. Escribe que el modelo
no supera significativamente el baseline. Eso es un resultado válido y publicable: dice
que la duración de estos procesos está dominada por el tipo de proceso y que el resto
es ruido de imputación. Un PFM honesto con resultado negativo vale más que uno que
infla métricas.

**Prohibido** para conseguir el umbral: tocar el test, cambiar la definición del target,
filtrar casos difíciles, o reajustar los baselines a la baja.

### Explicabilidad

Importancia por permutación sobre test, y SHAP si el tiempo lo permite. Una figura con
las 10 features más influyentes y dos o tres casos individuales explicados.

### Gate 5

| Criterio | Umbral | Si falla |
|---|---|---|
| MAE de M2 vs B1 en test temporal | mejora ≥ 10 % | Documenta el resultado negativo y sigue a la fase 6 igualmente |
| Mejora sostenida en GroupKFold | ≥ 3 de 4 folds | Si no, declara el resultado inestable |
| Ninguna feature prohibida | obligatorio | Bloqueo duro |

---

## FASE 6 — Anomalías y validación con experto

**Entrada:** el modelo entrenado.
**Script:** `src/06_anomalias.py` · **Informe:** `output/06_anomalias.md`

### Definición

```python
residuo    = y_real_min - y_pred_min
sigma_proc = residuos_train.groupby("proceso").std()      # solo train
z          = residuo / df["proceso"].map(sigma_proc)
es_anomalia = z.abs() > 3
```

Reporta: tasa de marcado global y por proceso, y el reparto entre anomalías por exceso
(z > 3, se ha tardado mucho más de lo esperado) y por defecto (z < −3, sospecha de
infraimputación).

Si usas M3, un caso fuera del intervalo [q10, q90] es una definición alternativa. Compara
ambas y quédate con la que marque un volumen manejable — más de un 5 % de casos marcados
es inútil en la práctica.

### Validación ciega con experto

Genera `output/validacion_experto.csv` con **40 casos**: 20 marcados como anómalos y 20
normales, **mezclados y sin la columna de predicción**. Columnas: `deal_id`, `proceso`,
`ejercicio`, `minutos_total`, y una columna vacía `veredicto_experto` con valores
posibles `razonable` / `anomalo` / `no_se`.

Cuando el usuario devuelva el archivo relleno, calcula acuerdo, precisión y recall
frente al criterio experto, y añádelo al informe. Si no lo devuelve, deja la sección
preparada y anótalo como pendiente. No la inventes.

### Gate 6

Informe escrito con la tasa de marcado y el archivo de validación generado.

---

## FASE 7 — Documentación y entrega

**Salidas:** `docs/entregas/` + `README.md` actualizado.

> El **formato y el estilo** de la entrega están especificados en la PARTE 4. No los
> improvises: el tutor ya señaló el formato como un problema. Léela antes de escribir
> una sola línea de la memoria.

### Contenido obligatorio

1. **Problema y alcance** — por qué una sola línea, por qué este pipeline.
2. **Datos** — origen, unidad de observación, volumen, ventana. Sin datos internos.
3. **Calidad** — resultados de la fase 2, con el sesgo de redondeo en primer plano.
4. **Metodología** — target, features, la regla anti-leakage explicada, particiones.
5. **Baselines** — la tabla de la fase 4.
6. **Resultados** — modelo vs baseline, en minutos, con las dos particiones.
7. **Explicabilidad**.
8. **Anomalías** — definición, tasa, validación con experto.
9. **Limitaciones declaradas** — la sección de abajo, literal.
10. **Trabajo futuro** — extensión a contabilidad y rentas.

### Limitaciones que deben aparecer sí o sí

1. El target es **tiempo imputado manualmente**, no medido. El modelo aprende tanto el
   esfuerzo real como el hábito de imputación. El % de redondeo cuantifica ese ruido.
2. Solo se observan negociaciones **cerradas y ganadas**: el resto está censurado.
3. El trabajo que no cuelga de ninguna negociación queda invisible al modelo (dar el %).
4. El histórico cubre un número limitado de campañas; la validación temporal se apoya en
   las de 2026.
5. Los resultados son específicos de esta asesoría y no generalizan a otras.
6. El modelo de control incluye al responsable como variable. Su finalidad es detectar
   anomalías de proceso, no evaluar el desempeño de personas.

---

# PARTE 4 — CÓMO DOCUMENTAR Y CÓMO ENTREGAR

## 4.1 El formato es parte de la nota

Cita literal de la corrección recibida:

> *"Estos formatos funcionan como contratos de trabajo: permiten que otras personas y
> procesos encuentren y utilicen correctamente lo entregado."*

Y también:

> *"El trabajo está mezclado con muchas carpetas ajenas al proyecto; en las próximas
> entregas espero un repositorio independiente dedicado exclusivamente al PFM."*

Es decir: el contenido puede ser impecable y la entrega seguir estando mal. Trata esta
parte con el mismo rigor que el modelado.

## 4.2 Repositorio independiente — obligatorio

El proyecto vive hoy dentro de un repositorio de material de curso, mezclado con
carpetas ajenas. Hay que extraerlo.

**Procedimiento:**

1. Crea un repositorio **nuevo y vacío**, dedicado solo al PFM.
2. Copia el contenido de `PFM/docs/corregido/` a la raíz del nuevo repositorio.
3. `git init` y **primer commit limpio**.
4. **No importes el historial del repositorio anterior.** Contiene IPs y nombres de
   base de datos en versiones antiguas de las entregas 2 y 3. Traer el historial trae
   los secretos.

Esto resuelve dos críticas de golpe: repositorio dedicado y purga de datos internos.

Aparte, en el repositorio antiguo hay que purgar esos secretos del historial
(`git filter-repo` o BFG) y rotar credenciales si siguen activas. Es una tarea
independiente: regístrala en `BLOQUEOS.md` como pendiente si no la ejecutas tú.

## 4.3 Convención de nombres de entregas

Ya existe una convención en el proyecto. **Respétala, no inventes otra.**

| Fuente (markdown, versionado) | Entregable (PDF, para subir) |
|---|---|
| `docs/entregas/01_ideas_producto.md` | `Entrega_1_....pdf` |
| `docs/entregas/02_datos_necesarios.md` | `Entrega_2_Seleccion_de_idea_y_datos_necesarios.pdf` |
| `docs/entregas/03_modelo_datos.md` | `Entrega_3_Modelo_de_datos_y_capa_gold.pdf` |
| `docs/entregas/04_<tema>.md` | `Entrega_4_<Tema>.pdf` |

Reglas:

- El **markdown es la fuente de verdad** y es lo que se versiona.
- El **PDF es el entregable** que se sube. Se genera desde el markdown, nunca se edita
  a mano.
- Numeración de dos dígitos en el archivo fuente, correlativa.
- El nombre del PDF usa `Entrega_N_Titulo_En_Snake_Case.pdf`.
- Las entregas anteriores **no se reescriben**. Se añade la siguiente.

## 4.4 Estilo de redacción — reglas duras

Escribe como están escritos el `README.md` y los prompts de este proyecto.

**Prohibido sin un número al lado:**
`excelente` · `garantizado` · `robusto` · `potente` · `de calidad` · `escalable` ·
`óptimo` · `100 %` · `sin problemas` · `viable` como afirmación suelta

Esos adjetivos son exactamente los que provocaron la corrección. Si quieres decir que
los datos son buenos, escribe *"el 87 % de las negociaciones cerradas tienen tiempo
imputado"* y deja que el lector concluya.

**Obligatorio:**

- Cada afirmación cuantitativa lleva **el número y de dónde sale** (script o tabla).
- **Tablas** para comparar alternativas. No listas de marcas de verificación verdes:
  una tabla de ventajas sin contrapartidas es publicidad, no análisis.
- **Sin emojis.** Ni de check, ni de aviso, ni decorativos.
- Toda decisión metodológica dice **qué se descartó y por qué**. Si no hay alternativa
  descartada, no era una decisión.
- La sección de **limitaciones va completa y al final**, no diluida entre el texto.
  Las seis de la Fase 7 aparecen todas.
- Nada de "próximos pasos" vagos. Si es futuro, di qué medida lo desbloquearía.
- En el texto de la memoria, cifras en formato español (coma decimal, punto de miles).
  En código y CSV, punto decimal.
- **Nunca**: nombres de servidor, puertos, nombres de base de datos, nombres de cliente,
  NIF, nombres de empleado. Ni en el texto, ni en las figuras, ni en los pies de tabla.

## 4.5 La próxima entrega debe responder al feedback, punto por punto

Abre la entrega con esta tabla, antes de cualquier otra cosa. Rellena la tercera columna
con la sección o archivo concreto.

| Observación del tutor | Qué se ha cambiado | Dónde verlo |
|---|---|---|
| Abarcaba predicción, anomalías y segmentación a la vez | Una sola línea: estimación de duración. La anomalía es el residuo del mismo modelo | § Alcance |
| 19 meses no permiten predecir 2027 | Se abandona la extrapolación temporal. Regresión transversal sobre procesos ejecutados | § Metodología |
| Muy pocos meses por cliente | La unidad pasa de cliente × mes a negociación | § Datos |
| Afirmar acceso garantizado y calidad excelente sin explorar | Fase de calidad ejecutada antes de la memoria, con cifras | § Calidad de datos |
| No demostraba mejorar un análisis sencillo | Baseline de mediana por proceso y comparación explícita | § Baselines |
| Sin plan contra el leakage temporal | Split temporal por campaña y GroupKFold por cliente; features históricas con ventana expansiva | § Validación |
| `pct_rentabilidad` rellenado con 0 e imputación de costes por medias | Métrica eliminada del alcance. Ya no se usa facturación ni costes | § Alcance |
| IPs y nombres de base de datos en el repositorio | Repositorio nuevo sin historial contaminado; conexiones por `.env` | § Seguridad |
| Trabajo mezclado con carpetas ajenas | Repositorio independiente dedicado solo al PFM | Raíz del repositorio |

Si alguna observación no se ha resuelto, **dilo en la tabla** con lo que falta. Una
casilla honesta pesa menos que un hueco.

## 4.6 Generación del PDF

Desde la raíz del repositorio:

```bash
pandoc docs/entregas/04_<tema>.md \
  -o Entrega_4_<Tema>.pdf \
  --pdf-engine=xelatex \
  --toc \
  -V lang=es \
  -V geometry:margin=2.5cm \
  -V mainfont="DejaVu Serif" \
  -V monofont="DejaVu Sans Mono"
```

Si `pandoc` o `xelatex` no están disponibles, no bloquees el proyecto: deja el markdown
terminado, anótalo en `BLOQUEOS.md` y sigue.

**Después de generar el PDF**, extrae su texto y busca en él los patrones de la sección
7.3. Un PDF es tan filtrable como un `.md`.

## 4.7 Checklist antes de subir

No subas nada hasta que todo esto esté marcado. Escribe el resultado en
`output/07_checklist_entrega.md`.

**Repositorio**
- [ ] Es un repositorio independiente que contiene **solo** el PFM
- [ ] Sin historial heredado del repositorio de curso
- [ ] `.gitignore` cubre `.env`, `output/`, `*.csv`, `*.parquet`, `*.pkl`
- [ ] `git ls-files` no devuelve ningún `.env`, CSV, parquet ni modelo serializado
- [ ] `README.md` explica en qué consiste el proyecto y cómo reproducirlo de cero
- [ ] `requirements.txt` con versiones fijadas

**Seguridad**
- [ ] Ejecutada la comprobación de la sección 7.3 sobre el árbol de trabajo
- [ ] Ejecutada también sobre el historial (`git log -p`)
- [ ] Ejecutada sobre el texto extraído del PDF
- [ ] Ninguna figura contiene nombres de cliente ni de empleado

**Contenido**
- [ ] Entrega numerada según 4.3, markdown y PDF
- [ ] Tabla de respuesta al feedback (4.5) al principio
- [ ] Las seis limitaciones de la Fase 7, completas
- [ ] Tabla de baselines con las cinco métricas
- [ ] Resultado del modelo frente a B1, en minutos, con ambas particiones
- [ ] Todo número del texto rastreable a un script de `src/`
- [ ] Cero adjetivos de la lista prohibida de 4.4

**Reproducibilidad**
- [ ] Cada `src/NN_*.py` se ejecuta de cero sin pasos manuales
- [ ] `random_state=42` en todo lo aleatorio
- [ ] Todas las figuras referenciadas en el texto existen en `output/figuras/`
- [ ] `DECISIONES.md` y `BLOQUEOS.md` al día

---

# PARTE 5 — ESTRUCTURA DEL REPOSITORIO

```
PFM/docs/corregido/
├── README.md                     documento contrato — mantener al día
├── GUIA_AGENTE.md                esta guía
├── DECISIONES.md                 registro de decisiones (D-001, D-002…)
├── BLOQUEOS.md                   registro de bloqueos (B-001, B-002…)
├── .env.example
├── .gitignore                    .env, output/, *.csv, *.parquet
├── requirements.txt
├── Entrega_4_<Tema>.pdf          entregable generado desde el markdown
├── sql/
│   ├── A_00_descubrimiento.sql
│   └── B_extraccion.sql
├── src/
│   ├── 01_extraccion.py
│   ├── 02_eda.py
│   ├── 03_dataset.py
│   ├── 04_baselines.py
│   ├── 05_modelos.py
│   └── 06_anomalias.py
├── output/                       NO se versiona
│   ├── deals.csv
│   ├── imputaciones.csv
│   ├── no_asignado.csv
│   ├── dataset_modelo.parquet
│   ├── figuras/
│   ├── 02_informe_calidad.md
│   ├── 03_diccionario_datos.md
│   ├── 04_baselines.md
│   ├── 05_modelos.md
│   ├── 06_anomalias.md
│   └── validacion_experto.csv
└── docs/
    ├── PROMPT_descubrimiento.md
    ├── PROMPT_extraccion.md
    └── entregas/
        ├── 01_ideas_producto.md
        ├── 02_datos_necesarios.md
        ├── 03_modelo_datos.md
        └── 04_<tema>.md          la nueva entrega
```

---

# PARTE 6 — RESUMEN OPERATIVO

Trabaja en este orden. No saltes fases. Evalúa el gate antes de avanzar.

```
F1 extracción     → gate: hay datos suficientes del pipeline objetivo
F2 calidad y EDA  → gate: el target tiene variabilidad utilizable
F3 dataset        → gate: sin features prohibidas, sin leakage
F4 baselines      → gate: B1 fijado como referencia
F5 modelos        → gate: ≥10 % sobre B1, o resultado negativo documentado
F6 anomalías      → gate: tasa de marcado e informe
F7 memoria        → gate: PARTE 4 completa y checklist 4.7 sin casillas vacías
```

## 7.3 Comprobación antes de cada commit

Busca en todo lo que vayas a versionar, y aborta el commit si aparece algo:

- patrones de IP `\d+\.\d+\.\d+\.\d+`
- las cadenas `password`, `passwd`, `pwd=`, `sitemanager`, `biloop`
- extensiones `.csv`, `.parquet`, `.pkl` fuera de `.gitignore`
- el archivo `.env`
- columnas con nombres de empresa, NIF o nombres de personas en cualquier salida

## Las seis reglas que no puedes romper

1. **Ninguna afirmación sin un número detrás.**
2. **Ninguna feature que se conozca después de ejecutar el proceso.**
3. **Ningún cálculo histórico que mire más allá de `fecha_creacion` de la fila.**
4. **Ningún bucle de mejora sin criterio de parada declarado antes de empezarlo.**
5. **Ningún dato interno ni personal en el repositorio, ni en su historial, ni en el PDF.**
6. **Ninguna entrega que no respete la convención de nombres y el estilo de la PARTE 4.**

Un resultado negativo bien medido supera a un resultado positivo mal medido. Si el
modelo no bate al baseline, dilo con claridad y explica por qué — eso también es el
proyecto.
