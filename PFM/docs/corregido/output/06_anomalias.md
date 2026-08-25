# Fase 6 - Anomalias y validacion con experto

Generado por `src/06_anomalias.py`. Se aplica sobre las 6,192 negociaciones de test (cerradas en 2026), que es el escenario de uso: control al cerrar la campana.

## 1. Definicion

La anomalia no es un segundo modelo. Es el residuo del modelo de planificacion de la Fase 5, estandarizado por la dispersion propia de cada proceso:

```
residuo    = minutos_reales - minutos_predichos
sigma_proc = desviacion tipica de los residuos de train, por proceso
z          = residuo / sigma_proc
anomalia   = |z| > 3
```

La sigma se estima con los residuos out-of-fold de train (GroupKFold por cliente). Usar residuos dentro de muestra la subestimaria y elevaria la tasa de marcado de forma artificial. Los procesos con menos de 20 casos en train usan la sigma global (32.09 min) en lugar de la suya.

## 2. Tasa de marcado

Tasa global: **3.86 %** (239 de 6,192 negociaciones de test).

| tipo   |    n |   pct |
|:-------|-----:|------:|
| normal | 5953 | 96.14 |
| exceso |  239 |  3.86 |

Las marcadas por exceso (z > 3) son negociaciones que han consumido mucho mas tiempo del estimado. Las marcadas por defecto (z < -3) apuntarian a infraimputacion: trabajo hecho que no se ha registrado.

No hay ninguna marcada por defecto, y no es un hallazgo sobre los datos sino una consecuencia aritmetica de la definicion. Los minutos no son negativos, asi que el residuo no puede bajar de `-prediccion_min`; con predicciones de pocos minutos y sigmas de decenas de minutos, el valor mas negativo que z puede tomar en todo el conjunto de test es -0.043, muy lejos de -3. **En escala de minutos, esta definicion solo puede detectar exceso.**

Por eso se calcula tambien la misma regla sobre el residuo en escala `log1p`, donde el residuo si es simetrico (seccion 4, rama b).

## 3. Tasa de marcado por proceso

| proceso                     |   n_test |   n_marcadas |   n_exceso |   n_defecto |   sigma_train |   pct_marcadas |
|:----------------------------|---------:|-------------:|-----------:|------------:|--------------:|---------------:|
| 303                         |     1712 |           59 |         59 |           0 |         27.41 |           3.45 |
| 200                         |      720 |           47 |         47 |           0 |         29.95 |           6.53 |
| 130                         |      605 |           21 |         21 |           0 |         13.59 |           3.47 |
| 390                         |      476 |            6 |          6 |           0 |         24.32 |           1.26 |
| 347                         |      460 |           13 |         13 |           0 |         92.88 |           2.83 |
| 115                         |      446 |           13 |         13 |           0 |         11.5  |           2.91 |
| 111                         |      276 |           12 |         12 |           0 |         10.32 |           4.35 |
| 303M                        |      181 |            6 |          6 |           0 |         24.43 |           3.31 |
| 202                         |      173 |            1 |          1 |           0 |         14.5  |           0.58 |
| 180                         |      164 |            7 |          7 |           0 |          8.57 |           4.27 |
| 349M                        |      155 |            9 |          9 |           0 |         12.03 |           5.81 |
| 349                         |      148 |            3 |          3 |           0 |         27.94 |           2.03 |
| 131                         |      105 |            1 |          1 |           0 |         17.85 |           0.95 |
| 190                         |      104 |           13 |         13 |           0 |          5.26 |          12.5  |
| INTRASTAT MENSUAL           |       83 |            7 |          7 |           0 |         16.55 |           8.43 |
| 123                         |       56 |            3 |          3 |           0 |         18.5  |           5.36 |
| 115M                        |       46 |            2 |          2 |           0 |          9.97 |           4.35 |
| 193                         |       45 |            1 |          1 |           0 |         12.59 |           2.22 |
| 184                         |       38 |            2 |          2 |           0 |         35.76 |           5.26 |
| 111M                        |       36 |            0 |          0 |           0 |         32.09 |           0    |
| GASOLEO PROFESIONAL         |       29 |            2 |          2 |           0 |         40.33 |           6.9  |
| GASOLEO AGRICOLA            |       26 |            6 |          6 |           0 |         19.62 |          23.08 |
| 303 Alquiler                |       25 |            1 |          1 |           0 |         32.09 |           4    |
| 123M                        |       18 |            0 |          0 |           0 |          6.73 |           0    |
| 714                         |       16 |            1 |          1 |           0 |         32.09 |           6.25 |
| GASOLEO PROFESIONAL MENSUAL |       15 |            0 |          0 |           0 |          9.06 |           0    |
| 309                         |       10 |            0 |          0 |           0 |         32.09 |           0    |
| 210                         |        7 |            0 |          0 |           0 |         32.09 |           0    |
| 216                         |        6 |            0 |          0 |           0 |         32.09 |           0    |
| 182                         |        5 |            1 |          1 |           0 |         32.09 |          20    |
| 296                         |        2 |            1 |          1 |           0 |         32.09 |          50    |
| 210 ALE                     |        1 |            1 |          1 |           0 |         32.09 |         100    |
| 210 ACE                     |        1 |            0 |          0 |           0 |         32.09 |           0    |
| 233                         |        1 |            0 |          0 |           0 |         32.09 |           0    |
| 720                         |        1 |            0 |          0 |           0 |         32.09 |           0    |

