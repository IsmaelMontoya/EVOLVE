---
title: "Estimación de la duración de procesos en una asesoría"
subtitle: "Entrega 4 — Modelo, baselines y detección de anomalías"
lang: es
---

# Respuesta al feedback de las entregas 2 y 3

| Observación del tutor | Qué se ha cambiado | Dónde verlo |
|---|---|---|
| Abarcaba predicción, anomalías y segmentación a la vez | Una sola línea: estimación de duración. La anomalía es el residuo del mismo modelo, no un modelo aparte | § 1 Problema y alcance; § 8 Anomalías |
| 19 meses no permiten predecir 2027 | Se abandona la extrapolación temporal. Regresión transversal: una negociación ejecutada es una observación | § 1 Problema y alcance; § 4 Metodología |
| Muy pocos meses por cliente | La unidad pasa de cliente × mes a negociación. 13.013 observaciones sobre 1.036 clientes | § 2 Datos |
| Afirmar acceso garantizado y calidad excelente sin explorar | Fase de calidad ejecutada antes de escribir la memoria, con cifras. El 21,74 % de las negociaciones cerradas del pipeline tiene 0 minutos imputados y el 11,71 % de las horas no cuelga de ninguna negociación | § 3 Calidad de datos |
| No demostraba mejorar un análisis sencillo | Cuatro baselines calculados antes que el modelo. B1 (mediana por proceso) fijado como referencia: MAE 16,37 min. El modelo mejora un 5,31 %, por debajo del 10 % que se había fijado como umbral, y así se reporta | § 5 Baselines; § 6 Resultados |
| Sin plan contra el leakage temporal | Split temporal por campaña (cierres de 2025 frente a cierres de 2026) y GroupKFold(4) por cliente. Features históricas con ventana expansiva estricta | § 4.3 Validación y regla anti-leakage |
| `pct_rentabilidad` rellenado con 0 e imputación de costes por medias | Métrica eliminada del alcance. No se usa facturación ni costes en ninguna parte del proyecto | § 1 Problema y alcance |
| IPs y nombres de base de datos en el repositorio | Todas las conexiones por `.env`, que no se versiona. Comprobación automática antes de cada commit (`src/_check_seguridad.py`) sobre lo que se va a versionar | § 10.2 Seguridad |
| Trabajo mezclado con carpetas ajenas | **No resuelto todavía.** El material está preparado para extraerse a un repositorio dedicado, pero la creación del repositorio nuevo y la purga del historial antiguo son acciones pendientes de ejecución manual, registradas con los pasos exactos | `BLOQUEOS.md`, B-003 |

La última fila queda abierta a propósito. El contenido está listo para moverse, pero el
repositorio independiente no existe aún.

---

# 1. Problema y alcance

## 1.1 Qué se estima

Cuántos minutos lleva ejecutar un proceso de asesoría, a partir de características del
proceso y del cliente conocidas **antes** de empezarlo.

Del mismo modelo salen dos usos:

| Uso | Momento | Cómo |
|---|---|---|
| Planificación | Antes de ejecutar | La predicción estima la carga de trabajo |
| Control | Al cerrar la campaña | El residuo estandarizado señala lo anómalo |

La detección de anomalías no es un segundo modelo. Si el modelo estima 24 min para un
proceso y se han imputado 1.004, ese residuo es la señal. No se entrena ningún
detector independiente.

## 1.2 Por qué una sola línea

Las versiones anteriores del proyecto abarcaban predicción de rentabilidad, detección
de anomalías y segmentación de clientes a la vez, y planteaban la predicción como un
problema temporal: extrapolar a 2027 con 19 meses de histórico y con la unidad de
observación cliente × mes.

Este planteamiento cambia las tres cosas:

| Antes | Ahora | Efecto medible |
|---|---|---|
| Tres líneas simultáneas | Una: duración | La anomalía se calcula con el mismo modelo, sin ajustar nada aparte |
| Serie temporal a 2027 | Regresión transversal | Cada ejecución cerrada es una observación; no se extrapola fuera del rango observado |
| Unidad cliente × mes | Unidad negociación | 13.013 observaciones frente a agregados mensuales con pocos puntos por cliente |
| Bitrix y un segundo sistema de facturación | Solo el CRM | Se elimina la dependencia de costes y facturación, origen de la crítica sobre `pct_rentabilidad` |

## 1.3 Qué pipeline y por qué

