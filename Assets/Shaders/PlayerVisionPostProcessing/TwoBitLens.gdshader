// base shader from https://youtu.be/gqe0InyIk4U?si=fWPijiPY79zPtgmk
shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform vec3 dark_tone: source_color = vec3(0.0);
uniform vec3 light_tone: source_color = vec3(1.0);
uniform float dark_amount: hint_range(0.0, 1.0, 0.01) = 0.5;


void vertex(){
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	
	vec3 screen_color = texture(SCREEN_TEXTURE, uv).rgb;
	float color_length = length(screen_color);
	float color_mask = step(dark_amount, color_length);
	
	vec3 new_color = color_mask * light_tone + (1.0 -color_mask) * dark_tone;
	
	ALBEDO = new_color;		// showing screen texture
}