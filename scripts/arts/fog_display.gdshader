// world_fog_sprite_ARTISTIC.gdshader
shader_type canvas_item;

// --- 可调节参数 (Uniforms) ---

// 【场地设置】(保持不变)
uniform vec2 arena_size = vec2(1280.0, 720.0);
uniform float arena_edge_softness : hint_range(0.0, 200.0) = 50.0;

// 【雾气外观】
uniform vec4 fog_color : source_color = vec4(0.8, 0.85, 0.9, 1.0);
uniform sampler2D noise_texture : filter_linear_mipmap, repeat_enable;

// 【修改点】我们用两套速度和缩放来创造层次感
uniform vec2 scroll_speed_layer1 = vec2(0.01, 0.005); // 大块雾的慢速
uniform float scale_layer1 = 800.0; // 大块雾的尺寸
uniform vec2 scroll_speed_layer2 = vec2(-0.02, 0.03); // 小块雾的快速
uniform float scale_layer2 = 350.0; // 小块雾的尺寸

// 【艺术控制核心】
// 这两个参数是解决“太厚实”问题的关键！
uniform float fog_threshold : hint_range(0.0, 1.0) = 0.4;   // 阈值：控制雾气的“浓密程度”
uniform float fog_softness : hint_range(0.0, 1.0) = 0.2;    // 柔和度：控制雾气边缘的“羽化”程度


// --- Varying & Vertex Shader (保持不变) ---
varying vec2 world_coord;
void vertex() {
    world_coord = VERTEX;
}


// --- 片段着色器 (Fragment Shader) ---
void fragment() {
    // === 1. 计算场地遮罩 (Arena Mask) (保持不变) ===
    vec2 distance_to_edge = abs(world_coord) - arena_size / 2.0;
    float dist = length(max(distance_to_edge, 0.0));
    float arena_mask = smoothstep(0.0, arena_edge_softness, dist);


    // === 2. 制作有层次感的雾气纹理 (全新逻辑) ===

    // -- 层 1: 大块的、缓慢移动的雾气“底座” --
    vec2 world_uv1 = world_coord / scale_layer1;
    vec2 scrolling_uv1 = world_uv1 + TIME * scroll_speed_layer1;
    float noise1 = texture(noise_texture, scrolling_uv1).r;

    // -- 层 2: 小块的、快速飘动的雾气“细节” --
    vec2 world_uv2 = world_coord / scale_layer2;
    vec2 scrolling_uv2 = world_uv2 + TIME * scroll_speed_layer2;
    float noise2 = texture(noise_texture, scrolling_uv2).r;

    // -- 组合层次 --
    // 将两层噪声相乘，可以创造出更自然、更复杂的形状，并产生天然的“空隙”。
    float combined_noise = noise1 * noise2;

    // -- 阈值化：解决“太厚实”问题的魔法 --
    // smoothstep 会根据阈值，将平滑的噪声“雕刻”成有清晰边界和大量透明区域的形状。
    // 只有当 combined_noise 的值大于 fog_threshold 时，雾气才会开始出现。
    float textured_alpha = smoothstep(fog_threshold, fog_threshold + fog_softness, combined_noise);


    // === 3. 组合最终效果 ===
    COLOR = fog_color;
    // 最终的透明度，就是我们“雕刻”出的雾气形状，再乘以场地遮罩。
    COLOR.a = textured_alpha * arena_mask;
}