## 4. Comparacion de las tres definiciones

| definicion                               |   n_marcadas |   pct_marcadas |   n_exceso |   n_defecto | manejable_bajo_5pct   |
|:-----------------------------------------|-------------:|---------------:|-----------:|------------:|:----------------------|
| (a) residuo en minutos, |z| > 3          |          239 |           3.86 |        239 |           0 | si                    |
| (b) residuo en escala log1p, |z| > 3     |           68 |           1.1  |         67 |           1 | si                    |
| (c) fuera del intervalo [q10, q90] de M3 |         2799 |          45.2  |       1492 |        1307 | no                    |

Reparto de la rama (b), en escala log1p:

| tipo_log   |    n |   pct |
|:-----------|-----:|------:|
| normal     | 6124 | 98.9  |
| exceso     |   67 |  1.08 |
| defecto    |    1 |  0.02 |

Las ramas (a) y (c) coinciden en 239 negociaciones. El criterio de eleccion declarado en la guia es el volumen manejable: por encima de un 5 % de casos marcados la deteccion es inutil en la practica.

- (a) marca el 3.86 %, todo por exceso.
- (b) marca el 1.10 %, y es la unica capaz de senalar infraimputacion.
- (c) marca el 45.20 %: queda descartada por volumen, y ademas hereda el problema de calibracion medido en la Fase 5 (cobertura observada del 54,80 % frente al 80 % nominal).

Se adopta **(a)** como definicion principal, por ser la que fija el alcance del proyecto y la que produce una lista revisable de casos con sobrecoste de tiempo. **(b)** se reporta como complemento porque cubre el unico caso que (a) no puede ver por construccion. Las dos usan el mismo modelo y el mismo residuo: cambian solo de escala.

## 5. Validacion ciega con experto

Se ha generado `output/validacion_experto.csv` con 40 casos: 20 marcados como anomalos y 20 normales, mezclados con `random_state=42` y sin la columna de prediccion ni la de z. Columnas: `deal_id`, `proceso`, `ejercicio`, `minutos_total`, `veredicto_experto`.

Valores admitidos en `veredicto_experto`: `razonable`, `anomalo`, `no_se`.

La clave (que caso estaba marcado y con que z) queda en `output/validacion_experto_clave.csv`, que no se entrega al experto.

### 5.1 Resultado del contraste

El archivo `output/validacion_experto.csv` esta generado y pendiente de que el experto lo rellene. Cuando devuelva el archivo relleno como `output/validacion_experto_relleno.csv` y se vuelva a ejecutar este script, esta seccion se completa con el acuerdo, la precision y el recall frente al criterio experto. No se rellena con datos inventados.

## 6. Gate 6

| criterio                              | valor     | resultado                                               |
|:--------------------------------------|:----------|:--------------------------------------------------------|
| Informe con la tasa de marcado        | 3.86 %    | cumple                                                  |
| Archivo de validacion generado        | 40 casos  | cumple                                                  |
| Volumen de marcado por debajo del 5 % | 3.86 %    | cumple                                                  |
| Contraste con el experto              | pendiente | pendiente de que el usuario devuelva el archivo relleno |

## 7. Figuras

- `figuras/06_distribucion_z.png`
- `figuras/06_tasa_por_proceso.png`
