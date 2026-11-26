shader_type canvas_item;
// Full-screen background: vertical gradient + paper grain/fibres + vignette.
// All procedural (no textures). `scroll` follows the camera for subtle parallax.
uniform vec4 top_color : source_color = vec4(0.11, 0.10, 0.23, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.05, 0.13, 0.20, 1.0);
uniform float grain = 0.0;
uniform float fibres = 0.0;
uniform float vignette = 0.25;
uniform float scroll = 0.0;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), u.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), u.x), u.y);
}
void fragment() {
	vec2 uv = UV;
	vec3 c = mix(top_color.rgb, bottom_color.rgb, uv.y);
	vec2 p = vec2(uv.x * 720.0, uv.y * 1280.0 + scroll * 0.35);
	float g = hash(floor(p)) - 0.5;
	c += g * grain;
	float f = noise(p * vec2(0.02, 0.15)) * noise(p * vec2(0.11, 0.013));
	c -= f * fibres;
	vec2 d = uv - 0.5;
	c *= 1.0 - vignette * dot(d, d) * 2.0;
	COLOR = vec4(c, 1.0);
}
