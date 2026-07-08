# Rugby Training Assistant - IA Generativa

**Proyecto Final:** Expert Agent con RAG + LangGraph + Claude  
**UUID:** 2e22b94b-be37-4685-b7c6-8292836c4e70  
**Estado:** ✅ COMPLETADO

---

## 🎯 Objetivo

Desarrollar un agente experto en entrenamiento de rugby que responda preguntas basadas en documentación de World Rugby, utilizando:
- **ChromaDB** para almacenamiento vectorial
- **HuggingFace Embeddings** (local, sin costo)
- **Claude Haiku 4.5** como LLM
- **LangGraph** para orquestación del agente

---

## 🏗️ Arquitectura

```
Usuario → LangGraph Agent → ChromaDB Retriever → Claude Haiku → Respuesta
                                   ↓
                          HuggingFace Embeddings
                          (all-MiniLM-L6-v2)
```

### Stack Técnico
- **Vector DB:** ChromaDB (en memoria, k=2)
- **Embeddings:** HuggingFace local (384D, $0)
- **LLM:** Claude Haiku 4.5 (~$0.80/1M tokens)
- **Frameworks:** LangChain + LangGraph
- **Herramienta:** `buscar_rugby()` - retrieval automático

---

## 📊 Knowledge Base

| Documento | Contenido |
|-----------|----------|
| **Tackle Ready** | 5 etapas del tackle seguro, tipos de tackle |
| **Breakdown Ready** | Breakdown ofensivo/defensivo, ruck/maul |
| **Coaching** | 6 roles del entrenador de alto rendimiento |

---

## 💰 Costo Operacional

| Componente | Costo |
|-----------|-------|
| HuggingFace Embeddings | $0 |
| ChromaDB | $0 |
| Claude Haiku (5 ejemplos) | ~$0.008 |
| **TOTAL** | **~$0.01** |

✅ **SIN FACTURA** - Costo negligible con Claude Max

---

## 🧪 Ejemplos de Uso

```python
# Pregunta 1
"¿Cuáles son las 5 etapas del tackle seguro?"
→ Respuesta: Rastreo, Preparación, Conexión, Aceleración, Terminación

# Pregunta 2
"¿Cuáles son los 6 roles del entrenador de alto rendimiento?"
→ Respuesta: Arquitecto, Curador, Creador, Médico, Cuidador, Contagioso
```

---

## 🚀 Ejecutar el Proyecto

### Requisitos
```bash
pip install -r requirements.txt
```

### Setup
1. Copiar `.env.example` → `.env`
2. Agregar tu API key de Claude en `.env`:
   ```
   ANTHROPIC_API_KEY=sk-ant-api03-...
   ```

### Ejecución
```bash
# En VSCode, abrir expert_agent_v4.ipynb
# Ejecutar todas las celdas (Ctrl+Shift+Enter)
```

---

## 📁 Archivos

- `expert_agent_v4.ipynb` - Notebook principal (Claude Haiku)
- `expert_agent_v2.ipynb` - Versión alternativa (Gemini)
- `.env.example` - Template de variables de entorno
- `.gitignore` - Excluye .env del repositorio
- `requirements.txt` - Dependencias Python
- `SYSTEM_PROMPT.md` - Prompt del agente

---

## ✅ Validación

- ✅ Ejecuta sin errores
- ✅ 3 documentos indexados
- ✅ 5 ejemplos funcionan correctamente
- ✅ Respuestas en español
- ✅ Énfasis en seguridad
- ✅ Costo negligible

---

## 🔄 Versiones Previas

| Versión | LLM | Embeddings | Estado |
|---------|-----|-----------|--------|
| v1 | Gemini | Gemini | ❌ Quota agotada |
| v2 | Gemini | HuggingFace | ❌ Quota agotada |
| v3 | Grok (xAI) | HuggingFace | ❌ Sin créditos |
| **v4** | **Claude** | **HuggingFace** | **✅ FUNCIONAL** |

---

## 📚 Próximas Fases (Opcional)

1. Expandir Knowledge Base (+50 documentos)
2. Multi-turn Conversation (memoria de contexto)
3. API REST (microservicio)
4. Web UI (interface para entrenadores)
5. Evaluación (benchmark vs expertos)

---

## 📝 Notas

- Los secretos (API keys) están en `.env` (excluido de git)
- Usar `.env.example` como template
- No compartir API keys
- ChromaDB está en memoria (datos de prueba)

---

**Fecha completación:** 2026-07-07  
**Estudiante:** Ismael  
**Email:** ismael@candreuexpertos.es
