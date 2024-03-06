shader_type spatial;
render_mode cull_disabled, specular_schlick_ggx;

group_uniforms color_properties;
uniform vec3 window_color: source_color;
uniform vec3 grid_color: source_color;
uniform float window_transparency: hint_range(0.0, 1.0, 0.01);
uniform float grid_transparency: hint_range(0.0, 1.0, 0.01);

group_uniforms grid_properties;
uniform vec2 grid_scale;
uniform float line_scale : hint_range(0.001, 1, 0.001);


float pristineGrid( vec2 uv, vec2 lineWidth)
{
    vec2 ddx = dFdx(uv);
    vec2 ddy = dFdy(uv);
	
    vec2 uvDeriv = vec2(length(vec2(ddx.x, ddy.x)), length(vec2(ddx.y, ddy.y)));
    bvec2 invertLine = bvec2(lineWidth.x > 0.5, lineWidth.y > 0.5);
	
    vec2 targetWidth = vec2(
      invertLine.x ? 1.0 - lineWidth.x : lineWidth.x,
      invertLine.y ? 1.0 - lineWidth.y : lineWidth.y
      );
	
    vec2 drawWidth = clamp(targetWidth, uvDeriv, vec2(0.5));
    vec2 lineAA = uvDeriv * 1.5;
    vec2 gridUV = abs(fract(uv) * 2.0 - 1.0);
	
    gridUV.x = invertLine.x ? gridUV.x : 1.0 - gridUV.x;
    gridUV.y = invertLine.y ? gridUV.y : 1.0 - gridUV.y;
	
    vec2 grid2 = smoothstep(drawWidth + lineAA, drawWidth - lineAA, gridUV);

    grid2 *= clamp(targetWidth / drawWidth, 0.0, 1.0);
    grid2 = mix(grid2, targetWidth, clamp(uvDeriv * 2.0 - 1.0, 0.0, 1.0));
    grid2.x = invertLine.x ? 1.0 - grid2.x : grid2.x;
    grid2.y = invertLine.y ? 1.0 - grid2.y : grid2.y;
    return mix(grid2.x, 1.0, grid2.y);
}

void fragment() 
{
	float grid_mask = step(0.5,pristineGrid(UV * grid_scale, vec2(line_scale)));
	
	ALBEDO = mix(window_color, grid_color, grid_mask);
	ALPHA = mix(window_transparency, grid_transparency, grid_mask);
	ROUGHNESS = 0.0;
	CLEARCOAT = 1.0;
	METALLIC = 0.5;
	SPECULAR = 0.5;
	//CLEARCOAT_ROUGHNESS = 0.0;
}