El trabajo de la asesoría está organizado en negociaciones del CRM repartidas en
pipelines. El alcance de esta entrega es el pipeline **Modelos de impuestos**.

Razones, con las cifras que las sostienen:

| Criterio | Cifra |
|---|---|
| Etiqueta nativa del proceso, sin heurística de texto | El campo *Modelo presentado* del CRM tiene 52 valores de lista; 16.941 de las 17.223 negociaciones del pipeline lo tienen relleno (98,4 %) |
| Repeticiones suficientes por clase | 25 valores de proceso con 30 o más negociaciones cerradas con tiempo; el más frecuente tiene 3.943 |
| Permite validación temporal | 6.821 negociaciones cerradas en 2025 y 6.192 en 2026, seis campañas trimestrales en la ventana |

Qué queda fuera y por qué:

| Ámbito | Estado | Motivo |
|---|---|---|
| Contabilidad (Contabilidad Interna, Contabilidad Externa, Cierres) | Extensión 1 | Sirve para comprobar si el método se transfiere. Volumen disponible: 10.347,6 h imputadas frente a las 3.703,0 h del pipeline objetivo |
| Rentas | Extensión 2 | Solo dos campañas (2025 y 2026). Una campaña es un único bloque temporal: no admite validación en el tiempo |
| Resto de pipelines | Fuera | — |

El código recibe el pipeline y el nombre de la columna de tipo de proceso como
parámetros (`PIPELINE_OBJETIVO` en `src/01_extraccion.py`, `src/02_eda.py` y
`src/03_dataset.py`). Ejecutarlo sobre contabilidad no requiere tocar la lógica.

---

# 2. Datos

## 2.1 Origen y cadena de enlace

Los datos provienen de la base de datos del CRM de la asesoría, en modo de solo
lectura. La cadena que conecta el tiempo con el proceso es:

```
imputación de tiempo  →  tarea  →  (campo UF_CRM_TASK = 'D_<id>')  →  negociación  →  pipeline
```

La tabla puente resultó llamarse `b_utm_tasks_task` y no `b_utm_task`, y el motor es
MySQL 5.7, sin soporte de expresiones `WITH` ni funciones de ventana. Ambas
discrepancias están registradas en `BLOQUEOS.md` (B-001 y B-002) y resueltas.

## 2.2 Unidad de observación

**Una negociación cerrada es una observación.** No la tarea, no la imputación
individual, no el cliente × mes. Cada negociación del pipeline es una ejecución
concreta de un proceso para un cliente: presentar un modelo 303 de un trimestre,
presentar un 200 de un ejercicio.

## 2.3 Volumen y ventana

Ventana de extracción: negociaciones creadas o cerradas desde el 1 de enero de 2025.

| Conjunto | Filas |
|---|---|
| Negociaciones de todos los pipelines | 30.836 |
| Imputaciones de tiempo con negociación asociada | 66.690 |
| Negociaciones del pipeline objetivo | 17.223 |
| Negociaciones del dataset modelable | 13.013 |
| Clientes distintos en el dataset modelable | 1.036 |
| Empleados distintos que imputan tiempo | 46 |
| Rango de fechas de cierre en el dataset | 3 de enero de 2025 a 25 de agosto de 2026 |

## 2.4 Variable objetivo

`minutos_total` = suma de los segundos imputados en las tareas de la negociación,
dividida entre 60. Se modela `log1p(minutos_total)` y todas las métricas se reportan en
minutos, deshaciendo la transformación con `expm1`.

## 2.5 Datos que no salen del sistema

Ningún archivo del repositorio contiene nombres de empresa, NIF, nombres de contacto,
direcciones, teléfonos, correos, nombres de empleado, títulos de tarea ni el texto de
los comentarios de las imputaciones. Clientes y empleados se identifican solo por
identificador numérico. Los nombres de pipeline, de etapa y los valores de lista (303,
111, 200, CCT) sí se usan: son categorías de proceso.

---

# 3. Calidad de datos

Todas las cifras de esta sección salen de `src/02_eda.py` y están en
`output/02_informe_calidad.md`.

## 3.1 Granularidad del target: el suelo del error

El target es tiempo imputado por una persona. Si ese tiempo se declarase en bloques
redondos, el modelo no podría bajar de la granularidad de esos bloques. Reparto de las
66.690 imputaciones:

