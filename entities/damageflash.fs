extern float is_on;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texture_color = Texel(tex, texture_coords);
    return mix(texture_color * color, vec4(1, 1, 1, texture_color.a), is_on);
}