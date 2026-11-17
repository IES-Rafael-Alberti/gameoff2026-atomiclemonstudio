shader_type canvas_item;

// Capture what is on the screen below the ColorRect (Godot 4)
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// Color blindness mode: 
// 0 = Normal, 1 = Protanopia, 2 = Deuteranopia, 3 = Tritanopia
uniform int mode : hint_range(0, 3) = 0;

void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	vec3 rgb = color.rgb;
	
	if (mode == 1) {
		
		mat3 protan_matrix = mat3(
			vec3(0.56667, 0.43333, 0.0),
			vec3(0.55833, 0.44167, 0.0),
			vec3(0.0, 0.24167, 0.75833)
		);
		rgb = protan_matrix * rgb;
	} 
	else if (mode == 2) {
		
		mat3 deuteran_matrix = mat3(
			vec3(0.625, 0.375, 0.0),
			vec3(0.7, 0.3, 0.0),
			vec3(0.0, 0.3, 0.7)
		);
		rgb = deuteran_matrix * rgb;
	} 
	else if (mode == 3) {
		
		mat3 tritan_matrix = mat3(
			vec3(0.95, 0.05, 0.0),
			vec3(0.0, 0.433, 0.567),
			vec3(0.0, 0.475, 0.525)
		);
		rgb = tritan_matrix * rgb;
	}
	
	COLOR = vec4(rgb, color.a);
}