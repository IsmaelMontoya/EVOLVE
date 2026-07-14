"""
Rugby Training Assistant - Streamlit Web App
Interfaz interactiva para el agente experto en rugby
"""

import streamlit as st
from dotenv import load_dotenv
import os
from langchain_chroma import Chroma
from langchain_core.documents import Document
from langchain.tools import tool
from langchain.agents import create_agent
from langchain_core.messages import HumanMessage
from langchain_huggingface.embeddings import HuggingFaceEmbeddings
from langchain_anthropic import ChatAnthropic

# ============================================================================
# Configuración de Página
# ============================================================================

st.set_page_config(
    page_title="Rugby Training Assistant",
    page_icon="🏉",
    layout="wide",
    initial_sidebar_state="expanded"
)

# CSS personalizado
st.markdown("""
    <style>
    .main {
        padding: 2rem;
    }
    .stTabs [data-baseweb="tab-list"] button [data-testid="stMarkdownContainer"] p {
        font-size: 1.25rem;
    }
    </style>
    """, unsafe_allow_html=True)

# ============================================================================
# Inicialización de Sesión
# ============================================================================

@st.cache_resource
def cargar_agente():
    """Cargar el agente RAG una sola vez (cachéado)"""

    # Cargar API key
    load_dotenv()
    ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY")

    if not ANTHROPIC_API_KEY:
        st.error("❌ ERROR: No se encontró ANTHROPIC_API_KEY en .env")
        st.stop()

    # Documentos de rugby
    rugby_docs = [
        Document(
            page_content="""TACKLE READY - LAS 5 ETAPAS DEL TACKLE SEGURO

            1. RASTREO: Identificar y seguir al portador. KPIs: distancia, alineación, velocidad.
            2. PREPARACIÓN: Posicionar correctamente. KPIs: alineación hombros, cabeza sobre pelota.
            3. CONEXIÓN: Contacto seguro con control. KPIs: punto contacto, envolvimiento brazos.
            4. ACELERACIÓN: Generar potencia. KPIs: fuerza, mantenimiento posición.
            5. TERMINACIÓN: Completar seguramente. KPIs: separación controlada, recuperación.

            TIPOS DE TACKLES:
            - Frontal (Head-on)
            - Lateral (Sidecar)
            - Trasero (Behind)
            - Multi-jugador""",
            metadata={"source": "tackle_ready", "tema": "tackle"}
        ),
        Document(
            page_content="""BREAKDOWN READY - FUNDAMENTOS DEL BREAKDOWN

            150-180 breakdowns por partido. Componentes críticos:

            BREAKDOWN OFENSIVO:
            - 1er Jugador: cae sobre pelota
            - 2º Jugador: apoyo inmediato
            - 3er Jugador: completa unidad

            BREAKDOWN DEFENSIVO:
            - Entrada rápida
            - Posición baja
            - Despegue controlado

            RUCK: pelota en suelo
            MAUL: pelota en manos""",
            metadata={"source": "breakdown_ready", "tema": "breakdown"}
        ),
        Document(
            page_content="""COACHING DE ALTO RENDIMIENTO - 6 ROLES DEL ENTRENADOR

            1. ARQUITECTO DE IDENTIDAD: define misión, valores, cultura
            2. CURADOR DE RELACIONES: construye confianza
            3. CREADOR DE CLARIDAD: comunica objetivos
            4. MÉDICO DEL RIESGO: gestiona seguridad física y psicológica
            5. CUIDADOR DE MOTIVACIÓN: inspira al equipo
            6. ENTRENADOR CONTAGIOSO: modela excelencia

            El ambiente óptimo es tan importante como la técnica.""",
            metadata={"source": "coaching", "tema": "liderazgo"}
        )
    ]

    # Crear embeddings y vector store
    embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
    vectorstore = Chroma.from_documents(
        documents=rugby_docs,
        embedding=embeddings,
        collection_name="rugby_training"
    )
    retriever = vectorstore.as_retriever(search_kwargs={"k": 2})

    # Crear herramienta de búsqueda
    @tool
    def buscar_rugby(query: str) -> str:
        """Busca información sobre rugby en la base de conocimiento."""
        docs = retriever.invoke(query)
        if not docs:
            return "No encontré información sobre ese tema en la base de conocimiento."

        resultados = []
        for doc in docs:
            fuente = doc.metadata.get('source', 'unknown')
            resultados.append(f"[{fuente}]\n{doc.page_content}")

        return "\n\n---\n\n".join(resultados)

    # Crear LLM
    llm = ChatAnthropic(
        model="claude-haiku-4-5-20251001",
        api_key=ANTHROPIC_API_KEY,
        temperature=0.5,
        max_tokens=2048
    )

    # System prompt
    system_prompt = """Eres Rugby Training Assistant, un experto en entrenamiento de rugby basado en World Rugby.
Cuando el usuario pregunta sobre técnicas, siempre usa la herramienta buscar_rugby.
Responde en español, sé claro y conciso.
Enfatiza la SEGURIDAD del jugador en todas las respuestas."""

    # Crear agente
    agente = create_agent(
        model=llm,
        tools=[buscar_rugby],
        system_prompt=system_prompt
    )

    return agente

# ============================================================================
# Función para hacer preguntas
# ============================================================================

