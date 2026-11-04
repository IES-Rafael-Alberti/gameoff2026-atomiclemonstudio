# Backlog Game Off 2026 — Viewmaster de colores

Plan de 4 semanas (4 nov → 30 nov). Un issue por bloque `###`; cada `- [ ]` es un sub-issue (tarea de 1–4 h aprox., con una persona y un resultado comprobable).

**Prioridad:** número dentro de cada categoría (1 = lo primero, número mayor = más prescindible). No se compara entre categorías.
**Sprints:** `S1` (4–10 nov), `S2` (11–17 nov), `S3` (18–24 nov), `S4` (25–30 nov).
**Estimación:** horas totales de trabajo del issue (suma orientativa de sus sub-issues).
**Responsables** según el README: @sdurutr436 (Sergio, prod/prog), @trueantonio (Antonio, niveles/sonido), @GunterMagno (Alejandro, prog/VFX), @JoelDevHub (Joel, diseño/prog), @lorenagl-1402 (Lorena, arte/marketing), @Gloriaa177 (Gloria, arte).

**Concepto:** puzzles en los que el jugador mira el mundo a través de un viewmaster de un solo ocular con discos de color superpuestos. El color del filtro tiñe el escenario: lo que coincide con el filtro se vuelve transparente/atravesable y el resto queda tintado u opaco.

**Corte de alcance:** si se retrasa algo, se recorta de abajo arriba en cada categoría.

**El GDD manda.** El GDD (de 1 página y de 10) es el documento de referencia: lo que debe hacerse en todas las categorías (diseño, producción, arte, sonido, marketing y programación) se decide ahí. Los issues de las demás categorías **ejecutan** lo que dice el GDD, no lo deciden. Por eso:
- El GDD fija las pautas del juego: mecánicas, nombre, público objetivo, USP, tono, etc. Marketing no las decide.
- Marketing decide y hace lo suyo: página del juego, plan y publicidad en redes, material promocional. Parte de lo que fija el GDD.
- `DIS-2` (reglas de color) y `DIS-5` (progresión) se escriben dentro del GDD extenso, no son documentos aparte.
- Si algo cambia, se cambia primero en el GDD y después en los issues.

## Correspondencia con el tablero de GitHub Projects

| Columna | Valor |
|---|---|
| Title | Título del issue (el ID `DIS-1` es solo referencia de este documento) |
| Role | Categoría: Diseño, Producción, Arte, Marketing o Programación |
| Priority Level | Número de prioridad dentro de su categoría |
| Sprint | S1, S2, S3 o S4 |
| Assignees | Los @ del responsable |
| Sub-issues | Cada `- [ ]` del issue |
| Estimated time | La estimación en horas del issue |

| Issue existente | Bloque | Comentario |
|---|---|---|
| #3 GDD Page 1 | DIS-1 | Asignado a @sdurutr436 en el tablero (aquí figura @JoelDevHub) |
| #4 GDD 10 Page | DIS-1b | Versión extensa del GDD |
| #6 Prototipado de nivel | DIS-3 / PRG-1 | Sin asignar ni categoría |
| #7 Creación moodboard | ART-1 | Primer sub-issue |
| #8 Creación de la jerarquía de carpetas | PRO-1 | Parte de PRO-1 |
| #9 Definición del estilo de arte | ART-1 | Parte de ART-1 |
| #11 Generación de assets | ART-4 | Se solapa con ART-4 y ART-2 |

---

# DISEÑO (niveles, mecánicas)

### DIS-1 · GDD de una página
**Prio 1 · S1 · @JoelDevHub · 4 h**
- [ ] Redactar pitch y pilares (2–3 frases cada uno).
- [ ] Describir el bucle de juego: ver → cambiar filtro → atravesar → resolver.
- [ ] Definir condiciones de victoria y de reinicio de un nivel.
- [ ] Fijar el alcance (8 niveles) y qué se recorta primero.
- [ ] Fijar nombre provisional del juego, público objetivo, USP (qué lo hace único) y plataforma.
- [ ] Listar los entregables de cada categoría (arte, sonido, marketing, producción, programación).

