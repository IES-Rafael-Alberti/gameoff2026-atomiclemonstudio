shader_type canvas_item;

uniform bool use_sprite_alpha = true;
uniform bool use_transition_texture = false;
uniform sampler2D transition_texture;
// Wiper = limpiaparabrisas: brazo que pivota en `position` y barre de vertical a horizontal.
uniform int transition_type: hint_enum("Basic", "Mask", "Shape", "Clock", "Wiper") = 4;

group_uniforms positioning;
// Centro de la transicion en UV (0..1). (1,1) = esquina inferior derecha.
uniform vec2 position = vec2(1.0, 1.0);
uniform bool invert = false;
uniform vec2 grid_size = vec2(1.0, 1.0);
uniform float rotation_angle = 0.0;

group_uniforms positioning.mirror;
uniform bool global_x_mirror = false;
uniform bool global_y_mirror = false;
uniform bool local_x_mirror = false;
uniform bool local_y_mirror = false;

group_uniforms positioning.stagger;
uniform vec2 stagger = vec2(0.0, 0.0);
uniform bool cumulative_stagger_flip = false;
uniform vec2 cumulative_stagger = vec2(0, 0);
uniform ivec2 stagger_frequency = ivec2(2, 2);
uniform ivec2 flip_frequency = ivec2(1, 1);

group_uniforms basic_transition_controls;
uniform float basic_feather = 0.0;

group_uniforms mask_transition_controls;
uniform sampler2D mask_texture;
uniform bool use_mask_size = false;
uniform vec2 mask_size = vec2(100.0);

group_uniforms shape_transition_controls;
uniform int edges : hint_range(3, 64) = 6; // default hexagon
uniform float shape_feather : hint_range(0.0, 10.0) = 0.1;

group_uniforms clock_transition_controls;
uniform int sectors : hint_range(1, 128) = 1;
uniform float clock_feather : hint_range(0.0, 16.0) = 0.0;

group_uniforms wiper_transition_controls;
// Curvatura del borde del brazo. 0 = recto, >0 se dobla hacia la vertical al alejarse del pivote.
uniform float wiper_curve : hint_range(-2.0, 2.0) = 0.5;
// Suavizado del borde (en radianes aproximados).
uniform float wiper_feather : hint_range(0.0, 2.0) = 0.05;

group_uniforms animation;
// 0 = sprite visible, 1 = totalmente transparente (igual en todos los modos).
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 progress_bias = vec2(0.0);

varying vec4 modulate;

vec2 use_actual_texture_size(vec2 uv, vec2 texture_size) {

	uv -= 0.5;
	vec2 uv_deriv = fwidth(uv);
	float screen_ratio = uv_deriv.x / uv_deriv.y;
	float texture_ratio = texture_size.x / texture_size.y;
	float mixed_ratio = texture_ratio * screen_ratio;

	if (screen_ratio > texture_ratio) {
		uv.x /= mixed_ratio;
	} else {
		uv.y *= mixed_ratio;
	}

	return uv + 0.5;
}

vec2 get_stagger_offset(vec2 grid) {
	vec2 cells = floor(grid);
	float offset_row = mod(cells.y, float(max(stagger_frequency.x, 1))) == 0.0 ? 0.5 : 0.0;
	float offset_col = mod(cells.x, float(max(stagger_frequency.y, 1))) == 0.0 ? 0.5 : 0.0;

	float row_index = cumulative_stagger_flip ? (grid_size.y - 1.0 - cells.y) : cells.y;
	float col_index = cumulative_stagger_flip ? (grid_size.x - 1.0 - cells.x) : cells.x;

	return vec2(
		offset_row * (stagger.x + row_index * cumulative_stagger.x),
		offset_col * (stagger.y + col_index * cumulative_stagger.y)
	);
}

vec2 get_grid_flip(vec2 grid) {
	vec2 cells = floor(grid);
	float flip_row = mod(cells.y, float(max(flip_frequency.x, 1))) == 0.0 ? 1.0 : -1.0;
	float flip_col = mod(cells.x, float(max(flip_frequency.y, 1))) == 0.0 ? 1.0 : -1.0;

	return vec2(
		flip_row * grid.x,
		flip_col * grid.y
	);
}

vec2 rotate(vec2 v, float angle) {
	return mat2(
		vec2(cos(angle), sin(angle)),
		vec2(-sin(angle), cos(angle))
		) * v;
}

vec2 get_edges(float center, float width) {
	float half_width = width * 0.5;
	float edge0 = center - half_width;
	float edge1 = center + half_width + 1e-5;
	return vec2(edge0, edge1);
}

