shader_type canvas_item;

// Cono de color que sale de la lente de Larry y funciona como un limpiaparabrisas
// de un solo sentido: el siguiente color primario baja desde el borde de arriba del
// cono (punto A) hasta el de abajo, fundiéndose con el anterior:
// amarillo -> rojo -> azul -> amarillo...

// Colores primarios, en orden de barrido (los mismos tintes que screen_transition.gd).
uniform vec3 color_a : source_color = vec3(0.97, 0.85, 0.2);
uniform vec3 color_b : source_color = vec3(0.9, 0.2, 0.2);
uniform vec3 color_c : source_color = vec3(0.2, 0.4, 0.95);

// Punta del cono, en píxeles dentro del nodo: la lente de Larry.
uniform vec2 origin = vec2(215.0, 503.0);
// Hacia dónde apunta, en grados: 0 = derecha, negativo = hacia arriba.
uniform float direction : hint_range(-180.0, 180.0) = -10.0;
// Apertura en grados. Con 360 lo cubre absolutamente todo.
uniform float cone_angle : hint_range(1.0, 360.0) = 100.0;
// Grados, desde cada borde hacia dentro, en los que el cono se va desvaneciendo.
uniform float edge_fade : hint_range(0.5, 180.0) = 35.0;

// Segundos que tarda un color en bajar y cubrir todo el cono.
uniform float sweep_time : hint_range(0.5, 20.0, 0.1) = 5.0;
// Grados que ocupa el fundido entre un color y el siguiente.
uniform float blend_angle : hint_range(1.0, 180.0) = 70.0;

// Ondas de luz que salen de la punta. light_color.a es la opacidad de todo el cono.
uniform vec4 light_color : source_color = vec4(1.0, 1.0, 1.0, 0.35);
uniform float light_speed : hint_range(0.0, 2000.0) = 120.0; // píxeles por segundo
uniform float light_size : hint_range(20.0, 1000.0) = 312.0; // píxeles entre dos ondas
uniform float light_strength : hint_range(0.0, 1.0, 0.01) = 0.25;

varying vec2 pixel;

vec3 primary_color(int index) {
	if (index == 0) {
		return color_a;
	}
	return index == 1 ? color_b : color_c;
}

vec3 rgb2hsv(vec3 c) {
	vec4 k = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, k.wz), vec4(c.gb, k.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
	vec3 p = abs(fract(c.xxx + vec3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
	return c.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}

// Mezcla por el tono, por el camino corto: de amarillo a rojo pasa por naranja, de
// rojo a azul por morado y de azul a amarillo por verde, sin quedarse en gris.
vec3 hue_mix(vec3 from, vec3 to, float t) {
	vec3 a = rgb2hsv(from);
	vec3 b = rgb2hsv(to);
	float turn = fract(b.x - a.x + 0.5) - 0.5;
	return hsv2rgb(vec3(a.x + turn * t, mix(a.yz, b.yz, t)));
}

void vertex() {
	pixel = VERTEX;
}

void fragment() {
	vec2 p = pixel - origin;
	float dist = length(p);
	// Ángulo respecto al centro del cono: negativo = por encima, positivo = por debajo.
	float angle = mod(atan(p.y, p.x) - radians(direction) + PI, TAU) - PI;

	// El cono no tiene final: llega hasta donde acabe la pantalla.
	float half_angle = radians(cone_angle) * 0.5;
	// Opaco en el centro y transparente del todo en los dos bordes.
	float cone_mask = 1.0 - smoothstep(half_angle - radians(edge_fade), half_angle, abs(angle));

	float turns = TIME / sweep_time;
	int current = int(mod(floor(turns), 3.0)); // color que entra en este barrido
	// El centro del fundido empieza y acaba fuera del cono, para que no haya saltos.
	float half_blend = radians(blend_angle) * 0.5;
	float sweep = mix(-half_angle - half_blend, half_angle + half_blend, fract(turns));

	// Por encima del fundido el color nuevo; por debajo, el del barrido anterior.
	float swept = 1.0 - smoothstep(-half_blend, half_blend, angle - sweep);
	vec3 base = hue_mix(primary_color((current + 2) % 3), primary_color(current), swept);

	float wave = sin((dist - TIME * light_speed) * TAU / light_size) * 0.5 + 0.5;
	vec3 color = mix(base, light_color.rgb, wave * light_strength);
	COLOR = vec4(color, cone_mask * light_color.a);
}
