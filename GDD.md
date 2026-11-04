# ColorShift
**GDD de una página** · Atomic Lemon Studio · GitHub Game Off 2026 (tema: *Shift*) · Godot 4.7

**Identidad / Mantra:**

**Pilares de diseño:** 1. · 2. · 3.

### Género / Historia / Mecánicas
**Género:** plataformas 2D de puzles (puzle-plataformas de cambio de color).
**Historia:** alguien ha robado el color del mundo. Una conejita caballero lo recorre con el **Cromoscopio** (*Chromoscope*), un visor de dos discos de colores que tiñe lo que mira.
**Mecánicas:** sin filtro (hueco transparente) todo se ve en escala de grises: el escenario neutro y los objetos de color, cada uno en el gris que le corresponde por luminosidad (el amarillo, el tono más claro; el azul, el más oscuro). Al girar un disco se aplica un filtro: el escenario gris se tiñe de ese color, los objetos de ese mismo color se vuelven transparentes y atravesables, y los ocultos de ese color aparecen. Los objetos de otros colores siguen sólidos y lo oculto de otros colores no se ve. *A debate del equipo:* cómo se ve con filtro un objeto de otro color ("corrompido", negro o en el color de la mezcla) y qué pasa, por ejemplo, con un objeto azul bajo el filtro violeta. (**Proposición**:Cada color da una habilidad: rojo = peso (rompe suelos, empuja bloques), azul = flotar, amarillo = supersalto. Las de los secundarios (verde = trepar, violeta = fase, naranja = dash) quedan *fuera de alcance*: si no da tiempo, esos colores solo revelan y abren.)
**Core loop:** explorar → identificar los obstáculos de color → girar los discos para revelar, abrir o activar una habilidad → llegar a la salida → siguiente nivel.
**Niveles:** 8 pantallas cortas de 2–4 minutos (el 9 y el 10 son opcionales). Del nivel 1 al 3 se juega con el disco derecho (rojo, amarillo, azul). En el 4 se consigue el izquierdo, que aparece superpuesto al primero y permite mezclar colores: naranja (R+A), verde (A+Az) y violeta (R+Az). Un objeto violeta solo reacciona al violeta.
- **Objetos:** puertas, muros y plataformas de color, llaves (pueden estar ocultas), interruptores y la salida.
- **Peligros:** pinchos, caídas y enemigos insecto de colores que patrullan de lado a lado. Con su filtro se vuelven invisibles, pero siguen matando al tocarlos.
- **Morir:** se reinicia la pantalla.
- **Pistas:** cada nivel tiene una.

### Características
- **Cromoscopio de dos discos:** 3 primarios + 3 mezclas + transparente.
- **Mundo reactivo al color:** puertas, plataformas, llaves y enemigos cambian con el filtro.
- **Música adaptativa:** el filtro activo añade acordes al tema del nivel.
- **Cámara "a través del visor":** se ve el borde del disco y el segundo disco cambia la vista.
- **Accesibilidad:** controles remapeables (jugable con una mano), mando y táctil. Modo daltónico con iconos por color, *si da tiempo*.

### Interfaz
| Acción | Teclado | Mando / táctil (distribución Xbox) |
|---|---|---|
| Moverse | WASD | Stick izquierdo / cruceta |
| Saltar | Espacio | A (abajo) |
| Acción (interruptores, llaves) | E | X (izquierda) |
| Reiniciar pantalla | R | Y (arriba) |
| Girar disco izquierdo (horario) / derecho (antihorario) | Shift izq. / Shift dcho. | L1 / R1 |

En móvil se muestra un mando virtual: stick, los botones A/X/Y y dos palancas para los discos. Todo es remapeable. El HUD es el marco del visor, que muestra los discos que tienes y el color activo.

### Estilo artístico
Pixel art. Sin filtro, todo es escala de grises; con filtro, el escenario se tiñe de su color y los objetos de ese color desaparecen; el cambio de color se anima como un giro del disco. **Referencias:** *Hollow Knight* (ambientación, caballero en 2D) y *Hue* (el color como mecánica).

### Música / Sonido
Cada nivel tiene un tema de misterio y resolución, y el filtro le añade una capa de acordes que transmite su emoción: rojo grave, azul tecno/acuático, amarillo bestial, verde terrenal, violeta mágico y naranja solar. **Referencias:** bandas sonoras de *Hue* (Alkis Livathinos), *Fez* (Disasterpeace) y *Hollow Knight* (Christopher Larkin).

### Hoja de ruta
**Plataformas:** web (itch.io) en escritorio y móvil. **Público:** desde 10 años; juega en sesiones cortas y a juegos de navegador; le interesan los puzles, los plataformas y los juegos accesibles.

| Hito 1: mecánicas | Hito 2: niveles 1–8 (congelación) | Hito 3: pulido y pruebas | Envío | Fecha límite |
|---|---|---|---|---|
| 15/11/26 | 22/11/26 | 29/11/26 | 30/11/26 | **01/12/26, 22:00** |

---

**Categoría:** PEGI 3 (estimado): sin violencia realista ni contenido sensible. Juego indie de navegador hecho para una jam.

