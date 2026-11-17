# Transición de color con escobilla (wiper)

Estado: propuesta. Documento de planificación, sin implementar la parte de tiles.

## Contexto

- Al pulsar Shift, `ScreenTransition.shift_color()` dibuja una escobilla recta de 12 px que
  pivota en la esquina inferior derecha y gira de vertical a horizontal
  (`ColorShift/shader/transitions/color-change.gdshader`, modo `Wiper`).
- El color del juego cambia a mitad del barrido (`CHANGE_AT = 0.5`).
- Hay una `TileMapLayer` por color. Cada una, en `tile_map_manager.gd` (`on_change_color`), pone
  `visible` y `collision_enabled` de golpe cuando salta `GameManager.color_changed`.
- `player_safety.gd` también escucha `color_changed` para sacar al jugador de un tile sólido.

## Objetivo

Que el tile set pase visualmente del color anterior al nuevo siguiendo el paso de la barra, y que
el efecto sea visualmente atractivo.

## Plan

### Fase 1: recorte por ángulo en las capas de tiles

- Shader nuevo `tile_wiper_reveal.gdshader` para las `TileMapLayer`.
- Usa `SCREEN_UV`, el pivote y el ángulo actual de la barra, para que el recorte siga la pantalla
  y no la cámara.
- Dos modos: "visible antes de la barra" (capa vieja) y "visible después de la barra" (capa nueva).

### Fase 2: coordinar el cambio

- `ScreenTransition` emite `sweep_started(old_color, new_color)` y el ángulo en cada frame.
- `tile_map_manager.gd` mantiene visibles la capa vieja y la nueva con ese material durante el
  barrido.
- Al terminar, quita el material y deja visible solo la capa nueva.
- Mientras dura el barrido hay que bloquear la lógica `visible = is_active` de `on_change_color`.
- Revisar la interacción con `player_safety.gd` (`resolve_overlap`).

### Fase 3: pulido visual

- Núcleo de la barra de 12 px como máximo (blanco o del color nuevo).
- Destello suave alrededor y estela degradada detrás, con el tinte del color nuevo.
- Brillo en el borde de recorte de los tiles.
- Easing in-out, como una escobilla real.
- Pequeño temblor de cámara al final y sonido corto (pendiente de decidir, ver preguntas).

### Fase 4: probar y ajustar

- Duración e intensidad del efecto.
- Cámara en movimiento, pausa durante el barrido y cambios de color repetidos.

## Preguntas abiertas

1. **¿Cuándo cambia la colisión?**
   - Al empezar el barrido (recomendado): el juego responde al instante y los tiles se ponen al
     día visualmente en unos 0.35 s.
   - A mitad del barrido: visualmente más honesto, pero mete retardo en la jugabilidad.
   - Tile a tile según pasa la barra: lo más fiel, pero bastante más complejo.
2. **¿El destello y la estela cuentan dentro del límite de 12 px?** Propuesta: el núcleo de la
   barra mide 12 px como máximo y el brillo y la estela son extra.
3. **¿Se incluyen sonido y temblor de cámara,** o solo lo visual?
4. **Concepto del disco de color (View-Master).** Un disco con un sector por color que avanza un
   paso con cada Shift. Tres formas de usarlo:
   - Disco como transición: sustituye a la escobilla; su borde barre la pantalla.
   - Disco como HUD: muestra el color actual y el siguiente.
   - Ambas: el HUD marca el siguiente color y el barrido hace la transición de tiles.
5. **¿Hay que prever los colores secundarios** (naranja, morado y verde, ya presentes en
   `GameManager.Colors2` y en `tile_map_manager.gd`) en el disco o en la transición?

## Notas

- Ya implementado y sin commitear: escobilla de 12 px (cambios en `color-change.gdshader`,
  `screen_transition.gd` y `screen_transition.tscn`).
- No se ha probado en el editor de Godot.