### DIS-1b · GDD extenso (10 páginas)
**Prio 2 · S1 · @JoelDevHub · 12 h**
Es el documento de referencia de todo el equipo. Cada sección la revisa quien la ejecuta.
- [ ] Mecánicas en detalle: filtros, discos y mezclas (incluye DIS-2).
- [ ] Tipos de objeto de puzzle y su comportamiento.
- [ ] Estructura de niveles, curva de dificultad y progresión de discos (incluye DIS-5).
- [ ] Controles, interfaz y flujo de menús.
- [ ] Dirección de arte: estilo, paleta, referencias y lista de assets (con @Gloriaa177).
- [ ] Dirección de sonido: música y efectos necesarios (con @trueantonio).
- [ ] Programación: arquitectura, motor y sistemas a desarrollar (con @sdurutr436 y @GunterMagno).
- [ ] Identidad del juego: nombre definitivo, público objetivo, USP, tono y referencias (con @lorenagl-1402, que lo usará en marketing).
- [ ] Producción: calendario, entregables por sprint y plan de recorte.
- [ ] Revisión de todo el equipo y cierre de versión.

### DIS-2 · Reglas de color y tabla de mezclas
**Prio 3 · S1 · @JoelDevHub · 3 h** · *Se escribe dentro del GDD extenso (DIS-1b)*
- [ ] Definir los colores base: gris, rojo, azul y amarillo.
- [ ] Definir las mezclas: morado, naranja y verde.
- [ ] Escribir la regla de transparencia (filtro igual al color del objeto = atravesable).
- [ ] Definir el comportamiento inverso (el objeto aparece solo con cierto filtro).
- [ ] Caso del objeto gris/neutro: ¿se ve siempre?
- [ ] Tabla final en una página que usan los programadores y los de nivel.

### DIS-3 · Prototipo de nivel (blockout)
**Prio 4 · S1 · @trueantonio · 5 h**
- [ ] Sala de pruebas con una puerta de color y un filtro.
- [ ] Probar la sensación del movimiento y la escala del jugador.
- [ ] Anotar problemas de legibilidad con cajas de color planas.

### DIS-4 · Guía de diseño de niveles y plantilla
**Prio 5 · S2 · @trueantonio · 4 h**
- [ ] Reglas: cada nivel introduce una idea, la prueba y la combina.
- [ ] Duración objetivo por nivel (2–4 minutos).
- [ ] Plantilla de nivel con inicio, salida y objetos listos para colocar.
- [ ] Checklist de revisión de un nivel (solución única, sin callejones).

### DIS-5 · Progresión de discos y reglas por nivel
**Prio 6 · S2 · @JoelDevHub · 3 h** · *Se escribe dentro del GDD extenso (DIS-1b)*
- [ ] Tabla nivel → reglas/objetos nuevos.
- [ ] Dónde y cómo se consigue el disco 2 (nivel 4).
- [ ] Qué mezclas se necesitan en cada nivel.

### DIS-6 · Niveles 1–3 (un disco)
**Prio 7 · S3 · @trueantonio · 12 h**
- [ ] N1: ver gris frente a color; primera puerta con el filtro correcto.
- [ ] N2: dos colores, elegir el filtro adecuado.
- [ ] N3: objetos que aparecen solo con un filtro.
- [ ] Anotar la solución de cada nivel.
- [ ] Prueba interna de los tres niveles.

### DIS-7 · Niveles 4–6 (segundo disco y mezclas)
**Prio 8 · S3 · @trueantonio, @JoelDevHub · 14 h**
- [ ] N4: conseguir el disco 2 y probarlo.
- [ ] N5: mezclas simples (morado, naranja, verde).
- [ ] N6: combinar mezclas con obstáculos.
- [ ] Anotar la solución de cada nivel.
- [ ] Prueba interna de los tres niveles.

