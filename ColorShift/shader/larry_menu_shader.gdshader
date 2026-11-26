shader_type canvas_item;

uniform vec4 light_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float light_speed: hint_range(0.0, 4.0, 0.01) = 0.0;
uniform float light_size: hint_range(0.1, 2.0, 0.1) = 0.01;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV;
	uv.y = 1.0 - uv.y; // 翻转Y轴：向上正
	float a = uv.x - uv.y; // 逆时针旋转45.0度
	a -= TIME * light_speed; // 平移
	a *=  2.0 * PI; // 把sin(a)周期缩放到: 1.0
	a /= (light_size * sqrt(2.0)); // 把sin(a)周期缩放到: light_size * sqrt(2.0)
	float b = sin(a) * 0.5 + 0.5; // 把值控制在[0.0, 1.0]
	vec4 tex = texture(TEXTURE, UV);
	COLOR = vec4(max(tex.rgb, (light_color * b).rgb), 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}