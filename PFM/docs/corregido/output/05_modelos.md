# Fase 5 - Modelado

Generado por `src/05_modelos.py`. Train: 6,821 negociaciones cerradas en 2025. Test: 6,192 cerradas en 2026. `random_state=42` en todo lo aleatorio. Todas las metricas en minutos, deshaciendo `log1p` con `expm1`.

Referencia fijada en la Fase 4: **B1 (mediana por proceso)**. MAE = 16.37 min en el test temporal y 11.53 min de media en GroupKFold(4) dentro de train.

## 1. Criterio de parada del bucle de mejora

Declarado antes de ejecutar ninguna variante:

- Metrica: MAE en minutos sobre la validacion interna GroupKFold(4) por cliente, dentro de train.
- Umbral: mejora >= 10 % sobre el MAE de B1 en esa misma validacion (11.53 min).
- Intentos maximos: 5, en el orden de la lista de la guia.
- El test temporal no interviene en la decision de parada. Su MAE aparece en la tabla solo como trayectoria observada (ver D-009).

Resultado del bucle: agotados los 5 intentos sin alcanzar el 10 %. Intentos consumidos: 5 de 5.

## 2. Trayectoria del bucle

| intento                                                     |   MAE_cv_min |   mejora_cv_sobre_B1_pct |   MAE_test_min |   mejora_test_sobre_B1_pct |
|:------------------------------------------------------------|-------------:|-------------------------:|---------------:|---------------------------:|
| 0. M2 base (features de la Fase 3)                          |        11.33 |                     1.67 |          15.91 |                       2.81 |
| 1. agrupar procesos con <100 casos en train en OTROS        |        11.34 |                     1.63 |          15.61 |                       4.64 |
| 2. anadir features de carga de campana                      |        11.36 |                     1.45 |          15.61 |                       4.64 |
| 3. ajustar max_iter / learning_rate / max_leaf_nodes        |        11.26 |                     2.28 |          15.5  |                       5.31 |
| 4. target encoding por cliente ajustado dentro de cada fold |        12.14 |                    -5.31 |          15.8  |                       3.48 |
| 5. recortar la cola al P99 solo en train                    |        11.26 |                     2.28 |          15.48 |                       5.44 |

## 3. Comparativa de modelos en el split temporal 2025 -> 2026

| modelo                                                                         |   mejora_MAE_sobre_B1_pct |   MAE_min |   MedAE_min |   pct_dentro_5min |   pct_dentro_15min |   pct_dentro_30min |   RMSE_min |   MAPE_pct |
|:-------------------------------------------------------------------------------|--------------------------:|----------:|------------:|------------------:|-------------------:|-------------------:|-----------:|-----------:|
| B1 mediana por proceso (referencia)                                            |                      0    |     16.37 |        4.88 |             50.95 |              72.37 |              88.53 |      41.05 |     247.34 |
| M1 regresion lineal sobre log1p                                                |                     -0.18 |     16.4  |        5.91 |             44.62 |              74.63 |              87.9  |      40.82 |     263.03 |
| M2 HistGradientBoosting (3. ajustar max_iter / learning_rate / max_leaf_nodes) |                      5.31 |     15.5  |        4.65 |             52.05 |              80.17 |              88    |      41.73 |     180.35 |
| M3 cuantil 0.5                                                                 |                      6.11 |     15.37 |        4.42 |             53.42 |              80.02 |              88.28 |      41.49 |     170.81 |
| Modelo de control (M2 + responsable + n_empleados)                             |                      8.74 |     14.94 |        5.18 |             49.03 |              78.81 |              89.26 |      39.14 |     245.52 |

## 4. Estabilidad: GroupKFold(4) por cliente dentro de train

|   fold |   MAE_B1_min |   MAE_M1_min |   MAE_M2_min |   M2_mejora_pct |
|-------:|-------------:|-------------:|-------------:|----------------:|
|      1 |        11.72 |        11.93 |        11.42 |            2.56 |
|      2 |        11.42 |        11.61 |        11.23 |            1.66 |
|      3 |        12.14 |        12.18 |        11.88 |            2.14 |
|      4 |        10.82 |        10.73 |        10.52 |            2.77 |

M2 mejora a B1 en 4 de 4 folds.

## 5. M3: prediccion por intervalos

Con los cuantiles 0,1 / 0,5 / 0,9 sobre la misma configuracion, el intervalo [q10, q90] contiene el valor real en el 54.80 % de las negociaciones de test, con una anchura mediana de 14.5 min. La cobertura nominal del intervalo es del 80 %: por encima de esa cifra el intervalo es conservador, por debajo es optimista.

La diferencia entre la cobertura observada (54.80 %) y la nominal (80 %) responde al mismo fenomeno que aparece en la Fase 4: los cuantiles se ajustan con negociaciones cerradas en 2025 y se aplican a 2026, cuya cola es mas pesada (P99 de 143.7 min en train frente a 189.9 min en test). El intervalo no es utilizable como garantia de cobertura sin recalibrarlo por campana.

## 6. Explicabilidad - modelo de planificacion

