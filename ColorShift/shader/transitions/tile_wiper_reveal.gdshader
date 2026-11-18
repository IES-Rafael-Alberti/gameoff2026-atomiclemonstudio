shader_type canvas_item;
#include "res://shader/transitions/wiper.gdshaderinc"

// Pinta los tiles del atlas de 4 colores con el cuadrante de un color:
// (0,0) gris, (1,0) rojo, (0,1) azul, (1,1) amarillo.
// Delante de la barra usa el color viejo y detras el nuevo.
// Otras texturas (puerta, coleccionables) se dibujan tal cual.
uniform vec2 atlas_size;
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
	if (distance(1.0 / TEXTURE_PIXEL_SIZE, atlas_size) < 0.5) {
		uv = mod(UV, vec2(0.5)) + (sd > 0.0 ? old_quadrant : new_quadrant) * 0.5;
	}
	COLOR = texture(TEXTURE, uv) * modulate;
	COLOR.a *= mix(float(show_new), float(show_old), smoothstep(-1.0, 1.0, sd));
	// Brillo en el borde de corte, solo mientras la barra barre.
	if (wiper_progress > 0.0 && wiper_progress < 1.0) {
		COLOR.rgb += vec3(edge_glow) * exp(-abs(sd) / 10.0) * COLOR.a;
	}
}
