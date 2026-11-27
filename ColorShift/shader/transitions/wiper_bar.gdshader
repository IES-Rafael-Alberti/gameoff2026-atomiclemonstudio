shader_type canvas_item;
#include "res://shader/transitions/wiper.gdshaderinc"

uniform vec4 tint : source_color = vec4(1.0);
// El nucleo mide como maximo bar_width; el destello y la estela son extra.
uniform float bar_width = 12.0;
uniform float glow_size = 36.0;
uniform float trail_size = 140.0;

void fragment() {
	float sd = wiper_distance(SCREEN_UV, 1.0 / SCREEN_PIXEL_SIZE);
	float d = abs(sd);

	float core = 1.0 - smoothstep(bar_width * 0.5 - 1.0, bar_width * 0.5, d);
	float glow = 0.45 * exp(-d * 3.0 / glow_size);
	float trail = sd < 0.0 ? 0.35 * exp(-d * 3.0 / trail_size) : 0.0;

	// Sin barra en reposo (progress 0 o 1).
	float live = smoothstep(0.0, 0.03, wiper_progress) * (1.0 - smoothstep(0.97, 1.0, wiper_progress));
	// Solo dentro del juego: nunca encima de las barras laterales.
	float x = wiper_game_px(SCREEN_UV, 1.0 / SCREEN_PIXEL_SIZE).x;
	live *= step(0.0, x) * step(x, wiper_game_size(1.0 / SCREEN_PIXEL_SIZE).x);

	vec3 rgb = mix(tint.rgb, vec3(1.0), core * 0.8);
	COLOR = vec4(rgb, clamp(core + glow + trail, 0.0, 1.0) * live);
}