def hacer_pregunta(agente, pregunta: str) -> str:
    """Hacer una pregunta al agente"""
    respuesta = agente.invoke({
        "messages": [HumanMessage(content=pregunta)]
    })

    if "messages" in respuesta:
        for msg in reversed(respuesta["messages"]):
            if hasattr(msg, 'content') and msg.content and not isinstance(msg, HumanMessage):
                return msg.content

    return "No se generó respuesta"

# ============================================================================
# Interfaz Principal
# ============================================================================

# Encabezado
col1, col2 = st.columns([3, 1])
with col1:
    st.title("🏉 Rugby Training Assistant")
    st.markdown("**Expert Agent con RAG + LangGraph + Claude**")

with col2:
    st.markdown("")
    st.markdown("")
    st.markdown("![Rugby](https://img.shields.io/badge/Rugby-Training-green)")

st.markdown("---")

# Información del proyecto
with st.expander("ℹ️ Sobre este Proyecto", expanded=False):
    col1, col2 = st.columns(2)

    with col1:
        st.markdown("""
        **Alumno:** Ismael
        **Email:** ismael@candreuexpertos.es
        **UUID:** 2e22b94b-be37-4685-b7c6-8292836c4e70
        **Fecha:** 7 de Julio de 2026
        """)

    with col2:
        st.markdown("""
        **Stack Tecnológico:**
        - ChromaDB (Vector Database)
        - HuggingFace Embeddings (Local)
        - Claude Haiku 4.5 (LLM)
        - LangGraph (Orchestration)
        """)

    st.markdown("""
    **Objetivo:** Crear un asistente experto que responde preguntas sobre rugby enfatizando la seguridad del jugador.

    **Costo:** ~$0.01 por sesión (ultra económico)
    """)

st.markdown("---")

# ============================================================================
# Cargar Agente
# ============================================================================

with st.spinner("⏳ Cargando agente RAG..."):
    agente = cargar_agente()

st.success("✅ Agente listo para responder preguntas")

# ============================================================================
# Interfaz de Chat
# ============================================================================

# Inicializar histórico de mensajes
if "mensajes" not in st.session_state:
    st.session_state.mensajes = []

# Mostrar histórico
for mensaje in st.session_state.mensajes:
    with st.chat_message(mensaje["rol"], avatar=mensaje["emoji"]):
        st.markdown(mensaje["contenido"])

# Input del usuario
pregunta = st.chat_input("Pregunta sobre rugby (tackle, breakdown, coaching, etc.)...")

if pregunta:
    # Agregar pregunta al histórico
    st.session_state.mensajes.append({
        "rol": "user",
        "emoji": "👤",
        "contenido": pregunta
    })

    # Mostrar pregunta
    with st.chat_message("user", avatar="👤"):
        st.markdown(pregunta)

    # Obtener respuesta
    with st.spinner("🤖 Pensando..."):
        respuesta = hacer_pregunta(agente, pregunta)

    # Agregar respuesta al histórico
    st.session_state.mensajes.append({
        "rol": "assistant",
        "emoji": "🏉",
        "contenido": respuesta
    })

    # Mostrar respuesta
    with st.chat_message("assistant", avatar="🏉"):
        st.markdown(respuesta)

# ============================================================================
# Barra Lateral
# ============================================================================

with st.sidebar:
    st.header("📚 Base de Conocimiento")

    st.markdown("""
    **Documentos Indexados:**
    """)

    st.markdown("""
    **1. Tackle Ready** 🛡️
    - 5 etapas del tackle seguro
    - Tipos de tackles
    - KPIs de rendimiento
    """)

    st.markdown("""
    **2. Breakdown Ready** 🔄
    - Breakdown ofensivo y defensivo
    - Diferencia entre ruck y maul
    - Componentes críticos
    """)

    st.markdown("""
    **3. Coaching** 👨‍🏫
    - 6 roles del entrenador moderno
    - Liderazgo y gestión
    - Construcción de equipos
    """)

    st.markdown("---")

    st.header("💡 Ejemplos de Preguntas")

    ejemplos = [
        "¿Cuáles son las 5 etapas del tackle seguro?",
        "¿Cuáles son los roles en el breakdown ofensivo?",
        "¿Cuáles son los 6 roles del entrenador de alto rendimiento?",
        "¿Cuál es la diferencia entre un ruck y un maul?"
    ]

    for i, ejemplo in enumerate(ejemplos, 1):
        if st.button(f"📌 Ejemplo {i}", key=f"ejemplo_{i}", use_container_width=True):
            st.session_state.mensajes.append({
                "rol": "user",
                "emoji": "👤",
                "contenido": ejemplo
            })
            st.rerun()

    st.markdown("---")

    st.header("🔧 Información Técnica")

    col1, col2 = st.columns(2)
    with col1:
        st.metric("Documentos", "3", "+0")
        st.metric("Embeddings", "384D", "Local")

    with col2:
        st.metric("Modelo", "Claude Haiku", "Ultra Económico")
        st.metric("Costo/Sesión", "$0.01", "~")

    st.markdown("---")

    if st.button("🗑️ Limpiar Historial", use_container_width=True):
        st.session_state.mensajes = []
        st.rerun()

# ============================================================================
# Pie de Página
# ============================================================================

st.markdown("---")
st.markdown("""
<div style='text-align: center'>
    <small>
    Rugby Training Assistant | Proyecto IA Generativa | 2026
    </small>
</div>
""", unsafe_allow_html=True)
