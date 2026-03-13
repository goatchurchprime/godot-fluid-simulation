shader_type canvas_item;

uniform vec2 texelsize;
void fragment() {
	float L = texture(TEXTURE, UV - vec2(texelsize.x, 0.0)).x;
	float R = texture(TEXTURE, UV + vec2(texelsize.x, 0.0)).x;
	float T = texture(TEXTURE, UV + vec2(0.0, texelsize.y)).y;
	float B = texture(TEXTURE, UV - vec2(0.0, texelsize.y)).y;
	vec2 C = texture(TEXTURE, UV).xy;
	if (UV.x - texelsize.x < 0.0)  L = -C.x;
	if (UV.x + texelsize.x > 1.0)  R = -C.x;
	if (UV.y + texelsize.y > 1.0)  T = -C.y;
	if (UV.y - texelsize.y < 0.0)  B = -C.y;
	float div = 0.5*(R - L + T - B);
	COLOR = vec4(div, -div, 0.0, 1.0);
}