float get_local_progress(vec2 grid) {
	vec2 cell = floor(grid);
	// Easier to control bias values
	vec2 pretty_bias = progress_bias / 10.0;
	float offset = dot(cell, pretty_bias);
	return progress - offset;
}

vec2 apply_mirror(vec2 uv, bool mirror_x, bool mirror_y) {
	vec2 mirrored = 0.5 - abs(uv - 0.5);
	vec2 toggle = vec2(float(mirror_x), float(mirror_y));
	return mix(uv, mirrored, toggle);
}

void vertex() {
	modulate = COLOR;
}

void fragment() {
	vec2 mirrored_uv = apply_mirror(UV, global_x_mirror, global_y_mirror);

	vec2 grid = mirrored_uv * grid_size;
	vec2 offset_uv = grid + get_stagger_offset(grid);
	vec2 grid_flipped_uv = get_grid_flip(offset_uv);
	vec2 tiled_uv = fract(grid_flipped_uv);

	tiled_uv = apply_mirror(tiled_uv, local_x_mirror, local_y_mirror);

	vec2 uv = (tiled_uv - position) * 2.0;
	uv = rotate(uv, radians(rotation_angle));

	// La celda del sesgo debe ser la que realmente se dibuja (tras stagger).
	float local_progress = get_local_progress(offset_uv);

	COLOR = texture(TEXTURE, UV) * modulate;
	float alpha = COLOR.a;
	float transition_progress = 0.0;

	if (transition_type == 1) {
		vec2 mask_zoom_uv = uv / max(local_progress, 1e-4);
		vec2 mask_zoom_uv_01 = mask_zoom_uv * 0.5 + 0.5;
		mask_zoom_uv_01 = use_mask_size ? use_actual_texture_size(mask_zoom_uv_01, mask_size) : mask_zoom_uv_01;

		transition_progress = texture(mask_texture, mask_zoom_uv_01).r;

	} else if(transition_type == 2) {
		float radius = length(uv);
		float angle = atan(uv.y, uv.x);
		float sector_angle = 2.0 * PI / float(edges);
		float half_sector = sector_angle / 2.0;
		// Define polygon sectors using the power of trigonometry
		float d = cos(half_sector) / cos(mod(angle + half_sector, sector_angle) - half_sector);

		vec2 smooth_edges = get_edges(local_progress, shape_feather);
		transition_progress = smoothstep(smooth_edges.x, smooth_edges.y, radius / d);

	} else if (transition_type == 3) {
		float radius = length(uv);
		float angle = atan(uv.y, uv.x);
		float sector_angle = 2.0 * PI / float(sectors);
		float half_sector = sector_angle / 2.0;
		angle = mod(angle - half_sector, sector_angle);

		float progress_angle = local_progress * 2.0 * PI / float(sectors);
		float smooth_angle = smoothstep(0.0, max(clock_feather, 1e-5), progress_angle - angle);
		// Misma polaridad que Basic/Shape: progress 0 = visible, 1 = transparente.
		transition_progress = 1.0 - smooth_angle;

	} else if (transition_type == 4) {
		// Limpiaparabrisas: pivote en `position` (por defecto esquina inferior derecha).
		// Con position = (1,1): uv.x <= 0 (hacia la izquierda) y uv.y <= 0 (hacia arriba).
		vec2 d = abs(uv);
		float radius = length(d);
		// theta = 0 en la vertical (hacia arriba), PI/2 en la horizontal (hacia la izquierda).
		float theta = atan(d.x, d.y);
		// Borde curvo: el angulo de barrido depende de la distancia al pivote.
		float s = theta + wiper_curve * radius;
		// Valor maximo de `s` en el cuadrante, para que en progress = 1 cubra todo.
		float s_max = 0.5 * PI + abs(wiper_curve) * length(vec2(2.0));
		float t = local_progress * (s_max + wiper_feather);
		// Zona barrida (s < t) -> transparente.
		transition_progress = smoothstep(t - max(wiper_feather, 1e-5), t, s);

	} else {
		vec2 smooth_edges = get_edges(local_progress, basic_feather);

		float separation_x = smoothstep(smooth_edges.x, smooth_edges.y, abs(uv.x));
		float separation_y = smoothstep(smooth_edges.x, smooth_edges.y, abs(uv.y));
		transition_progress = max(separation_x, separation_y);
	}

	alpha = invert ? 1.0 - transition_progress : transition_progress;
	alpha = use_sprite_alpha ? min(COLOR.a, alpha) : alpha;

	if (use_transition_texture) {
		vec4 transition_color = texture(transition_texture, UV);
		COLOR = mix(transition_color, COLOR, alpha);
	} else {
		COLOR.a = alpha;
	}
}
