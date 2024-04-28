// base shader from https://youtu.be/gqe0InyIk4U?si=fWPijiPY79zPtgmk
shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform vec2 r_displacement = vec2(3.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-3.0, 0.0);

void vertex(){
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	
	float r = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0005*r_displacement), 0.0).r;
	float g = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0005*g_displacement), 0.0).g;
	float b = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0005*b_displacement), 0.0).b;
	
	ALBEDO = vec3(r,g,b);		// showing screen texture
}