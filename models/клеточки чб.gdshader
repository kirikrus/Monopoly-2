shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;

uniform sampler3D noise_texture;
uniform vec3 box_size = vec3(1.0);
uniform float density = 1.2;
uniform float thickness = 0.1;
uniform vec4 color = vec4(1.0);
uniform float steps = 64.0;

void fragment() {
    vec3 start = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec3 ray_dir = normalize(CAMERA_POSITION - (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz);

    vec3 local_pos = (WORLD_POSITION - vec3(0.0)) / box_size;
    float alpha = 0.0;
    vec3 accum_color = vec3(0.0);
    
    for (float i = 0.0; i < 1.0; i += 1.0 / steps) {
        vec3 sample_pos = local_pos + ray_dir * i * thickness;
        float n = texture(noise_texture, sample_pos).r;
        float a = smoothstep(0.4, 1.0, n) * density * (1.0 / steps);
        vec3 col = color.rgb;
        
        accum_color += col * a * (1.0 - alpha);
        alpha += a * (1.0 - alpha);
        if (alpha >= 1.0) break;
    }

    ALBEDO = accum_color;
    ALPHA = alpha;
    if (alpha < 0.01) {
        discard;
    }
}
