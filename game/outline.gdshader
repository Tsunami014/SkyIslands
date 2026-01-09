// Modified slightly from https://godotshaders.com/shader/lightweight-pixel-perfect-outline/ !
shader_type canvas_item;
instance uniform vec4 outline_colour : source_color = vec4(0.0, 0.0, 0.0, 1.0);
//Blinking modulates the base color.
//Set blink_time_scale to 0 if you don't want blinking.
instance uniform vec4 blink_colour : source_color = vec4(1.0);
instance uniform float blink_time_scale : hint_range(0.0, 10.0, 0.1) = 0.0;

instance uniform vec4 bg_colour : source_color = vec4(0.0, 0.0, 0.0, 0.0);
instance uniform vec4 tint_colour : source_color = vec4(0.0, 0.0, 0.0, 0.0);

const int OFFS_LEN = 4;
const ivec2 OFFS[OFFS_LEN] = ivec2[](
	ivec2(1, 0),
	ivec2(0, -1),
	ivec2(0, 1),
	ivec2(-1, 0)
);


void fragment() {
	vec2 pixel_size = TEXTURE_PIXEL_SIZE;

	bool outside = texture(TEXTURE, UV).a == 0.0;
	vec4 col;
	if (outside) {
		for (int i = 0; i < OFFS_LEN; i++) {
			vec2 uv2 = UV + pixel_size * vec2(OFFS[i]);
			if (texture(TEXTURE, uv2).a > 0.0) {
				outside = false;
				if (tint_colour != vec4(0.0,0.0,0.0,0.0)) {
					col = mix(outline_colour, tint_colour, 0.25);
				} else {
					col = outline_colour;
				}
				break;
			}
		}
	} else {
		if (tint_colour != vec4(0.0,0.0,0.0,0.0)) {
			col = mix(COLOR, tint_colour, 0.45);
		} else {
			col = COLOR;
		}
	}
	if (outside) {
		COLOR = bg_colour;
	} else {
		if (blink_time_scale != 0.0) {
			col = mix(col, col * blink_colour, 0.5 - 0.5 * cos(TIME * blink_time_scale));
		}
		COLOR = col;
	}
}