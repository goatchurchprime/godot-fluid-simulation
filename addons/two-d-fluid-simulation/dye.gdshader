shader_type canvas_item;

uniform sampler2D splattexture;
void fragment() {
	vec3 dyecolor = texture(TEXTURE, UV).xyz;
	vec3 splat = texture(splattexture, UV).xyz;
	COLOR = vec4(dyecolor + splat, 1.0);
}
