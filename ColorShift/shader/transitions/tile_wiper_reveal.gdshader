shader_type canvas_item;
#include "res://shader/transitions/wiper.gdshaderinc"

// true: capa vieja (visible delante de la barra). false: capa nueva (visible detras).
uniform bool keep_before = false;
uniform float edge_glow = 0.6;

void fragment() {
	float sd = wiper_distance(SCREEN_UV, 1.0 / SCREEN_PIXEL_SIZE);
	COLOR.a *= smoothstep(-1.0, 1.0, keep_before ? sd : -sd);
	// Brillo en el borde de corte.
	COLOR.rgb += vec3(edge_glow) * exp(-abs(sd) / 10.0) * COLOR.a;
}
