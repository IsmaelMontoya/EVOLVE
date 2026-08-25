# Fase 3 - Diccionario de datos y construccion del dataset

Generado por `src/03_dataset.py`. Pipeline objetivo: Modelos de impuestos.

## 1. Embudo de filtros de inclusion

| filtro                             |   filas_antes |   filas_caidas |   filas_despues |
|:-----------------------------------|--------------:|---------------:|----------------:|
| pipeline == 'Modelos de impuestos' |         30836 |          13613 |           17223 |
| cerrada == 'Y'                     |         17223 |             90 |           17133 |
| semantica == 'S' (ganada)          |         17133 |           2257 |           14876 |
| minutos_total > 0                  |         14876 |           1738 |           13138 |
| proceso no vacio                   |         13138 |            125 |           13013 |
| fecha_cierre no nula               |         13013 |              0 |           13013 |

El filtro 6 de la guia (tarea con enlace a un unico deal) se aplica en la Fase 1, antes de agregar el tiempo: 5 tareas y 1,98 h descartadas (D-002).

## 2. Reparto por anio de cierre

|   anio_cierre |    n |   mediana_min |   clientes |
|--------------:|-----:|--------------:|-----------:|
|          2025 | 6821 |           5.1 |        894 |
|          2026 | 6192 |           6   |        917 |

## 3. Diccionario de columnas

| columna                        | tipo          | descripcion                                                                                                          |   pct_nulos |
|:-------------------------------|:--------------|:---------------------------------------------------------------------------------------------------------------------|------------:|
| deal_id                        | identificador | id de la negociacion; no es feature                                                                                  |        0    |
| cliente_id                     | identificador | id numerico de la empresa; se usa como grupo en GroupKFold, no es feature                                            |        0.06 |
| fecha_creacion                 | fecha         | inicio del proceso; corte de la ventana expansiva                                                                    |        0    |
| fecha_cierre                   | fecha         | fin del proceso; define el split temporal, no es feature                                                             |        0    |
| anio_cierre                    | entero        | anio de fecha_cierre; 2025 = train, 2026 = test                                                                      |        0    |
| minutos_total                  | numerica      | TARGET en minutos; suma de las imputaciones de la negociacion                                                        |        0    |
| y_log                          | numerica      | TARGET modelado: log1p(minutos_total)                                                                                |        0    |
| proceso                        | categorica    | modelo presentado (UF_CRM_1715872169), valor legible del enum                                                        |        0    |
| ejercicio                      | numerica      | ejercicio fiscal declarado (UF_CRM_1741263970530)                                                                    |       21.18 |
| trimestre_fiscal               | categorica    | derivada: trimestre de (fecha_creacion - 1 mes); ver D-006                                                           |        0    |
| mes_creacion                   | categorica    | mes de fecha_creacion, 1-12                                                                                          |        0    |
| dias_desde_alta_cliente        | numerica      | dias entre el alta de la empresa en el CRM y la creacion del deal                                                    |        0.11 |
| n_procesos_previos_cliente     | numerica      | HISTORICA: negociaciones del cliente cerradas antes de fecha_creacion                                                |        0    |
| mediana_min_cliente_hist       | numerica      | HISTORICA: mediana de minutos del cliente en negociaciones cerradas antes de fecha_creacion; NaN si no hay historial |       17.23 |
| mediana_min_proceso_hist       | numerica      | HISTORICA: idem por proceso                                                                                          |       17.31 |
| n_deals_misma_campana          | numerica      | negociaciones de la misma campana (proceso x ejercicio x trimestre) creadas en la misma fecha o antes                |        0    |
| es_primera_vez_cliente_proceso | binaria       | 1 si el cliente no habia cerrado antes ese proceso                                                                   |        0    |
| responsable_id_grp             | categorica    | SOLO modelo de control: id del responsable; los que tienen <30 casos se agrupan en OTROS                             |        0    |
| n_empleados                    | numerica      | SOLO modelo de control: empleados distintos que imputaron                                                            |        0    |

## 4. Regla anti-leakage

Las cuatro features marcadas como HISTORICA se calculan recorriendo el dataset en orden de `fecha_creacion` y acumulando solo negociaciones con `fecha_cierre < fecha_creacion` de la fila en construccion (ventana expansiva, comparacion estricta). Las filas sin historial reciben NaN; no se rellenan con la media global, porque rellenar con un estadistico calculado sobre todo el conjunto es leakage encubierto. Los modelos de arboles gestionan NaN de forma nativa.

Filas sin historial de cliente: 2,242 (17.2 %). Sin historial de proceso: 2,253 (17.3 %).

## 5. Features prohibidas

No entran en el dataset por conocerse solo despues de ejecutar el proceso: `minutos_max_imputacion`, `n_imputaciones`, `n_tareas`, `n_empleados`, `fecha_ultima_imputacion`, `fecha_cierre`, `fecha_primera_imputacion`, `etapa`, `etapa_id`, `semantica`, `cerrada`. La unica excepcion es `n_empleados`, que la guia asigna expresamente al modelo de control y que no se usa en el modelo de planificacion.

## 6. Validacion de la regla de `trimestre_fiscal`

Sobre las 6,138 filas en las que el campo `periodo` del CRM toma un valor trimestral (1T-4T), la regla derivada coincide con el valor declarado en el 99.63 % de los casos.

## 7. Test de leakage: asociacion de cada feature con el target en train

| feature                        | tipo      |   valor | supera_0.95   |
|:-------------------------------|:----------|--------:|:--------------|
| proceso                        | eta       |  0.4405 | no            |
| mes_creacion                   | eta       |  0.2923 | no            |
| mediana_min_proceso_hist       | |pearson| |  0.2178 | no            |
| es_primera_vez_cliente_proceso | |pearson| |  0.1081 | no            |
| mediana_min_cliente_hist       | |pearson| |  0.1048 | no            |
| dias_desde_alta_cliente        | |pearson| |  0.1031 | no            |
| trimestre_fiscal               | eta       |  0.0765 | no            |
| n_deals_misma_campana          | |pearson| |  0.0305 | no            |
| n_procesos_previos_cliente     | |pearson| |  0.0179 | no            |
| ejercicio                      | |pearson| |  0.0157 | no            |

## 8. Gate 3

| criterio                                                       | umbral   |   valor | resultado   |
|:---------------------------------------------------------------|:---------|--------:|:------------|
| Filas tras filtros                                             | >= 300   |   13013 | cumple      |
| Features prohibidas en el modelo de planificacion              | 0        |       0 | cumple      |
| Features prohibidas entre las columnas de features del parquet | 0        |       0 | cumple      |
| Features con correlacion > 0.95 con el target en train         | 0        |       0 | cumple      |
