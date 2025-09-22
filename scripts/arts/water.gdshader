// water_surface_SERENE.gdshader
shader_type canvas_item;

// --- 可调节参数 (Uniforms) ---

// 【极简调色板】
uniform vec4 water_dark_color : source_color = vec4(0.2, 0.4, 0.7, 1.0); // 暗部颜色
uniform vec4 water_light_color : source_color = vec4(0.3, 0.5, 0.8, 1.0); // 亮部颜色

// 【噪声与流动】
uniform sampler2D noise_texture : filter_linear_mipmap, repeat_enable;

// 【修改点】我们现在只需要一层噪声，且速度极慢
uniform vec2 scroll_speed = vec2(0.005, 0.002); // 极其缓慢的速度，创造“似动非动”的感觉
uniform float scale = 800.0; // 使用一个较大的尺寸，让形状更大、更舒展

// 【艺术风格控制器】
uniform float color_threshold : hint_range(0.0, 1.0) = 0.5; // 色阶分界线
uniform float edge_softness : hint_range(0.0, 0.1) = 0.01;   // 边缘的硬度


// --- Varying & Vertex Shader (保持不变) ---
varying vec2 world_coord;
void vertex() {
    world_coord = VERTEX;
}


// --- 片段着色器 (Fragment Shader) ---
void fragment() {
    // === 1. 制作一层、缓慢滚动的噪声 ===
    // 【修改点】逻辑大幅简化，只保留一层噪声
    vec2 world_uv = world_coord / scale;
    vec2 scrolling_uv = world_uv + TIME * scroll_speed;
    float noise = texture(noise_texture, scrolling_uv).r;
    
    // === 2. “画”出宁静的、两色的水体底色 ===
    // 【修改点】我们不再有单独的波纹，整个水面就是一幅由两种颜色构成的“画”
    // a. 用 smoothstep 将平滑的 noise 分割成 0 或 1 的硬边色块
    float shape = smoothstep(color_threshold, color_threshold + edge_softness, noise);
    
    // b. 根据这个形状，在暗色和亮色之间进行选择
    vec3 final_color = mix(water_dark_color.rgb, water_light_color.rgb, shape);
    
    COLOR = vec4(final_color, 1.0);
}