// base shader from https://youtu.be/gqe0InyIk4U?si=fWPijiPY79zPtgmk
shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform float red_amount: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float green_amount: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float blue_amount: hint_range(0.0, 1.0, 0.1) = 1.0;

void vertex(){
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	
	vec3 screen_color = texture(SCREEN_TEXTURE, uv).rgb;
	vec3 modified_color = vec3(screen_color.r * red_amount,
								screen_color.g * green_amount,
								screen_color.b * blue_amount);
	
	float screen_color_len = length(screen_color);
	vec3 new_color = normalize(modified_color) * screen_color_len;
	
	ALBEDO = new_color;		// showing screen texture
}