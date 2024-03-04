// base shader from https://youtu.be/gqe0InyIk4U?si=fWPijiPY79zPtgmk
shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void vertex(){
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	vec3 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;

	ALBEDO = screen_color.rgb;		// showing screen texture
}