| Granularidad | n | % |
|---|---|---|
| Múltiplo exacto de 60 min | 536 | 0,80 |
| Múltiplo exacto de 30 min | 455 | 0,68 |
| Múltiplo exacto de 15 min | 837 | 1,26 |
| Múltiplo exacto de 5 min | 2.236 | 3,35 |
| Valor no redondo | 62.626 | 93,91 |

El 93,91 % de las imputaciones tiene un valor no redondo. El tiempo se registra con un
cronómetro, no por estimación en bloques. Esto elimina el techo de granularidad que se
esperaba encontrar, pero no elimina el resto del ruido de imputación: lo que se mide es
cuándo alguien arrancó y paró un contador, no el esfuerzo real.

## 3.2 Distribución del target

Sobre las 13.388 negociaciones cerradas con tiempo del pipeline objetivo:

| Estadístico | Valor (min) |
|---|---|
| Mediana | 5,5 |
| P99 | 169,4 |
| Máximo | 1.003,7 |
| Ratio P99 / mediana | 30,8 |

La cola es larga: el percentil 99 está 30,8 veces por encima de la mediana. Esto
justifica modelar `log1p` y evaluar con MAE y MedAE en lugar de RMSE, que quedaría
dominado por unos pocos casos.

## 3.3 Censura

| Estado | n | % |
|---|---|---|
| Cerrada y ganada | 14.876 | 86,37 |
| Cerrada y perdida | 2.257 | 13,10 |
| En curso | 90 | 0,52 |

Se modela solo lo cerrado y ganado. Las 2.257 perdidas y las 90 en curso quedan fuera:
son censura por la derecha, no ruido.

## 3.4 Cobertura y coherencia

| Comprobación | Valor |
|---|---|
| Horas imputadas que no cuelgan de ninguna negociación | 11,71 % (4.066,6 h de 34.721,4 h) |
| Negociaciones cerradas del pipeline con 0 minutos imputados | 21,74 % (3.745 de 17.223) |
| Negociaciones con más de un empleado imputando | 3,84 % |
| Negociaciones con más de 8 h imputadas | 0,06 % (8 de 13.388) |
| Negociaciones con menos de 1 minuto imputado | 7,31 % (978 de 13.388) |
| Imputaciones fechadas fuera de la ventana [creación, cierre] de su negociación | 1,65 % |
| Días entre creación y cierre (mediana) | 14 |
| Días entre primera y última imputación (mediana) | 0 |

Las dos primeras filas son las que más condicionan el alcance del modelo: casi el 12 %
del tiempo registrado no es atribuible a ningún proceso, y más de una de cada cinco
negociaciones cerradas no tiene tiempo imputado. El modelo aprende del trabajo que
llegó a registrarse contra un proceso, no de todo el trabajo hecho.

---

# 4. Metodología

## 4.1 Filtros de inclusión

| Filtro | Filas antes | Filas caídas | Filas después |
|---|---|---|---|
| Pipeline = Modelos de impuestos | 30.836 | 13.613 | 17.223 |
| Negociación cerrada | 17.223 | 90 | 17.133 |
| Semántica ganada | 17.133 | 2.257 | 14.876 |
| Minutos imputados > 0 | 14.876 | 1.738 | 13.138 |
| Valor de proceso no vacío | 13.138 | 125 | 13.013 |
| Fecha de cierre no nula | 13.013 | 0 | 13.013 |

Además, en la extracción se descartan las tareas enlazadas a más de una negociación,
para no duplicar su tiempo: 5 tareas, 3 imputaciones y 1,98 h sobre 30.654,8 h con
negociación (0,006 %).

## 4.2 Features

Modelo de **planificación**, el principal. Solo información conocida antes de ejecutar
el proceso.

| Feature | Tipo | Nulos (%) |
|---|---|---|
| `proceso` | categórica | 0,00 |
| `ejercicio` | numérica | 21,18 |
| `trimestre_fiscal` | categórica derivada | 0,00 |
| `mes_creacion` | categórica | 0,00 |
| `dias_desde_alta_cliente` | numérica | 0,11 |
| `n_procesos_previos_cliente` | numérica histórica | 0,00 |
| `mediana_min_cliente_hist` | numérica histórica | 17,23 |
| `mediana_min_proceso_hist` | numérica histórica | 17,31 |
| `n_deals_misma_campana` | numérica | 0,00 |
| `es_primera_vez_cliente_proceso` | binaria | 0,00 |

