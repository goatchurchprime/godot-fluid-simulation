shader_type canvas_item;

uniform sampler2D vorticitytexture;

uniform vec2 texelsize;
void fragment() {
	float L = texture(TEXTURE, UV - vec2(texelsize.x, 0.0)).x;
	float R = texture(TEXTURE, UV + vec2(texelsize.x, 0.0)).x;
	float T = texture(TEXTURE, UV + vec2(0.0, texelsize.y)).x;
	float B = texture(TEXTURE, UV - vec2(0.0, texelsize.y)).x;
	vec2 velocity = texture(vorticitytexture, UV).xy;
	velocity.xy -= vec2(R - L, T - B);
	COLOR = vec4(velocity, 0.0, 1.0);
}
