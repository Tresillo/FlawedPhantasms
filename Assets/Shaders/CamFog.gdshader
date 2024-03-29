shader_type spatial;
render_mode unshaded, cull_front, depth_draw_always;

uniform sampler2D noise_texture;
uniform float scroll_speed: hint_range(0.0, 10.0, 0.1);
uniform float noise_alpha_weight: hint_range(0.0,10.0,0.1);
uniform float noise_color_weight: hint_range(0.0,1.0,0.01);
uniform vec3 void_color: source_color;
uniform float transparency: hint_range(0.0, 1.0, 0.05);

void fragment() {
	vec2 noise_sample_point = vec2(UV.x + scroll_speed * 0.04 * TIME, UV.y + scroll_speed * 0.04 * TIME);
	float noise = texture(noise_texture, noise_sample_point).x - 0.5;
	
	ALBEDO = clamp(void_color + noise * 0.1 * noise_color_weight,vec3(0.0),vec3(1.0));
	//ALPHA = clamp(noise * noise_alpha_weight,0.7,1.0);
	ALPHA = 1.0 - transparency;
}
