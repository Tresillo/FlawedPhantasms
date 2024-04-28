// base shader from https://youtu.be/gqe0InyIk4U?si=fWPijiPY79zPtgmk
// vingette adapted from https://godotshaders.com/shader/vignette/
shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform vec3 vingette_color: source_color = vec3(0.0);
uniform float inner_radius = 0.0;
uniform float outer_radius = 1.0;

void vertex(){
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	
	vec3 screen_color = texture(SCREEN_TEXTURE, uv).rgb;
	
	float x = abs(uv.x - 0.5) * 2.0;
	float y = abs(uv.y - 0.5) * 2.0;
	float q = 1.0-(1.0-sqrt(x*x+y*y)/outer_radius)/(1.0-inner_radius);
	
	ALBEDO = mix(screen_color,vingette_color,q);		// showing screen texture
}