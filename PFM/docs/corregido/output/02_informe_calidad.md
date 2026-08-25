# Fase 2 - Informe de calidad y analisis exploratorio

Generado por `src/02_eda.py`. Pipeline objetivo: Modelos de impuestos. Todas las cifras salen de `output/deals.csv` (30,836 filas) y `output/imputaciones.csv` (66,690 filas).

## 1. Cobertura: negociaciones con y sin tiempo imputado

### 1.1 Por pipeline

| pipeline                                                 |   n_deals |   n_cerradas |   n_con_tiempo |   horas |   pct_con_tiempo |
|:---------------------------------------------------------|----------:|-------------:|---------------:|--------:|-----------------:|
| Contabilidad Interna                                     |      1472 |          871 |           1155 |  7720.7 |             78.5 |
| Gestión Interna                                          |       130 |           68 |            110 |  4250   |             84.6 |
| Modelos de impuestos                                     |     17223 |        17133 |          13392 |  3699.4 |             77.8 |
| Actividades                                              |      2956 |         2552 |           2633 |  3188.1 |             89.1 |
| RENTAS                                                   |      2422 |         2420 |           1962 |  2290   |             81   |
| Expedientes                                              |      1041 |          638 |            766 |  2192.3 |             73.6 |
| Cierres                                                  |      1666 |         1382 |            905 |  1911.7 |             54.3 |
| Contabilidad Externa                                     |       822 |          289 |            291 |   669.6 |             35.4 |
| Cuentas Anuales                                          |       828 |          442 |            624 |   482.3 |             75.4 |
| Facturación                                              |         9 |            2 |              8 |   438.7 |             88.9 |
| Tareas Recurrentes                                       |        97 |            4 |             79 |   397.6 |             81.4 |
| BITRIX                                                   |        28 |            9 |             20 |   359.3 |             71.4 |
| OnBoarding clientes                                      |       184 |          139 |            174 |   242.1 |             94.6 |
| Informe BI                                               |         4 |            1 |              4 |   222.7 |            100   |
| Derecho Civil                                            |        20 |            9 |             20 |   186.2 |            100   |
| Libros Oficiales                                         |       701 |          346 |            287 |   135.9 |             40.9 |
| Mercantil                                                |        12 |            1 |             10 |    97   |             83.3 |
| Nóminas                                                  |       376 |          217 |             60 |    79.9 |             16   |
| V.Adm.Proc. Gestión y comprobación Limitada              |        11 |            6 |             11 |    47.8 |            100   |
| --- Administración                                       |        25 |            4 |             19 |    41.1 |             76   |
| Actividades Laborales                                    |        77 |           69 |             61 |    39.4 |             79.2 |
| V.Adm-Liquidación de impuesto de sucesiones y donaciones |         6 |            1 |              6 |    23.9 |            100   |
| Libros de Actas y Socios                                 |       593 |          159 |             27 |    20.7 |              4.6 |
| (cat 0)                                                  |        45 |           15 |             20 |    15.1 |             44.4 |
| Dirección                                                |         2 |            0 |              2 |    13.4 |            100   |
| V. Adm - Liq. ITAJD                                      |         3 |            1 |              3 |    11.2 |            100   |
| Offboarding clientes                                     |        26 |           21 |             23 |    10   |             88.5 |
| Onboarding Laboral                                       |         7 |            5 |              5 |     9.5 |             71.4 |
| --- Juridico                                             |         1 |            1 |              1 |     6.3 |            100   |
| V. Adm. Liq. Plusvalia                                   |         2 |            1 |              2 |     5.5 |            100   |
| Expedientes Laborales                                    |         7 |            5 |              6 |     2.8 |             85.7 |
| V.Judicial - Recurso contencioso Adminstrativo           |         1 |            0 |              1 |     1.4 |            100   |
| --- DATOS                                                |         1 |            0 |              1 |     0.1 |            100   |
| GETIC                                                    |         2 |            0 |              0 |     0   |              0   |
| ---- Laboral                                             |        36 |            0 |              0 |     0   |              0   |

### 1.2 Pipeline objetivo, por anio de creacion

|   anio_creacion |   n_deals |   n_cerradas |   n_con_tiempo |   pct_con_tiempo |
|----------------:|----------:|-------------:|---------------:|-----------------:|
|            2024 |       184 |          184 |              9 |              4.9 |
|            2025 |      9466 |         9457 |           7466 |             78.9 |
|            2026 |      7573 |         7492 |           5917 |             78.1 |

Horas imputadas que cuelgan de una negociacion: 28,811.9. Horas sin negociacion: 4,066.6 (12.37 % del total).

## 2. Sesgo de redondeo del target

