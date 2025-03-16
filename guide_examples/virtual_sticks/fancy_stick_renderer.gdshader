shader_type canvas_item;

uniform vec2 stick_offset;
uniform vec4 stick_color:source_color;

void fragment() {
	
	vec2 stick_center = stick_offset / 2.0 + vec2(0.5);
	
	float d = distance(UV, stick_center);
	COLOR = stick_color;
	COLOR.a = 1.0-d;
}
