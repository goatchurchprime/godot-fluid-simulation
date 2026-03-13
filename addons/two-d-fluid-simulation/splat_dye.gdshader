shader_type canvas_item;

uniform float aspectRatio = 1.0;
uniform vec3 color;
uniform vec2 point;
uniform float radius = 0.001;

void fragment() {
    vec2 p = UV - point.xy;
    p.x *= aspectRatio;
    vec3 splat = exp(-dot(p, p) / radius) * color;
    COLOR = vec4(splat, 1.0);
}
