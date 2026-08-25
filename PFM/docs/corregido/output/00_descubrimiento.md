# Fase 1 - Descubrimiento del esquema

Ventana de analisis: 2025-01-01 a 2026-08-01


## A0. Tablas esperadas

| TABLE_NAME           |   TABLE_ROWS |
|:---------------------|-------------:|
| b_crm_company        |         1945 |
| b_crm_deal           |        26292 |
| b_crm_deal_category  |           37 |
| b_crm_status         |          545 |
| b_tasks              |        52228 |
| b_tasks_elapsed_time |        79136 |
| b_user_field         |          762 |
| b_user_field_enum    |         5510 |
| b_user_field_lang    |         4383 |
| b_utm_tasks_task     |       130134 |
| b_uts_crm_deal       |        32914 |


## A1. Pipelines

|   category_id | pipeline                                                 |   SORT |
|--------------:|:---------------------------------------------------------|-------:|
|            13 | Dirección                                                |    200 |
|            33 | --- Administración                                       |    300 |
|            45 | Facturación                                              |    400 |
|            46 | Offboarding clientes                                     |    500 |
|             3 | OnBoarding clientes                                      |    600 |
|            12 | Gestión Interna                                          |    700 |
|            20 | Tareas Recurrentes                                       |    900 |
|            34 | --- Contable                                             |   1000 |
|             4 | Contabilidad Interna                                     |   1100 |
|            10 | Contabilidad Externa                                     |   1200 |
|            47 | Cierres                                                  |   1400 |
|            35 | --- Fiscal                                               |   1600 |
|             6 | Modelos de impuestos                                     |   1700 |
|            30 | RENTAS                                                   |   1800 |
|             5 | Expedientes                                              |   1900 |
|            15 | Actividades                                              |   2000 |
|            16 | Cuentas Anuales                                          |   2100 |
|            17 | Libros Oficiales                                         |   2200 |
|            19 | Libros de Actas y Socios                                 |   2300 |
|            37 | --- Juridico                                             |   2400 |
|            43 | V.Adm.Proc. Gestión y comprobación Limitada              |   2500 |
|            38 | V.Adm-Liquidación de impuesto de sucesiones y donaciones |   2600 |
|            41 | V. Adm - Liq. ITAJD                                      |   2700 |
|            42 | V. Adm. Liq. Plusvalia                                   |   2800 |
|            40 | V.Judicial - Recurso contencioso Adminstrativo           |   2900 |
|            39 | Derecho Civil                                            |   3000 |
|            44 | Mercantil                                                |   3100 |
|            21 | ---- Laboral                                             |   3200 |
|            22 | Nóminas                                                  |   3300 |
|            23 | Actividades Laborales                                    |   3400 |
|            24 | Expedientes Laborales                                    |   3500 |
|            25 | Onboarding Laboral                                       |   3600 |
|            31 | --- DATOS                                                |   3700 |
|            49 | BITRIX                                                   |   3800 |
|            48 | Informe BI                                               |   3900 |
|            32 | GETIC                                                    |   4000 |
|            52 | Nuevo pipeline                                           |   4100 |


## A2. Negociaciones por pipeline y anio de creacion

|   CATEGORY_ID | pipeline                                                 |   anio |   n_deals |   n_cerradas |
|--------------:|:---------------------------------------------------------|-------:|----------:|-------------:|
|             0 | (cat 0)                                                  |   2025 |         7 |            4 |
|             0 | (cat 0)                                                  |   2026 |        38 |           11 |
|             3 | OnBoarding clientes                                      |   2025 |       100 |           96 |
|             3 | OnBoarding clientes                                      |   2026 |        82 |           41 |
|             4 | Contabilidad Interna                                     |   2025 |       547 |          393 |
|             4 | Contabilidad Interna                                     |   2026 |       497 |           53 |
|             5 | Expedientes                                              |   2025 |       418 |          270 |
|             5 | Expedientes                                              |   2026 |       562 |          317 |
|             6 | Modelos de impuestos                                     |   2025 |      9466 |         9457 |
|             6 | Modelos de impuestos                                     |   2026 |      7573 |         7492 |
|            10 | Contabilidad Externa                                     |   2025 |       320 |          121 |
|            10 | Contabilidad Externa                                     |   2026 |       348 |           15 |
|            12 | Gestión Interna                                          |   2025 |        81 |           54 |
|            12 | Gestión Interna                                          |   2026 |        43 |           11 |
|            13 | Dirección                                                |   2025 |         2 |            0 |
|            15 | Actividades                                              |   2025 |      1878 |         1699 |
|            15 | Actividades                                              |   2026 |       908 |          690 |
|            16 | Cuentas Anuales                                          |   2025 |       440 |          366 |
|            16 | Cuentas Anuales                                          |   2026 |       387 |           75 |
|            17 | Libros Oficiales                                         |   2025 |       363 |          282 |
|            17 | Libros Oficiales                                         |   2026 |       322 |           48 |
|            19 | Libros de Actas y Socios                                 |   2025 |       275 |           98 |
|            19 | Libros de Actas y Socios                                 |   2026 |       318 |           61 |
|            20 | Tareas Recurrentes                                       |   2026 |        97 |            4 |
|            21 | ---- Laboral                                             |   2025 |        36 |            0 |
|            22 | Nóminas                                                  |   2025 |       326 |          185 |
|            22 | Nóminas                                                  |   2026 |        50 |           32 |
|            23 | Actividades Laborales                                    |   2025 |        76 |           69 |
|            23 | Actividades Laborales                                    |   2026 |         1 |            0 |
|            24 | Expedientes Laborales                                    |   2025 |         7 |            5 |
|            25 | Onboarding Laboral                                       |   2025 |         7 |            5 |
|            30 | RENTAS                                                   |   2025 |      1216 |         1216 |
|            30 | RENTAS                                                   |   2026 |      1206 |         1204 |
|            31 | --- DATOS                                                |   2026 |         1 |            0 |
|            32 | GETIC                                                    |   2026 |         2 |            0 |
|            33 | --- Administración                                       |   2025 |         2 |            1 |
|            33 | --- Administración                                       |   2026 |        23 |            3 |
|            37 | --- Juridico                                             |   2025 |         1 |            1 |
|            38 | V.Adm-Liquidación de impuesto de sucesiones y donaciones |   2026 |         6 |            1 |
|            39 | Derecho Civil                                            |   2025 |         2 |            0 |
|            39 | Derecho Civil                                            |   2026 |        18 |            9 |
|            40 | V.Judicial - Recurso contencioso Adminstrativo           |   2026 |         1 |            0 |
|            41 | V. Adm - Liq. ITAJD                                      |   2026 |         3 |            1 |
|            42 | V. Adm. Liq. Plusvalia                                   |   2026 |         2 |            1 |
|            43 | V.Adm.Proc. Gestión y comprobación Limitada              |   2025 |         2 |            1 |
|            43 | V.Adm.Proc. Gestión y comprobación Limitada              |   2026 |         9 |            5 |
|            44 | Mercantil                                                |   2025 |         3 |            0 |
|            44 | Mercantil                                                |   2026 |         9 |            1 |
|            45 | Facturación                                              |   2025 |         2 |            2 |
|            45 | Facturación                                              |   2026 |         7 |            0 |
|            46 | Offboarding clientes                                     |   2026 |        26 |           21 |
|            47 | Cierres                                                  |   2025 |       851 |          851 |
|            47 | Cierres                                                  |   2026 |       815 |          531 |
|            48 | Informe BI                                               |   2026 |         4 |            1 |
|            49 | BITRIX                                                   |   2026 |        28 |            9 |


