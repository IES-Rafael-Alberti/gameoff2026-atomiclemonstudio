shader_type canvas_item;
#include "res://shader/transitions/wiper.gdshaderinc"

// Pinta los tiles de los atlas de color con el cuadrante de un color:
//   Tileset - 4 colors / grass1  -> (0,0) gris, (1,0) rojo, (0,1) azul, (1,1) amarillo
//   Tileset-2222 / grass2        -> (0,0) gris, (1,0) morado, (0,1) verde, (1,1) naranja
// Delante de la barra usa el color viejo y detras el nuevo.
// Otras texturas (puerta, coleccionables) se dibujan tal cual.
uniform vec2 atlas_size;
// Segundo tamaño de atlas (los atlas de hierba son 512x576; los de color 384x448).
// A 0.0 solo hay una familia de atlas, como en los niveles 1, 2 y 3.
uniform vec2 atlas_size_alt = vec2(0.0);
uniform vec2 old_quadrant = vec2(0.0);
uniform vec2 new_quadrant = vec2(0.0);
// false: la capa no se ve en ese lado de la barra.
uniform bool show_old = true;
uniform bool show_new = true;
uniform float edge_glow = 0.6;

varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {
	float sd = wiper_distance(SCREEN_UV, 1.0 / SCREEN_PIXEL_SIZE);
	vec2 uv = UV;
	vec2 texture_size = 1.0 / TEXTURE_PIXEL_SIZE;
	bool is_color_atlas = distance(texture_size, atlas_size) < 0.5
		|| (atlas_size_alt.x > 0.5 && distance(texture_size, atlas_size_alt) < 0.5);
	if (is_color_atlas) {
		uv = mod(UV, vec2(0.5)) + (sd > 0.0 ? old_quadrant : new_quadrant) * 0.5;
	}
	COLOR = texture(TEXTURE, uv) * modulate;
	COLOR.a *= mix(float(show_new), float(show_old), smoothstep(-1.0, 1.0, sd));
	// Brillo en el borde de corte, solo mientras la barra barre.
	if (wiper_progress > 0.0 && wiper_progress < 1.0) {
		COLOR.rgb += vec3(edge_glow) * exp(-abs(sd) / 10.0) * COLOR.a;
	}
}
