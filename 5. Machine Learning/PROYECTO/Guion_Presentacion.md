# Guion de presentación — Modelo de probabilidad de recompra
**Duración objetivo: 5 minutos** · Proyecto Machine Learning · Ismael

> Cómo usarlo: el texto en redonda es lo que dices (puedes parafrasear, no memorices palabra por palabra). En *cursiva* van las indicaciones de gesto/ritmo. El cronómetro de la derecha es orientativo.

---

## SLIDE 1 — Portada · *(0:00 – 0:30)*

*(Mira al tribunal antes de empezar. Tono tranquilo.)*

"Buenos días. Imaginad que sois el equipo de marketing de una tienda online y tenéis presupuesto para una campaña, pero no para toda la base de clientes. ¿A quién se lo dais?

Eso es lo que resuelve este proyecto: he construido un modelo que estima, para **cada cliente**, la probabilidad de que vuelva a comprar. Con eso podemos dirigir el dinero a quien conviene.

Trabajo sobre Online Retail II: 24 meses de tickets de una tienda británica de regalos. Un millón de transacciones, casi cinco mil clientes, y un modelo que ya os adelanto que acierta bastante: un AUC de 0,81."

> *(SI ALGUIEN NO SABE QUÉ ES EL AUC, EXPLÍCALO ASÍ: "El AUC es como una nota de 0 a 1 de lo bien que el modelo distingue a quien va a volver de quien no. 0,5 sería acertar como quien tira una moneda al aire; 1 sería un acierto perfecto. Un 0,81 es una nota alta: si cojo al azar un cliente que sí volvió y uno que no, el modelo le da más probabilidad al correcto 8 de cada 10 veces.")*

*(Avanza.)*

---

## SLIDE 2 — Objetivos e hipótesis · *(0:30 – 1:25)*

"El objetivo de negocio es doble: **fidelizar** a quien tiene alta probabilidad de volver, y **retener** a quien tiene baja probabilidad, antes de que se vaya.

Aquí está la parte interesante del problema. El dataset son tickets sueltos: no existe una columna que diga 'este cliente recompró'. Así que la **variable objetivo hay que construirla**. Lo hago con una **fecha de corte**, el 1 de junio de 2011: con todo lo de **antes** describo al cliente —cada cuánto compra, cuánto gasta, cómo de reciente es su última compra—; y con lo de **después** miro si volvió a comprar o no. Eso me da el sí o el no que el modelo aprende.

*(Señala la tarjeta derecha.)*

Y muy importante: **qué dejé fuera y por qué**. Quité las ventas sin cliente identificado, que son casi un 23% y no se pueden atribuir a nadie.

Quité las **cancelaciones** —las devoluciones—, y aquí matizo, porque es la pregunta lógica: no las quito porque devolver 'no importe'. Las quito por dos motivos. Uno, porque una devolución **no es una compra**, y lo que predigo son recompras; meterlas ensuciaría la variable objetivo. Y dos, porque son líneas con **cantidades negativas** que distorsionarían el gasto y la frecuencia del cliente. *(Y si quieres rematar:)* Dicho esto, el comportamiento de devolución **sí podría tener señal** —quien devuelve mucho quizá esté más insatisfecho—, por eso en próximos pasos propongo añadir una **tasa de devolución** como variable propia. En esta primera versión lo simplifico.

Quité también valores imposibles, como precio o cantidad negativos. Y acoté los outliers de los grandes mayoristas para que no distorsionen.

El resultado: una base limpia de casi 5.000 clientes, con un 53% de recompra. Es decir, **las clases están equilibradas**, lo cual nos viene bien para modelar."

---

## SLIDE 3 — Descriptivo · *(1:25 – 2:10)*

"Tres ideas del análisis exploratorio, las más relevantes para negocio.

Una: la facturación tiene una **estacionalidad muy clara** —lo veis en el gráfico—, con un pico fuerte antes de Navidad los dos años. La campaña de recompra hay que lanzarla **antes** de ese pico, no durante.

Dos: el negocio está **concentradísimo en Reino Unido**, un 92% de las ventas. Por eso el país, como variable, apenas aporta señal.

Y tres: **muchos clientes compran una sola vez**. Justamente por eso tiene valor saber, de los que ya han comprado, quién va a repetir."

*(Transición.)* "¿Y cómo de bien lo predecimos? Vamos al modelo."

---

## SLIDE 4 — El modelo · *(2:10 – 3:20)*

"Probé tres algoritmos, sin complicarme: una **regresión logística** como base, un **Random Forest** y un **XGBoost**. Los comparé con validación cruzada, para no engañarme con un resultado de suerte.