## A3. Campos personalizados de CRM_DEAL

|   field_id | FIELD_NAME                | tipo            | MULTIPLE   | etiqueta   |   n_valores |
|-----------:|:--------------------------|:----------------|:-----------|:-----------|------------:|
|        153 | UF_CRM_1653378834943      | boolean         | N          |            |           0 |
|        154 | UF_CRM_1680617870088      | file            | Y          |            |           0 |
|        155 | UF_CRM_1685692470297      | resourcebooking | Y          |            |           0 |
|        156 | UF_CRM_1686902813446      | date            | N          |            |           0 |
|        157 | UF_CRM_1715757101563      | boolean         | N          |            |           0 |
|        158 | UF_CRM_1715872169         | enumeration     | N          |            |          52 |
|        159 | UF_CRM_1718201573892      | enumeration     | N          |            |          14 |
|        160 | UF_CRM_1654277626413      | enumeration     | N          |            |           5 |
|        161 | UF_CRM_1654300700073      | file            | Y          |            |           0 |
|        225 | UF_CRM_1725611727666      | enumeration     | N          |            |          20 |
|        226 | UF_CRM_1725611868981      | enumeration     | N          |            |           6 |
|        234 | UF_CRM_1725964421788      | enumeration     | N          |            |           3 |
|        235 | UF_CRM_1725964461273      | file            | Y          |            |           0 |
|        237 | UF_CRM_1725964641531      | enumeration     | N          |            |           4 |
|        239 | UF_CRM_1725964751213      | boolean         | N          |            |           0 |
|        240 | UF_CRM_1725965071633      | file            | Y          |            |           0 |
|        251 | UF_CRM_651FDF792269E      | string          | N          |            |           0 |
|        252 | UF_CRM_651FDF78DF40E      | string          | N          |            |           0 |
|        253 | UF_CRM_651FDF79328CD      | string          | N          |            |           0 |
|        254 | UF_CRM_651FDF792A5AC      | string          | N          |            |           0 |
|        255 | UF_CRM_651FDF791B112      | string          | N          |            |           0 |
|        341 | UF_CRM_1728403293978      | enumeration     | N          |            |          16 |
|        351 | UF_CRM_1730120168         | enumeration     | Y          |            |          11 |
|        391 | UF_CRM_1731414417343      | enumeration     | Y          |            |          21 |
|        400 | UF_CRM_1731510089816      | address         | N          |            |           0 |
|        419 | UF_CRM_1733303821208      | double          | N          |            |           0 |
|        420 | UF_CRM_DEAL_1733304332549 | date            | N          |            |           0 |
|        465 | UF_CRM_1736507428836      | money           | N          |            |           0 |
|        475 | UF_CRM_1740068728         | enumeration     | N          |            |           2 |
|        477 | UF_CRM_1740136809         | enumeration     | N          |            |           2 |
|        479 | UF_CRM_1740409959         | enumeration     | N          |            |           2 |
|        481 | UF_CRM_1740583336212      | string          | N          |            |           0 |
|        482 | UF_CRM_1740583422968      | string          | N          |            |           0 |
|        483 | UF_CRM_1740583444506      | date            | N          |            |           0 |
|        484 | UF_CRM_1740583482587      | date            | N          |            |           0 |
|        485 | UF_CRM_1740583554684      | string          | N          |            |           0 |
|        496 | UF_CRM_1740585651045      | string          | N          |            |           0 |
|        497 | UF_CRM_1740585668293      | date            | N          |            |           0 |
|        498 | UF_CRM_1740585694094      | date            | N          |            |           0 |
|        499 | UF_CRM_1740585726365      | address         | N          |            |           0 |
|        500 | UF_CRM_1740585795785      | string          | N          |            |           0 |
|        501 | UF_CRM_1740585882786      | enumeration     | N          |            |           2 |
|        502 | UF_CRM_1740585909546      | enumeration     | N          |            |           2 |
|        503 | UF_CRM_1740585955047      | enumeration     | N          |            |           2 |
|        504 | UF_CRM_1740587094091      | file            | N          |            |           0 |
|        520 | UF_CRM_1741092867216      | enumeration     | N          |            |           3 |
|        526 | UF_CRM_1741263970530      | enumeration     | N          |            |          17 |
|        529 | UF_CRM_1741348398477      | enumeration     | N          |            |           4 |
|        531 | UF_CRM_1741778396780      | enumeration     | N          |            |          16 |
|        532 | UF_CRM_1741779150740      | enumeration     | N          |            |           4 |
|        533 | UF_CRM_1741780703607      | enumeration     | N          |            |           7 |
|        540 | UF_CRM_1742210700326      | string          | N          |            |           0 |
|        542 | UF_CRM_1742210780         | file            | Y          |            |           0 |
|        543 | UF_CRM_1742210817         | file            | Y          |            |           0 |
|        544 | UF_CRM_1742210840         | file            | Y          |            |           0 |
|        562 | UF_CRM_1743152414955      | enumeration     | N          |            |           7 |
|        583 | UF_CRM_1743752820178      | string          | N          |            |           0 |
|        584 | UF_CRM_1743752916474      | string          | N          |            |           0 |
|        585 | UF_CRM_1743753138486      | enumeration     | N          |            |           2 |
|        586 | UF_CRM_1743753493010      | enumeration     | N          |            |           3 |
|        587 | UF_CRM_1743753775182      | money           | N          |            |           0 |
|        598 | UF_CRM_1745997664637      | string          | N          |            |           0 |
|        599 | UF_CRM_1745997712207      | file            | N          |            |           0 |
|        600 | UF_CRM_1745997750213      | file            | N          |            |           0 |
|        604 | UF_CRM_6821D14791CCA      | boolean         | N          |            |           0 |
|        614 | UF_CRM_1748439341744      | file            | N          |            |           0 |
|        616 | UF_CRM_1748599579751      | file            | N          |            |           0 |
|        728 | UF_CRM_1757957565         | string          | N          |            |           0 |
|        730 | UF_CRM_68CD3E98BB901      | string          | N          |            |           0 |
|        731 | UF_CRM_68CD3E9937960      | string          | N          |            |           0 |
|        746 | UF_CRM_1761344488705      | enumeration     | N          |            |          11 |
|        748 | UF_CRM_1761346501581      | enumeration     | N          |            |           6 |
|        764 | UF_CRM_1762436643779      | double          | N          |            |           0 |
|        765 | UF_CRM_1762436664907      | double          | N          |            |           0 |
|        783 | UF_CRM_1773657311         | double          | N          |            |           0 |
|        787 | UF_CRM_1774518664         | file            | N          |            |           0 |
|        797 | UF_CRM_1775490299         | boolean         | N          |            |           0 |
|        799 | UF_CRM_1775490378         | money           | N          |            |           0 |
|        800 | UF_CRM_1775490424         | file            | N          |            |           0 |
|        807 | UF_CRM_1775633621620      | double          | N          |            |           0 |
|        808 | UF_CRM_1775633646854      | string          | N          |            |           0 |
|        815 | UF_CRM_1775660261         | enumeration     | N          |            |           2 |
|        817 | UF_CRM_1775722718         | file            | N          |            |           0 |
|        818 | UF_CRM_1775722734         | file            | N          |            |           0 |
|        819 | UF_CRM_1775723168         | file            | N          |            |           0 |
|        820 | UF_CRM_1775723196         | file            | N          |            |           0 |
|        826 | UF_CRM_1776687096         | employee        | Y          |            |           0 |
|        828 | UF_CRM_1776761989         | file            | N          |            |           0 |
|        830 | UF_CRM_69F84871D3119      | enumeration     | N          |            |          12 |
|        863 | UF_CRM_1779364320         | double          | N          |            |           0 |
|        866 | UF_CRM_1779364434         | string          | N          |            |           0 |
|        868 | UF_CRM_1779364464         | string          | N          |            |           0 |
|        879 | UF_CRM_1782756846699      | file            | Y          |            |           0 |


