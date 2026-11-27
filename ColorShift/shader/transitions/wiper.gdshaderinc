// Barra de escobilla compartida por la capa de pantalla (wiper_bar) y los tiles (tile_wiper_reveal).
// Pivota en la esquina inferior derecha del juego y gira de vertical a horizontal.
// Los niveles se ven en 16:9 con el juego 4:3 centrado entre las barras laterales, asi
// que el rectangulo del juego se calcula aqui (en 4:3 es la pantalla entera).
// Con `wiper_mirror` (rueda izquierda) pivota en la inferior izquierda.
// `wiper_progress` y `wiper_mirror` son shader globals (project.godot) que mueve ScreenTransition.
global uniform float wiper_progress;
global uniform bool wiper_mirror;

const float WIPER_PAD = 0.12;
const float GAME_ASPECT = 4.0 / 3.0;

// Tamano en pixeles del rectangulo del juego, centrado en la pantalla.
vec2 wiper_game_size(vec2 screen_px) {
	return vec2(screen_px.y * GAME_ASPECT, screen_px.y);
}

// Posicion en pixeles dentro del juego: x < 0 o x > ancho cae sobre las barras laterales.
vec2 wiper_game_px(vec2 screen_uv, vec2 screen_px) {
	vec2 offset = vec2((screen_px.x - wiper_game_size(screen_px).x) * 0.5, 0.0);
	return screen_uv * screen_px - offset;
}

// Distancia con signo en pixeles a la barra: > 0 delante (sin barrer), < 0 detras (barrido).
float wiper_distance(vec2 screen_uv, vec2 screen_px) {
	vec2 game = wiper_game_size(screen_px);
	vec2 p = wiper_game_px(screen_uv, screen_px);
	if (wiper_mirror) {
		p.x = game.x - p.x;
	}
	vec2 v = game - p;
	// theta = 0 hacia arriba, PI/2 hacia la izquierda.
	float angle = mix(-WIPER_PAD, PI * 0.5 + WIPER_PAD, wiper_progress);
	return length(v) * sin(atan(v.x, v.y) - angle);
}
