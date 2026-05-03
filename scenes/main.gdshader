shader_type canvas_item;

uniform float speed : hint_range(0.5, 10.0) = 2.0;
uniform float intensity : hint_range(0.0, 1.0) = 0.8;

void fragment() {
    vec4 original = texture(TEXTURE, UV);
    float pulse = (sin(TIME * speed) + 1.0) / 2.0; // от 0 до 1
    vec3 red_tint = vec3(1.0, 0.2, 0.2);
    vec3 mixed = mix(original.rgb, red_tint, pulse * intensity);
    COLOR = vec4(mixed, original.a);
}