**USP:**
- **Mezclar, no solo alternar:** dos discos dan 6 filtros, cada uno con su habilidad.
- **Se oye el color:** cada filtro añade acordes a la música.
- **El color también es peligro:** un enemigo de tu filtro desaparece de la vista, pero sigue ahí.
- **El *Shift* literal:** se juega con las teclas Shift y la perspectiva cambia con el segundo disco.

**Juegos similares:**
| Juego | Parecido | Diferencia |
|---|---|---|
| *Hue* (2016) | Cambiar el color hace aparecer o desaparecer objetos | Aquí se mezclan dos discos, cada color da una habilidad y cambia la música |
| *Fez* (2012) | Cambiar la perspectiva es la mecánica de los puzles 2D | *Fez* rota el espacio 3D; aquí se "rota" el color |
| *Celeste* (2018) | Plataformas 2D en pantallas cortas, con mucha atención a la accesibilidad | *Celeste* es de precisión; aquí el reto es el puzle de color |

### Plataformas objetivo
**Plataforma:** navegador web en escritorio y móvil, mediante la página de itch.io (exportación HTML5 de Godot 4.7).

**Características técnicas:** WebAssembly + WebGL 2.0 con el renderizador *Compatibility*, el único que admite la web. Exportación sin hilos, así no se depende de `SharedArrayBuffer` y funciona en Safari para iOS. Entrada por teclado, mando (Gamepad API) y táctil. El motor pesa unas decenas de MB, muy por debajo de los límites de itch.io.

| Ventajas | Limitaciones |
|---|---|
| Sin instalación: se juega en un clic, en escritorio y en móvil | Rendimiento inferior al nativo, sobre todo en móviles de gama baja |
| La Game Off se entrega en itch.io, el mismo sitio donde se juega | El navegador bloquea el audio hasta la primera interacción |
| Una sola build para todos los sistemas | Carga inicial del motor (varios segundos) |
| Exportación integrada en Godot, sin coste | En móvil no hay teclado y la pantalla es pequeña; algunas teclas las captura el sistema |

**Justificación:** es un juego 2D en pixel art, ligero, que no necesita potencia nativa. Lo que importa es que cualquiera pueda jugarlo al instante y en cualquier dispositivo: eso da votos en una jam y encaja con un público de sesiones cortas.

**Adaptaciones:**
- Pasar el proyecto de *Forward+* a *Compatibility*.
- Pantalla de "pulsa para empezar" para desbloquear el audio.
- Capas de música con `AudioStreamSynchronized`.
- Distinguir Shift izquierdo y derecho (`InputEventKey.location`) y avisar de las *Teclas especiales* de Windows (Shift ×5).
- En móvil: mando virtual táctil, orientación horizontal, botón de pantalla completa y elementos legibles en pantallas pequeñas.
- Guardado del progreso y de los controles en el almacenamiento del navegador.

---

## Preguntas pendientes — GDD extenso (wiki).

**1. Historia.** ¿Quién roba el color y por qué? ¿Cómo termina el juego tras el nivel 8? ¿Se cuenta con texto, con viñetas o sin texto? ¿Cómo se llama la conejita?
> R:

**2. Orden de los discos.** ¿En qué orden van los colores en cada disco (por ejemplo, transparente → rojo → amarillo → azul)? ¿Cada disco gira solo en un sentido?
> R:

**3. Jugador atrapado.** Si giras el disco cuando estás dentro de algo atravesable y ese objeto vuelve a ser sólido, ¿mueres, sales expulsado o no te deja girar?
> R:

**4. Objetos ocultos.** Cuando no se ven, ¿tampoco existen (no se pueden pisar ni recoger)? ¿Las reglas cambian al empezar la animación de giro o al terminarla?
> R:

**5. Habilidades.** ¿Están activas solo mientras su filtro está puesto? ¿Son pasivas (el peso o el flotar actúan solos) o usan un botón? ¿El supersalto es el salto normal pero más alto?
> R:

**6. Interruptores, llaves y salida.** ¿Qué activan los interruptores y las placas (puertas, plataformas móviles…)? ¿La llave se coge al tocarla o con E/X? ¿La salida necesita llave?
> R:

**7. Enemigos y pinchos.** ¿Qué insectos hay además de la hormiga y la oruga, y en qué se diferencian? ¿Se pueden eliminar (por ejemplo, cayéndoles encima con el peso rojo)? ¿Los pinchos tienen color?
> R:

**8. Soluciones.** DIS-4 dice "solución única" y el issue #28 dice "múltiple solución". ¿Cuál vale?
> R:

**9. Curva de dificultad.** En la página Levels propongo en qué nivel aparece cada habilidad y cada peligro. ¿Te vale?
> R:

**10. Pistas y menús.** ¿Las pistas aparecen tras un tiempo o con un botón? ¿Hay selección de niveles o el juego es lineal? ¿Pausa con Esc/Start?
> R:

**11. Arte.** ¿Qué resolución base tiene el pixel art? ¿Hay paleta concreta (valores hex)? ¿Qué animaciones lleva la conejita?
> R:

**12. Plan de recorte.** En la página Production propongo un orden de recorte (niveles 9–10 → habilidades secundarias → modo daltónico → pistas → táctil). ¿Te vale?
> R:
