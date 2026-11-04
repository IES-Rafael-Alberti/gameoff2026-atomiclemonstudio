shader_type canvas_item;

uniform vec4 death_color : source_color = vec4(0.1, 0.1, 0.1, 1.0);
uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    color.rgb = mix(color.rgb, death_color.rgb, progress);
    COLOR = color;
}