### DIS-8 · Niveles 7–8 y cierre
**Prio 9 · S3 · @trueantonio, @JoelDevHub · 12 h**
- [ ] N7: puzzle que combina todas las reglas.
- [ ] N8: nivel final.
- [ ] Pantalla o escena de cierre.
- [ ] Prueba interna de los dos niveles.

### DIS-9 · Sistema de pistas
**Prio 10 · S3 · @JoelDevHub · 3 h**
- [ ] Definir cuándo se ofrece la pista (tiempo o botón).
- [ ] Redactar o definir la pista de cada nivel.

### DIS-10 · Pruebas de juego externas y balance
**Prio 11 · S4 · Todo el equipo · 6 h**
- [ ] Preparar formulario de observación (dónde se atasca, cuánto tarda).
- [ ] Probar con 3 personas externas como mínimo.
- [ ] Priorizar los problemas detectados y abrir issues.
- [ ] Ajustar dificultad de los niveles peores.

### DIS-11 · Niveles 9–10 y extras
**Prio 12 · S3–S4 · @trueantonio, @JoelDevHub · 12 h**
- [ ] Solo si el contenido principal está cerrado y probado.

---

# PRODUCCIÓN

### PRO-1 · Motor, estructura del repo y flujo de trabajo
**Prio 1 · S1 · @sdurutr436 · 5 h**
- [ ] Elegir motor (recomendado: Godot 4) y 2D o 3D.
- [ ] Crear el proyecto del motor y subirlo a `develop`.
- [ ] Crear la jerarquía de carpetas (#8).
- [ ] Configurar `.gitignore` y Git LFS si hace falta.
- [ ] Documentar el flujo de ramas (`develop` → PR → `main`) y la convención de commits.
- [ ] Probar que todo el equipo abre el proyecto sin errores.

### PRO-2 · Tema de la jam, tablero y milestones
**Prio 2 · S1 · @sdurutr436 · 3 h**
- [ ] Confirmar el tema oficial de la Game Off 2026 y cómo encaja el concepto.
- [ ] Rellenar Role, Priority Level, Sprint y Estimated time de los issues existentes.
- [ ] Crear los issues y sub-issues de este documento.
- [ ] Reunión corta semanal de seguimiento (fijar día y hora).

### PRO-3 · Seguimiento semanal
**Prio 3 · S1–S4 · @sdurutr436 · 4 h**
- [ ] Revisión del tablero al inicio de cada sprint.
- [ ] Mover o recortar tareas retrasadas.
- [ ] Aviso al equipo del estado antes de cada sprint.

### PRO-4 · Congelación de contenido
**Prio 4 · S3 (24 nov) · @sdurutr436 · 1 h**
- [ ] Anunciar el corte: a partir de esa fecha solo errores y pulido.
- [ ] Mover al backlog lo que no entra.

### PRO-5 · Build y exportación
**Prio 5 · S4 · @sdurutr436 · 4 h**
- [ ] Configurar la exportación web (o Windows).
- [ ] Probar la build en otra máquina sin el motor instalado.
- [ ] Generar la build final etiquetada (`v1.0`).

### PRO-6 · Publicación en itch.io y envío a la Game Off
**Prio 6 · S4 · @sdurutr436 · 3 h**
- [ ] Subir la build a itch.io (ver MKT-4 para la página).
- [ ] Enviarlo a la jam con 24 h de margen.
- [ ] Comprobar la página desde un navegador sin sesión.

### PRO-7 · README, créditos y licencias
**Prio 7 · S4 · @sdurutr436 · 2 h**
- [ ] Instrucciones de build y controles.
- [ ] Créditos del equipo.
- [ ] Licencias de assets y herramientas.

---

# ARTE (sonido y arte 2D) <- Quitando la duda, está todo ->

### ART-1 · Dirección de arte
**Prio 1 · S1 · @Gloriaa177, @lorenagl-1402 · 8 h**
- [ ] Moodboard (#7).
- [ ] Definición del estilo de arte (#9): formas, contorno, resolución.
- [ ] Paleta base legible en gris, rojo, azul y amarillo.
- [ ] Probar la paleta con simuladores de daltonismo.
- [ ] Hoja de estilo de una página para todo el equipo.

### ART-2 · Viewmaster y HUD
**Prio 2 · S2 · @Gloriaa177 · 8 h**
- [ ] Diseño del viewmaster (silueta y marco).
- [ ] Sprites de los dos discos.
- [ ] Indicador del color activo y de los discos que tienes.
- [ ] Animación del giro del disco.

### ART-3 · Sonido: primera pasada
**Prio 3 · S2 · @trueantonio · 5 h**
- [ ] Efecto de clic del disco y cambio de filtro.
- [ ] Efecto de puerta/objeto que se vuelve transparente.
- [ ] Efecto de victoria y de reinicio.
- [ ] Música de prueba en bucle.

### ART-4 · Arte de entornos y objetos
**Prio 4 · S3 · @Gloriaa177, @lorenagl-1402 · 20 h**
- [ ] Tileset del entorno.
- [ ] Sprites de puerta, muro, plataforma, interruptor y llave (#11).
- [ ] Variantes de color de cada objeto.
- [ ] Sprite del jugador (reposo, andar).
- [ ] Fondo de nivel.
- [ ] Integración de los assets en el motor.

### ART-5 · Iconos y patrones por color -> Duda con este issue
**Prio 5 · S3 · @Gloriaa177 · 4 h**
- [ ] Un icono o patrón por color.
- [ ] Revisión con los objetos en pantalla.

### ART-6 · Música y ambiente por nivel
**Prio 6 · S3 · @trueantonio · 8 h**
- [ ] Música del tutorial.
- [ ] Música de los niveles con mezclas.
- [ ] Sonido ambiente.

### ART-7 · Pulido de sonido y música
**Prio 7 · S4 · @trueantonio · 4 h**
- [ ] Equilibrar volúmenes de efectos y música.
- [ ] Ajustes de bucle y transición entre niveles.

---

# MARKETING

Marketing decide y ejecuta la promoción: página del juego, plan y publicidad en redes, material promocional. Parte de lo que fija el GDD (nombre, público objetivo, USP, tono, identidad) y no lo redefine.

### MKT-0 · Plan de marketing
**Prio 1 · S1 · @lorenagl-1402 · 4 h** · *Depende de DIS-1*
- [ ] Canales y calendario de publicaciones (RRSS, itch.io, comunidad de la Game Off).
- [ ] Mensajes clave a partir del USP y el público del GDD.
- [ ] Qué material hace falta y quién lo produce.

### MKT-1 · Actualizar la web del estudio
**Prio 2 · S1 · @lorenagl-1402 · 4 h** · *No depende del GDD*
- [ ] Sustituir el post de bienvenida de Jekyll.
- [ ] Página del equipo.
- [ ] Portada del juego en `docs/` (cuando el GDD fije el nombre).

### MKT-2 · Logo y portada del juego
**Prio 3 · S2 · @lorenagl-1402, @Gloriaa177 · 5 h** · *Depende de DIS-1b (nombre e identidad)*
- [ ] Logo.
- [ ] Portada provisional.

### MKT-3 · Publicidad en redes y material promocional
**Prio 4 · S3 · @lorenagl-1402 · 6 h** · *Depende de MKT-0*
- [ ] Capturas de pantalla de los mejores niveles.
- [ ] GIF del viewmaster en acción.
- [ ] Publicaciones de avance según el calendario de MKT-0.

### MKT-4 · Página del juego en itch.io
**Prio 5 · S4 · @lorenagl-1402 · 5 h** · *Depende de MKT-0 y MKT-2*
- [ ] Redactar la descripción y los controles.
- [ ] Portada, capturas y GIF.
- [ ] Etiquetas y créditos.

---

# PROGRAMACIÓN

### PRG-1 · Controlador de jugador y cámara
**Prio 1 · S1 · @JoelDevHub · 6 h**
- [ ] Movimiento y colisiones.
- [ ] Interacción con el botón de acción.
- [ ] Cámara.
- [ ] Probar en la sala de DIS-3.

### PRG-2 · Sistema de color: `ColorState` y filtro
**Prio 2 · S1 · @sdurutr436 · 6 h**
- [ ] Enum o recurso de colores (ninguno, rojo, azul, amarillo).
- [ ] Señal global `filter_changed(color)`.
- [ ] Input para cambiar de filtro con el disco 1.
- [ ] Objeto de prueba que reacciona al cambio.

### PRG-3 · Objeto `ColoredObject`
**Prio 3 · S1 · @GunterMagno · 8 h**
- [ ] Color propio por objeto.
- [ ] Atravesable con el filtro coincidente, opaco y tintado con otro.
- [ ] Modo invertido (aparece solo con ciertos filtros).
- [ ] Puerta roja de prueba: atravesable con filtro rojo.

### PRG-4 · Shader de tinte del escenario
**Prio 4 · S1 · @GunterMagno · 8 h**
- [ ] Post-proceso que tiñe la pantalla con el color activo.
- [ ] Gris sin filtro.
- [ ] Parámetros de intensidad y contraste.
- [ ] Plan B: tintar sprites directamente si el post-proceso se complica.

### PRG-5 · Segundo disco y mezcla de colores
**Prio 5 · S2 · @sdurutr436, @JoelDevHub · 10 h**
- [ ] Ampliar `ColorState` a colores compuestos.
- [ ] Segunda rueda superpuesta a la primera.
- [ ] Input para cambiar cada disco por separado.
- [ ] Probar los 6 colores con sus objetos.

### PRG-6 · Inventario de discos
**Prio 6 · S2 · @JoelDevHub · 4 h**
- [ ] Objeto recogible disco.
- [ ] Guardar los discos entre niveles.

### PRG-7 · Elementos de puzzle base
**Prio 7 · S2 · @GunterMagno · 12 h**
- [ ] Puerta de color.
- [ ] Muro tintado.
- [ ] Plataforma que solo existe con cierto filtro.
- [ ] Interruptor/placa de presión.
- [ ] Llave y cerradura.
- [ ] Salida del nivel.

### PRG-8 · Gestor de niveles y flujo de juego
**Prio 8 · S2 · @sdurutr436 · 10 h**
- [ ] Carga de niveles por orden.
- [ ] Menú principal.
- [ ] Pausa.
- [ ] Reinicio de nivel con una tecla.
- [ ] Pantalla final.

### PRG-9 · Modo daltónico
**Prio 9 · S3 · @GunterMagno · 3 h**
- [ ] Opción en ajustes.
- [ ] Mostrar los iconos y patrones de ART-5.

### PRG-10 · VFX: transiciones y feedback
**Prio 10 · S3 · @GunterMagno · 8 h**
- [ ] Transición suave al cambiar de filtro.
- [ ] Partículas al resolver un puzzle.
- [ ] Efecto de desvanecimiento del objeto atravesable.

### PRG-11 · Corrección de errores
**Prio 11 · S4 · @sdurutr436, @JoelDevHub, @GunterMagno · 12 h**
- [ ] Resolver los fallos detectados en DIS-10.
- [ ] Probar la build final de principio a fin.

---

## Riesgos
- **Alcance:** 8 niveles buenos valen más que 15 mediocres.
- **Legibilidad del color:** probar daltonismo desde S1.
- **Dependencia del shader:** ver el plan B en PRG-4.
- **Carga desigual:** Antonio concentra niveles y sonido en S3; si se retrasa, mover sonido (ART-6) a otra persona.