Reparto de las imputaciones individuales segun si su duracion en segundos es multiplo exacto de 60, 30, 15 o 5 minutos. Marca el suelo del error alcanzable: si la mayoria de las imputaciones fueran redondas, el target seria casi ordinal.

| granularidad          |     n |   pct |
|:----------------------|------:|------:|
| 1. multiplo de 60 min |   536 |  0.8  |
| 2. multiplo de 30 min |   455 |  0.68 |
| 3. multiplo de 15 min |   837 |  1.26 |
| 4. multiplo de 5 min  |  2236 |  3.35 |
| 5. valor no redondo   | 62626 | 93.91 |

Imputaciones con valor no redondo: 93.91 %.

## 3. Distribucion de `minutos_total` por proceso

Solo negociaciones del pipeline objetivo cerradas y con tiempo imputado (13,388 filas).

| proceso                     |    n |   mediana |   p25 |   p75 |   p90 |   p99 |    max |   ratio_p99_mediana |
|:----------------------------|-----:|----------:|------:|------:|------:|------:|-------:|--------------------:|
| 303                         | 3943 |       6.3 |   2.4 |  18.2 |  39.3 | 131   |  709.8 |                20.8 |
| 130                         | 1384 |       3.8 |   1.8 |   8.6 |  17.6 |  78.9 |  238.3 |                20.8 |
| 115                         | 1050 |       4.4 |   2.1 |  10.7 |  19.5 |  72.6 |  160.2 |                16.5 |
| 347                         |  992 |      19.5 |   6.8 |  57.9 | 141.4 | 411.2 | 1003.7 |                21.1 |
| 390                         |  863 |       3.8 |   1.8 |  10   |  21.5 |  79.8 |  360   |                21   |
| 200                         |  757 |       7.7 |   2.9 |  27   |  72.7 | 238.6 |  582   |                31   |
| 202                         |  706 |       2.3 |   1.5 |   5.1 |  12.5 |  40.9 |  278.5 |                17.8 |
| 111                         |  659 |       3   |   1.4 |   7.5 |  16.4 |  61   |  106.9 |                20.3 |
| 303M                        |  417 |      11.6 |   5.3 |  24.7 |  49.1 | 123.1 |  225   |                10.6 |
| 349M                        |  363 |       6   |   3.3 |  13.7 |  25.8 |  93.9 |  162.8 |                15.6 |
| 349                         |  335 |       3.5 |   1.5 |   9.8 |  23.5 | 119.7 |  281.9 |                34.2 |
| 180                         |  317 |       4   |   1.9 |   8.3 |  17.2 |  70.3 |  177.6 |                17.6 |
| 131                         |  245 |       3.1 |   1.7 |   6.6 |  12.6 |  72.2 |  166.5 |                23.3 |
| 190                         |  239 |       2.5 |   1.5 |   5.4 |  13.3 |  81.4 |  187.8 |                32.6 |
| INTRASTAT MENSUAL           |  200 |      15.6 |   8.1 |  28.2 |  48.8 | 109.5 |  178.7 |                 7   |
| 123                         |  144 |       7.3 |   2.4 |  18.4 |  42.5 |  84.7 |  137   |                11.6 |
| 115M                        |   96 |       3.6 |   2.3 |   7.4 |  14.6 |  57.7 |   70.9 |                16   |
| 193                         |   85 |       4.2 |   1.4 |  13.7 |  26.8 |  83.3 |  216.1 |                19.8 |
| 184                         |   74 |      17.1 |   7   |  47.6 |  83.3 | 185.6 |  339.3 |                10.9 |
| GASOLEO AGRICOLA            |   62 |      30.6 |  13.3 |  52.3 |  75.1 | 189.5 |  310.9 |                 6.2 |
| GASOLEO PROFESIONAL         |   59 |       9.8 |   4.8 |  22.6 |  37   | 232.3 |  266.7 |                23.7 |
| 123M                        |   41 |       3.9 |   1.9 |   7.2 |  10.4 |  20.7 |   23   |                 5.3 |
| GASOLEO PROFESIONAL MENSUAL |   39 |      12.2 |   8.6 |  19.7 |  25.1 |  39.4 |   41.2 |                 3.2 |
| 111M                        |   37 |      12.5 |   4.8 |  17.6 |  31   |  50.9 |   55   |                 4.1 |
| 232                         |   31 |      19.8 |   8.7 |  35.3 |  55.9 |  94.5 |   99.1 |                 4.8 |
| 303 Alquiler                |   25 |      21.2 |  11.9 |  32.7 |  74.7 | 140.2 |  154.2 |                 6.6 |
| 309                         |   20 |       7.4 |   4.8 |  13.7 |  19.7 |  55.9 |   64   |                 7.6 |
| 714                         |   19 |      12   |   4.5 |  35.4 |  89.1 | 193.1 |  213.9 |                16.1 |
| 210                         |   14 |      84   |  53.4 |  92.1 | 121.5 | 145.4 |  147.4 |                 1.7 |
| 216                         |   10 |       9.4 |   5.8 |  15.1 |  19.8 |  21.2 |   21.4 |                 2.3 |
| 182                         |    9 |      42   |  40.1 | 109.1 | 236.9 | 295   |  301.5 |                 7   |
| 583 3T                      |    8 |      97.6 |  50.6 | 138.9 | 161.3 | 176.3 |  177.9 |                 1.8 |
| 583 ANUAL                   |    6 |      10.4 |   7.7 |  29.4 | 105.9 | 169.3 |  176.4 |                16.3 |
| 296                         |    3 |     190.7 | 101.2 | 220.8 | 238.8 | 249.6 |  250.8 |                 1.3 |
| 210 ACE                     |    2 |      58.3 |  43.7 |  72.9 |  81.6 |  86.9 |   87.5 |                 1.5 |
| 233                         |    2 |      63.5 |  60.3 |  66.8 |  68.7 |  69.9 |   70   |                 1.1 |
| 210 ALE                     |    1 |     376.8 | 376.8 | 376.8 | 376.8 | 376.8 |  376.8 |                 1   |
| 210 SAL                     |    1 |      40   |  40   |  40   |  40   |  40   |   40   |                 1   |
| 345                         |    1 |      15.4 |  15.4 |  15.4 |  15.4 |  15.4 |   15.4 |                 1   |
| 720                         |    1 |      82.3 |  82.3 |  82.3 |  82.3 |  82.3 |   82.3 |                 1   |
| INTRASTAT                   |    1 |      25.2 |  25.2 |  25.2 |  25.2 |  25.2 |   25.2 |                 1   |

