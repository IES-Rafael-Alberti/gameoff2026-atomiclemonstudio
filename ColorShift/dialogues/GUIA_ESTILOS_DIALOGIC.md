# Guía de estilos de diálogo en Dialogic

Este documento resume cómo están configurados los bocadillos de Larry y
Bechamel y cómo repetir el proceso para otro personaje.

## Archivos y responsabilidades

- [`dialogue_style.tres`](./dialogue_style.tres) es el estilo base del layout
  Dialogic.
- [`dialogue_style_larry.tres`](./dialogue_style_larry.tres) y
  [`dialogue_style_bechamel.tres`](./dialogue_style_bechamel.tres) heredan del
  estilo base y guardan sus cambios en la capa de texto VN, cuyo ID es `"13"`.
- [`dialogue_bubble_larry.tres`](./dialogue_bubble_larry.tres) y
  [`dialogue_bubble_bechamel.tres`](./dialogue_bubble_bechamel.tres) son
  recursos `StyleBoxTexture`: indican qué imagen usar, qué parte de la imagen
  mostrar y cuánto espacio dejar para el texto.
- Las imágenes están en `../assets/dialogues/`. La de Bechamel es
  [`bocadillo texto bechamel.png`](../assets/dialogues/bocadillo%20texto%20bechamel.png).
- [`../project.godot`](../project.godot) registra los estilos para que Dialogic
  pueda encontrarlos por nombre.

## Cómo se construye un bocadillo

Un `StyleBoxTexture` usa dos ajustes distintos:

- `region_rect = Rect2(x, y, ancho, alto)` recorta la zona visible de la imagen.
- `content_margin_left`, `content_margin_top`, `content_margin_right` y
  `content_margin_bottom` son el espacio interior que se reserva para el
  contenido. No recortan la imagen.

Valores actuales:

| Personaje | Imagen | `region_rect` | Márgenes L/T/R/B |
|---|---|---|---|
| Larry | `bocadillo texto larry.png` | `Rect2(557, 1364, 4926, 1908)` | `55 / 80 / 55 / 35` |
| Bechamel | `bocadillo texto bechamel.png` | `Rect2(65, 186, 631, 240)` | `55 / 80 / 55 / 30` |

El recorte de Bechamel corresponde a los límites visibles de su imagen de
768 × 768. Si se cambia la imagen, hay que revisar que el nuevo rectángulo esté
dentro de sus dimensiones y que incluya todo el dibujo.

## Ajustes de texto y nombre

En cada estilo, las opciones del layer `"13"` se guardan en
`layer_info["13"].overrides`.

- Para que el diálogo sea negro independientemente del color global de Dialogic:
  `text_use_global_color = false` y `text_custom_color = Color(0, 0, 0, 1)`.
- El panel se deja sin tinte global con `box_color_use_global = false` y
  `box_color_custom = Color(1, 1, 1, 1)`.
- Larry usa texto blanco y panel negro explícitos, independientes de los
  colores globales y del personaje, para mantener el contraste.
- Bechamel conserva el color global o el color del personaje para el nombre.
- Bechamel tiene `name_label_alignment = "2"` para colocar el panel del nombre
  a la derecha. En la enumeración de Dialogic, `LEFT = 0`, `CENTER = 1` y
  `RIGHT = 2`. Larry conserva la alineación izquierda.

El tamaño del cuadro se configura también en los overrides del layer:
`Vector2(620, 240)` para Larry y `Vector2(620, 235)` para Bechamel.

## Estilos heredados y cambios entre personajes

El estilo base tiene las capas `"10"` a `"17"`. Los estilos heredados deben
mantener esa lista y las entradas locales correspondientes en `layer_info`;
el editor de estilos de Dialogic las crea al añadir un estilo heredado. La capa
`"13"` es la que contiene los overrides del cuadro de texto.

También se corrigió el cambio entre estilos que comparten el mismo estilo base:
en `../addons/dialogic/Modules/Style/subsystem_styles.gd`, el addon obtiene el
ID de cada capa con `style_resource.get_layer_inherited_list()`. No debe
reemplazarse por `get_layer_id_at_index()` en ese recorrido: este último usa la
lista local del estilo y puede no identificar correctamente las capas
heredadas.

## Registrar y asignar un estilo

Para que Dialogic encuentre un estilo por nombre:

1. Define en el recurso `.tres` un `name` único, por ejemplo
   `dialogue_style_bechamel`.
2. Añade el recurso a `dialogic/layout/style_list` en `project.godot`.
3. Añade el alias exacto y su ruta a `dialogic/layout/style_directory`.
   Dialogic puede acabar reconstruyendo este directorio desde `style_list`,
   pero ambos valores deben quedar coherentes.
4. Asigna el mismo nombre en `custom_info.style` del recurso `.dch` del
   personaje.
5. Si el timeline cambia el estilo explícitamente, usa un evento antes de la
   línea:

   ```text
   [style name="dialogue_style_bechamel"]
   Bechamel: Texto del diálogo
   ```

El nombre debe coincidir exactamente en el recurso, `project.godot`, el `.dch`
y el timeline. Si Dialogic no encuentra el alias, puede resolverlo al estilo
predeterminado; por eso un bocadillo puede seguir apareciendo con el panel
predeterminado aunque el `.tres` personalizado exista.

## Pasos para añadir otro personaje

1. En Dialogic, crea un estilo nuevo heredando de `dialogue_style.tres`.
   Conviene crearlo desde el editor para que se generen la lista y las entradas
   de capas heredadas.
2. Crea un `StyleBoxTexture` para su imagen. Ajusta `region_rect` a la zona
   dibujada y los cuatro `content_margin_*` para que el texto quede dentro.
3. En el layer `"13"` del estilo, asigna el `box_panel`, tamaño y colores del
   diálogo.
4. Decide la alineación del nombre con `name_label_alignment`; evita forzar
   negro para el nombre si el fondo de su etiqueta es oscuro.
5. Registra el estilo en `project.godot`, asígnalo al personaje `.dch` y añade
   los eventos `[style name=...]` necesarios en el timeline.
6. Ejecuta el diálogo y comprueba una línea antes y después de cambiar de
   personaje. Si se modificó `project.godot` o código del addon, cierra y vuelve
   a abrir el proyecto para que se recarguen la configuración y el addon.

## Diagnóstico rápido

- **Aparece el panel predeterminado:** verifica que el estilo esté en
  `style_list`, que el alias coincida exactamente y que los overrides estén en
  la capa `"13"`.
- **El estilo funciona solo para el primer personaje:** verifica el recorrido
  de capas heredadas de `subsystem_styles.gd`.
- **No aparece la imagen:** verifica la ruta del `box_panel`, la ruta de la
  textura y que `region_rect` esté dentro de las dimensiones de la imagen.
- **El texto no contrasta:** usa un color explícito con
  `text_use_global_color = false`; revisa por separado el color del nombre y el
  fondo de su etiqueta.
- **No aparece el nombre:** la etiqueta debe actualizar su texto y la
  visibilidad de su panel; el subsistema de texto lo hace mediante
  `DialogicNode_NameLabel.set_dialogic_text()`.
