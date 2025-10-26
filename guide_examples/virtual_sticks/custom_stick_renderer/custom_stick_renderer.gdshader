shader_type canvas_item;

// Radius of the stick in UV units
uniform float stick_radius = 0.1;

// Position of the stick in UV units
uniform vec2 stick_position = vec2(0.5, 0.5);

// thickness of the outline
uniform float outline_thickness = 0.05;

// SDF for a smooth union
// https://iquilezles.org/articles/distfunctions/
float smooth_union(float first, float second, float smoothness) {
	smoothness *= 4.0;
    float h = max(smoothness-abs(first-second),0.0);
    return min(first, second) - h*h*0.25/smoothness;	
}

float outline(float value, float thickness) {
	float radius = thickness / 2.0;
	return -(radius-abs(value));
}

// SDF for the joy at the given position using the given 
// joy radius and joy position.
float circle(vec2 position, float joy_radius, vec2 joy_position) {
	return length(position-joy_position) - joy_radius; 
}


void fragment() {
	float center = circle(UV, stick_radius * 0.5, vec2(0.5));
	float moved = circle(UV, stick_radius, stick_position);
	float final = outline(smooth_union(center, moved, 0.01), outline_thickness);
	float mask = clamp(-sign(final), 0, 1);
	
	COLOR = vec4(1) * mask;
}
