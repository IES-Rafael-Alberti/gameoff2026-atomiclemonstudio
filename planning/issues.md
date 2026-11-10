# Backlog Game Off 2026 — ColorShift

Plan de 4 sprints (2 → 30 nov) con Scrum, en el Project 293. Los issues están en español porque son internos.

**Sprints:** `S1` (2–8 nov), `S2` (9–15 nov), `S3` (16–22 nov), `S4` (23–30 nov).
**Fase (campo Phase):** S1 = Preproduction · S2 y S3 = Production · S4 = Postproduction. Al final del texto de cada issue va `**Fase:** …`.
**Prioridad (Priority Level):** número del 1 al X **dentro de cada rol y de cada sprint** (1 = lo primero). Cada sprint tiene su prioridad 1 en cada rol. El campo "Priority" no se usa.
**Estimación (Estimated time):** horas totales del issue.
**Sub-issues:** los issues de **más de 8 h** tienen sub-issues reales, cada uno con su responsable (el que va tras la flecha `→`). El resto usa casillas en el texto.
**Milestones:** sirven de referencia de lo que debería estar hecho al final de cada sprint. Son Demo (06/11), S1 · Preproducción y prototipo (08/11), S2 · Mecánicas completas (15/11), S3 · Contenido y congelación (22/11) y S4 · Lanzamiento (30/11).
**Equipo:** @sdurutr436 (Sergio, producción/programación; supervisa y reparte carga), @trueantonio (Antonio, niveles/sonido), @GunterMagno (Alejandro, programación/VFX), @JoelDevHub (Joel, diseño/programación), @lorenagl-1402 (Lorena, arte/marketing), @Gloriaa177 (Gloria, arte; supervisa todo el arte).

**Concepto:** plataformas 2D de puzles. La conejita caballero mira el mundo a través del Cromoscopio (Viewmaster, nombre provisional interno), un visor de dos discos de color. Sin filtro todo es gris; con un filtro, el escenario neutro se tiñe de ese color y lo que es de ese color se vuelve atravesable, o aparece si estaba oculto.

**El GDD manda.** El GDD de una página (`GDD.md`) y el extenso (wiki) son la referencia. Los issues ejecutan, no deciden; marketing se adapta al GDD. Si algo cambia, se cambia primero en el GDD.

**Corte de alcance:** se recorta de abajo arriba dentro de cada rol y sprint. Los issues propuestos que se descarten se cierran con el comentario "Descartado".

