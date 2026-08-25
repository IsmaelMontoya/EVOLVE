# Fase 1 - Resumen de extraccion
Ventana de extraccion: desde 2025-01-01. Generado por `src/01_extraccion.py`.

## 1. Campos personalizados localizados

Localizados en `b_user_field` (`ENTITY_ID = 'CRM_DEAL'`); los valores de lista se resuelven contra `b_user_field_enum` y se exporta el texto legible, no el id de enum.

| concepto                         |   field_id | nombre_tecnico       | tipo        |   n_valores |
|:---------------------------------|-----------:|:---------------------|:------------|------------:|
| proceso (modelo presentado)      |        158 | UF_CRM_1715872169    | enumeration |          52 |
| ejercicio                        |        526 | UF_CRM_1741263970530 | enumeration |          17 |
| periodo                          |        225 | UF_CRM_1725611727666 | enumeration |          20 |
| tipo_renta (Individual/Conjunta) |        586 | UF_CRM_1743753493010 | enumeration |           3 |

Los valores UF de negociacion residen en `b_uts_crm_deal`. El puente tarea -> CRM es `b_utm_tasks_task` con `FIELD_ID = 6` (`UF_CRM_TASK`); la tabla `b_utm_task` que asumia la guia no existe en este esquema (ver B-001).

## 2. Filas exportadas

| archivo          |   filas |   columnas |
|:-----------------|--------:|-----------:|
| deals.csv        |   30836 |         23 |
| imputaciones.csv |   66690 |          6 |
| no_asignado.csv  |      20 |          3 |

## 3. Volumen por pipeline

|   pipeline_id | pipeline                                                 |   n_deals |   n_cerradas |   n_con_tiempo |   horas |
|--------------:|:---------------------------------------------------------|----------:|-------------:|---------------:|--------:|
|             4 | Contabilidad Interna                                     |      1472 |          871 |           1155 |  7720.7 |
|            12 | Gestión Interna                                          |       130 |           68 |            110 |  4250   |
|             6 | Modelos de impuestos                                     |     17223 |        17133 |          13392 |  3699.4 |
|            15 | Actividades                                              |      2956 |         2552 |           2633 |  3188.1 |
|            30 | RENTAS                                                   |      2422 |         2420 |           1962 |  2290   |
|             5 | Expedientes                                              |      1041 |          638 |            766 |  2192.3 |
|            47 | Cierres                                                  |      1666 |         1382 |            905 |  1911.7 |
|            10 | Contabilidad Externa                                     |       822 |          289 |            291 |   669.6 |
|            16 | Cuentas Anuales                                          |       828 |          442 |            624 |   482.3 |
|            45 | Facturación                                              |         9 |            2 |              8 |   438.7 |
|            20 | Tareas Recurrentes                                       |        97 |            4 |             79 |   397.6 |
|            49 | BITRIX                                                   |        28 |            9 |             20 |   359.3 |
|             3 | OnBoarding clientes                                      |       184 |          139 |            174 |   242.1 |
|            48 | Informe BI                                               |         4 |            1 |              4 |   222.7 |
|            39 | Derecho Civil                                            |        20 |            9 |             20 |   186.2 |
|            17 | Libros Oficiales                                         |       701 |          346 |            287 |   135.9 |
|            44 | Mercantil                                                |        12 |            1 |             10 |    97   |
|            22 | Nóminas                                                  |       376 |          217 |             60 |    79.9 |
|            43 | V.Adm.Proc. Gestión y comprobación Limitada              |        11 |            6 |             11 |    47.8 |
|            33 | --- Administración                                       |        25 |            4 |             19 |    41.1 |
|            23 | Actividades Laborales                                    |        77 |           69 |             61 |    39.4 |
|            38 | V.Adm-Liquidación de impuesto de sucesiones y donaciones |         6 |            1 |              6 |    23.9 |
|            19 | Libros de Actas y Socios                                 |       593 |          159 |             27 |    20.7 |
|             0 | (cat 0)                                                  |        45 |           15 |             20 |    15.1 |
|            13 | Dirección                                                |         2 |            0 |              2 |    13.4 |
|            41 | V. Adm - Liq. ITAJD                                      |         3 |            1 |              3 |    11.2 |
|            46 | Offboarding clientes                                     |        26 |           21 |             23 |    10   |
|            25 | Onboarding Laboral                                       |         7 |            5 |              5 |     9.5 |
|            37 | --- Juridico                                             |         1 |            1 |              1 |     6.3 |
|            42 | V. Adm. Liq. Plusvalia                                   |         2 |            1 |              2 |     5.5 |
|            24 | Expedientes Laborales                                    |         7 |            5 |              6 |     2.8 |
|            40 | V.Judicial - Recurso contencioso Adminstrativo           |         1 |            0 |              1 |     1.4 |
|            31 | --- DATOS                                                |         1 |            0 |              1 |     0.1 |
|            21 | ---- Laboral                                             |        36 |            0 |              0 |     0   |
|            32 | GETIC                                                    |         2 |            0 |              0 |     0   |

