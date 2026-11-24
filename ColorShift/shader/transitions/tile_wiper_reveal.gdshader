shader_type canvas_item;
#include "res://shader/transitions/wiper.gdshaderinc"

// Pinta los tiles de los atlas de color con el cuadrante de un color:
//   Tileset - 4 colors / grass1  -> (0,0) gris, (1,0) rojo, (0,1) azul, (1,1) amarillo
//   Tileset-2222 / grass2        -> (0,0) gris, (1,0) morado, (0,1) verde, (1,1) naranja
// Las mezclas (combo) salen de la textura de mezclas de su familia.
// Cada familia tiene dos PNG del mismo tamano (4 colors/2222, grass1/grass2) y el
// shader no sabe de cual vino el tile, asi que siempre muestrea de los dos PNG
// (base para gris/rojo/azul/amarillo, mezclas para morado/verde/naranja).
// Delante de la barra usa el color viejo y detras el nuevo.
// Otras texturas (puerta, coleccionables) se dibujan tal cual.
uniform vec2 atlas_size;
// Segunda familia de atlas (hierba). A 0.0 si el TileSet no la usa.
uniform vec2 atlas_size_alt = vec2(0.0);
uniform vec2 old_quadrant = vec2(0.0);
uniform vec2 new_quadrant = vec2(0.0);
uniform bool old_combo = false;
uniform bool new_combo = false;
// png base y de mezclas de cada familia, sin el relleno de 1 px que Godot anade a cada tile.
uniform sampler2D base_atlas : filter_nearest, repeat_disable;
uniform sampler2D combo_atlas : filter_nearest, repeat_disable;
uniform sampler2D base_atlas_alt : filter_nearest, repeat_disable;
uniform sampler2D combo_atlas_alt : filter_nearest, repeat_disable;
const float TILE_PX = 32.0;
// false: la capa no se ve en ese lado de la barra.
uniform bool show_old = true;
uniform bool show_new = true;
uniform float edge_glow = 0.6;

varying vec4 modulate;

// Mismo pixel en el png: tile * 32 + desplazamiento dentro del tile con relleno.
vec2 combo_uv(vec2 uv, vec2 padded_size, vec2 raw_size) {
	vec2 cell = padded_size / (raw_size / TILE_PX);
	vec2 p = uv * padded_size;
	vec2 t = floor(p / cell);
	return (t * TILE_PX + p - t * cell - (cell - TILE_PX) * 0.5) / raw_size;
}

void vertex() {
	modulate = COLOR;
}

void fragment() {
	float sd = wiper_distance(SCREEN_UV, 1.0 / SCREEN_PIXEL_SIZE);
	vec4 texel = texture(TEXTURE, UV);
	vec2 texture_size = 1.0 / TEXTURE_PIXEL_SIZE;
	bool is_alt = atlas_size_alt.x > 0.5 && distance(texture_size, atlas_size_alt) < 0.5;
	if (is_alt || distance(texture_size, atlas_size) < 0.5) {
		bool before = sd > 0.0;
		vec2 uv = mod(UV, vec2(0.5)) + (before ? old_quadrant : new_quadrant) * 0.5;
		bool combo = before ? old_combo : new_combo;
		if (is_alt) {
			vec2 raw = vec2(textureSize(base_atlas_alt, 0));
			vec2 raw_uv = combo_uv(uv, atlas_size_alt, raw);
			texel = combo ? texture(combo_atlas_alt, raw_uv) : texture(base_atlas_alt, raw_uv);
		} else {
			vec2 raw = vec2(textureSize(base_atlas, 0));
			vec2 raw_uv = combo_uv(uv, atlas_size, raw);
			texel = combo ? texture(combo_atlas, raw_uv) : texture(base_atlas, raw_uv);
		}
	}
	COLOR = texel * modulate;
	COLOR.a *= mix(float(show_new), float(show_old), smoothstep(-1.0, 1.0, sd));
	// Brillo en el borde de corte, solo mientras la barra barre.
	if (wiper_progress > 0.0 && wiper_progress < 1.0) {
		COLOR.rgb += vec3(edge_glow) * exp(-abs(sd) / 10.0) * COLOR.a;
	}
}
