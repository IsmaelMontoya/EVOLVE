# Entrega 3 - Diseño del Modelo de Datos y Capa Gold

---

## 1. Resumen de la Idea y Datos del Proyecto

### Problema que resuelve

En una asesoría, el análisis de rentabilidad de clientes está disperso. No se puede predecir qué clientes caerán en rentabilidad, detectar anomalías automáticamente, ni segmentar para tarifar diferenciado. Los datos de imputación de tiempo y facturación existen pero no se relacionan sistemáticamente por cliente.

### Solución a construir

Sistema de análisis y predicción de rentabilidad basado en:
1. **Detección de anomalías**: Identificar clientes con patrones anómalos (mucho tiempo, poco facturado)
2. **Predicción de rentabilidad**: Modelo ML que predice si un cliente será rentable en el siguiente período
3. **Segmentación de clientes**: Agrupar clientes por perfil (cash cow, en riesgo, alto potencial, anómalo)
4. **Validación temporal**: Entrenar con datos pasados (ene-dic 2025), validar contra realidad (ene-jul 2026), predecir futuro (ago-dic 2026 + 2027)
5. **Explicabilidad**: SHAP values para entender qué influye en cada predicción

### Fuentes de datos principales

| Fuente | Tabla | Registros | Información |
|---|---|---|---|
| **Bitrix MySQL** | FactTiemposBitrix | 65.526 | Imputaciones horarias por empleado/tarea/fecha |
| **Bitrix MySQL** | DimEmpresaBitrix | 914 | Información de clientes: tipo, despacho, grupo, actividades |
| **Bitrix MySQL** | DimCosteEmpleado | 45 | Coste/hora por empleado |
| **Biloop SQL Server** | FactFacturasBiloop | 87.679 | Facturación por cliente/fecha |
| **Bitrix MySQL** | BridgeTareaDeal | 49.422 | Conexión tarea ↔ deal ↔ empresa |

### Histórico disponible

- **Período:** ene 2025 - jul 2026 (19 meses reales)
- **TRAIN:** ene-ago 2025 (8 meses)
- **VALIDATION:** sep-dic 2025 (4 meses)
- **TEST:** ene-jul 2026 (7 meses - validación real ya disponible)
- **PREDICT:** ago-dic 2026 + 2027 (predicciones futuras)

---

## 2. Tecnología o Formato de Almacenamiento Elegido

### Decisión: **CSV + Python (Pandas, Scikit-learn)**

### Justificación

1. **Volumen manejable:** ~17.366 registros (914 empresas × 19 meses) fácil de procesar en memoria
2. **Simplicidad:** CSV es estándar, reproducible, versionable en Git
3. **Flexibilidad:** Python permite feature engineering complejo, ML, análisis EDA completo
4. **Control total:** No depende de BDD ni infraestructura compleja
5. **Iteración rápida:** Cambios y experimentos sin fricción
6. **Académicamente robusto:** Código reproducible, pipeline clara, documentado

### Stack tecnológico

```
Extracción:          SQL queries (Bitrix, Biloop) → CSV
Procesamiento:       Python 3.10+ (Pandas, NumPy)
Machine Learning:    Scikit-learn, XGBoost/LightGBM
Feature Engineering: Pandas, custom functions
Visualización:       Matplotlib, Seaborn, Plotly
Explicabilidad:      SHAP values
Documentación:       Jupyter Notebooks, Markdown
Versionado:          Git + GitHub
```

---

## 3. Estructura de Capas de Datos

```
data/
├── raw/
│   ├── fact_tiempos_bitrix.csv         (65.526 registros, sin modificar)
│   ├── fact_facturas_biloop.csv        (87.679 registros, sin modificar)
│   ├── dim_empresa_bitrix.csv          (914 empresas, sin modificar)
│   ├── dim_coste_empleado.csv          (45 empleados, sin modificar)
│   └── bridge_tarea_deal.csv           (49.422 registros, sin modificar)
│
├── processed/
│   ├── tiempos_limpios.csv             (imputaciones validadas, sin nulls)
│   ├── facturas_limpias.csv            (facturas normalizadas)
│   ├── empresas_enriquecidas.csv       (empresas con features categóricas)
│   └── costos_empleado_imputados.csv   (costes interpolados para nulls)
│
└── gold/
    └── gold_rentabilidad_clientes.csv  (TABLA FINAL: 914 empresas × 19 meses)
```

