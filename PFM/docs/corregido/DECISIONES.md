# Registro de decisiones

Una entrada por decisión tomada sin poder consultar al usuario.
Formato obligatorio: decisión, alternativa descartada, motivo, impacto estimado.
Numeración correlativa D-001, D-002...

Si la decisión cambia materialmente el resultado, no elijas: implementa ambas
ramas y reporta las dos (ver GUIA_AGENTE.md, seccion 0.2, Caso B).

---

## D-000 · Plantilla (no borrar)

**Decisión:**
**Alternativa descartada:**
**Motivo:**
**Impacto estimado:** alto / medio / bajo
**Fase:**

---

## D-001 · Qué se hace con los archivos del borrador anterior

**Decisión:** se conserva `sql/A_00_descubrimiento.sql` como documentación de las
consultas de descubrimiento y se reescribe su ejecución en `src/00_descubrimiento.py`
(con la corrección de nombre de tabla de B-001). Se elimina
`src/00_exploracion_viabilidad.py`.
**Alternativa descartada:** adaptar `src/00_exploracion_viabilidad.py` a la lógica de
negociaciones.
**Motivo:** ese script clasificaba el tipo de proceso con una lista fija de modelos
tributarios buscada en el texto de las tareas (`MODELOS_TRIBUTARIOS`, línea 190). La
guía usa la etiqueta nativa del CRM (campo *Modelo presentado*, `UF_CRM_1715872169`),
que no requiere heurística de texto. Mantener el script obligaría a justificar en la
memoria una taxonomía inventada que ya no se usa.
**Impacto estimado:** bajo (ningún resultado depende de él).
**Fase:** 1

## D-002 · Tareas enlazadas a más de una negociación

**Decisión:** se descartan por completo las tareas cuyo campo `UF_CRM_TASK` apunta a
más de un deal; su tiempo no se asigna a ninguna negociación.
**Alternativa descartada:** repartir el tiempo entre los deals enlazados, o asignarlo
al de menor `deal_id`.
**Motivo:** es la opción conservadora (no inventa una atribución que el dato no
respalda). El volumen medido es despreciable: 5 tareas sobre 54.474 con enlace a deal
(0,009 %), 3 imputaciones y 1,98 h sobre 30.656,8 h con negociación (0,006 %).
**Impacto estimado:** bajo, medido.
**Fase:** 1

## D-003 · Ventana de extracción de negociaciones

**Decisión:** `deals.csv` incluye toda negociación con `DATE_CREATE >= 2025-01-01`
**o** `CLOSEDATE >= 2025-01-01`.
**Alternativa descartada:** filtrar solo por `DATE_CREATE`.
**Motivo:** filtrar solo por fecha de creación perdería las negociaciones abiertas en
2024 y cerradas dentro de la ventana, que sí tienen tiempo imputado en el período y
son observaciones válidas para el split temporal por fecha de cierre.
**Impacto estimado:** medio (afecta al recuento de filas, no al método).
**Fase:** 1

## D-004 · Columna `dias_desde_alta_cliente` en `deals.csv`

**Decisión:** se exporta la antigüedad del cliente como entero de días
(`DATEDIFF(deal.DATE_CREATE, company.DATE_CREATE)`) en lugar de la fecha de alta.
**Alternativa descartada:** exportar la fecha de alta de la empresa.
**Motivo:** la feature `dias_desde_alta_cliente` de la Fase 3 la necesita; exportar el
entero evita sacar del sistema un atributo de la ficha de empresa. Nulos: 2,66 %.
**Impacto estimado:** bajo.
**Fase:** 1