`trimestre_fiscal` se deriva como el trimestre natural de (`fecha_creacion` − 1 mes).
El CRM tiene un campo *Periodo*, pero solo toma valor trimestral en 6.138 de las 13.013
filas (47,2 %); el resto son valores anuales, mensuales o de pago fraccionado. Sobre
esas 6.138 filas comparables, la regla derivada coincide con el valor declarado en el
99,63 % de los casos. La decisión, con la alternativa descartada, está en `DECISIONES.md`
(D-006).

El modelo de **control** añade `responsable_id_grp` (responsables con menos de 30 casos
agrupados en `OTROS`) y `n_empleados`. Se entrena y se reporta por separado.

**Features excluidas por conocerse solo después de ejecutar el proceso:**
`minutos_max_imputacion`, `n_imputaciones`, `n_tareas`, `n_empleados`,
`fecha_ultima_imputacion`, `fecha_cierre`, `fecha_primera_imputacion`, `etapa`,
`etapa_id`, `semantica`, `cerrada`. La única excepción es `n_empleados`, reservada al
modelo de control. `src/03_dataset.py` comprueba la ausencia de todas ellas y aborta si
alguna aparece.

## 4.3 Validación y regla anti-leakage

**Regla aplicada:** toda feature histórica se calcula usando exclusivamente
negociaciones cuya `fecha_cierre` es **estrictamente anterior** a la `fecha_creacion` de
la fila que se está construyendo. Ventana expansiva, nunca el conjunto completo.

Las filas sin historial suficiente reciben `NaN`, no la media global: rellenar con un
estadístico calculado sobre todo el conjunto sería leakage encubierto. El coste de esta
decisión está medido: 2.242 filas (17,2 %) quedan sin historial de cliente y 2.253
(17,3 %) sin historial de proceso.

**Particiones:**

| Partición | Definición | Filas | Clientes |
|---|---|---|---|
| Train | Negociaciones cerradas en 2025 | 6.821 | 894 |
| Test | Negociaciones cerradas en 2026 | 6.192 | 917 |
| Validación interna | `GroupKFold(n_splits=4)` agrupando por cliente, dentro de train | — | — |

El agrupamiento por cliente evita que un mismo cliente aparezca a ambos lados del
corte. Su efecto es verificable en la tabla de baselines: B3, que corrige por la mediana
histórica del cliente, obtiene exactamente el mismo MAE que B1 en los cuatro folds,
porque ningún cliente de validación aparece en el ajuste.

**Comprobación de leakage:** asociación de cada feature con el target dentro de train.
Ninguna supera 0,95. La más alta es `proceso`, con una razón de correlación de 0,441.

`random_state=42` en todo lo que tiene aleatoriedad.

---

# 5. Baselines

Calculados **antes** que el modelo, para no ajustar el listón. Los cuatro se ajustan
solo con train y se evalúan en test.

| Id | Definición |
|---|---|
| B0 | La mediana de train, para todas las filas |
| B1 | La mediana de train del mismo valor de proceso |
| B2 | La mediana de train de proceso × ejercicio, con retroceso a B1 y a B0 |
| B3 | B1 multiplicado por (mediana del cliente en train / mediana global de train), con el factor acotado a [0,2 · 5,0] |

Resultado en el split temporal, todas las métricas en minutos:

| Baseline | MAE | MedAE | % ±5 min | % ±15 min | % ±30 min | RMSE | MAPE (%) |
|---|---|---|---|---|---|---|---|
| B0 mediana global | 16,39 | 3,90 | 63,47 | 77,70 | 86,48 | 43,42 | 150,94 |
| **B1 mediana por proceso** | **16,37** | **4,88** | **50,95** | **72,37** | **88,53** | **41,05** | **247,34** |
| B2 proceso × ejercicio | 16,40 | 4,88 | 50,95 | 72,29 | 88,55 | 41,05 | 249,45 |
| B3 proceso ajustada por cliente | 17,77 | 5,40 | 48,18 | 72,67 | 85,90 | 44,70 | 295,80 |

**B1 queda fijado como referencia del proyecto: MAE = 16,37 min.**

Dos observaciones que la tabla obliga a hacer:

1. B1 solo mejora a B0 en 0,02 min de MAE. Conocer el tipo de proceso apenas reduce el
   error medio, aunque sí cambia el reparto: B0 tiene mejor MedAE (3,90 frente a 4,88) y
   mejor porcentaje dentro de ±5 min (63,47 frente a 50,95). B1 acierta mejor en la cola
   y peor en el centro.