Agregado del pipeline: n = 13,388, mediana = 5.5 min, P99 = 169.4 min, maximo = 1003.7 min, ratio P99/mediana = 30.8.

## 4. Censura: reparto por estado de la negociacion

| cerrada   | semantica   |     n |   n_con_tiempo |   pct |
|:----------|:------------|------:|---------------:|------:|
| N         | (en curso)  |    90 |              4 |  0.52 |
| Y         | F           |  2257 |            250 | 13.1  |
| Y         | S           | 14876 |          13138 | 86.37 |

Negociaciones que sobreviven a los filtros de la Fase 3 (cerrada, ganada, con tiempo): 13,138 de 17,223 (76.3 %). Perdidas excluidas: 2,257.

## 5. Estacionalidad: negociaciones cerradas por trimestre natural

Ocho procesos mas frecuentes.

| trimestre   |   303 |   130 |   115 |   347 |   390 |   200 |   202 |   111 |
|:------------|------:|------:|------:|------:|------:|------:|------:|------:|
| 2025Q1      |   499 |   260 |   158 |   589 |   549 |     1 |    24 |   124 |
| 2025Q2      |   674 |   254 |   172 |     2 |     1 |     3 |   206 |   147 |
| 2025Q3      |   680 |   252 |   171 |     0 |     0 |    31 |     0 |   161 |
| 2025Q4      |   678 |   246 |   176 |     0 |     0 |     0 |   488 |   164 |
| 2026Q1      |   656 |   249 |   175 |   658 |   613 |     1 |     0 |   159 |
| 2026Q2      |   647 |   237 |   169 |     1 |     0 |   416 |   246 |   163 |
| 2026Q3      |   668 |   236 |   162 |     0 |     0 |   417 |     2 |   158 |

## 6. Concentracion por empleado

Empleados que han imputado en el pipeline objetivo: 34. Con menos de 30 negociaciones: 8.

