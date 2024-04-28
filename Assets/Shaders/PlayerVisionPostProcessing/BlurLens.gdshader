// base shader from https://youtu.be/gqe0InyIk4U?si=fWPijiPY79zPtgmk
// https://godotshaders.com/shader/blur-vignette-post-processing-colorrect-godot-4-2-1/
shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;


uniform float blur_amount : hint_range(-2.0, 10.0);
uniform float mix_amount : hint_range(0.0, 1.0);
uniform vec4 color_over : source_color;

void vertex(){
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
    // Original color of the pixel from the screen
    vec4 blurred = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
	vec4 fin = mix(blurred, color_over, mix_amount);
	ALBEDO = fin.rgb;
}