2. B3 empeora a B1 en 1,40 min. Corregir por la mediana histórica del cliente perjudica
   la predicción en este pipeline.

Sobre `% ±15 min` y `% ±30 min`: con una mediana de 5,1 min en train, una ventana de 15
o 30 minutos cubre casi toda la distribución y las dos métricas se saturan. Se incluyen
porque el guion de la entrega las pide, y se añade `% ±5 min`, que sí discrimina en esta
escala.

MAPE se reporta solo como información. Con negociaciones de menos de un minuto (7,31 %
del dataset) el denominador se acerca a cero y la métrica se dispara; no se usa para
decidir nada.

---

# 6. Resultados

## 6.1 Modelos evaluados

| Id | Modelo |
|---|---|
| M1 | Regresión lineal sobre `log1p` con codificación one-hot |
| M2 | `HistGradientBoostingRegressor` |
| M3 | M2 con pérdida cuantílica, q = 0,1 / 0,5 / 0,9 |

## 6.2 Bucle de mejora, con criterio de parada declarado antes de abrirlo

| Elemento | Valor |
|---|---|
| Métrica | MAE en minutos sobre la validación interna GroupKFold(4) por cliente |
| Umbral | Mejora ≥ 10 % sobre el MAE de B1 en esa misma validación (11,53 min) |
| Intentos máximos | 5, en el orden de la lista prevista |
| Papel del test | Ninguno en la decisión de parada |

Trayectoria completa:

| Intento | MAE validación (min) | Mejora sobre B1 (%) | MAE test (min) |
|---|---|---|---|
| 0. M2 con las features de partida | 11,33 | 1,67 | 15,91 |
| 1. Agrupar procesos con <100 casos en `OTROS` | 11,34 | 1,63 | 15,61 |
| 2. Añadir features de carga de campaña | 11,36 | 1,45 | 15,61 |
| 3. Ajustar `max_iter` / `learning_rate` / `max_leaf_nodes` | 11,26 | 2,28 | 15,50 |
| 4. Target encoding por cliente ajustado dentro de cada fold | 12,14 | −5,31 | 15,80 |
| 5. Recortar la cola al P99 solo en train | 11,26 | 2,28 | 15,48 |

Se agotaron los 5 intentos sin alcanzar el 10 %. La variante seleccionada es la 3, la
mejor en validación interna. No es la mejor en test (la 5 obtiene 15,48 frente a 15,50),
lo que confirma que la selección no miró el conjunto de evaluación.

## 6.3 Resultado en el split temporal 2025 → 2026

| Modelo | MAE | Mejora sobre B1 (%) | MedAE | % ±5 min | % ±15 min | % ±30 min | RMSE | MAPE (%) |
|---|---|---|---|---|---|---|---|---|
| B1 (referencia) | 16,37 | 0,00 | 4,88 | 50,95 | 72,37 | 88,53 | 41,05 | 247,34 |
| M1 regresión lineal | 16,40 | −0,18 | 5,91 | 44,62 | 74,63 | 87,90 | 40,82 | 263,03 |
| M2 gradient boosting | 15,50 | 5,31 | 4,65 | 52,05 | 80,17 | 88,00 | 41,73 | 180,35 |
| M3 cuantil 0,5 | 15,37 | 6,11 | 4,42 | 53,42 | 80,02 | 88,28 | 41,49 | 170,81 |
| Modelo de control | 14,94 | 8,74 | 5,18 | 49,03 | 78,81 | 89,26 | 39,14 | 245,52 |

## 6.4 Estabilidad en GroupKFold(4) por cliente

| Fold | MAE B1 | MAE M1 | MAE M2 | Mejora de M2 (%) |
|---|---|---|---|---|
| 1 | 11,72 | 11,93 | 11,42 | 2,56 |
| 2 | 11,42 | 11,61 | 11,23 | 1,66 |
| 3 | 12,14 | 12,18 | 11,88 | 2,14 |
| 4 | 10,82 | 10,73 | 10,52 | 2,77 |

M2 mejora a B1 en 4 de 4 folds. La mejora es pequeña pero no es inestable.

## 6.5 Lectura del resultado