## A5. Etapas de negociacion

| ENTITY_ID     | STATUS_ID             | etapa                                                     |   SORT | semantica   |
|:--------------|:----------------------|:----------------------------------------------------------|-------:|:------------|
| DEAL_STAGE    | NEW                   | Nuevo                                                     |     10 | nan         |
| DEAL_STAGE    | PREPARATION           | Reunión / llamada                                         |     20 | nan         |
| DEAL_STAGE    | FINAL_INVOICE         | Presupuesto generado y enviado                            |     30 | nan         |
| DEAL_STAGE    | UC_7G26VA             | Presu. aceptado / preparar contrato                       |     40 | nan         |
| DEAL_STAGE    | UC_T8P44T             | Generar y enviar contratos                                |     50 | nan         |
| DEAL_STAGE    | UC_8Z3XP9             | Contratos firmados                                        |     60 | nan         |
| DEAL_STAGE    | WON                   | Completado                                                |     70 | S           |
| DEAL_STAGE    | LOSE                  | Cancelado                                                 |     80 | F           |
| DEAL_STAGE_10 | C10:UC_11I0RI         | 0. Por iniciar                                            |    100 | nan         |
| DEAL_STAGE_10 | C10:PREPARATION       | Enero                                                     |    200 | nan         |
| DEAL_STAGE_10 | C10:NEW               | Febrero                                                   |    300 | nan         |
| DEAL_STAGE_10 | C10:PREPAYMENT_INVOIC | Marzo                                                     |    400 | nan         |
| DEAL_STAGE_10 | C10:EXECUTING         | 1r Trimestre                                              |    500 | nan         |
| DEAL_STAGE_10 | C10:FINAL_INVOICE     | Abril                                                     |    600 | nan         |
| DEAL_STAGE_10 | C10:UC_3FW5S1         | Mayo                                                      |    601 | nan         |
| DEAL_STAGE_10 | C10:UC_AQB8J8         | Junio                                                     |    602 | nan         |
| DEAL_STAGE_10 | C10:UC_HL9PAV         | 2do Trimestre                                             |    603 | nan         |
| DEAL_STAGE_10 | C10:UC_WI2FVK         | Julio                                                     |    604 | nan         |
| DEAL_STAGE_10 | C10:UC_ESM94C         | Agosto                                                    |    605 | nan         |
| DEAL_STAGE_10 | C10:UC_2RRRIT         | Septiembre                                                |    606 | nan         |
| DEAL_STAGE_10 | C10:UC_6RS9DA         | 3er Trimestre                                             |    607 | nan         |
| DEAL_STAGE_10 | C10:UC_9JK0L2         | Octubre                                                   |    608 | nan         |
| DEAL_STAGE_10 | C10:UC_DQ3S0L         | Noviembre                                                 |    609 | nan         |
| DEAL_STAGE_10 | C10:UC_IGBV3C         | Diciembre                                                 |    610 | nan         |
| DEAL_STAGE_10 | C10:UC_45JUS5         | 4to Trimestre                                             |    611 | nan         |
| DEAL_STAGE_10 | C10:UC_O0XYF5         | Anual                                                     |    612 | nan         |
| DEAL_STAGE_10 | C10:WON               | Contabilidad Cerrada                                      |    700 | S           |
| DEAL_STAGE_10 | C10:LOSE              | Cerrado Perdido                                           |    800 | F           |
| DEAL_STAGE_12 | C12:NEW               | Por iniciar                                               |     10 | nan         |
| DEAL_STAGE_12 | C12:PREPARATION       | En curso                                                  |     20 | nan         |
| DEAL_STAGE_12 | C12:WON               | Cerrado Ganado                                            |     50 | S           |
| DEAL_STAGE_12 | C12:LOSE              | Cerrado Perdido                                           |     60 | F           |
| DEAL_STAGE_13 | C13:NEW               | Por iniciar                                               |     10 | nan         |
| DEAL_STAGE_13 | C13:PREPARATION       | En curso                                                  |     20 | nan         |
| DEAL_STAGE_13 | C13:WON               | Cerrado Ganado                                            |     60 | S           |
| DEAL_STAGE_13 | C13:LOSE              | Cerrado Perdido                                           |     70 | F           |
| DEAL_STAGE_15 | C15:NEW               | Por iniciar                                               |     10 | nan         |
| DEAL_STAGE_15 | C15:PREPAYMENT_INVOIC | En proceso                                                |     20 | nan         |
| DEAL_STAGE_15 | C15:UC_NG8XYY         | Facturable                                                |     30 | nan         |
| DEAL_STAGE_15 | C15:WON               | Completado                                                |     40 | S           |
| DEAL_STAGE_15 | C15:LOSE              | Cancelado                                                 |     50 | F           |
| DEAL_STAGE_16 | C16:NEW               | Por iniciar                                               |     10 | nan         |
| DEAL_STAGE_16 | C16:PREPARATION       | Generadas                                                 |     20 | nan         |
| DEAL_STAGE_16 | C16:PREPAYMENT_INVOIC | Firmadas                                                  |     30 | nan         |
| DEAL_STAGE_16 | C16:EXECUTING         | Enviar a RM                                               |     40 | nan         |
| DEAL_STAGE_16 | C16:FINAL_INVOICE     | Subsanación                                               |     50 | nan         |
| DEAL_STAGE_16 | C16:UC_PDV73Z         | Facturable                                                |     51 | nan         |
| DEAL_STAGE_16 | C16:WON               | Cerrado Ganado                                            |     60 | S           |
| DEAL_STAGE_16 | C16:LOSE              | Cerrado Perdido                                           |     70 | F           |
| DEAL_STAGE_17 | C17:NEW               | Por iniciar                                               |     10 | nan         |
| DEAL_STAGE_17 | C17:PREPARATION       | Generadas                                                 |     20 | nan         |
| DEAL_STAGE_17 | C17:PREPAYMENT_INVOIC | Enviar a RM                                               |     30 | nan         |
| DEAL_STAGE_17 | C17:EXECUTING         | Facturable                                                |     40 | nan         |
| DEAL_STAGE_17 | C17:WON               | Cerrado Ganado                                            |     60 | S           |
| DEAL_STAGE_17 | C17:LOSE              | Cerrado Perdido                                           |     70 | F           |
| DEAL_STAGE_19 | C19:NEW               | Por iniciar                                               |     10 | nan         |
| DEAL_STAGE_19 | C19:PREPARATION       | Generadas                                                 |     20 | nan         |
| DEAL_STAGE_19 | C19:PREPAYMENT_INVOIC | Enviar a RM                                               |     30 | nan         |
| DEAL_STAGE_19 | C19:FINAL_INVOICE     | Facturable                                                |     50 | nan         |
| DEAL_STAGE_19 | C19:WON               | Cerrado Ganado                                            |     60 | S           |
| DEAL_STAGE_19 | C19:LOSE              | Cerrado Perdido                                           |     70 | F           |
| DEAL_STAGE_20 | C20:NEW               | Por iniciar                                               |     10 | nan         |
| DEAL_STAGE_20 | C20:PREPARATION       | En curso                                                  |     20 | nan         |
| DEAL_STAGE_20 | C20:WON               | Cerrado Ganado                                            |     60 | S           |
| DEAL_STAGE_20 | C20:LOSE              | Cerrado Perdido                                           |     70 | F           |
| DEAL_STAGE_21 | C21:NEW               | ----                                                      |     10 | nan         |
| DEAL_STAGE_21 | C21:WON               | Cerrado Ganado                                            |     60 | S           |
| DEAL_STAGE_21 | C21:LOSE              | Cerrado Perdido                                           |     70 | F           |
| DEAL_STAGE_22 | C22:NEW               | Por iniciar                                               |     10 | nan         |
| DEAL_STAGE_22 | C22:PREPARATION       | En curso                                                  |     20 | nan         |
| DEAL_STAGE_22 | C22:UC_98MWS5         | Enviado y confirmado                                      |     30 | nan         |
| DEAL_STAGE_22 | C22:WON               | Cerrado Ganado                                            |     80 | S           |
| DEAL_STAGE_22 | C22:LOSE              | Cerrado Perdido                                           |     90 | F           |
| DEAL_STAGE_23 | C23:NEW               | Por iniciar                                               |     10 | nan         |
| DEAL_STAGE_23 | C23:PREPARATION       | En proceso                                                |     20 | nan         |
| DEAL_STAGE_23 | C23:PREPAYMENT_INVOIC | Facturable                                                |     30 | nan         |
| DEAL_STAGE_23 | C23:WON               | Cerrado Ganado                                            |     60 | S           |
| DEAL_STAGE_23 | C23:LOSE              | Cerrado Perdido                                           |     70 | F           |
| DEAL_STAGE_24 | C24:NEW               | Por iniciar                                               |     10 | nan         |
| DEAL_STAGE_24 | C24:PREPARATION       | En proceso                                                |     20 | nan         |
| DEAL_STAGE_24 | C24:PREPAYMENT_INVOIC | Atendido / Presentado                                     |     30 | nan         |
| DEAL_STAGE_24 | C24:EXECUTING         | Pendiente respuesta terceros                              |     40 | nan         |
| DEAL_STAGE_24 | C24:FINAL_INVOICE     | Facturable                                                |     50 | nan         |
| DEAL_STAGE_24 | C24:WON               | Cerrado Ganado                                            |     60 | S           |
| DEAL_STAGE_24 | C24:LOSE              | Cerrado Perdido                                           |     70 | F           |
| DEAL_STAGE_25 | C25:NEW               | Por iniciar                                               |     10 | nan         |
| DEAL_STAGE_25 | C25:PREPARATION       | Solicitar datos del cliente                               |     20 | nan         |
| DEAL_STAGE_25 | C25:PREPAYMENT_INVOIC | Dar de alta en aplicaciones                               |     30 | nan         |
| DEAL_STAGE_25 | C25:UC_NE7HBR         | Enviar contrato y notificar alta                          |     40 | nan         |
| DEAL_STAGE_25 | C25:UC_79J6AU         | Auditoria Laboral                                         |     50 | nan         |
| DEAL_STAGE_25 | C25:UC_FZN526         | Facturable                                                |     60 | nan         |
| DEAL_STAGE_25 | C25:WON               | Cerrado Ganado                                            |     70 | S           |
| DEAL_STAGE_25 | C25:LOSE              | Cerrado Perdido                                           |     80 | F           |
| DEAL_STAGE_25 | C25:APOLOGY           | Analizar la falla                                         |     90 | F           |
| DEAL_STAGE_3  | C3:UC_IBFKJK          | Comnprobar datos para el Onboarding                       |     10 | nan         |
| DEAL_STAGE_3  | C3:UC_5EP9MX          | Dar de Alta en Aplicaciones                               |     20 | nan         |
| DEAL_STAGE_3  | C3:NEW                | Enviar contrato y seguimiento                             |     30 | nan         |
| DEAL_STAGE_3  | C3:WON                | Completado                                                |     40 | S           |
| DEAL_STAGE_3  | C3:LOSE               | Cancelado                                                 |     50 | F           |
| DEAL_STAGE_30 | C30:NEW               | Por iniciar - Falta pago                                  |    100 | nan         |
| DEAL_STAGE_30 | C30:PREPARATION       | Pagada / Facturable                                       |    200 | nan         |
| DEAL_STAGE_30 | C30:PREPAYMENT_INVOIC | Datos Fiscales / Importacion                              |    300 | nan         |
| DEAL_STAGE_30 | C30:EXECUTING         | Revision Datos / Elaboracion                              |    400 | nan         |
| DEAL_STAGE_30 | C30:FINAL_INVOICE     | Conformidad cliente y presentacion                        |    500 | nan         |
| DEAL_STAGE_30 | C30:WON               | Presentada                                                |    600 | S           |
| DEAL_STAGE_30 | C30:LOSE              | NO presentada                                             |    700 | F           |
| DEAL_STAGE_31 | C31:NEW               | ----                                                      |     10 | nan         |
| DEAL_STAGE_31 | C31:UC_KFUCZI         | Prueba1                                                   |     11 | nan         |
| DEAL_STAGE_31 | C31:UC_RLFAJA         | Prueba2                                                   |     12 | nan         |
| DEAL_STAGE_31 | C31:WON               | Cerrado Ganado                                            |     60 | S           |
| DEAL_STAGE_31 | C31:LOSE              | Cerrado Perdido                                           |     70 | F           |
| DEAL_STAGE_31 | C31:APOLOGY           | Analizar la falla                                         |     80 | F           |
| DEAL_STAGE_32 | C32:NEW               | Analisis previo                                           |     10 | nan         |
| DEAL_STAGE_32 | C32:PREPARATION       | Reunión cliente                                           |     20 | nan         |
| DEAL_STAGE_32 | C32:PREPAYMENT_INVOIC | Tratamiento datos                                         |     30 | nan         |
| DEAL_STAGE_32 | C32:WON               | Cerrado Ganado                                            |     60 | S           |
| DEAL_STAGE_32 | C32:LOSE              | Cerrado Perdido                                           |     70 | F           |
| DEAL_STAGE_32 | C32:APOLOGY           | Analizar la falla                                         |     80 | F           |
| DEAL_STAGE_33 | C33:NEW               | En desarrollo                                             |     10 | nan         |
| DEAL_STAGE_33 | C33:PREPARATION       | Crear documentos                                          |     20 | nan         |
| DEAL_STAGE_33 | C33:PREPAYMENT_INVOIC | Factura                                                   |     30 | nan         |
| DEAL_STAGE_33 | C33:EXECUTING         | En progreso                                               |     40 | nan         |
| DEAL_STAGE_33 | C33:FINAL_INVOICE     | Factura final                                             |     50 | nan         |
| DEAL_STAGE_33 | C33:WON               | Cerrado Ganado                                            |     60 | S           |
| DEAL_STAGE_33 | C33:LOSE              | Cerrado Perdido                                           |     70 | F           |
| DEAL_STAGE_33 | C33:APOLOGY           | Analizar la falla                                         |     80 | F           |
| DEAL_STAGE_34 | C34:NEW               | En desarrollo                                             |     10 | nan         |
| DEAL_STAGE_34 | C34:PREPARATION       | Crear documentos                                          |     20 | nan         |
| DEAL_STAGE_34 | C34:PREPAYMENT_INVOIC | Factura                                                   |     30 | nan         |
| DEAL_STAGE_34 | C34:EXECUTING         | En progreso                                               |     40 | nan         |
| DEAL_STAGE_34 | C34:FINAL_INVOICE     | Factura final                                             |     50 | nan         |
| DEAL_STAGE_34 | C34:WON               | Cerrado Ganado                                            |     60 | S           |
| DEAL_STAGE_34 | C34:LOSE              | Cerrado Perdido                                           |     70 | F           |
| DEAL_STAGE_34 | C34:APOLOGY           | Analizar la falla                                         |     80 | F           |
| DEAL_STAGE_35 | C35:NEW               | En desarrollo                                             |     10 | nan         |
| DEAL_STAGE_35 | C35:PREPARATION       | Crear documentos                                          |     20 | nan         |
| DEAL_STAGE_35 | C35:PREPAYMENT_INVOIC | Factura                                                   |     30 | nan         |
| DEAL_STAGE_35 | C35:EXECUTING         | En progreso                                               |     40 | nan         |
| DEAL_STAGE_35 | C35:FINAL_INVOICE     | Factura final                                             |     50 | nan         |
| DEAL_STAGE_35 | C35:WON               | Cerrado Ganado                                            |     60 | S           |
| DEAL_STAGE_35 | C35:LOSE              | Cerrado Perdido                                           |     70 | F           |
| DEAL_STAGE_35 | C35:APOLOGY           | Analizar la falla                                         |     80 | F           |
| DEAL_STAGE_37 | C37:NEW               | ----                                                      |     10 | nan         |
| DEAL_STAGE_37 | C37:WON               | Cerrado Ganado                                            |     60 | S           |
| DEAL_STAGE_37 | C37:LOSE              | Cerrado Perdido                                           |     70 | F           |
| DEAL_STAGE_37 | C37:APOLOGY           | Analizar la falla                                         |     80 | F           |
| DEAL_STAGE_38 | C38:UC_5P58LM         | ENCARGO DE TRABAJO - PROVISION                            |     10 | nan         |
| DEAL_STAGE_38 | C38:NEW               | Recopilación de la información // formacion de inventario |     20 | nan         |
| DEAL_STAGE_38 | C38:PREPARATION       | Contacto con la notaria                                   |     30 | nan         |
| DEAL_STAGE_38 | C38:PREPAYMENT_INVOIC | Estimacion impuesto                                       |     40 | nan         |
| DEAL_STAGE_38 | C38:EXECUTING         | Estimacion plusvalia municipal // IRPF                    |     50 | nan         |
| DEAL_STAGE_38 | C38:FINAL_INVOICE     | Firma Escritura Pública                                   |     60 | nan         |
| DEAL_STAGE_38 | C38:UC_5NTQCQ         | Liquidacion y pago Modelo 650                             |     70 | nan         |
| DEAL_STAGE_38 | C38:UC_UVRSQF         | liquidacion y pago IIVTNU                                 |     80 | nan         |
| DEAL_STAGE_38 | C38:UC_KMIDA3         | Actuaciones registro de la propiedad                      |     90 | nan         |
| DEAL_STAGE_38 | C38:UC_2365AE         | Facturable                                                |    100 | nan         |
| DEAL_STAGE_38 | C38:WON               | Cerrado Ganado                                            |    110 | S           |
| DEAL_STAGE_38 | C38:LOSE              | Cerrado Perdido                                           |    120 | F           |
| DEAL_STAGE_38 | C38:APOLOGY           | Analizar la falla                                         |    130 | F           |
| DEAL_STAGE_39 | C39:NEW               | Hoja de Encargo  // provisión                             |     10 | nan         |
| DEAL_STAGE_39 | C39:PREPARATION       | En proceso                                                |     20 | nan         |
| DEAL_STAGE_39 | C39:EXECUTING         | Facturable                                                |     40 | nan         |
| DEAL_STAGE_39 | C39:WON               | Cerrado Ganado                                            |     60 | S           |
| DEAL_STAGE_39 | C39:LOSE              | Cerrado Perdido                                           |     70 | F           |
| DEAL_STAGE_39 | C39:APOLOGY           | Analizar la falla                                         |     80 | F           |
| DEAL_STAGE_4  | C4:UC_OUW4G5          | Por iniciar                                               |     10 | nan         |
| DEAL_STAGE_4  | C4:NEW                | Enero                                                     |     20 | nan         |
| DEAL_STAGE_4  | C4:UC_PY69X3          | Febrero                                                   |     30 | nan         |
| DEAL_STAGE_4  | C4:UC_0HH032          | Marzo                                                     |     40 | nan         |
| DEAL_STAGE_4  | C4:UC_ZHHART          | 1r Trimestre                                              |     50 | nan         |
| DEAL_STAGE_4  | C4:UC_MKCDIV          | Abril                                                     |     60 | nan         |
| DEAL_STAGE_4  | C4:UC_KU83U1          | Mayo                                                      |     70 | nan         |
| DEAL_STAGE_4  | C4:UC_GTAL7P          | Junio                                                     |     80 | nan         |
| DEAL_STAGE_4  | C4:UC_WDWR7W          | 2º Trimestre                                              |     90 | nan         |
| DEAL_STAGE_4  | C4:UC_9SGHER          | Julio                                                     |    100 | nan         |
| DEAL_STAGE_4  | C4:UC_04XH69          | Agosto                                                    |    110 | nan         |
| DEAL_STAGE_4  | C4:UC_L7QE31          | Septiembre                                                |    120 | nan         |
| DEAL_STAGE_4  | C4:UC_MW3FWU          | 3r Trimestre                                              |    130 | nan         |
| DEAL_STAGE_4  | C4:UC_GV57VD          | Octubre                                                   |    140 | nan         |
| DEAL_STAGE_4  | C4:UC_BX02QH          | Noviembre                                                 |    150 | nan         |
| DEAL_STAGE_4  | C4:UC_H3I7J9          | Diciembre                                                 |    160 | nan         |
| DEAL_STAGE_4  | C4:UC_BETPL9          | 4º Trimestre                                              |    170 | nan         |
| DEAL_STAGE_4  | C4:UC_3ZQP7Y          | Anual                                                     |    180 | nan         |
| DEAL_STAGE_4  | C4:WON                | Contabilidad cerrada                                      |    190 | S           |
| DEAL_STAGE_4  | C4:LOSE               | Cancelada                                                 |    200 | F           |
| DEAL_STAGE_40 | C40:NEW               | Encargo de trabajo                                        |     10 | nan         |
| DEAL_STAGE_40 | C40:PREPARATION       | Estudio line defensa                                      |     20 | nan         |
| DEAL_STAGE_40 | C40:PREPAYMENT_INVOIC | Otorgamiento poder a pleitos                              |     30 | nan         |
| DEAL_STAGE_40 | C40:EXECUTING         | Interposición del Recurso                                 |     40 | nan         |
| DEAL_STAGE_40 | C40:UC_CIKI8D         | Demanda                                                   |     41 | nan         |
| DEAL_STAGE_40 | C40:UC_NC3W4Y         | Conclusiones                                              |     42 | nan         |
| DEAL_STAGE_40 | C40:UC_C8YRAI         | Vista Oral                                                |     43 | nan         |
| DEAL_STAGE_40 | C40:UC_2DCJZI         | Incidente de Ejecución                                    |     44 | nan         |
| DEAL_STAGE_40 | C40:UC_L381N6         | Recurso de Apelación                                      |     45 | nan         |
| DEAL_STAGE_40 | C40:UC_RRN5FC         | Recurso de Casación                                       |     46 | nan         |
| DEAL_STAGE_40 | C40:UC_VNKD0F         | Tasación de costas                                        |     47 | nan         |
| DEAL_STAGE_40 | C40:FINAL_INVOICE     | Facturable                                                |     50 | nan         |
| DEAL_STAGE_40 | C40:WON               | Cerrado Ganado                                            |     60 | S           |
| DEAL_STAGE_40 | C40:LOSE              | Cerrado Perdido                                           |     70 | F           |
| DEAL_STAGE_40 | C40:APOLOGY           | Analizar la falla                                         |     80 | F           |


