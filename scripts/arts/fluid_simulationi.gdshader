// fluid_simulation_test.gdshader
shader_type canvas_item;

// 用来接收从 GDScript 传来的交互数据
uniform vec2 impulse_position = vec2(-1.0, -1.0); // 默认在屏幕外，避免显示
uniform float impulse_radius = 0.1;
uniform float impulse_strength = 0.0;

// 我们需要上一帧的结果来进行累积绘制
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // 获取上一帧该像素的颜色
    vec4 last_frame_color = texture(SCREEN_TEXTURE, SCREEN_UV);

    // 计算当前像素到冲击点的距离
    float dist = distance(UV, impulse_position);
    
    // 如果在冲击半径内，就画一个白色的圆
    if (dist < impulse_radius) {
        // 使用mix函数平滑地混合一个白色圆圈
        // strength > 0 会变亮，< 0 会变暗
        float circle = smoothstep(impulse_radius, impulse_radius - 0.01, dist);
        COLOR = mix(last_frame_color, vec4(1.0), circle * impulse_strength);
    } else {
        // 如果不在冲击范围内，就保持上一帧的颜色
        COLOR = last_frame_color;
    }
}