**El modelo no alcanza el umbral fijado.** M2 reduce el MAE de 16,37 a 15,50 min, una
mejora del 5,31 % frente al 10 % declarado como criterio. Se reporta así, sin tocar el
test, sin filtrar casos difíciles y sin reajustar el baseline a la baja.

Tres cifras ya medidas explican por qué el margen es estrecho:

1. **La distribución está dominada por la cola.** Ratio P99 / mediana = 30,8. Los dos
   mayores errores de test son negociaciones del proceso 347 con 1.003,7 y 795,4 minutos
   imputados, frente a una mediana histórica de ese proceso de 22,8 min. Ninguna feature
   disponible antes de ejecutar el proceso anticipa esa diferencia.
2. **Hay deriva entre las dos campañas.** El P99 de `minutos_total` pasa de 143,7 min en
   train a 189,9 min en test, y el MAE de B1 pasa de 11,53 min en la validación interna a
   16,37 min en el test temporal, un 42,0 % más. Parte del error de 2026 no estaba
   presente en los datos de 2025.
3. **El target no recoge todo el trabajo.** El 11,71 % de las horas imputadas no cuelga
   de ninguna negociación y el 21,74 % de las negociaciones cerradas del pipeline tiene
   0 minutos imputados.

La conclusión sustantiva es que la duración de estos procesos está determinada
principalmente por el tipo de proceso y por el nivel histórico de tiempo del cliente, y
el resto de la variación procede de cada ejecución concreta y del hábito de imputación.
Un modelo con estas features no puede reducir mucho más el error.

Esto no invalida el uso de planificación: M2 sitúa el 80,17 % de las negociaciones
dentro de ±15 min frente al 72,37 % de B1, y el 52,05 % dentro de ±5 min frente al
50,95 %. Para estimar la carga de una campaña completa, la diferencia entre 16,37 y
15,50 min de error medio por negociación se acumula sobre miles de ejecuciones.

## 6.6 Predicción por intervalos

M3 produce un intervalo [q10, q90] con anchura mediana de 14,5 min. Ese intervalo
contiene el valor real en el 54,80 % de las negociaciones de test, frente al 80 %
nominal. Está mal calibrado, por la misma deriva entre campañas descrita arriba. No es
utilizable como garantía de cobertura sin recalibrarlo por campaña.

---

# 7. Explicabilidad

Importancia por permutación sobre test, 10 repeticiones, `random_state=42`, medida como
caída del MAE en la escala `log1p` al permutar cada columna.

| Feature | Importancia media | Desviación |
|---|---|---|
| `mediana_min_cliente_hist` | 0,0869 | 0,0030 |
| `proceso` | 0,0704 | 0,0043 |
| `n_procesos_previos_cliente` | 0,0138 | 0,0018 |
| `dias_desde_alta_cliente` | 0,0083 | 0,0008 |
| `mediana_min_proceso_hist` | 0,0058 | 0,0018 |
| `mes_creacion` | 0,0019 | 0,0010 |
| `n_deals_misma_campana` | 0,0015 | 0,0005 |
| `es_primera_vez_cliente_proceso` | 0,0009 | 0,0007 |
| `trimestre_fiscal` | −0,0000 | 0,0003 |
| `ejercicio` | 0,0000 | 0,0000 |

Dos features aportan casi toda la señal: el nivel histórico de tiempo del cliente y el
tipo de proceso. `trimestre_fiscal` y `ejercicio` aportan cero: en este pipeline, saber
de qué trimestre o de qué ejercicio es la declaración no cambia cuánto se tarda en
presentarla.

Dos casos individuales, los de mayor error absoluto en test:

| deal_id | proceso | Mediana histórica del proceso | Mediana histórica del cliente | Minutos reales | Minutos predichos |
|---|---|---|---|---|---|
| 31928 | 347 | 22,8 | 19,7 | 1.003,7 | 23,8 |
| 31899 | 347 | 22,8 | 6,5 | 795,4 | 7,8 |

En los dos casos el modelo predice cerca de la mediana histórica y el tiempo real la
supera en más de un orden de magnitud. Son exactamente el tipo de caso que la sección 8
marca como anomalía.

## 7.1 Modelo de control

El modelo de control añade `responsable_id_grp` y `n_empleados`. Su MAE en test es
14,94 min frente a los 15,50 min del modelo de planificación, y `responsable_id_grp`
ocupa la posición 2 de 12 en importancia por permutación.

