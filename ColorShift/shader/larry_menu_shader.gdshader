shader_type canvas_item;

// Cono de color que sale de la lente de Larry y funciona como un limpiaparabrisas
// de un solo sentido: los colores primarios entran por el borde de arriba del cono
// (punto A) y bajan hasta el de abajo, siempre con dos o más a la vista:
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
uniform float cone_angle : hint_range(1.0, 360.0) = 70.0;
// Grados, desde cada borde hacia dentro, en los que el cono se va desvaneciendo.
uniform float edge_fade : hint_range(0.5, 180.0) = 12.0;

// Cuántos colores caben a la vez en el cono. Con 2 o más siempre se ven al menos dos.
uniform float colors_in_cone : hint_range(1.0, 6.0, 0.1) = 2.0;
// Segundos que tarda la línea entre dos colores en bajar de un borde al otro.
uniform float sweep_time : hint_range(0.5, 20.0, 0.1) = 5.0;
// Grosor en grados de la línea donde se funden dos colores.
uniform float blend_angle : hint_range(0.1, 30.0) = 5.0;

// Ondas de luz que salen de la punta. light_color.a es la opacidad de todo el cono.
uniform vec4 light_color : source_color = vec4(1.0, 1.0, 1.0, 0.35);
uniform float light_speed : hint_range(0.0, 2000.0) = 120.0; // píxeles por segundo
uniform float light_size : hint_range(20.0, 1000.0) = 312.0; // píxeles entre dos ondas
uniform float light_strength : hint_range(0.0, 1.0, 0.01) = 0.15;

varying vec2 pixel;

vec3 primary_color(int index) {
	if (index == 0) {
		return color_a;
	}
	return index == 1 ? color_b : color_c;
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

	// Franja de color a la que pertenece el píxel: sube con el tiempo y hacia arriba,
	// así las líneas entre colores bajan.
	float band = radians(cone_angle) / colors_in_cone;
	float position = TIME / sweep_time * colors_in_cone - (angle + half_angle) / band;
	float line = floor(position + 0.5); // la línea más cercana
	float half_blend = radians(blend_angle) / band * 0.5;
	float blend = smoothstep(-half_blend, half_blend, position - line);
	// El + 0.5 evita que un 2.9999 se quede en 2 al sacar el resto.
	int next = int(mod(line, 3.0) + 0.5) % 3;
	vec3 base = mix(primary_color((next + 2) % 3), primary_color(next), blend);

	float wave = sin((dist - TIME * light_speed) * TAU / light_size) * 0.5 + 0.5;
	vec3 color = mix(base, light_color.rgb, wave * light_strength);
	COLOR = vec4(color, cone_mask * light_color.a);
}