Gana **XGBoost optimizado**, con un **AUC de 0,81** en datos que el modelo no había visto. Y un detalle honesto: la logística da casi lo mismo, así que la guardo como modelo de respaldo, porque es más fácil de explicar.

*(Señala la curva ROC.)* Esta curva muestra que el modelo separa muy por encima del azar —la diagonal sería tirar una moneda.

Pero lo más útil para vosotros está aquí *(señala las variables)*. Lo que más pesa en la predicción es la **frecuencia** de compra, el **número de artículos**, el **ritmo de compra** y la **recencia**. Traducido: el mejor predictor de que un cliente vuelva es **lo activo que ha sido hasta ahora**. No hace falta nada exótico; el propio comportamiento de compra lo dice casi todo."

---

## SLIDE 5 — Conclusiones y propuesta · *(3:20 – 4:30)*

"Y aquí está la prueba de que esto sirve de verdad. Cogí el modelo, lo apliqué a **toda la base** y la partí en tres segmentos según la probabilidad. Luego comprobé qué porcentaje **recompró realmente** en cada grupo.

*(Señala las tarjetas, de arriba a abajo.)*

En el segmento de **alta probabilidad**, unos 1.500 clientes, recompró el **91%**. A estos: **fidelización** —programa VIP, ventas cruzadas, acceso anticipado a novedades.

En el **medio**, recompró el 54%. A estos: **activación** —un empujón, incentivos puntuales, recomendaciones.

Y en el **bajo**, solo el 21%. Ahí está el riesgo de fuga: **retención** —campaña de recuperación, un descuento de reenganche.

Fijaos en lo limpia que es la separación: del 91 al 21 por ciento. Eso significa que las probabilidades son **fiables y accionables**: cada euro de marketing va donde más rinde."

---

## SLIDE 6 — Próximos pasos y cierre · *(4:30 – 5:00)*

"Para terminar, cómo lo mejoraría con más tiempo: añadir variables de comportamiento, como categorías de producto o devoluciones; probar otras fechas de corte; calibrar las probabilidades para afinar los umbrales; usar SHAP para explicar caso por caso; y, sobre todo, **validarlo con un test A/B real** de las campañas, que es la única forma de medir el impacto de verdad.

En resumen: con un modelo sencillo y un AUC de 0,81, podemos decidir a quién fidelizar y a quién retener, y gastar el presupuesto donde de verdad cuenta. Gracias."

*(Pausa. Mira al tribunal.)* "¿Alguna pregunta?"

---

## Apéndice — Posibles preguntas del tribunal *(no se presenta, es para ti)*

**¿Por qué AUC y no accuracy?**
Porque no queremos solo clasificar, queremos **ordenar** a los clientes por probabilidad para priorizar campañas. El AUC mide justo esa capacidad de ordenar, y además no se deja engañar por el desbalance de clases.

**¿Por qué esa fecha de corte (junio 2011)?**
Deja unos 6 meses de histórico futuro para observar la recompra, suficiente para etiquetar bien, y mantiene una base amplia de clientes con compras previas. Es un parámetro que en "próximos pasos" propongo testear con otros valores.

**¿No hay fuga de información (data leakage)?**
No: las variables se calculan **solo** con datos anteriores al corte, y la etiqueta **solo** con datos posteriores. Nunca se mezclan.

**¿Por qué XGBoost si la logística da casi igual?**
Por eso mismo lo digo abiertamente: la señal es muy lineal. XGBoost gana por poco y da la importancia de variables; la logística queda como respaldo interpretable. En producción, elegir la logística sería defendible.

**¿Por qué quitas las devoluciones? ¿No son una señal de que el cliente no va a volver?**
Buen apunte. Las quito por dos razones técnicas: una devolución no es una compra (no puede ser una "recompra", así que ensuciaría la etiqueta), y son líneas con cantidad negativa que distorsionan el gasto y la frecuencia agregados. **Pero no porque sean irrelevantes**: el comportamiento de devolución probablemente tiene poder predictivo. Por eso la mejora natural —y la incluyo en próximos pasos— es crear una variable de **tasa de devolución por cliente** y meterla en el modelo. En esta primera versión simplifico para tener un baseline limpio.

**¿Qué harías con el 23% de ventas sin cliente?**
Para este modelo se excluyen porque el objetivo es a nivel de cliente. Pero son ventas reales: en otro análisis (de producto o de ticket) sí las usaría.

**¿Cómo se pasa esto a producción?**
Recalcular las variables periódicamente, puntuar a cada cliente y volcar el segmento al CRM para disparar las campañas. El siguiente paso obligado sería el test A/B para medir incrementalidad.