| feature                        |   importancia_media |   desv |
|:-------------------------------|--------------------:|-------:|
| mediana_min_cliente_hist       |              0.0869 | 0.003  |
| proceso                        |              0.0704 | 0.0043 |
| n_procesos_previos_cliente     |              0.0138 | 0.0018 |
| dias_desde_alta_cliente        |              0.0083 | 0.0008 |
| mediana_min_proceso_hist       |              0.0058 | 0.0018 |
| mes_creacion                   |              0.0019 | 0.001  |
| n_deals_misma_campana          |              0.0015 | 0.0005 |
| es_primera_vez_cliente_proceso |              0.0009 | 0.0007 |
| trimestre_fiscal               |             -0      | 0.0003 |
| ejercicio                      |              0      | 0      |
| n_deals_cliente_mismo_dia      |             -0.0005 | 0.0008 |
| n_deals_mismo_dia              |             -0.0009 | 0.0004 |

Importancia por permutacion sobre test (10 repeticiones, `random_state=42`), medida como caida del MAE en la escala `log1p` al permutar cada columna. Figura: `figuras/05_importancia_permutacion.png`. Dispersograma real frente a predicho: `figuras/05_real_vs_predicho.png`.

### 6.1 Dos casos individuales con el mayor error absoluto en test

|   deal_id |   proceso | trimestre_fiscal   |   mediana_min_proceso_hist |   mediana_min_cliente_hist |   minutos_reales |   minutos_predichos |
|----------:|----------:|:-------------------|---------------------------:|---------------------------:|-----------------:|--------------------:|
|     31928 |       347 | 1T                 |                       22.8 |                       19.7 |           1003.7 |                23.8 |
|     31899 |       347 | 1T                 |                       22.8 |                        6.5 |            795.4 |                 7.8 |

## 7. Modelo de control

| feature                        |   importancia_media |
|:-------------------------------|--------------------:|
| proceso                        |              0.1638 |
| responsable_id_grp             |              0.0881 |
| mediana_min_cliente_hist       |              0.0646 |
| n_empleados                    |              0.0513 |
| n_procesos_previos_cliente     |              0.0133 |
| dias_desde_alta_cliente        |              0.0116 |
| es_primera_vez_cliente_proceso |              0.0104 |
| mes_creacion                   |              0.0076 |
| trimestre_fiscal               |              0.0011 |
| n_deals_misma_campana          |              0.0008 |
| ejercicio                      |             -0      |
| mediana_min_proceso_hist       |             -0.0012 |

El modelo de control anade `responsable_id_grp` y `n_empleados` al de planificacion. Su MAE en test es 14.94 min frente a 15.50 min del de planificacion. `responsable_id_grp` ocupa la posicion 2 de 12 en importancia por permutacion.

Este modelo existe para detectar anomalias de proceso, no para evaluar el desempeno de personas. Se reporta por separado por esa razon.

## 8. Gate 5

| criterio                                          | umbral         | valor   | resultado                                  |
|:--------------------------------------------------|:---------------|:--------|:-------------------------------------------|
| MAE de M2 vs B1 en el test temporal               | mejora >= 10 % | +5.31 % | NO cumple - resultado negativo documentado |
| Folds de GroupKFold en los que M2 mejora a B1     | >= 3 de 4      | 4 de 4  | cumple                                     |
| Features prohibidas en el modelo de planificacion | 0              | 0       | cumple                                     |

## 9. Lectura del resultado

El modelo M2 reduce el MAE de 16.37 a 15.50 min en el test temporal, una mejora del 5.31 % frente al 10 % fijado como umbral. El bucle de mejora se agoto en 5 intentos y ninguna de las ideas de la lista acerco la mejora al umbral: la mayor ganancia en validacion interna la aporto el ajuste de hiperparametros (intento 3), y el target encoding por cliente (intento 4) empeoro el MAE de validacion en un 5,31 %.

La mejora es pequena pero consistente: M2 bate a B1 en los cuatro folds de GroupKFold, con ganancias entre el 1,66 % y el 2,77 %. Es decir, el modelo no es inestable, es que hay poco que ganar.

La lectura sustantiva es que la duracion de estos procesos esta dominada por el tipo de proceso y por el nivel historico del cliente, y el resto del error procede de la variabilidad de cada ejecucion concreta. Tres cifras ya medidas lo sostienen:

1. La distribucion tiene una cola muy larga: ratio P99/mediana = 30,8 (Fase 2). El MAE esta dominado por unos pocos casos extremos. Los dos mayores errores de test son negociaciones del mismo proceso (347) con 1.003,7 y 795,4 minutos imputados, frente a una mediana historica de ese proceso de 22,8 min: ninguna feature disponible antes de ejecutar el proceso anticipa esa diferencia.
2. Hay deriva temporal entre las dos campanas: el P99 pasa de 143.7 min en train a 189.9 min en test, y el MAE de B1 pasa de 11.53 a 16.37 min. Parte del error de 2026 no estaba en los datos de 2025.
3. El 11,71 % de las horas imputadas no cuelga de ninguna negociacion (Fase 1) y el 21,74 % de las negociaciones cerradas del pipeline tiene 0 minutos imputados (Fase 2). El target no recoge todo el trabajo realizado.

El resultado se reporta como negativo respecto al umbral y no se ha intentado alcanzarlo tocando el test, recortando casos dificiles ni reajustando el baseline a la baja.
