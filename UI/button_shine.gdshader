shader_type canvas_item;

uniform sampler2D main_color;
uniform float shine_size : hint_range(0.01, 1.0, 0.01) = 0.04;
uniform float shine_angle : hint_range(0.0, 89.9, 0.1) = 75.0;
uniform float shine_speed : hint_range(0.0, 5.0, 0.01) = 1.1;
uniform float shine_spacing : hint_range(0.0, 1.0, 0.01) = 0.12;
uniform bool shine_active = true;

float scale(float value, float inMin, float inMax, float outMin, float outMax) {
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

void fragment() {
    vec2 pixelation = 1.0 / TEXTURE_PIXEL_SIZE;
    vec2 pixelated_uv = floor(UV * pixelation) / pixelation;
    COLOR = texture(TEXTURE, UV);

    float slope = tan(radians(shine_angle));

    float base_progress;
    if (shine_active) {
        base_progress = mod(TIME * shine_speed, 3.0);
    } else {
        base_progress = 2.0;
    }

    float progress1 = scale(base_progress, 0.0, 1.0, -1.0 - shine_size - shine_size * slope, 1.0 * slope + shine_size + shine_size * slope);
    float shine_distance1 = (slope * pixelated_uv.x - pixelated_uv.y - progress1) / (sqrt(slope * slope + 1.0));
    float shine1 = step(shine_distance1, shine_size) - step(shine_distance1, -shine_size);

    float progress2 = scale(base_progress + shine_spacing, 0.0, 1.0, -1.0 - shine_size - shine_size * slope, 1.0 * slope + shine_size + shine_size * slope);
    float shine_distance2 = (slope * pixelated_uv.x - pixelated_uv.y - progress2) / (sqrt(slope * slope + 1.0));
    float shine2 = step(shine_distance2, shine_size) - step(shine_distance2, -shine_size);

    float total_shine = max(shine1, shine2);

    vec4 white = vec4(1.0, 1.0, 1.0, 1.0);
    COLOR.rgb = mix(COLOR.rgb, white.rgb, total_shine * white.a);
}