## 4. Pipeline objetivo: Modelos de impuestos

Negociaciones del pipeline: 17,223. Cerradas con tiempo imputado: 13,388.

| proceso                     |    n |   mediana_min |
|:----------------------------|-----:|--------------:|
| 303                         | 3943 |           6.4 |
| 130                         | 1384 |           3.8 |
| 115                         | 1050 |           4.4 |
| 347                         |  992 |          19.5 |
| 390                         |  863 |           3.8 |
| 200                         |  757 |           7.7 |
| 202                         |  706 |           2.3 |
| 111                         |  659 |           3   |
| 303M                        |  417 |          11.6 |
| 349M                        |  363 |           6   |
| 349                         |  335 |           3.5 |
| 180                         |  317 |           4   |
| 131                         |  245 |           3.1 |
| 190                         |  239 |           2.5 |
| INTRASTAT MENSUAL           |  200 |          15.6 |
| 123                         |  144 |           7.3 |
| 115M                        |   96 |           3.6 |
| 193                         |   85 |           4.2 |
| 184                         |   74 |          17.1 |
| GASOLEO AGRICOLA            |   62 |          30.6 |
| GASOLEO PROFESIONAL         |   59 |           9.8 |
| 123M                        |   41 |           3.9 |
| GASOLEO PROFESIONAL MENSUAL |   39 |          12.2 |
| 111M                        |   37 |          12.5 |
| 232                         |   31 |          19.8 |
| 303 Alquiler                |   25 |          21.2 |
| 309                         |   20 |           7.4 |
| 714                         |   19 |          12   |
| 210                         |   14 |          84   |
| 216                         |   10 |           9.4 |
| 182                         |    9 |          42   |
| 583 3T                      |    8 |          97.6 |
| 583 ANUAL                   |    6 |          10.4 |
| 296                         |    3 |         190.7 |
| 210 ACE                     |    2 |          58.3 |
| 233                         |    2 |          63.5 |
| 210 ALE                     |    1 |         376.8 |
| 210 SAL                     |    1 |          40   |
| 345                         |    1 |          15.4 |
| 720                         |    1 |          82.3 |
| INTRASTAT                   |    1 |          25.2 |

## 5. Cobertura del tiempo

| enlace          |   n_imputaciones |   horas |
|:----------------|-----------------:|--------:|
| con negociacion |            66693 | 30654.8 |
| sin negociacion |             6413 |  4066.6 |

Horas sin negociacion asociada: 11.71 % del total imputado desde 2025-01-01.

Tareas enlazadas a mas de una negociacion: 5. Imputaciones descartadas por esa regla: 3 (1.98 h).

## 6. Nulos en deals.csv (%)

| columna                  |   pct_nulos |
|:-------------------------|------------:|
| deal_id                  |        0    |
| pipeline_id              |        0    |
| pipeline                 |        0    |
| proceso                  |       32.25 |
| ejercicio                |       39.31 |
| periodo                  |       51.59 |
| tipo_renta               |       95.91 |
| cliente_id               |        1.37 |
| responsable_id           |        0    |
| etapa_id                 |        0    |
| etapa                    |        0    |
| semantica                |       13.05 |
| cerrada                  |        0    |
| fecha_creacion           |        0    |
| fecha_cierre             |        0.19 |
| dias_desde_alta_cliente  |        2.66 |
| n_tareas                 |        0    |
| n_imputaciones           |        0    |
| n_empleados              |        0    |
| minutos_total            |        0    |
| minutos_max_imputacion   |        0    |
| fecha_primera_imputacion |       26.42 |
| fecha_ultima_imputacion  |       26.42 |

## 7. Gate 1

| criterio                                                             | umbral   |    valor | resultado   |
|:---------------------------------------------------------------------|:---------|---------:|:------------|
| Filas del pipeline 'Modelos de impuestos' en deals.csv               | > 0      | 17223    | cumple      |
| Negociaciones cerradas con minutos_total > 0 en el pipeline objetivo | >= 500   | 13388    | cumple      |
| Valores distintos de 'proceso' con >= 30 casos                       | >= 3     |    25    | cumple      |
| Horas que no cuelgan de ninguna negociacion                          | < 40 %   |    11.71 | cumple      |

## 8. Avisos

- Negociaciones cerradas con tiempo del pipeline objetivo sin valor de 'proceso': 127.
- Idem sin valor de 'ejercicio': 2,918.
- Negociaciones del pipeline objetivo con mas de 480 min (8 h) imputados: 8.
- Negociaciones cerradas del pipeline objetivo con 0 min imputados: 3,745.