### Descripción de capas

| Capa | Contenido | Propósito |
|---|---|---|
| **raw** | Datos originales tal como se descargan de Bitrix/Biloop | Auditoría, trazabilidad, replicabilidad |
| **processed** | Datos limpios, normalizados, con tratamiento de errores | Preparación para análisis |
| **gold** | Tabla final lista para ML, análisis y reportes | Input para modelos, EDA, visualización |

---

## 4. Definición de la Capa Gold

### Dataset Principal: `gold_rentabilidad_clientes.csv`

| Atributo | Valor |
|---|---|
| **Nombre del fichero** | `gold_rentabilidad_clientes.csv` |
| **Descripción funcional** | Tabla de hechos con rentabilidad agregada por empresa y período (mensual). Combina imputaciones de tiempo, costes de empleados y facturación. Base para modelos ML, análisis exploratorio y reportes. |
| **Granularidad** | **1 fila = 1 empresa + 1 mes** |
| **Nº de registros esperado** | ~17.366 (914 empresas × 19 meses) |
| **Período** | ene 2025 - jul 2026 |
| **Clave primaria** | `id_bitrix` + `año_mes` (combinada) |

### Campos Principales

| Campo | Tipo | Descripción | Fuente | Obligatorio | Observaciones |
|---|---|---|---|---|---|
| `id_bitrix` | int | Identificador único empresa (anonimizado) | DimEmpresaBitrix | Sí | Reemplaza nombre |
| `año_mes` | date | Fecha del período (YYYY-MM-01) | Cálc. | Sí | Formato ISO 8601 |
| `tipo_empresa` | str | Tipo jurídico (PF/SL/CB) | DimEmpresaBitrix | Sí | Categorical, 4 valores |
| `despacho` | str | Despacho responsable | DimEmpresaBitrix | Sí | 7 valores posibles |
| `grupo_id` | int | ID grupo empresarial | DimEmpresaBitrix | No | NULL si no tiene grupo |
| `horas_imputadas` | float | Total horas trabajadas en mes | FactTiemposBitrix | Sí | Rango: 0-200 h/mes típico |
| `coste_directo` | float | Σ(horas × CosteHora empleado) | Cálc. | Sí | Rango: €0 - €3.000 típico |
| `coste_indirecto` | float | horas_imputadas × 15.8 | Cálc. | Sí | Fijo €/h, costo indirecto |
| `coste_total` | float | coste_directo + coste_indirecto | Cálc. | Sí | En euros |
| `facturado` | float | BASEIMPONIBLE total facturado | FactFacturasBiloop | Sí | Rango: €0 - €5.000+ típico |
| `n_facturas` | int | Número de facturas emitidas | FactFacturasBiloop | Sí | Típico: 0-10/mes |
| `n_rectificativas` | int | Número de facturas rectificativas | FactFacturasBiloop | No | Proxy de errores |
| `rendimiento` | float | facturado - coste_total | Cálc. | Sí | **Positivo = rentable** |
| `pct_rentabilidad` | float | (rendimiento / facturado) × 100 | Cálc. | Sí | **TARGET PRIMARIO** |
| `volatilidad_horas_6m` | float | Std desv. horas últimos 6 meses | Cálc. | No | Feature ingeniería |
| `trend_facturado_6m` | float | Pendiente regresión lineal facturación 6m | Cálc. | No | Feature ingeniería |
| `ratio_imputaciones_altas` | float | COUNT(>6h) / COUNT(todas) | Cálc. | No | Feature ingeniería |
| `dias_desde_alta` | int | Días desde DATE_CREATE empresa | Cálc. | Sí | Antigüedad cliente |
| `num_actividades` | int | Número de actividades asignadas | DimActividad | No | Multi-label |
| `num_obligaciones` | int | Número de modelos tributarios | DimObligacionTributaria | No | Proxy de complejidad |

### Variables Objetivo / Métricas Relevantes

| Variable | Tipo | Uso |
|---|---|---|
| **`pct_rentabilidad`** | float | Target primario: predicción de rentabilidad (%) |
| **`rendimiento`** | float | Target alternativo: margen absoluto (€) |
| **`es_rentable`** | binary (derivado) | Target de clasificación: rentable (>20%) vs no rentable |
| **`es_anomalia`** | binary (derivado) | Target de detección: anomalía en tiempo/coste |

