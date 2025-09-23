// water_surface_ULTIMATE_NO_NORMAL_MAP.gdshader
shader_type canvas_item;
render_mode blend_mix;

// --- Uniforms ---
// 【修改点】我们不再需要 normal_map！
uniform sampler2D noise_texture : filter_linear_mipmap, repeat_enable;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec4 water_color : source_color = vec4(0.3, 0.5, 0.8, 0.3);
uniform float refraction_strength : hint_range(0.0, 0.1) = 0.01;
uniform float caustics_strength : hint_range(0.0, 2.0) = 0.5;
uniform float caustics_scale : hint_range(100.0, 2000.0) = 700.0;
uniform float caustics_speed_multiplier = 1.2;
uniform float specular_shininess : hint_range(1.0, 128.0) = 32.0;
uniform float specular_strength : hint_range(0.0, 2.0) = 0.8;
uniform vec2 scroll_speed = vec2(0.02, 0.01);
// 【新增】用于控制伪造法线的强度
uniform float fake_normal_strength : hint_range(0.0, 50.0) = 20.0;

// --- Varying & Vertex ---
varying vec2 world_coord;
void vertex() {
    world_coord = VERTEX;
}

// --- Fragment Shader ---
void fragment() {
    // === 1. 程序化生成“伪”法线 [全新核心逻辑] ===
    vec2 normal_uv = world_coord / 800.0 + TIME * scroll_speed;
    vec2 texel_size = 1.0 / vec2(textureSize(noise_texture, 0));
    
    // 通过比较邻近像素，计算出噪声图的“坡度”
    float center = texture(noise_texture, normal_uv).r;
    float right = texture(noise_texture, normal_uv + vec2(texel_size.x, 0.0)).r;
    float top = texture(noise_texture, normal_uv - vec2(0.0, texel_size.y)).r;
    
    // 将坡度构造成一个法线向量
    vec3 normal = normalize(vec3((right - center) * fake_normal_strength, (top - center) * fake_normal_strength, 1.0));

    // === 2. 计算折射 (逻辑不变，但现在由伪法线驱动) ===
    vec2 refracted_uv = SCREEN_UV + normal.xy * refraction_strength;
    vec3 refracted_color = texture(SCREEN_TEXTURE, refracted_uv).rgb;

    // === 3. 程序化生成焦散 (逻辑不变) ===
    vec2 caustics_uv1 = world_coord / caustics_scale + TIME * scroll_speed * caustics_speed_multiplier;
    float noise1 = texture(noise_texture, caustics_uv1).r;
    vec2 caustics_uv2 = world_coord / (caustics_scale * 0.7) - TIME * scroll_speed * (caustics_speed_multiplier * 0.8);
    float noise2 = texture(noise_texture, caustics_uv2).r;
    float caustics_raw = 1.0 - abs(noise1 - noise2);
    float caustics = pow(caustics_raw, 4.0);
    vec3 color_with_caustics = refracted_color + caustics * caustics_strength;

    // === 4. 计算高光 (逻辑不变，但现在由伪法线驱动) ===
    vec3 light_dir = normalize(vec3(0.5, -1.0, 0.8));
    float specular = pow(max(0.0, dot(normal, light_dir)), specular_shininess);
    specular *= specular_strength;
    
    // === 5. 组合最终颜色 (逻辑不变) ===
    vec3 final_color = mix(color_with_caustics, water_color.rgb, water_color.a);
    final_color += specular;
    
    COLOR = vec4(final_color, 1.0);
}