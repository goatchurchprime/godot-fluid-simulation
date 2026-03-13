shader_type canvas_item;

uniform vec2 texelsize;
void fragment() {
	float L = texture(TEXTURE, UV - vec2(texelsize.x, 0.0)).y;
	float R = texture(TEXTURE, UV + vec2(texelsize.x, 0.0)).y;
	float T = texture(TEXTURE, UV + vec2(0.0, texelsize.y)).x;
	float B = texture(TEXTURE, UV - vec2(0.0, texelsize.y)).x;
	float vorticity = R - L - T + B;
	COLOR = vec4(0.5*vorticity, 0.0, 0.0, 1.0);
}
