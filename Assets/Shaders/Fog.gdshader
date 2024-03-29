shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_always;

uniform sampler2D DEPTH_TEXTURE : source_color, hint_depth_texture;
uniform sampler2D noise_texture;
uniform float scroll_speed: hint_range(0.0, 10.0, 0.1);
uniform float noise_alpha_weight: hint_range(0.0,1.0,0.1);
uniform float noise_color_weight: hint_range(0.0,1.0,0.01);
uniform vec3 void_color: source_color;
uniform float depth_range:hint_range(0.1, 10.0, 0.1);

void fragment() {
	vec2 noise_sample_point = vec2(UV.x + scroll_speed * 0.04 * TIME, UV.y + scroll_speed * 0.04 * TIME);
	float noise = texture(noise_texture, noise_sample_point).x - 0.5;
	
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = clamp(-view.z / depth_range,0.0,1.0);
	
	vec3 fog_color = clamp(void_color + noise * 0.1 * noise_color_weight,vec3(0.0),vec3(1.0));
	float fog_alpha = clamp(linear_depth - noise * noise_alpha_weight,0.7,1.0);
	
	FOG = vec4(fog_color, fog_alpha);
	ALBEDO = fog_color;
	ALPHA = fog_alpha;
	
}

