shader_type canvas_item;

// Colores del cono, desde Larry hasta el borde de la pantalla.
uniform vec3 color_a : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 color_b : source_color = vec3(0.0, 0.0, 1.0);
uniform vec3 color_c : source_color = vec3(1.0, 1.0, 0.0);

// Punta del cono, en píxeles dentro del nodo: la lente de Larry.
uniform vec2 origin = vec2(215.0, 503.0);
// Hacia dónde apunta, en grados: 0 = derecha, negativo = hacia arriba.
uniform float direction : hint_range(-180.0, 180.0) = -10.0;
// Apertura en grados. Con 360 lo cubre absolutamente todo.
uniform float cone_angle : hint_range(1.0, 360.0) = 100.0;
// Distancia en píxeles desde la punta hasta el último color.
uniform float reach : hint_range(100.0, 2000.0) = 1250.0;
uniform float softness : hint_range(0.001, 0.1) = 0.005;

// Ondas de luz que recorren el cono. light_color.a es la opacidad de todo el cono.
uniform vec4 light_color : source_color = vec4(1.0, 1.0, 1.0, 0.6);
uniform float light_speed : hint_range(0.0, 4.0, 0.01) = 0.3;
uniform float light_size : hint_range(0.05, 2.0, 0.01) = 0.25;
uniform float light_strength : hint_range(0.0, 1.0, 0.01) = 0.4;

varying vec2 pixel;

vec3 three_colors(float t) {
	vec3 first_half = mix(color_a, color_b, clamp(t * 2.0, 0.0, 1.0));
	return mix(first_half, color_c, clamp(t * 2.0 - 1.0, 0.0, 1.0));
}

void vertex() {
	pixel = VERTEX;
}

void fragment() {
	vec2 p = pixel - origin;
	float dist = length(p);
	vec2 forward = vec2(cos(radians(direction)), sin(radians(direction)));
	float angle = acos(clamp(dot(p / max(dist, 0.001), forward), -1.0, 1.0));

	// El cono no tiene final: llega hasta donde acabe la pantalla.
	float half_angle = radians(cone_angle) * 0.5;
	float cone_mask = 1.0 - smoothstep(half_angle, half_angle + softness, angle);

	float t = dist / reach; // 0.0 en la punta, 1.0 a la distancia "reach"
	vec3 base = three_colors(clamp(t, 0.0, 1.0));

	float a = t - TIME * light_speed; // las ondas salen desde la punta
	a *= 2.0 * PI / light_size; // light_size = distancia entre dos ondas
	float b = sin(a) * 0.5 + 0.5; // valor entre 0.0 y 1.0

	vec3 color = mix(base, light_color.rgb, b * light_strength);
	COLOR = vec4(color, cone_mask * light_color.a);
}
