shader_type spatial;
render_mode unshaded, cull_front, depth_draw_always;
uniform vec3 void_color: source_color;

void fragment() {
	ALBEDO = void_color;
}
