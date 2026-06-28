# Guion de la presentación — Análisis de reseñas Trustpilot (Halfords)

Duración objetivo: **~5 minutos**. Cada diapositiva incluye lo que decir y el tiempo aproximado.

---

## Diapositiva 1 — Portada *(~20 s)*

Buenas, soy Ismael. Como Data Scientist de **Halfords**, el director de Customer Experience me pidió analizar las reseñas de la compañía en **Trustpilot** para detectar oportunidades de mejora. Elegí Halfords dentro del sector **Vehicles & Transportation**, que es el que más competidores tiene, para poder hacer una buena comparación.

---

## Diapositiva 2 — Objetivos e hipótesis *(~45 s)*

El análisis responde a cuatro preguntas: si las reseñas son positivas o negativas, de qué temas hablan, qué sentimiento tiene cada tema frente a la competencia, y dónde están las áreas de mejora.

La **hipótesis metodológica** es clave: las estrellas del dataset están sesgadas —todas las empresas tienen la misma distribución—, así que **no uso el rating**. Mido el sentimiento con un **modelo de NLP** (un transformer, DistilBERT) y extraigo los temas con **TF-IDF + NMF**, ajustado sobre todo el sector para que Halfords y sus 59 competidores compartan el mismo espacio de temas. En total, 123.000 reseñas; el foco son las 100 de Halfords frente a 5.665 de la competencia.

---

## Diapositiva 3 — Sentimiento positivo y negativo *(Pregunta 1, ~50 s)*

El modelo clasifica como **negativas la mayoría de reseñas**: Halfords tiene un 65% negativas y un 35% positivas. Pero ojo, esto **no es un mal dato aislado**: todo el sector es muy crítico. De hecho, Halfords está **por encima de la media** (la competencia tiene un 32% de positivas) y es la empresa **número 15 de 60** en porcentaje de reseñas positivas.

El alto volumen de críticas tiene sentido porque la muestra tiene las estrellas balanceadas. Lo importante es la lectura **relativa**: lo hacemos algo mejor que nuestros rivales.

---

## Diapositiva 4 — Análisis de topics *(Pregunta 2, ~45 s)*

Con NMF salen 8 temas. Halfords se concentra muchísimo en su **tienda física y taller**: el tema *Personal y taller (MOT)* es el **45%** de sus reseñas, seguido de *Atención al cliente* (19%) y *Pedidos online* (13%).

La competencia, al ser más digital —ferries, parking, e-commerce—, **reparte** mucho más sus temas. Esto retrata bien el modelo de negocio de Halfords: tienda + taller presencial.

---

## Diapositiva 5 — Sentimiento y topics *(Pregunta 3, ~50 s)*

Aquí cruzo sentimiento y tema. A la izquierda, el % de reseñas positivas por tema; a la derecha, la **diferencia frente a la competencia** —verde si somos mejores, rojo si somos peores—.

Donde **ganamos** es en el **factor humano**: *Personal y taller*, que además es nuestro tema número uno, con +4,7 puntos sobre la competencia. Donde **perdemos** es en lo **digital**: *Reservas y web/app* (−12,9 puntos, la mayor brecha), *Neumáticos* y *Pedidos online* (solo 7,7% positivas). Resumiendo: el taller funciona; lo digital, no.

---

## Diapositiva 6 — Áreas de mejora *(Pregunta 4, ~45 s)*

Priorizo por impacto: volumen × sentimiento × brecha frente a la competencia. Salen tres focos:

1. **Postventa y pedidos online** — el más urgente: confirmaciones de pago que no llegan, informes de MOT no entregados, reembolsos lentos. Solo 7,7% positivas.
2. **Web/app y reservas** — la mayor desventaja competitiva; chat de soporte que no resuelve y flujo de reserva confuso.
3. **Click & collect y montaje** — esperas largas y artículos que faltan.

Las reseñas negativas reales confirman exactamente este patrón.

---

## Diapositiva 7 — Conclusiones y próximos pasos *(~45 s)*

En conclusión: Halfords no está mal dentro de un sector durísimo. Su **fortaleza** es el factor humano —taller y personal— y su **debilidad** es lo digital y la postventa, justo donde pierde frente a la competencia. Y algo importante: usar las estrellas habría **ocultado** este diagnóstico.

Como **próximos pasos** propongo un plan de choque en postventa (confirmaciones automáticas y SLA de reembolsos), rediseñar el flujo web/app de reservas y el chat, mejorar el click & collect, **comunicar en marketing** la fortaleza del taller, y repetir el análisis cada trimestre para medir el progreso.

Gracias.

---

### Consejos para la exposición
- Apóyate en los números clave: **35% / 65%**, **puesto 15 de 60**, **45% del volumen en taller**, **−12,9 pts en web/app**.
- Si te preguntan por el alto % de negativas: recuérdales el **sesgo de las estrellas** y que la lectura es **relativa** a la competencia.
- Si preguntan por el modelo: DistilBERT (binario POS/NEG) sobre texto en inglés; topics con NMF y 8 temas.
