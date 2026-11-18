// Barra de escobilla compartida por la capa de pantalla (wiper_bar) y los tiles (tile_wiper_reveal).
// Pivota en la esquina inferior derecha de la pantalla y gira de vertical a horizontal.
// `wiper_progress` es un shader global (project.godot) que mueve ScreenTransition.
global uniform float wiper_progress;

const float WIPER_PAD = 0.12;

// Distancia con signo en pixeles a la barra: > 0 delante (sin barrer), < 0 detras (barrido).
float wiper_distance(vec2 screen_uv, vec2 screen_px) {
	vec2 v = (vec2(1.0) - screen_uv) * screen_px;
	// theta = 0 hacia arriba, PI/2 hacia la izquierda.
	float angle = mix(-WIPER_PAD, PI * 0.5 + WIPER_PAD, wiper_progress);
	return length(v) * sin(atan(v.x, v.y) - angle);
}