|   user_id |   n_negociaciones |   horas |   pct_negociaciones |
|----------:|------------------:|--------:|--------------------:|
|        20 |              2000 |   273   |               14.94 |
|        24 |              1783 |   291.1 |               13.32 |
|        23 |              1539 |   502.2 |               11.5  |
|        13 |              1351 |   274.7 |               10.09 |
|        17 |              1241 |   445.3 |                9.27 |
|         9 |              1145 |   222.4 |                8.55 |
|        18 |               853 |   236.5 |                6.37 |
|         8 |               558 |   157.1 |                4.17 |
|        22 |               508 |   124.5 |                3.79 |
|        12 |               377 |    74.1 |                2.82 |
|        25 |               376 |    54.5 |                2.81 |
|        15 |               354 |    94.4 |                2.64 |
|        76 |               351 |   134   |                2.62 |
|        19 |               239 |    48.3 |                1.79 |
|        73 |               193 |    99.6 |                1.44 |
|       114 |               171 |    85.8 |                1.28 |
|        16 |               159 |    27.2 |                1.19 |
|       100 |               153 |    85.9 |                1.14 |
|         6 |               120 |    30.3 |                0.9  |
|        99 |                80 |    82.3 |                0.6  |
|       140 |                75 |    97.1 |                0.56 |
|        91 |                63 |    63.5 |                0.47 |
|       101 |                61 |    46.9 |                0.46 |
|        10 |                45 |    19.6 |                0.34 |
|       104 |                40 |     5.4 |                0.3  |
|        14 |                34 |    62.2 |                0.25 |
|        77 |                18 |     5   |                0.13 |
|        54 |                11 |     8.7 |                0.08 |
|       105 |                 8 |     8.5 |                0.06 |
|        80 |                 6 |    15.9 |                0.04 |
|       141 |                 6 |     7.5 |                0.04 |
|        21 |                 5 |    12.4 |                0.04 |
|       128 |                 3 |     1.4 |                0.02 |
|       127 |                 1 |     0   |                0.01 |

## 7. Negociaciones con mas de un empleado imputando

|   n_empleados |   n_negociaciones |
|--------------:|------------------:|
|             1 |             12874 |
|             2 |               491 |
|             3 |                21 |
|             4 |                 2 |

Porcentaje con mas de un empleado: 3.84 %.

## 8. Desfase temporal (dias)

| medida                                 |     n |   mediana |   p25 |   p75 |   p90 |   p99 |   max |
|:---------------------------------------|------:|----------:|------:|------:|------:|------:|------:|
| dias entre creacion y cierre           | 13388 |        14 |    10 |    21 |    28 |   363 |   529 |
| dias entre primera y ultima imputacion | 13388 |         0 |     0 |     0 |     2 |    21 |   537 |

## 9. Coherencia

| comprobacion                                                 |    n |   sobre |   pct |
|:-------------------------------------------------------------|-----:|--------:|------:|
| cerradas con minutos_total = 0                               | 3745 |   17223 | 21.74 |
| duracion superior a 8 h (480 min)                            |    8 |   13388 |  0.06 |
| duracion inferior a 1 min                                    |  978 |   13388 |  7.31 |
| imputaciones fuera de la ventana [creacion, cierre] del deal |  305 |   18439 |  1.65 |
| negociaciones sin cliente asignado                           |   10 |   17223 |  0.06 |

## 10. Nulos por columna (%)

| columna                  |   pct_nulos_deals |   pct_nulos_pipeline_objetivo |
|:-------------------------|------------------:|------------------------------:|
| deal_id                  |              0    |                          0    |
| pipeline_id              |              0    |                          0    |
| pipeline                 |              0    |                          0    |
| proceso                  |             32.25 |                          0.95 |
| ejercicio                |             39.31 |                         21.8  |
| periodo                  |             51.59 |                         13.72 |
| tipo_renta               |             95.91 |                        100    |
| cliente_id               |              1.37 |                          0.06 |
| responsable_id           |              0    |                          0    |
| etapa_id                 |              0    |                          0    |
| etapa                    |              0    |                          0    |
| semantica                |             13.05 |                          0    |
| cerrada                  |              0    |                          0    |
| fecha_creacion           |              0    |                          0    |
| fecha_cierre             |              0.19 |                          0    |
| dias_desde_alta_cliente  |              2.66 |                          0.1  |
| n_tareas                 |              0    |                          0    |
| n_imputaciones           |              0    |                          0    |
| n_empleados              |              0    |                          0    |
| minutos_total            |              0    |                          0    |
| minutos_max_imputacion   |              0    |                          0    |
| fecha_primera_imputacion |             26.42 |                          0    |
| fecha_ultima_imputacion  |             26.42 |                          0    |
| anio_creacion            |              0    |                        nan    |
| con_tiempo               |              0    |                        nan    |

## 11. Gate 2

| criterio                                                 | umbral     |   valor | resultado                            |
|:---------------------------------------------------------|:-----------|--------:|:-------------------------------------|
| Imputaciones no redondas                                 | > 10 %     |   93.91 | cumple                               |
| Ratio P99 / mediana (agregado del pipeline)              | se reporta |   30.8  | reportado; > 10 confirma log1p + MAE |
| Al menos un proceso con >= 100 casos cerrados con tiempo | >= 100     | 3943    | cumple                               |

## 12. Figuras

- `figuras/01_hist_log1p_minutos.png`
- `figuras/02_boxplot_por_proceso.png`
- `figuras/03_serie_cerradas_mes.png`
- `figuras/04_sesgo_redondeo.png`