### Fases posteriores que consumirán este dataset

| Fase | Uso |
|---|---|
| **EDA** | Análisis exploratorio: distribución rentabilidad, correlaciones, outliers, trends |
| **Feature Engineering** | Crear features adicionales (rolling means, seasonal, interacciones) |
| **Modelo Predictivo** | Random Forest / XGBoost para predecir `pct_rentabilidad` |
| **Outlier Detection** | Isolation Forest para detectar anomalías |
| **Segmentación** | K-means para clusters de clientes |
| **Explicabilidad** | SHAP values: qué variables impactan cada predicción |
| **Dashboard/Reporte** | Visualización de rentabilidad, anomalías, predicciones |

---

## 5. Relaciones entre Datos

### Estructura relacional

```
FactTiemposBitrix (65.526)
    ↓ JOIN por TASK_ID
BridgeTareaDeal (49.422)
    ↓ JOIN por DEAL_ID
DimDealBitrix → COMPANY_ID
    ↓ JOIN por COMPANY_ID
DimEmpresaBitrix (914)
    ↓ JOIN por ID_Bitrix
        ├→ DimCosteEmpleado (45) [vía USER_ID → ID_Empleado]
        ├→ DimActividad (20) [vía BridgeEmpresaActividad]
        ├→ DimObligacionTributaria (52) [vía BridgeEmpresaObligacion]
        └→ DimGrupoEmpresarial (86) [vía Grupo_ID]

FactFacturasBiloop (87.679)
    ↓ JOIN por NIF_Norm
DimEmpresaBitrix (914)
```

### Cardinalidades

| Relación | Cardinalidad | Tipo | Problema potencial |
|---|---|---|---|
| FactTiemposBitrix → DimUsuarioBitrix | N:1 | Inner | Algunos empleados sin coste (IDs negativos) |
| FactTiemposBitrix → BridgeTareaDeal → DimEmpresaBitrix | N:1 | Inner | Tareas sin deal → empresa nula |
| FactFacturasBiloop → DimEmpresaBitrix | N:1 | Left | Facturas de clientes no en Bitrix |
| DimEmpresaBitrix → DimActividad (BridgeEmpresaActividad) | N:N | Many | Multi-label (empresa múltiples actividades) |
| DimEmpresaBitrix → DimObligacionTributaria | N:N | Many | Multi-label (empresa múltiples obligaciones) |

### Joins necesarios

1. **Join temporal** (crítico):
   - FactTiemposBitrix + FactFacturasBiloop por empresa + mes
   - Agrupación: por id_empresa + año_mes
   - Resultado: 1 registro = 1 empresa + 1 mes

2. **Join de costes:**
   - FactTiemposBitrix JOIN DimCosteEmpleado
   - Calcular Coste Directo = Σ(horas × CosteHora)

3. **Join de metadata:**
   - Empresas rentabilidad JOIN DimEmpresaBitrix (tipo, despacho, actividades, obligaciones, grupo)

---

## 6. Diccionario de Datos Inicial

