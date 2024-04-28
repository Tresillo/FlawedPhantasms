// base shader from https://youtu.be/gqe0InyIk4U?si=fWPijiPY79zPtgmk
// Pixelation adapted from https://godotshaders.com/shader/3d-pixelation-filter/
shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform int pixel_size = 4; //resolution must be divisible by pixel_size

void vertex(){
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	float x = float(int(FRAGCOORD.x) % pixel_size);
	float y = float(int(FRAGCOORD.y) % pixel_size);

	x = FRAGCOORD.x + floor(float(pixel_size) / 2.0) - x;
	y = FRAGCOORD.y + floor(float(pixel_size) / 2.0) - y;

	ALBEDO = texture(SCREEN_TEXTURE, vec2(x, y) / VIEWPORT_SIZE).xyz;
}