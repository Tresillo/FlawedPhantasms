// base shader from https://youtu.be/gqe0InyIk4U?si=fWPijiPY79zPtgmk
// https://godotshaders.com/shader/bayer-dithering/
shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : source_color, hint_depth_texture;


const mat4 bayerIndex = mat4(
    vec4(00.0/16.0, 12.0/16.0, 03.0/16.0, 15.0/16.0),
    vec4(08.0/16.0, 04.0/16.0, 11.0/16.0, 07.0/16.0),
    vec4(02.0/16.0, 14.0/16.0, 01.0/16.0, 13.0/16.0),
    vec4(10.0/16.0, 06.0/16.0, 09.0/16.0, 05.0/16.0));

void vertex(){
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	 // sample the texture
	vec2 uv = SCREEN_UV;
    vec4 col = texture(SCREEN_TEXTURE,uv);
    
    // gamma correction
    col = vec4(pow(col.rgb,vec3(2.2)) - 0.004,col.a);
    
    // find bayer matrix entry based on fragment position
    float bayerValue = bayerIndex[int(FRAGCOORD.x) % 4][int(FRAGCOORD.y) % 4];
    
    
        // output
     ALBEDO = vec3(
            step(bayerValue,col.r),
            step(bayerValue,col.g),
            step(bayerValue,col.b)
			);
}