| Campo | Descripción | Tipo | Fuente | Obligatorio | Observaciones |
|---|---|---|---|---|---|
| id_bitrix | ID único empresa en Bitrix (anonimizado) | int | DimEmpresaBitrix | Sí | Clave primaria |
| año_mes | Período mensual (YYYY-MM-01) | date | Cálc. | Sí | Formato ISO 8601 |
| tipo_empresa | Tipo jurídico: PF\|SL\|CB\|OT | str | DimEmpresaBitrix | Sí | Categorical, 4 valores |
| despacho | Despacho responsable | str | DimEmpresaBitrix | Sí | 7 valores: Candreu, Cartagena, MAAP, etc. |
| grupo_id | ID grupo empresarial (si existe) | int | DimEmpresaBitrix | No | NULL si empresa no pertenece a grupo |
| horas_imputadas | Total horas trabajadas (suma SECONDS/3600) | float | FactTiemposBitrix | Sí | Rango: 0-200 h/mes típico |
| coste_directo | Suma (horas × CosteHora empleado) | float | Cálc. | Sí | Rango: €0 - €3.000 típico |
| coste_indirecto | horas_imputadas × 15.8 | float | Cálc. | Sí | Fijo, costo indirecto por hora |
| coste_total | coste_directo + coste_indirecto | float | Cálc. | Sí | Total costo servicio |
| facturado | BASEIMPONIBLE total facturado | float | FactFacturasBiloop | Sí | Excluye rectificativas en n_rectificativas; rango: €0 - €5.000+ |
| n_facturas | Número de facturas emitidas | int | FactFacturasBiloop | Sí | Rango: 0-10 facturas/mes típico |
| n_rectificativas | Número de facturas rectificativas | int | FactFacturasBiloop | No | Proxy de errores; rango: 0-2 |
| rendimiento | facturado - coste_total (margen €) | float | Cálc. | Sí | **Positivo = rentable**; rango: -€2.000 a +€4.000 |
| pct_rentabilidad | (rendimiento / facturado) × 100 (%) | float | Cálc. | Sí | **TARGET PRIMARIO**; rango: -100% a +300% (outliers) |
| volatilidad_horas_6m | Desviación estándar horas últimos 6 meses | float | Cálc. | No | Feature ingeniería; proxy variabilidad carga |
| trend_facturado_6m | Pendiente regresión lineal facturación 6m | float | Cálc. | No | Feature ingeniería; positivo=crecimiento |
| ratio_imputaciones_altas | COUNT(>6h) / COUNT(todas) | float | Cálc. | No | Feature ingeniería; rango 0-1 |
| dias_desde_alta | Días desde DATE_CREATE empresa | int | Cálc. | Sí | Antigüedad cliente; rango: 30-3.000+ días |
| num_actividades | Número de actividades asignadas | int | DimActividad | No | Rango: 0-5 típicamente |
| num_obligaciones | Número de modelos tributarios | int | DimObligacionTributaria | No | Rango: 1-15 típicamente |

---

## 7. Problemas de Calidad Esperados

### Problema 1: Valores Nulos

**Dónde:** 
- `grupo_id`: ~80% de empresas sin grupo (NULL normal)
- `coste_directo`: NULL si empleado no tiene coste (IDs negativos)

**Impacto:** Medio. Campos opcionales para modelo.

**Solución:** Rellenar `grupo_id=0` (sin grupo); imputar `coste_directo` con media/mediana

---

### Problema 2: Outliers en Imputaciones de Tiempo

**Dónde:** FactTiemposBitrix - algunas imputaciones >6h, >8h

**Impacto:** Alto. Distorsionan rentabilidad y modelos.

**Solución:** Detectar outliers por empleado (P95); crear flag `es_outlier_hora`; opcionalmente excluir/cap

---

### Problema 3: Inconsistencia en Fechas

**Dónde:** CREATED_DATE vs DATE_START/DATE_STOP; Imputación vs Facturación (desfase 1-3 meses)

**Impacto:** Medio. Afecta matching temporal.

**Solución:** Agrupar imputaciones por mes de CREATED_DATE; permitir desfase temporal

---

### Problema 4: Duplicados Potenciales

**Dónde:** Empresas duplicadas por NIF (ya filtradas en Bitrix); Facturas duplicadas

**Impacto:** Bajo. Bitrix ya filtra.

**Solución:** Deduplicación en join; excluir rectificativas de facturado (pero contar)

---

### Problema 5: Cambios de Definición entre Fuentes

**Dónde:** Coste indirecto 15.8 €/h (hardcoded); Tipo de empresa (¿actualizado?)

**Impacto:** Bajo-medio. Cambios infrecuentes.

**Solución:** Documentar supuesto; actualizar si cambia

---

### Problema 6: Datos Desactualizados / Incompletos

**Dónde:** Mes actual (julio 2026) puede estar incompleto; algunas empresas sin facturación en meses activos

**Impacto:** Bajo-medio para histórico; crítico para predicción julio.

**Solución:** Excluir mes actual si está incompleto; documentar corte de datos

---

## 8. Decisiones de Limpieza y Transformación Previstas

### 8.1. Tratamiento de Valores Nulos

| Campo | Estrategia |
|---|---|
| `grupo_id` | Rellenar con 0 (sin grupo) |
| `coste_directo` | Imputar media de empleados válidos para mes |
| `num_actividades`, `num_obligaciones` | Rellenar con 0 (sin dato) |
| Otros campos críticos | Excluir registro si NULL |

### 8.2. Agregaciones por empresa + mes