**Traslado:** los issues antiguos (#1, #3–#43) se cierran con "Sustituido por #N (nuevo backlog)".

## Correspondencia con el Project 293
| Campo | Valor |
|---|---|
| Title | Título del bloque (el ID `DIS-1` es solo referencia de este documento) |
| Role | Design, Programmer, Artist, Sound, Marketing, Producer, QA/Testing |
| Priority Level | Prioridad dentro de su rol y sprint |
| Sprint | Sprint 1–4 |
| Phase | Preproduction, Production, Postproduction |
| Milestone | El del sprint (la demo, en "Demo") |
| Estimated time | Horas del issue |
| Status | Todo, salvo lo indicado con "Estado" |

---

# DISEÑO

### DIS-1 · GDD de una página
**Prio 1 · S1 · Design, Producer · @JoelDevHub, @sdurutr436 · 4 h · Fase: preproducción · Estado: In Progress**
- [ ] Redactar mantra y pilares (pendiente con el equipo).
- [x] Describir el bucle de juego.
- [x] Definir condiciones de victoria y de reinicio de un nivel.
- [x] Fijar el alcance (8 niveles) y qué se recorta primero.
- [x] Fijar nombre provisional, público objetivo, USP y plataforma.
- [x] Listar los entregables de cada categoría (wiki, página Production).
- [x] Renombrar a `GDD.md` en la raíz del repo.
- [ ] Revisión del equipo.

### DIS-1b · GDD extenso (wiki)
**Prio 2 · S1 · Design, Producer · @JoelDevHub, @sdurutr436 · 12 h · Fase: preproducción · Estado: Done** · *Wiki v0.1 publicada; lo que falta va en DIS-1c*
- [x] Mecánicas en detalle: filtros, discos y mezclas.
- [x] Tipos de objeto de puzle y su comportamiento.
- [x] Estructura de niveles, curva de dificultad y progresión de discos.
- [x] Controles, interfaz y flujo de menús.
- [x] Dirección de arte.
- [x] Dirección de sonido.
- [x] Programación: arquitectura, motor y sistemas.
- [x] Identidad del juego.
- [x] Producción: calendario, entregables por sprint y plan de recorte.

### DIS-1c · Decisiones pendientes del GDD extenso
**Prio 3 · S1 · Design, Producer · @JoelDevHub, @sdurutr436 · 4 h · Fase: preproducción**
- [ ] Mantra (motto) del juego.
- [ ] Historia: quién roba el color y por qué.
- [ ] Historia: cómo termina el juego tras el nivel 8.
- [ ] Historia: cómo se cuenta (bocadillos, viñetas o sin texto).
- [ ] Nombre de la conejita caballero.
- [ ] Responder las preguntas abiertas de la wiki (al pie de `GDD.md`).
- [ ] Revisión de todo el equipo y cierre de la versión 1.0 de la wiki.

### DIS-2 · Reglas de color y tabla de mezclas
**Prio 4 · S1 · Design, Producer · @JoelDevHub, @sdurutr436 · 3 h · Fase: preproducción · Estado: In Progress** · *Escrito en la wiki (Mechanics)*
- [x] Definir los colores base: gris, rojo, azul y amarillo.
- [x] Definir las mezclas: violeta, naranja y verde.
- [x] Escribir la regla de transparencia (filtro igual al color del objeto = atravesable).
- [x] Definir el comportamiento inverso (el objeto aparece solo con cierto filtro).
- [x] Caso del objeto gris/neutro: siempre se ve, es sólido y se tiñe con el filtro.
- [x] Tabla final que usan los programadores y los de nivel.
- [ ] Decidir el aspecto de los objetos de otro color bajo un filtro ("corrompido", negro o color de la mezcla; por ejemplo, un objeto azul con filtro violeta).

### DIS-3 · Prototipo de nivel (blockout)
**Prio 5 · S1 · Design, Programmer, Producer · @trueantonio, @JoelDevHub, @GunterMagno, @sdurutr436 · 5 h · Fase: preproducción**
- [ ] Sala de pruebas con una puerta de color y un filtro.
- [ ] Probar la sensación del movimiento y la escala del jugador.
- [ ] Fijar los parámetros de movimiento (velocidad, altura de salto, gravedad).
- [ ] Anotar problemas de legibilidad con cajas de color planas.

### DIS-4 · Guía de diseño de niveles y plantilla
**Prio 1 · S2 · Design, Producer · @trueantonio, @sdurutr436, @JoelDevHub · 4 h · Fase: producción**
- [ ] Reglas: cada nivel introduce una idea, la prueba y la combina.
- [ ] Duración objetivo por nivel (2–4 minutos).
- [ ] Plantilla de nivel con inicio, salida y objetos listos para colocar.
- [ ] Checklist de revisión de un nivel (solución única, que es lo óptimo para la jam; sin callejones sin salida).
- [x] Soluciones: una única por nivel; los niveles 9 y 10 pueden tener varias.

### DIS-5 · Progresión de discos y reglas por nivel
**Prio 2 · S2 · Design, Producer · @sdurutr436, @JoelDevHub · 3 h · Fase: producción** · *Se escribe en la wiki (Levels)*
- [ ] Tabla nivel → reglas y objetos nuevos.
- [ ] En qué nivel se introduce cada habilidad y cada peligro.
- [ ] Dónde y cómo se consigue el disco 2 (nivel 4): al principio del nivel.
- [ ] Qué mezclas se necesitan en cada nivel.

### DIS-6 · Niveles 1–3 (un disco)
**Prio 1 · S3 · Design, Programmer · @JoelDevHub, @trueantonio, @GunterMagno · 12 h · Fase: producción**
- [ ] N1: ver el gris frente al color; primera puerta con el filtro correcto. → @trueantonio
- [ ] N2: dos colores, elegir el filtro adecuado; introduce el supersalto (amarillo). → @trueantonio
- [ ] N3: objetos que solo aparecen con un filtro; introduce el peso (rojo), el flotar (azul) y el primer enemigo. → @JoelDevHub
- [ ] Anotar la solución de los niveles 1–3. → @trueantonio
- [ ] Prueba interna de los niveles 1–3. → @GunterMagno

### DIS-7 · Niveles 4–6 (segundo disco y mezclas)
**Prio 2 · S3 · Design, Programmer · @JoelDevHub, @trueantonio, @GunterMagno · 14 h · Fase: producción**
- [ ] N4: conseguir el disco 2 y probarlo. → @JoelDevHub
- [ ] N5: mezclas simples (violeta, naranja, verde). → @trueantonio
- [ ] N6: combinar mezclas con obstáculos; enemigos invisibles con su filtro. → @trueantonio
- [ ] Anotar la solución de los niveles 4–6. → @trueantonio
- [ ] Prueba interna de los niveles 4–6. → @GunterMagno

### DIS-8 · Niveles 7–8 y cierre
**Prio 3 · S3 · Design, Programmer · @JoelDevHub, @trueantonio, @GunterMagno · 12 h · Fase: producción**
- [ ] N7: puzle que combina todas las reglas. → @trueantonio
- [ ] N8: nivel final. → @JoelDevHub
- [ ] Pantalla o escena de cierre (según DIS-1c; arte en ART-8). → @JoelDevHub
- [ ] Prueba interna de los niveles 7–8. → @GunterMagno

### DIS-9 · Sistema de pistas
**Prio 4 · S3 · Design, Programmer · @JoelDevHub, @trueantonio, @GunterMagno · 3 h · Fase: producción**
- [ ] Definir cuándo se ofrece la pista (tiempo o botón).
- [ ] Redactar o definir la pista de cada nivel.

### DIS-11 · Niveles 9–10 y extras
**Prio 5 · S3 · Design, Programmer · @JoelDevHub, @trueantonio, @GunterMagno · 12 h · Fase: producción** · *Solo si da tiempo antes de la congelación (22/11); si no, fuera*
- [ ] N9. → @trueantonio
- [ ] N10. → @JoelDevHub

### DIS-10 · Pruebas de juego externas y balance
**Prio 1 · S4 · Design, QA/Testing · @sdurutr436, @trueantonio, @GunterMagno, @JoelDevHub, @lorenagl-1402, @Gloriaa177 · 6 h · Fase: postproducción**
- [ ] Preparar formulario de observación (dónde se atasca, cuánto tarda).
- [ ] Probar con 3 personas externas como mínimo.
- [ ] Priorizar los problemas detectados y abrir issues.
- [ ] Ajustar la dificultad de los niveles peores.

---

# PRODUCCIÓN

### PRO-0 · Demo jugable para el profesor (viernes 06/11)
**Prio 1 · S1 · Producer, Programmer, Design · @sdurutr436, @JoelDevHub, @GunterMagno, @trueantonio · 6 h · Fase: preproducción · Milestone: Demo**
- [ ] Sala de blockout con una puerta de color (DIS-3).
- [ ] Moverse y saltar (PRG-1).
- [ ] Girar el disco derecho: sin filtro, rojo, amarillo y azul (PRG-2).
- [ ] Tinte del escenario en gris y con el color del filtro (PRG-4).
- [ ] Puerta de color atravesable con su filtro (PRG-3).
- [ ] Build web privada en itch.io.
- [ ] Presentarla el viernes 06/11.

### PRO-1 · Motor, estructura del repo y flujo de trabajo
**Prio 2 · S1 · Producer · @sdurutr436 · 5 h · Fase: preproducción · Estado: In Progress**
- [x] Elegir motor (Godot 4.7) y 2D o 3D (2D).
- [x] Crear el proyecto del motor y subirlo a `develop`.
- [ ] Pasar el renderizador de *Forward+* a *Compatibility* (necesario para exportar a web).
- [ ] Jerarquía de carpetas toda en minúsculas (`Scenes/` → `scenes/`).
- [ ] Configurar `.gitignore` y Git LFS si hace falta.
- [ ] Documentar el flujo de ramas (`develop` → PR → `main`) y la convención de commits.
- [ ] Probar que todo el equipo abre el proyecto sin errores.

### PRO-2 · Tema de la jam, tablero y milestones
**Prio 3 · S1 · Producer · @sdurutr436 · 3 h · Fase: preproducción**
- [ ] Confirmar el tema oficial de la Game Off 2026 y cómo encaja el concepto.
- [ ] Configurar las vistas del Project por fase y por rol.
- [ ] Fijar día y hora de la reunión semanal de seguimiento.
- [ ] Plantillas de issue (reporte de bugs, etc.): en otra tarea.

### PRO-3 · Seguimiento del Sprint 1
**Prio 4 · S1 · Producer · @sdurutr436 · 1 h · Fase: preproducción**
- [ ] Revisar el tablero al inicio del sprint.
- [ ] Mover o recortar tareas retrasadas.
- [ ] Avisar al equipo del estado.

### PRO-4 · Seguimiento del Sprint 2
**Prio 1 · S2 · Producer · @sdurutr436 · 1 h · Fase: producción**
- [ ] Revisar el tablero al inicio del sprint.
- [ ] Mover o recortar tareas retrasadas.
- [ ] Avisar al equipo del estado.

### PRO-5 · Prueba temprana de la build web
**Prio 2 · S2 · Producer, QA/Testing · @sdurutr436 · 2 h · Fase: producción**
- [ ] Exportar a web sin hilos y subir una build de prueba privada a itch.io.
- [ ] Probar en escritorio, en un móvil de gama media y con mando.
- [ ] Anotar problemas de rendimiento y de controles.

### PRO-6 · Seguimiento del Sprint 3
**Prio 1 · S3 · Producer · @sdurutr436 · 1 h · Fase: producción**
- [ ] Revisar el tablero al inicio del sprint.
- [ ] Mover o recortar tareas retrasadas.
- [ ] Avisar al equipo del estado.

### PRO-7 · Congelación de contenido (22/11)
**Prio 2 · S3 · Producer · @sdurutr436 · 1 h · Fase: producción**
- [ ] Anunciar el corte: a partir de esa fecha solo errores y pulido.
- [ ] Decidir si entran los extras (DIS-11, PRG-16) o se descartan.
- [ ] Mover al backlog lo que no entra.

### PRO-8 · Seguimiento del Sprint 4
**Prio 1 · S4 · Producer · @sdurutr436 · 1 h · Fase: postproducción**
- [ ] Revisar el tablero al inicio del sprint.
- [ ] Mover o recortar tareas retrasadas.
- [ ] Avisar al equipo del estado.

### PRO-9 · Build y exportación
**Prio 2 · S4 · Producer · @sdurutr436 · 4 h · Fase: postproducción**
- [ ] Configurar la exportación web (escritorio y móvil), sin hilos.
- [ ] Probar la build en otra máquina sin el motor, en móvil y con mando.
- [ ] Generar la build final etiquetada (`v1.0`).

### PRO-10 · Publicación en itch.io y envío a la Game Off
**Prio 3 · S4 · Producer · @sdurutr436 · 3 h · Fase: postproducción**
- [ ] Subir la build a itch.io (ver MKT-4 para la página).
- [ ] Enviarlo a la jam con 24 h de margen (el 30/11). Fecha límite: 01/12/26, 22:00 (hora peninsular).
- [ ] Comprobar la página desde un navegador sin sesión.

### PRO-11 · README, créditos y licencias
**Prio 4 · S4 · Producer · @sdurutr436 · 2 h · Fase: postproducción**
- [ ] Instrucciones de build y controles.
- [ ] Créditos del equipo y del músico externo, si lo hay.
- [ ] Licencias de assets (incluidos los placeholders: caballero, slimes, tileset) y herramientas.

---

# ARTE

### ART-1 · Dirección de arte
**Prio 1 · S1 · Artist · @Gloriaa177, @lorenagl-1402 · 8 h · Fase: preproducción**
- [ ] Moodboard.
- [ ] Definición del estilo de arte: formas, contorno y resolución base del pixel art.
- [ ] Paleta base legible: gris, rojo, amarillo y azul, más naranja, verde y violeta.
- [ ] Comprobar que cada color tiene un gris distinto por luminosidad (amarillo el más claro, azul el más oscuro).
- [ ] Probar la paleta con simuladores de daltonismo.
- [ ] Hoja de estilo de una página para todo el equipo.

### ART-2 · Cromoscopio (Viewmaster) y HUD
**Prio 1 · S2 · Artist, Producer · @Gloriaa177, @lorenagl-1402, @sdurutr436 · 8 h · Fase: producción**
- [ ] Diseño del Cromoscopio (silueta y marco).
- [ ] Sprites de los dos discos.
- [ ] Indicador del color activo y de los discos que tienes.
- [ ] Animación del giro del disco.

### ART-3 · Conejita caballero
**Prio 2 · S2 · Artist, Design, Programmer · @Gloriaa177, @JoelDevHub, @GunterMagno · 8 h · Fase: producción**
- [ ] Sprite de la conejita caballero.
- [ ] Animaciones: reposo, andar, saltar, caer y morir.
- [ ] Montaje de las animaciones en Godot (apoyo de diseño y programación).

### ART-4 · Arte de entornos y objetos
**Prio 1 · S3 · Artist · @Gloriaa177, @lorenagl-1402 · 12 h · Fase: producción**
- [ ] Tileset del entorno. → @Gloriaa177
- [ ] Sprites de puerta, muro, plataforma, interruptor, pincel (con versión de contorno punteado), cerradura y salida. → @lorenagl-1402, @Gloriaa177
- [ ] Variantes de color de cada objeto. → @lorenagl-1402, @Gloriaa177
- [ ] Objetos de habilidad: suelo agrietado, bloque empujable y pared de salto. → @lorenagl-1402, @Gloriaa177
- [ ] Fondo de nivel. → @Gloriaa177
- [ ] Integración de los assets en el motor. → @lorenagl-1402, @Gloriaa177

### ART-5 · Enemigos y peligros
**Prio 2 · S3 · Artist, Design, Programmer · @lorenagl-1402, @Gloriaa177, @JoelDevHub, @GunterMagno · 6 h · Fase: producción**
- [ ] Hormiga y oruga en sus colores.
- [ ] Animaciones de patrulla y muerte.
- [ ] Pinchos.
- [ ] Montaje de las animaciones en Godot (apoyo de diseño y programación).

### ART-6 · Interfaz y menús
**Prio 3 · S3 · Artist, Programmer · @lorenagl-1402, @Gloriaa177, @GunterMagno · 6 h · Fase: producción**
- [ ] Menú principal, pausa, ajustes y créditos.
- [ ] Botones y palancas del mando virtual táctil.
- [ ] Pantalla de "pulsa para empezar".

### ART-7 · Iconos y patrones por color
**Prio 4 · S3 · Artist · @Gloriaa177 · 4 h · Fase: producción**
- [ ] Un icono o patrón por color.
- [ ] Revisión con los objetos en pantalla.

### ART-8 · Cierre y narrativa
**Prio 5 · S3 · Artist, Design · @Gloriaa177, @lorenagl-1402, @JoelDevHub · 4 h · Fase: producción** · *Depende de DIS-1c*
- [ ] Pantalla de cierre.
- [ ] Escena final.
- [ ] Bocadillos de texto o viñetas, si hay narrativa.

---

# SONIDO

### SND-1 · Sonido: primera pasada
**Prio 1 · S2 · Sound · @trueantonio · 5 h · Fase: producción**
- [ ] Efecto de clic del disco y de cambio de filtro.
- [ ] Efecto de puerta u objeto que se vuelve transparente.
- [ ] Efecto de victoria y de reinicio.
- [ ] Música de prueba en bucle.

### SND-2 · Música por capas (sistema)
**Prio 2 · S2 · Sound, Programmer, Producer · @trueantonio, @JoelDevHub, @sdurutr436 · 6 h · Fase: producción**
- [ ] Capas sincronizadas con `AudioStreamSynchronized`.
- [ ] Activar la capa de cada color según el filtro; las mezclas combinan las capas de sus dos primarios.
- [ ] Fundido al cambiar de filtro (≈0,25 s, igual que la animación del disco).

### SND-4 · Música y ambiente
**Prio 1 · S3 · Sound, Producer · @trueantonio, @sdurutr436 · 12 h · Fase: producción** · *4 temas (uno cada 2 niveles) × 3 capas (rojo, amarillo, azul) = 16 piezas; puede que no dé tiempo a todas*
- [ ] Buscar un músico externo; si no surge, se hace internamente. → @sdurutr436
- [ ] Tema 1 (niveles 1–2) con sus 3 capas. → @trueantonio
- [ ] Tema 2 (niveles 3–4) con sus 3 capas. → @trueantonio
- [ ] Tema 3 (niveles 5–6) con sus 3 capas. → @trueantonio
- [ ] Tema 4 (niveles 7–8) con sus 3 capas. → @trueantonio
- [ ] Sonido ambiente. → @trueantonio

### SND-3 · Efectos del jugador y de los menús
**Prio 2 · S3 · Sound, Programmer · @trueantonio, @GunterMagno · 4 h · Fase: producción**
- [ ] Salto y aterrizaje.
- [ ] Muerte.
- [ ] Recoger pincel o disco.
- [ ] Objeto oculto que aparece.
- [ ] Navegar y confirmar en los menús.
- [ ] Integración en Godot (apoyo de programación).

### SND-5 · Pulido de sonido y música
**Prio 1 · S4 · Sound · @trueantonio · 4 h · Fase: postproducción**
- [ ] Equilibrar los volúmenes de efectos y música.
- [ ] Ajustes de bucle y de transición entre niveles.

---

# MARKETING

Marketing hace la promoción: página del juego, plan y publicidad en redes y material promocional. Parte del GDD y se adapta a él.

### MKT-5 · Nombre definitivo del juego
**Prio 1 · S1 · Marketing, Design · @lorenagl-1402 · 1 h · Fase: preproducción** · *Se crea el último*
- [ ] Proponer el nombre definitivo al equipo (05/11).
- [ ] Registrarlo en el GDD.

### MKT-0 · Plan de marketing
**Prio 2 · S1 · Marketing · @lorenagl-1402 · 4 h · Fase: preproducción** · *Depende de DIS-1*
- [ ] Canales y calendario de publicaciones (redes, itch.io, comunidad de la Game Off).
- [ ] Mensajes clave a partir del USP y del público del GDD.
- [ ] Anuncio de que nos hemos establecido como estudio.
- [ ] Plan de teasers: pistas con pequeños objetos del juego.
- [ ] En público (itch.io, redes) solo se usa "Cromoscopio" / *Chromoscope*, nunca "Viewmaster" (marca registrada de Mattel).
- [ ] Qué material hace falta y quién lo produce.

### MKT-1 · Actualizar la web del estudio
**Prio 3 · S1 · Marketing · @lorenagl-1402 · 4 h · Fase: preproducción**
- [ ] Sustituir el post de bienvenida de Jekyll.
- [ ] Página del equipo.
- [ ] Portada del juego en `docs/` (cuando se fije el nombre).

### MKT-W1 · Publicaciones de la semana 1
**Prio 4 · S1 · Marketing · @lorenagl-1402 · 2 h · Fase: preproducción**
- [ ] Anuncio del estudio.
- [ ] Primer teaser según el plan de MKT-0.

### MKT-2 · Logo y portada del juego
**Prio 1 · S2 · Marketing, Artist · @lorenagl-1402, @Gloriaa177 · 5 h · Fase: producción** · *Depende de MKT-5 (nombre)*
- [ ] Logo.
- [ ] Portada provisional.

### MKT-W2 · Publicaciones de la semana 2
**Prio 2 · S2 · Marketing · @lorenagl-1402 · 2 h · Fase: producción**
- [ ] Teaser con un objeto del juego.
- [ ] Publicación de avance según el calendario de MKT-0.

### MKT-3 · Material promocional
**Prio 1 · S3 · Marketing · @lorenagl-1402 · 6 h · Fase: producción** · *Depende de MKT-0*
- [ ] Capturas de pantalla de los mejores niveles.
- [ ] GIF del Cromoscopio en acción.

### MKT-W3 · Publicaciones de la semana 3
**Prio 2 · S3 · Marketing · @lorenagl-1402 · 2 h · Fase: producción**
- [ ] Teaser con un objeto del juego.
- [ ] Publicación con capturas o GIF de MKT-3.

### MKT-4 · Página del juego en itch.io
**Prio 1 · S4 · Marketing · @lorenagl-1402 · 5 h · Fase: postproducción** · *Depende de MKT-0 y MKT-2*
- [ ] Descripción y controles (teclado, mando y táctil), en español e inglés.
- [ ] Portada, capturas y GIF.
- [ ] Etiquetas y créditos.

### MKT-W4 · Publicaciones de la semana 4
**Prio 2 · S4 · Marketing · @lorenagl-1402 · 2 h · Fase: postproducción**
- [ ] Anuncio del lanzamiento con el enlace a itch.io.
- [ ] Publicación después del envío a la jam.

---

# PROGRAMACIÓN

### PRG-1 · Controlador de jugador y cámara
**Prio 1 · S1 · Programmer · @JoelDevHub, @sdurutr436 · 6 h · Fase: preproducción**
- [ ] Movimiento y colisiones.
- [ ] Salto de altura variable, *coyote time* y *jump buffer* (propuesta).
- [ ] Interacción con el botón de acción (E / X).
- [ ] Cámara descentrada que deja ver el marco del Cromoscopio.
- [ ] Probar en la sala de DIS-3.

### PRG-2 · Sistema de color: `ColorState` y filtro
**Prio 2 · S1 · Programmer · @sdurutr436 · 6 h · Fase: preproducción**
- [ ] Enum o recurso de colores (ninguno, rojo, amarillo, azul): cambiar `GREEN` por `YELLOW` en `game_manager.gd`. Propuesta: colores como bits (página Programming de la wiki).
- [ ] Registrar `GameManager` y `SceneManager` como autoload.
- [ ] Señal global `filter_changed(color)`.
- [ ] Input para girar los discos: Q (izquierdo) y E (derecho), y 1–4 / 5–8 para ir directo a un color.
- [ ] Objeto de prueba que reacciona al cambio.

### PRG-3 · Objeto `ColoredObject`
**Prio 3 · S1 · Programmer · @GunterMagno · 8 h · Fase: preproducción**
- [ ] Color propio por objeto.
- [ ] Atravesable con el filtro coincidente; sólido con otro.
- [ ] Modo oculto (aparece solo con su filtro).
- [ ] Puerta roja de prueba: atravesable con filtro rojo.

### PRG-4 · Shader de tinte del escenario
**Prio 4 · S1 · Programmer · @GunterMagno · 8 h · Fase: preproducción**
- [ ] Post-proceso que tiñe el escenario con el color activo, compatible con WebGL 2 (*Compatibility*).
- [ ] Escala de grises por luminosidad sin filtro.
- [ ] Parámetros de intensidad y contraste.
- [ ] Plan B: tintar los sprites directamente si el post-proceso se complica.

### PRG-5 · Segundo disco y mezcla de colores
**Prio 1 · S2 · Programmer, Producer · @sdurutr436, @JoelDevHub · 10 h · Fase: producción**
- [ ] Ampliar `ColorState` a los colores compuestos. → @sdurutr436
- [ ] Segundo disco superpuesto al primero. → @JoelDevHub
- [ ] Input para girar cada disco por separado (Q / E, L1 / R1). → @sdurutr436
- [ ] Probar los 6 colores con sus objetos. → @JoelDevHub

### PRG-6 · Inventario de discos y guardado
**Prio 2 · S2 · Programmer · @JoelDevHub · 4 h · Fase: producción**
- [ ] Objeto recogible disco.
- [ ] Guardar los discos y el progreso entre niveles (`user://`).

### PRG-7 · Elementos de puzle base
**Prio 3 · S2 · Programmer, Design, Producer · @GunterMagno, @JoelDevHub, @trueantonio, @sdurutr436 · 12 h · Fase: producción**
- [ ] Puerta de color. → @GunterMagno
- [ ] Muro tintado. → @GunterMagno
- [ ] Plataforma que solo existe con cierto filtro. → @GunterMagno
- [ ] Interruptor / placa de presión (abren puertas y mueven plataformas). → @JoelDevHub, @trueantonio
- [ ] Pincel (se recoge al tocarlo) y cerradura (se abre con F). → @JoelDevHub
- [ ] Pincel oculto (sin su filtro solo se ve el contorno punteado del color que hay que elegir). → @JoelDevHub
- [ ] Vibración única del tileset cuando el filtro no coincide con el color de la pared o plataforma. → @GunterMagno
- [ ] Salida del nivel. → @GunterMagno

### PRG-8 · Gestor de niveles y flujo de juego
**Prio 4 · S2 · Programmer · @sdurutr436 · 10 h · Fase: producción**
- [ ] Carga de niveles por orden. → @sdurutr436
- [ ] Pantalla de "pulsa para empezar" (desbloquea el audio en web). → @sdurutr436
- [ ] Menú principal. → @sdurutr436
- [ ] Menú con Tabulador (hace de pausa) y selección de nivel. → @sdurutr436
- [ ] Reinicio de nivel con R / Y. → @sdurutr436
- [ ] Pantalla final. → @sdurutr436

### PRG-9 · Habilidades por color
**Prio 5 · S2 · Programmer, Design, Producer · @JoelDevHub, @GunterMagno, @trueantonio, @sdurutr436 · 10 h · Fase: producción** · *Propuesta: si no encaja, se cierra como "Descartado"*
- [ ] Habilidad activa mientras su filtro está puesto. → @JoelDevHub
- [ ] Rojo, peso: cae más rápido, rompe suelos agrietados y empuja bloques. → @JoelDevHub
- [ ] Azul, flotar: gravedad reducida. → @GunterMagno
- [ ] Amarillo: supersalto y salto en pared. → @GunterMagno
- [ ] Objetos de habilidad: suelo agrietado, bloque empujable y pared de salto. → @GunterMagno
- [ ] Ajustar los parámetros de las habilidades en el blockout. → @trueantonio

### PRG-10 · Peligros y condiciones de derrota
**Prio 6 · S2 · Programmer, Design, Producer · @JoelDevHub, @GunterMagno, @trueantonio, @sdurutr436 · 8 h · Fase: producción**
- [ ] Pinchos.
- [ ] Caída fuera de la pantalla.
- [ ] Enemigo insecto que patrulla de lado a lado, con color.
- [ ] Enemigo invisible con su filtro, pero que sigue matando.
- [ ] Muerte: efecto en el personaje y reinicio de la pantalla.

### PRG-11 · Ajustes, remapeo y mando
**Prio 1 · S3 · Programmer, QA/Testing · @JoelDevHub, @GunterMagno, @sdurutr436 · 8 h · Fase: producción** · *QA: @sdurutr436*
- [ ] Remapeo de controles (jugable con una mano).
- [ ] Soporte de mando: stick o cruceta, A / X / Y y L1 / R1.
- [ ] Volúmenes de música y efectos por separado.
- [ ] Pantalla completa.

### PRG-13 · VFX: transiciones y feedback
**Prio 2 · S3 · Programmer · @GunterMagno · 8 h · Fase: producción**
- [ ] Transición suave al cambiar de filtro (giro del disco, ≈0,25 s).
- [ ] Partículas al resolver un puzle.
- [ ] Efecto de desvanecimiento del objeto atravesable.

### PRG-18 · Localización ES / EN
**Prio 3 · S3 · Programmer, QA/Testing · @GunterMagno, @JoelDevHub, @sdurutr436 · 6 h · Fase: producción** · *QA: @sdurutr436*
- [ ] Archivo CSV de traducciones de Godot (español e inglés).
- [ ] Selector de idioma en Ajustes.
- [ ] Traducir menús, ajustes, pistas y bocadillos.
- [ ] Revisar textos que no caben en pantalla.

### PRG-17 · Bocadillos de texto
**Prio 4 · S3 · Programmer, Design · @JoelDevHub, @GunterMagno · 6 h · Fase: producción** · *Se prepara por si se usa; depende de DIS-1c*
- [ ] Sistema de bocadillos sobre los personajes.
- [ ] Textos cargados desde el archivo de traducción (PRG-18).
- [ ] Activar un bocadillo al entrar en una zona.
- [ ] Probarlo en un nivel.

### PRG-12 · Modo daltónico
**Prio 5 · S3 · Programmer · @GunterMagno · 3 h · Fase: producción** · *Recortable*
- [ ] Opción en ajustes.
- [ ] Mostrar los iconos y patrones de ART-7.

### PRG-14 · Mando virtual táctil
**Prio 6 · S3 · Programmer, QA/Testing · @JoelDevHub, @GunterMagno, @sdurutr436 · 6 h · Fase: producción** · *Recortable: si se recorta, el juego queda solo para escritorio. QA: @sdurutr436*
- [ ] Stick virtual.
- [ ] Botones A / X / Y.
- [ ] Palancas para los dos discos.
- [ ] Orientación horizontal y botón de pantalla completa.

### PRG-16 · Habilidades secundarias
**Prio 7 · S3 · Programmer, Design, Producer · @JoelDevHub, @GunterMagno, @trueantonio, @sdurutr436 · 8 h · Fase: producción** · *Fuera de alcance: solo si da tiempo antes de la congelación (22/11); si no, se cierra como "Descartado"*
- [ ] Verde: trepar por enredaderas.
- [ ] Violeta: atravesar paredes finas.
- [ ] Naranja: dash horizontal.

### PRG-15 · Corrección de errores
**Prio 1 · S4 · Programmer, QA/Testing · @sdurutr436, @JoelDevHub, @GunterMagno · 12 h · Fase: postproducción**
- [ ] Resolver los fallos de jugabilidad detectados en DIS-10. → @JoelDevHub
- [ ] Resolver los fallos técnicos y de rendimiento detectados en DIS-10. → @GunterMagno
- [ ] Probar la build final de principio a fin. → @sdurutr436

---

## Riesgos
- **Alcance:** 8 niveles buenos valen más que 15 mediocres.
- **Legibilidad del color:** probar el daltonismo desde S1.
- **Dependencia del shader:** ver el plan B en PRG-4.
- **Rendimiento en móvil:** prueba temprana en S2 (PRO-5).
- **Música:** 16 piezas en 12 h; si no da tiempo, se priorizan los temas 1 y 2 y se buscan assets de sonido.
