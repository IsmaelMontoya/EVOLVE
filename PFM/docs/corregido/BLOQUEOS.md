# Registro de bloqueos

Una entrada por cada punto en el que el dato no existe, el gate no se cumple o
la realidad contradice lo previsto en la guia.

No inventes el dato. No lo aproximes sin decirlo. No pases de fase fingiendo
que el gate se cumplio.

Numeracion correlativa B-001, B-002...

---

## B-000 · Plantilla (no borrar)

**Esperado:**
**Encontrado:**
**Probado:**
**Accion tomada:**
**Fase:**
**Estado:** abierto / resuelto / asumido como limitacion

---

## B-001 · La tabla puente `b_utm_task` no existe

**Esperado:** tabla `b_utm_task` con el enlace tarea -> CRM (GUIA_AGENTE.md, 2.2).
**Encontrado:** no existe. El esquema tiene `b_utm_tasks_task` (130.134 filas), con las
mismas columnas (`ID`, `VALUE_ID`, `FIELD_ID`, `VALUE`, ...). El campo `UF_CRM_TASK` de
`TASKS_TASK` es `FIELD_ID = 6`.
**Probado:** listado de `information_schema.TABLES` con patrones `b_utm%`, `%tasks%`,
`b_uts%`. Reparto de prefijos en `b_utm_tasks_task`: D 54.479, CO 47.054, C 1.489,
L 499, resto 553.
**Accion tomada:** se usa `b_utm_tasks_task` con `FIELD_ID = 6` en todas las consultas.
Los valores UF de negociación se leen de `b_uts_crm_deal`, confirmada por
`information_schema` (32.914 filas).
**Fase:** 1
**Estado:** resuelto

## B-002 · El motor no admite CTE ni funciones de ventana

**Esperado:** MariaDB / MySQL con soporte de `WITH` y `OVER ()`.
**Encontrado:** `SELECT VERSION()` devuelve 5.7. `WITH` produce error 1064.
**Probado:** primera versión de `sql/B_extraccion.sql` escrita con CTE; falla en la
primera consulta.
**Accion tomada:** todas las consultas reescritas con tablas derivadas. Sin cambio de
semántica: los recuentos de `deals.csv` (30.836 filas) e `imputaciones.csv` (66.690
filas) coinciden con los agregados de descubrimiento.
**Fase:** 1
**Estado:** resuelto

## B-003 · Extracción a repositorio independiente (PARTE 4.2) — no ejecutada

**Esperado:** el PFM vive en un repositorio propio, sin historial heredado.
**Encontrado:** hoy vive en `PFM/docs/corregido/` dentro de un repositorio de material
de curso. La corrección del tutor exige repositorio dedicado.
**Probado:** nada. Es una acción de cara al exterior (creación de repositorio remoto,
purga de historial y rotación de credenciales) que requiere confirmación explícita del
usuario y no se ejecuta de forma autónoma.
**Accion tomada:** pendiente de ejecución manual. Pasos exactos:

1. Crear un repositorio nuevo y vacío, dedicado solo al PFM.
2. Copiar el contenido de `PFM/docs/corregido/` a la raíz del nuevo repositorio
   (sin `output/` ni `.env`).
3. `git init` y primer commit limpio. No importar el historial del repositorio actual.
4. En el repositorio actual, purgar del historial las versiones antiguas de las
   entregas 2 y 3 que contienen IPs y nombres de base de datos
   (`git filter-repo` o BFG).
5. Rotar las credenciales de acceso a la base de datos si siguen activas.

**Fase:** 7
**Estado:** abierto — requiere acción del usuario

## B-004 · El modelo no alcanza el umbral de mejora del Gate 5

**Esperado:** MAE de M2 al menos un 10 % mejor que el de B1 en el test temporal.
**Encontrado:** M2 obtiene 15,50 min frente a los 16,37 min de B1, una mejora del
5,31 %. El criterio secundario sí se cumple: M2 mejora a B1 en 4 de 4 folds de
GroupKFold, con ganancias entre 1,66 % y 2,77 %.
**Probado:** el bucle de mejora agotó los 5 intentos previstos (agrupar procesos poco
frecuentes, features de carga de campaña, ajuste de hiperparámetros, target encoding
por cliente ajustado por fold, recorte de cola al P99 solo en train). La mejor variante
en validación interna fue el ajuste de hiperparámetros (MAE de validación 11,26 min
frente a los 11,53 min de B1, un 2,28 %). El target encoding por cliente empeoró la
validación en un 5,31 %.
**Accion tomada:** se para el bucle según el criterio declarado antes de abrirlo y se
documenta el resultado negativo en `output/05_modelos.md`, sección 9, con las tres
cifras que lo explican (ratio P99/mediana = 30,8; deriva del P99 de 143,7 a 189,9 min
entre train y test; 11,71 % de horas sin negociación y 21,74 % de negociaciones
cerradas con 0 minutos). No se ha tocado el test, ni filtrado casos difíciles, ni
reajustado el baseline. El proyecto continúa a la Fase 6 con este modelo.
**Fase:** 5
**Estado:** asumido como limitación
