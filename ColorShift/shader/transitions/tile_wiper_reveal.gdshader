shader_type canvas_item;
#include "res://shader/transitions/wiper.gdshaderinc"

// Pinta los tiles del atlas de 4 colores con el cuadrante de un color:
// (0,0) gris, (1,0) rojo, (0,1) azul, (1,1) amarillo.
// Las mezclas (combo) salen de combo_atlas, Tileset-2222.png, con la misma
// distribucion: (1,0) morado, (0,1) verde, (1,1) naranja.
// Delante de la barra usa el color viejo y detras el nuevo.
// Otras texturas (puerta, coleccionables) se dibujan tal cual.
uniform vec2 atlas_size;
uniform vec2 old_quadrant = vec2(0.0);
uniform vec2 new_quadrant = vec2(0.0);
uniform bool old_combo = false;
uniform bool new_combo = false;
// png sin el relleno de 1 px que Godot anade a cada tile del atlas.
uniform sampler2D combo_atlas : filter_nearest, repeat_disable;
const vec2 ATLAS_GRID = vec2(12.0, 14.0);
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
	vec4 texel = texture(TEXTURE, UV);
	if (distance(1.0 / TEXTURE_PIXEL_SIZE, atlas_size) < 0.5) {
		bool before = sd > 0.0;
		vec2 uv = mod(UV, vec2(0.5)) + (before ? old_quadrant : new_quadrant) * 0.5;
		if (before ? old_combo : new_combo) {
			// Mismo pixel en el png: tile * 32 + desplazamiento dentro del tile con relleno.
			vec2 raw_size = vec2(textureSize(combo_atlas, 0));
			vec2 cell = atlas_size / ATLAS_GRID;
			vec2 tile = raw_size / ATLAS_GRID;
			vec2 p = uv * atlas_size;
			vec2 t = floor(p / cell);
			texel = texture(combo_atlas, (t * tile + p - t * cell - (cell - tile) * 0.5) / raw_size);
		} else {
			texel = texture(TEXTURE, uv);
		}
	}
	COLOR = texel * modulate;
	COLOR.a *= mix(float(show_new), float(show_old), smoothstep(-1.0, 1.0, sd));
	// Brillo en el borde de corte, solo mientras la barra barre.
	if (wiper_progress > 0.0 && wiper_progress < 1.0) {
		COLOR.rgb += vec3(edge_glow) * exp(-abs(sd) / 10.0) * COLOR.a;
	}
}
