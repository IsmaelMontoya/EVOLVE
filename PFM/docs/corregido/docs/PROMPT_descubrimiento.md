# Prompt para Claude Code (VS Code, con acceso a la BD de Bitrix)

Copia todo lo que hay debajo de la línea.

---

Necesito una **exploración de solo lectura** sobre la base de datos de Bitrix para
decidir el alcance de mi proyecto fin de máster. No modifiques nada: solo `SELECT`.

## Contexto

El trabajo de la asesoría está organizado en **negociaciones** (deals) de Bitrix,
repartidas en pipelines (categorías). Cada negociación es una ejecución concreta de
un proceso para un cliente. El tiempo se imputa en **tareas** que cuelgan de la
negociación mediante el campo `UF_CRM_TASK`.

La cadena que quiero validar es:

```
b_tasks_elapsed_time → tarea → (UF_CRM_TASK = 'D_<id_deal>') → negociación → pipeline
```

Los pipelines que existen, según me consta:

- **Administración**: Facturación interna · Onboarding clientes · Gestión interna
- **Contable**: Contable interno · Contabilidad externa · Cierres
- **Fiscal**: Modelos de impuestos · Rentas
- **Fiscal / expedientes**: Cuentas anuales · Libros oficiales · Libro de socios

Mi hipótesis de trabajo es que el MVP será el pipeline **"Modelos de impuestos"**,
usando el campo de lista *modelo presentado* como variable de tipo de proceso, y
que la variable objetivo será el tiempo total imputado por negociación.

Ventana de análisis: **2025-01-01 en adelante**.

## Reglas obligatorias de seguridad

El resultado lo voy a compartir fuera. Por tanto:

- **NO incluyas** IPs, hostnames, puertos, nombres de base de datos, usuarios ni
  contraseñas en ningún punto de la salida.
- **NO incluyas** nombres de empresa, NIF/CIF, nombres de contacto, ni nombres de
  empleado. Si necesitas referirte a un empleado, usa `USER_ID`.
- Todas las salidas deben ser **agregadas** (conteos, sumas, percentiles). Nada de
  volcados de filas individuales.
- Los nombres de pipelines, etapas y valores de listas SÍ los quiero (son
  categorías de proceso, no datos personales).

## Qué necesito averiguar

Investiga y respóndeme a esto. Si algún nombre de tabla que menciono no coincide
con el esquema real, localiza el equivalente y **dime cuál has usado**.

### 1. Pipelines
Lista de categorías de negociación con su `CATEGORY_ID` y nombre. Recuerda que el
embudo "General" es `CATEGORY_ID = 0` y no aparece en `b_crm_deal_category`.

### 2. Volumen por pipeline y año
Para cada pipeline y cada año (2025, 2026): número de negociaciones creadas,
cuántas están cerradas (`CLOSED = 'Y'`) y el porcentaje.

### 3. Campos personalizados de negociación
Todos los campos `UF_*` de la entidad `CRM_DEAL`: nombre técnico, tipo, si es
múltiple, la etiqueta en español y cuántos valores tiene si es lista.
**Identifica cuál es el campo "modelo presentado"** y cuál podría servir para
clasificar el tipo de renta.

### 4. Valores de esas listas
Para los campos que hayas identificado en el punto 3, dame la lista completa de
valores posibles (`b_user_field_enum`) y, si puedes, cuántas negociaciones usan
cada valor.

### 5. Etapas por pipeline
Etapas de cada pipeline con su semántica (ganada / perdida / en curso). Necesito
saber qué etapa significa "el proceso ha terminado".

### 6. Validación de la cadena tiempo → negociación  ← LA MÁS IMPORTANTE
Para cada pipeline, desde 2025-01-01:

- negociaciones distintas con tiempo imputado
- tareas distintas
- número de imputaciones
- empleados distintos
- horas totales
- minutos medios por negociación

Si esta consulta no devuelve nada, dímelo claramente: significa que el puente
`UF_CRM_TASK` no funciona como creo y hay que buscar otra vía.

### 7. Cobertura
Qué porcentaje de las horas imputadas **no** cuelga de ninguna negociación.
Necesito saber cuánto trabajo quedaría invisible al modelo.

### 8. Sesgo de redondeo del tiempo imputado
Reparto de las imputaciones (`b_tasks_elapsed_time.SECONDS`) según si son múltiplo
exacto de 60 min, 30 min, 15 min, 5 min, o valor no redondo. En número y en
porcentaje.

### 9. Distribución del tiempo por negociación, para el pipeline de Modelos de impuestos
Agrupando por el campo *modelo presentado*:

- número de negociaciones cerradas con tiempo
- mediana, P25, P75, P90 y máximo de minutos totales por negociación
- número de clientes distintos

Quiero ver qué modelos tienen suficientes repeticiones para modelar.

### 10. Estacionalidad
Para el pipeline de Modelos de impuestos: negociaciones cerradas por trimestre
natural desde 2025-T1. Quiero confirmar que se ven las campañas trimestrales.

## Formato de salida

Escribe un único archivo `docs/corregido/output/A_resultados_descubrimiento.md`
con una sección por punto, cada una con:

1. La consulta SQL que has ejecutado (en un bloque de código).
2. La tabla de resultados en markdown.
3. Una línea de observación tuya si algo te ha sorprendido o no cuadra.

Al final, añade una sección **"Avisos"** con: tablas o campos que esperaba y no
existen, nombres alternativos que has tenido que usar, y cualquier cosa que
invalide alguna de mis suposiciones.

No interpretes los resultados ni propongas modelos: solo mide y reporta.
