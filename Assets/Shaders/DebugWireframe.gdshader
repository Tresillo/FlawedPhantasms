shader_type spatial;
render_mode wireframe, cull_disabled, unshaded;

uniform vec3 frame_color : source_color = vec3(1);

void fragment() {
	ALBEDO = frame_color;
}
