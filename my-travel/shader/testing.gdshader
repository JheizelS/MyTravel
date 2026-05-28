shader_type spatial;
uniform sampler2D road_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform float scale = 0.1;

void fragment() {
    vec2 uv = vec2(FRAGCOORD.x, FRAGCOORD.y) * scale * 0.01;
    ALBEDO = texture(road_tex, uv).rgb;
    ROUGHNESS = 0.9;
    METALLIC = 0.0;
}