## A6a. Campos UF_CRM de TASKS_TASK

|   field_id | FIELD_NAME   | ENTITY_ID   |
|-----------:|:-------------|:------------|
|          6 | UF_CRM_TASK  | TASKS_TASK  |


## A6b. Prefijos de enlace en b_utm_tasks_task

| prefijo   |     n |
|:----------|------:|
| D         | 54479 |
| CO        | 47054 |
| nan       | 31639 |
| C         |  1489 |
| L         |   499 |
| T42c      |   426 |
| T41a      |    84 |
| T43a      |    23 |
| T436      |    18 |
| T456      |     2 |


## A7. Horas imputadas por pipeline (cadena completa)

|   CATEGORY_ID | pipeline                                                 |   deals_con_tiempo |   tareas |   imputaciones |   empleados |   horas |
|--------------:|:---------------------------------------------------------|-------------------:|---------:|---------------:|------------:|--------:|
|             4 | Contabilidad Interna                                     |               1172 |     6408 |          12957 |          36 |  7750.8 |
|            12 | Gestión Interna                                          |                114 |     3642 |           8421 |          40 |  5782.2 |
|             6 | Modelos de impuestos                                     |              13398 |    13886 |          18446 |          34 |  3703   |
|            15 | Actividades                                              |               2647 |     4254 |           7602 |          35 |  3230.6 |
|            30 | RENTAS                                                   |               1962 |     3699 |           5903 |          27 |  2290   |
|             5 | Expedientes                                              |                771 |     1519 |           3124 |          32 |  2199.9 |
|            47 | Cierres                                                  |                905 |     1465 |           2920 |          28 |  1911.7 |
|            10 | Contabilidad Externa                                     |                306 |      742 |           1193 |          24 |   685.1 |
|            16 | Cuentas Anuales                                          |                624 |      768 |           1598 |          14 |   482.3 |
|            45 | Facturación                                              |                  8 |      284 |            941 |           5 |   438.7 |
|            20 | Tareas Recurrentes                                       |                 79 |      699 |            707 |          20 |   397.6 |
|            49 | BITRIX                                                   |                 20 |       99 |            347 |          14 |   359.3 |
|             3 | OnBoarding clientes                                      |                175 |      415 |            873 |           7 |   242.9 |
|            48 | Informe BI                                               |                  4 |       14 |            119 |           1 |   222.7 |
|            13 | Dirección                                                |                  5 |      116 |            171 |           2 |   199.3 |
|            39 | Derecho Civil                                            |                 20 |       84 |            220 |           3 |   186.2 |
|            17 | Libros Oficiales                                         |                287 |      301 |            463 |          11 |   135.9 |
|            44 | Mercantil                                                |                 10 |       32 |             83 |           4 |    97   |
|            22 | Nóminas                                                  |                 60 |       63 |             92 |           1 |    79.9 |
|            43 | V.Adm.Proc. Gestión y comprobación Limitada              |                 11 |       43 |             75 |           3 |    47.8 |
|            33 | --- Administración                                       |                 19 |       36 |             82 |           4 |    41.1 |
|            23 | Actividades Laborales                                    |                 61 |       62 |             84 |           4 |    39.4 |
|            38 | V.Adm-Liquidación de impuesto de sucesiones y donaciones |                  6 |       13 |             32 |           2 |    23.9 |
|            19 | Libros de Actas y Socios                                 |                 27 |       30 |             67 |           4 |    20.7 |
|             0 | (cat 0)                                                  |                 20 |       22 |             47 |           6 |    15.1 |
|            41 | V. Adm - Liq. ITAJD                                      |                  3 |       10 |             14 |           1 |    11.2 |
|            46 | Offboarding clientes                                     |                 23 |       31 |             42 |           3 |    10   |
|            25 | Onboarding Laboral                                       |                  5 |        6 |             12 |           1 |     9.5 |
|            37 | --- Juridico                                             |                  1 |        1 |              1 |           1 |     6.3 |
|            42 | V. Adm. Liq. Plusvalia                                   |                  2 |        6 |             13 |           1 |     5.5 |
|            24 | Expedientes Laborales                                    |                  6 |        6 |             10 |           2 |     2.8 |
|            40 | V.Judicial - Recurso contencioso Adminstrativo           |                  1 |        1 |              1 |           1 |     1.4 |
|            31 | --- DATOS                                                |                  1 |        1 |              1 |           1 |     0.1 |


## A8. Tiempo con y sin negociacion

| enlace          |   imputaciones |   horas |
|:----------------|---------------:|--------:|
| con negociacion |          66696 | 30656.8 |
| sin negociacion |           6413 |  4066.6 |


## A9. Sesgo de redondeo de las imputaciones

| granularidad          |     n |
|:----------------------|------:|
| 1. multiplo de 60 min |   589 |
| 2. multiplo de 30 min |   500 |
| 3. multiplo de 15 min |   900 |
| 4. multiplo de 5 min  |  2463 |
| 5. valor no redondo   | 68654 |


## A10. Tareas con enlace a mas de una negociacion

|   n_deals_por_tarea |   n_tareas |
|--------------------:|-----------:|
|                   1 |      54469 |
|                   2 |          5 |