```python
df_gold = df_combined.groupby(['id_bitrix', 'año_mes']).agg({
    'horas': 'sum',                  # horas_imputadas
    'segundos': 'sum',               # para cálculo directo
    'coste_hora': 'mean',            # coste/hora promedio
    'facturado': 'sum',              # facturado
    'id_factura': 'count',           # n_facturas
    'es_rectificativa': 'sum',       # n_rectificativas
}).reset_index()

# Calcular costes
df_gold['coste_directo'] = df_gold['segundos'] / 3600 * df_gold['coste_hora']
df_gold['coste_indirecto'] = (df_gold['segundos'] / 3600) * 15.8
df_gold['coste_total'] = df_gold['coste_directo'] + df_gold['coste_indirecto']
df_gold['rendimiento'] = df_gold['facturado'] - df_gold['coste_total']
df_gold['pct_rentabilidad'] = (df_gold['rendimiento'] / df_gold['facturado'] * 100).fillna(0)

# Features ingeniería
df_gold['volatilidad_horas_6m'] = rolling_std(horas, window=6)
df_gold['trend_facturado_6m'] = rolling_trend(facturado, window=6)
```

### 8.3. Filtros Aplicados

- `ZOMBIE='N'` (tareas no zombie)
- `COMPANY_ID NOT NULL` (tarea con empresa asignada)
- `SECONDS > 0` (imputación válida)
- Empresas en DimEmpresaBitrix (cliente válido)
- Excluir mes incompleto si aplica

---

## 9. Riesgos del Modelo de Datos

### ¿Qué parte está más clara?

✅ **Fuentes de datos y estructura relacional**
- Bitrix/Biloop bien documentados en Reporte_Modelo_Completo.md
- Campos, relaciones y cardinalidades claros
- Acceso garantizado

✅ **Capa gold (tabla de rentabilidad por empresa)**
- Granularidad clara: 1 empresa + 1 mes
- Campos bien definidos con ~20 variables
- Target variables obvios (pct_rentabilidad, rendimiento, anomalías)

---

### ¿Qué genera más incertidumbre?

⚠️ **Calidad de imputaciones de tiempo**
- ¿Cuántas imputaciones son errores/olvidos?
- ¿Qué % de horas son outliers (>6h)?

⚠️ **Desfase temporal**
- Imputación mes N → facturación mes N+1, N+2
- ¿Cómo reconciliar para calcular rentabilidad real?

⚠️ **Algunos empleados sin coste**
- IDs negativos en DimCosteEmpleado
- ¿Impacto en Coste Directo?

---

### ¿Qué fuente/tabla puede dar más problemas?

🔴 **FactTiemposBitrix** (65.526 registros)
- Datos manuales, outliers, nulls
- Mitigación: EDA exhaustivo, detección de anomalías, capping

🟡 **FactFacturasBiloop** (87.679 registros)
- Rectificativas, cambios de empresa/despacho
- Mitigación: Separar rectificativas, validar join con Bitrix

🟡 **DimCosteEmpleado** (45 empleados)
- Hardcoded, pueden cambiar
- Mitigación: Documentar supuesto, revisar mensualmente

---

### ¿Qué ocurriría si no podemos construir la capa gold así?

**Simplificación 1: Datos agregados por sector**
- Agrupar 914 empresas en 4-5 sectores
- 76 registros en lugar de 17.366
- Menos granularidad pero más estable

**Simplificación 2: Agregación trimestral**
- Cambiar de mensual a trimestral
- 914 × 6 = 5.484 registros
- Menos ruido, menos granularidad

**Simplificación 3: Features reducidas**
- Usar solo campos críticos (id, mes, horas, facturado, rentabilidad)
- Skipear features engineered
- ML más simple pero menos potente

---

## Conclusión

**El modelo de datos es viable y realista** para desarrollar durante el curso:

✅ Datos reales, accesibles, bien estructurados  
✅ Volumen manejable (17.366 registros)  
✅ Capa gold clara y bien definida  
✅ Riesgos identificados y mitigables  

**Próximos pasos:**
1. Descargar datos raw desde Bitrix/Biloop a CSV
2. Limpiar y procesar en Python (sección `processed/`)
3. Construir capa gold (sección `gold/`)
4. Validar calidad con EDA
5. Entrenar modelos ML (Anomalías + Predicción + Segmentación)
6. Documentar y reportar resultados
