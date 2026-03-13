shader_type canvas_item;

uniform sampler2D velocitytexture;
// uniform sampler2D uCurl;  texture
uniform float curl = 30.0;
uniform float dt = 0.015;

uniform vec2 texelsize;
void fragment() {
	float L = texture(TEXTURE, UV - vec2(texelsize.x, 0.0)).x;
	float R = texture(TEXTURE, UV + vec2(texelsize.x, 0.0)).x;
	float T = texture(TEXTURE, UV + vec2(0.0, texelsize.y)).x;
	float B = texture(TEXTURE, UV - vec2(0.0, texelsize.y)).x;
	float C = texture(TEXTURE, UV).x;

	vec2 force = 0.5 * vec2(abs(T) - abs(B), abs(L) - abs(R));
	force /= (length(force) + 0.0001);
	force *= curl * C;

	vec2 velocity = texture(velocitytexture, UV).xy;

	velocity += force * dt;
	velocity = clamp(velocity, vec2(-1000.0,-1000.0), vec2(1000.0,1000.0));

	COLOR = vec4(velocity, 0.0, 1.0);
}
