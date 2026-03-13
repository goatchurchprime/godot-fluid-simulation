shader_type canvas_item;

uniform sampler2D divergencetexture;
uniform vec2 texelsize;
uniform float pressurefac = 1.0;

void fragment() {
	float L = texture(TEXTURE, UV - vec2(texelsize.x, 0.0)).x;
	float R = texture(TEXTURE, UV + vec2(texelsize.x, 0.0)).x;
	float T = texture(TEXTURE, UV + vec2(0.0, texelsize.y)).x;
	float B = texture(TEXTURE, UV - vec2(0.0, texelsize.y)).x;
	float divergence = texture(divergencetexture, UV).x;
	float pressure = ((L + R + B + T)*pressurefac - divergence) * 0.25;
	COLOR = vec4(pressure, 0.0, 0.0, 1.0);
	//COLOR = vec4(pressure, pressurefac, divergence, 1.0);
}
