// lakebed_STYLED.gdshader
shader_type canvas_item;

// --- 可调节参数 (Uniforms) ---

// 【[全新] 湖底调色板】
uniform vec4 sand_color : source_color = vec4(0.35, 0.3, 0.2, 1.0);  // 沙地/泥土的颜色
uniform vec4 rock_color : source_color = vec4(0.5, 0.45, 0.4, 1.0);  // 石头的颜色
uniform vec4 rock_shadow_color : source_color = vec4(0.2, 0.18, 0.15, 1.0); // 石头阴影色，营造立体感

// 【噪声与流动】
uniform sampler2D noise_texture : filter_linear_mipmap, repeat_enable;
uniform vec2 scroll_speed = vec2(0.003, 0.001); // 极其缓慢的速度，让水底看起来“静止但不死板”
uniform float base_scale = 700.0; // 基础纹理尺寸
uniform float rock_scale = 400.0; // 石头的尺寸

// 【艺术风格控制器】
uniform float rock_threshold : hint_range(0.0, 1.0) = 0.5; // 石头出现的阈值
uniform float rock_softness : hint_range(0.0, 0.1) = 0.02;  // 石头边缘的硬度
uniform float rock_shadow_offset = 0.01; // 石头阴影的偏移量


// --- Varying & Vertex Shader (保持不变) ---
varying vec2 world_coord;
void vertex() {
    world_coord = VERTEX;
}


// --- 片段着色器 (Fragment Shader) ---
void fragment() {
    // === 1. “画”出沙/泥质的湖底基础 ===
    vec2 world_uv_base = world_coord / base_scale;
    vec2 scrolling_uv_base = world_uv_base + TIME * scroll_speed;
    // 用一层噪声给沙地增加一些自然的明暗变化
    float base_noise = texture(noise_texture, scrolling_uv_base).r;
    vec3 final_color = mix(sand_color.rgb, rock_color.rgb, base_noise * 0.2); // 微弱混合

    // === 2. 在沙地上“雕刻”出鹅卵石 ===
    vec2 world_uv_rock = world_coord / rock_scale;
    vec2 scrolling_uv_rock = world_uv_rock + TIME * scroll_speed * 1.5; // 让石头流速稍快
    float rock_noise = texture(noise_texture, scrolling_uv_rock).r;
    
    // a. 雕刻出石头的基本形状
    float rock_shape = smoothstep(rock_threshold, rock_threshold + rock_softness, rock_noise);

    // === 3. 为石头“添加”立体感 (简单的阴影) ===
    // a. 采样同一个噪声，但在一个微小的偏移位置
    vec2 shadow_uv = scrolling_uv_rock + vec2(rock_shadow_offset);
    float shadow_noise = texture(noise_texture, shadow_uv).r;
    // b. 用同样的阈值雕刻出阴影的形状
    float shadow_shape = smoothstep(rock_threshold, rock_threshold + rock_softness, shadow_noise);
    
    // c. 组合：先画阴影，再在阴影上画石头
    final_color = mix(final_color, rock_shadow_color.rgb, shadow_shape);
    final_color = mix(final_color, rock_color.rgb, rock_shape);
    
    COLOR = vec4(final_color, 1.0);
}