Es un hallazgo, y se reporta como tal: quién ejecuta el proceso explica parte de la
duración. La finalidad de este modelo es detectar anomalías de proceso, no evaluar el
desempeño de personas. Por eso se entrena y se reporta por separado del modelo de
planificación, que no incluye al responsable.

---

# 8. Anomalías

## 8.1 Definición

La anomalía es el residuo del modelo de la sección 6, estandarizado por la dispersión
propia de cada proceso:

```
residuo    = minutos_reales − minutos_predichos
sigma_proc = desviación típica de los residuos de train, por proceso
z          = residuo / sigma_proc
anomalía   = |z| > 3
```

La sigma se estima con los residuos **out-of-fold** de train (GroupKFold por cliente).
Usar residuos dentro de muestra la subestimaría y elevaría la tasa de marcado de forma
artificial. Los procesos con menos de 20 casos en train usan la sigma global.

## 8.2 Tasa de marcado

Sobre las 6.192 negociaciones cerradas en 2026:

| Tipo | n | % |
|---|---|---|
| Normal | 5.953 | 96,14 |
| Anomalía por exceso (z > 3) | 239 | 3,86 |
| Anomalía por defecto (z < −3) | 0 | 0,00 |

**Tasa global de marcado: 3,86 %**, por debajo del 5 % que se había fijado como límite
de manejabilidad.

## 8.3 Una limitación aritmética de la definición

No hay ninguna anomalía por defecto, y no es un hallazgo sobre los datos: es una
consecuencia de la definición. Los minutos no son negativos, así que el residuo no puede
bajar de `−minutos_predichos`. Con predicciones de pocos minutos y sigmas de decenas de
minutos, el valor más negativo que z alcanza en todo el conjunto de test es **−0,043**,
muy lejos de −3. En escala de minutos, esta definición solo puede detectar exceso, y la
sospecha de infraimputación que se pretendía cubrir queda fuera.

Por eso se calcula también la misma regla sobre el residuo en escala `log1p`, donde el
residuo sí es simétrico:

| Definición | Marcadas | % | Por exceso | Por defecto | Volumen manejable (<5 %) |
|---|---|---|---|---|---|
| (a) Residuo en minutos, \|z\| > 3 | 239 | 3,86 | 239 | 0 | sí |
| (b) Residuo en escala `log1p`, \|z\| > 3 | 68 | 1,10 | 67 | 1 | sí |
| (c) Fuera del intervalo [q10, q90] de M3 | 2.799 | 45,20 | 1.492 | 1.307 | no |

Se adopta **(a)** como definición principal: produce una lista revisable de casos con
sobrecoste de tiempo. **(b)** se reporta como complemento, porque cubre el único caso que
(a) no puede ver por construcción. **(c)** queda descartada por volumen: marcar el
45,20 % de las negociaciones no es una alerta, y además hereda el problema de
calibración de la sección 6.6.

## 8.4 Validación ciega con experto

Se ha generado `output/validacion_experto.csv` con 40 casos: 20 marcados como anómalos
y 20 normales, mezclados con `random_state=42` y sin la columna de predicción ni la de
z. Columnas: `deal_id`, `proceso`, `ejercicio`, `minutos_total`, `veredicto_experto`,
esta última vacía y con valores admitidos `razonable`, `anomalo` y `no_se`.

La clave (qué caso estaba marcado y con qué z) se guarda aparte, en
`output/validacion_experto_clave.csv`, y no se entrega junto con el archivo de
validación.

**Estado: pendiente.** El experto todavía no ha devuelto el archivo relleno. Cuando lo
devuelva como `output/validacion_experto_relleno.csv`, al reejecutar
`src/06_anomalias.py` se calculan el acuerdo, la precisión y el recall del marcado
frente al criterio experto, y la sección 5.1 de `output/06_anomalias.md` se completa
sola. No se rellena con cifras inventadas.

---

# 9. Limitaciones declaradas

1. **El target es tiempo imputado manualmente, no medido.** El modelo aprende tanto el
   esfuerzo real como el hábito de imputación. En este caso el registro es cronometrado
   —el 93,91 % de las imputaciones tiene un valor no redondo—, lo que descarta el
   redondeo en bloques como fuente principal de ruido, pero no garantiza que el
   cronómetro se arranque y se pare cuando empieza y acaba el trabajo.
2. **Solo se observan negociaciones cerradas y ganadas.** Las 2.257 perdidas (13,10 %) y
   las 90 en curso (0,52 %) del pipeline quedan censuradas y fuera del modelo.
