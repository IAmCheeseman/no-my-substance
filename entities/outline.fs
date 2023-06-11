extern vec4 outline_color;
extern float outline_width;

vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen_uv) {

    vec4 pixel = Texel(texture, uv);

    if (pixel.a == 0.0) 
        discard;

    float dist = pixel.a;
    for (float i = 1.; i <= outline_width; i++) {
        dist = min(dist, Texel(texture, uv + vec2( i,  0.0)).a);
        dist = min(dist, Texel(texture, uv + vec2(-i,  0.0)).a);
        dist = min(dist, Texel(texture, uv + vec2(0.0,   i)).a);
        dist = min(dist, Texel(texture, uv + vec2(0.0,  -i)).a);
    }

    if (dist > 1.0 - outline_width) {
        return mix(outline_color, color, pixel.a);
    }

    return pixel * color;

}
