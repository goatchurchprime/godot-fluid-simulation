shader_type canvas_item;

uniform vec2 texelsize;
uniform float dt = 0.015;
uniform float dissipation = 0.2;

void fragment() {
	vec2 coord = UV - dt * texture(TEXTURE, UV).xy * texelsize;
	vec4 result = texture(TEXTURE, coord);
	float decay = 1.0 + dissipation*dt;
	COLOR = result / decay;
}