3. **El trabajo que no cuelga de ninguna negociación es invisible al modelo.** Son
   4.066,6 h, el 11,71 % de las horas imputadas en la ventana. A esto se suma que el
   21,74 % de las negociaciones cerradas del pipeline no tiene ningún minuto imputado.
4. **El histórico cubre un número limitado de campañas.** La validación temporal se
   apoya en los cierres de 2026 (6.192 negociaciones) frente a los de 2025 (6.821). Con
   dos años, la deriva medida entre campañas —el P99 pasa de 143,7 a 189,9 min— no puede
   separarse de la variación año a año.
5. **Los resultados son específicos de esta asesoría.** Dependen de su cartera de
   clientes, de su reparto de modelos tributarios y de sus hábitos de imputación. No hay
   base para extrapolarlos a otra asesoría.
6. **El modelo de control incluye al responsable como variable.** Su finalidad es
   detectar anomalías de proceso, no evaluar el desempeño de personas. Se reporta por
   separado del modelo de planificación, que no lo incluye, y su uso queda restringido a
   la revisión de casos.

---

# 10. Trabajo futuro y estado de la entrega

## 10.1 Qué desbloquearía cada línea

| Línea | Qué falta para abordarla |
|---|---|
| Extensión a contabilidad | Ejecutar los mismos scripts cambiando `PIPELINE_OBJETIVO`. Volumen disponible: 10.347,6 h entre Contabilidad Interna, Contabilidad Externa y Cierres. No requiere código nuevo |
| Extensión a rentas | Requiere una tercera campaña. Con dos (2025 y 2026) la validación temporal se reduce a un único corte |
| Cerrar la validación con experto | Que el experto devuelva `validacion_experto.csv` relleno. El cálculo ya está programado |
| Recalibrar los intervalos de M3 | Estimar los cuantiles por campaña en lugar de sobre train completo, y medir de nuevo la cobertura frente al 80 % nominal |
| Reducir la censura del 21,74 % de negociaciones sin tiempo | Es un cambio de proceso en la asesoría, no de modelo: imputar tiempo a toda negociación cerrada |

## 10.2 Seguridad y reproducibilidad

Las conexiones se configuran mediante un archivo `.env` que no se versiona. Antes de
cada commit se ejecuta `src/_check_seguridad.py`, que busca en todo lo que se va a
versionar patrones de dirección IP, cadenas de credencial y nombres de base de datos, y
aborta si encuentra alguno. Los datos (`*.csv`, `*.parquet`, `*.pkl`) están excluidos del
control de versiones; solo se versionan el código, los informes en markdown y las
figuras.

Cada script de `src/` se ejecuta de cero sin pasos manuales:

```
py -m pip install -r requirements.txt
py src/00_descubrimiento.py
py src/01_extraccion.py
py src/02_eda.py
py src/03_dataset.py
py src/04_baselines.py
py src/05_modelos.py
py src/06_anomalias.py
```

## 10.3 Lo que queda pendiente

| Pendiente | Estado |
|---|---|
| Repositorio independiente dedicado solo al PFM | Registrado en `BLOQUEOS.md` (B-003) con los cinco pasos exactos. Requiere crear el repositorio y purgar el historial del antiguo, acciones que no se han ejecutado |
| Rotación de las credenciales de acceso a la base de datos | Incluida en B-003 |
| Validación ciega con experto | Archivo generado, veredictos pendientes |

## 10.4 Trazabilidad de las cifras

Toda cifra de este documento procede de un script de `src/` y está en un informe de
`output/`:

| Sección | Script | Informe |
|---|---|---|
| 2 Datos | `01_extraccion.py` | `RESUMEN_extraccion.md` |
| 3 Calidad | `02_eda.py` | `02_informe_calidad.md` |
| 4 Metodología | `03_dataset.py` | `03_diccionario_datos.md` |
| 5 Baselines | `04_baselines.py` | `04_baselines.md` |
| 6 Resultados y 7 Explicabilidad | `05_modelos.py` | `05_modelos.md` |
| 8 Anomalías | `06_anomalias.py` | `06_anomalias.md` |

Las decisiones tomadas durante la ejecución, con su alternativa descartada, están en
`DECISIONES.md` (D-001 a D-013). Los puntos en los que la realidad contradijo lo
previsto, en `BLOQUEOS.md` (B-001 a B-004).
