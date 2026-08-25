# Fase 4 - Baselines

Generado por `src/04_baselines.py`. Ajuste sobre train (6,821 negociaciones cerradas en 2025), evaluacion sobre test (6,192 cerradas en 2026). Todas las metricas en minutos.

## 1. Definicion

| id   | definicion                                                                                                                                                 |
|:-----|:-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| B0   | la mediana de minutos_total de train, para todas las filas                                                                                                 |
| B1   | la mediana de train del mismo valor de proceso; mediana global si el proceso no aparece en train                                                           |
| B2   | la mediana de train de proceso x ejercicio; retrocede a B1 y luego a B0 cuando la celda no existe                                                          |
| B3   | B1 multiplicado por (mediana del cliente en train / mediana global de train), con el factor acotado a [0,2 · 5,0]; factor 1 si el cliente no esta en train |

El acotado del factor de B3 a [0,2 · 5,0] evita que un cliente con una sola negociacion en train dispare la prediccion. Sin acotar, el MAE de B3 empeora (se reporta mas abajo el valor acotado, que es el favorable al baseline).

## 2. Resultado en el split temporal 2025 -> 2026

| baseline                                    |   MAE_min |   MedAE_min |   pct_dentro_5min |   pct_dentro_15min |   pct_dentro_30min |   RMSE_min |   MAPE_pct |
|:--------------------------------------------|----------:|------------:|------------------:|-------------------:|-------------------:|-----------:|-----------:|
| B0 mediana global                           |     16.39 |        3.9  |             63.47 |              77.7  |              86.48 |      43.42 |     150.94 |
| B1 mediana por proceso                      |     16.37 |        4.88 |             50.95 |              72.37 |              88.53 |      41.05 |     247.34 |
| B2 mediana por proceso x ejercicio          |     16.4  |        4.88 |             50.95 |              72.29 |              88.55 |      41.05 |     249.45 |
| B3 mediana por proceso ajustada por cliente |     17.77 |        5.4  |             48.18 |              72.67 |              85.9  |      44.7  |     295.8  |

**B1 queda fijado como referencia del proyecto: MAE = 16.37 min en test.** El modelo de la Fase 5 se compara contra este numero.

Nota sobre `pct_dentro_15min` y `pct_dentro_30min`: con una mediana de 5.1 min en train, una ventana de 15 o 30 minutos cubre casi toda la distribucion y las dos metricas se saturan. Se incluyen porque la guia las exige, y se anade `pct_dentro_5min`, que si discrimina en esta escala.

## 3. Estabilidad: GroupKFold(4) por cliente dentro de train

| baseline                                    |   MAE_min_medio |   MAE_min_desv |   MedAE_min_medio | MAE_por_fold               |
|:--------------------------------------------|----------------:|---------------:|------------------:|:---------------------------|
| B0 mediana global                           |           12.26 |           0.55 |              3.72 | 12.37, 12.35, 12.94, 11.40 |
| B1 mediana por proceso                      |           11.53 |           0.48 |              3.76 | 11.72, 11.42, 12.14, 10.82 |
| B2 mediana por proceso x ejercicio          |           11.51 |           0.5  |              3.55 | 11.70, 11.38, 12.16, 10.79 |
| B3 mediana por proceso ajustada por cliente |           11.53 |           0.48 |              3.76 | 11.72, 11.42, 12.14, 10.82 |

El agrupamiento por cliente impide que un mismo cliente aparezca a ambos lados del corte. Consecuencia directa y verificable en la tabla: B3 obtiene exactamente el mismo MAE que B1 en los cuatro folds, porque ningun cliente del fold de validacion aparece en el de ajuste y su factor de correccion es siempre 1,0. B3 solo es evaluable en el split temporal.

El MAE de B1 es 11.53 min de media en GroupKFold y 16.37 min en el test temporal, una diferencia de 42.0 %. Las negociaciones cerradas en 2026 tienen una cola mas pesada que las de 2025 (P99 de minutos_total: 143.7 min en train frente a 189.9 min en test). Es deriva temporal, y hay que tenerla en cuenta al comparar ambas particiones en la Fase 5.

## 4. B1 desglosado por proceso en test

| proceso                     |   n_test |   mediana_real |   prediccion_b1 |   MAE_min |
|:----------------------------|---------:|---------------:|----------------:|----------:|
| 303                         |     1712 |           6.36 |            6.38 |     14.88 |
| 200                         |      720 |           7.32 |           26.88 |     29.71 |
| 130                         |      605 |           4.12 |            3.57 |      7.45 |
| 390                         |      476 |           3.76 |            3.88 |      7.72 |
| 347                         |      460 |          26.74 |           22.82 |     49.78 |
| 115                         |      446 |           4.44 |            4.4  |      6.93 |
| 111                         |      276 |           3.12 |            2.97 |      6.18 |
| 303M                        |      181 |          14.22 |           10.46 |     16.81 |
| 202                         |      173 |           2.5  |            2.23 |      3.79 |
| 180                         |      164 |           4.06 |            3.92 |      6.76 |
| 349M                        |      155 |           7.22 |            4.97 |     11.01 |
| 349                         |      148 |           3.58 |            3.64 |      9.44 |
| 131                         |      105 |           2.78 |            3.48 |      4.25 |
| 190                         |      104 |           3.24 |            2.37 |      8.2  |
| INTRASTAT MENSUAL           |       83 |          18.22 |           15.07 |     18.03 |
| 123                         |       56 |           8.83 |            5.73 |     16.68 |
| 115M                        |       46 |           3.44 |            3.7  |      6.11 |
| 193                         |       45 |           4.22 |            5    |     10.75 |
| 184                         |       38 |          17.77 |           17.1  |     30    |
| 111M                        |       36 |          12.49 |            5.12 |     10.39 |
| GASOLEO PROFESIONAL         |       29 |          12.22 |            8.77 |     24    |
| GASOLEO AGRICOLA            |       26 |          52.14 |           24.33 |     41.69 |
| 303 Alquiler                |       25 |          21.25 |            5.12 |     28.32 |
| 123M                        |       18 |           4.01 |            2.33 |      3.55 |
| 714                         |       16 |          18.78 |            5.53 |     30.55 |
| GASOLEO PROFESIONAL MENSUAL |       15 |          17.23 |           11.52 |      7.3  |
| 309                         |       10 |           7.02 |            7.78 |      4.4  |
| 210                         |        7 |          81.53 |           92.06 |     32.45 |
| 216                         |        6 |           7.9  |           12.74 |      6.23 |
| 182                         |        5 |          40.37 |          144.62 |     94.65 |
| 296                         |        2 |         131.29 |          190.68 |    119.54 |
| 210 ALE                     |        1 |         376.83 |            5.12 |    371.71 |
| 210 ACE                     |        1 |          87.45 |            5.12 |     82.33 |
| 233                         |        1 |          70    |           57.02 |     12.98 |
| 720                         |        1 |          82.27 |            5.12 |     77.15 |
