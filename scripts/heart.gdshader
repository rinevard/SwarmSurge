shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    float dist = distance(UV, vec2(0.5));
    float threshold = progress * 0.71; 
    float alpha_multiplier = step(threshold, dist);
    color.a *= alpha_multiplier;
    COLOR = color;
}