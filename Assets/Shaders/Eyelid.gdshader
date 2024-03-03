shader_type canvas_item;

uniform vec3 lid_color: source_color;
uniform float lid_transparency: hint_range(0.0, 1.0, 0.01);
uniform float close_amount: hint_range(0.0, 1.0, 0.01);
uniform float lid_width: hint_range(0.0, 1.0, 0.01);

void fragment() {
	// Called for every pixel the material is visible on.
	float upper_bound = 0.5 - lid_width + close_amount;
	float lower_bound = 0.5  + lid_width - close_amount;
	float vertical_mask =  clamp(1.0 + smoothstep(upper_bound,upper_bound + lid_width,UV.y) - smoothstep(lower_bound - lid_width,lower_bound,UV.y),0.0,1.0);
	float alpha = max(-1.0,1.0-lid_transparency);
	//COLOR = vec4(vertical_mask,vertical_mask,vertical_mask,1.0);
	COLOR = vec4(lid_color,alpha) * vertical_mask;
}

