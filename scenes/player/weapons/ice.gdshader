shader_type canvas_item;

// --- 流动效果的 Uniforms ---
uniform sampler2D noise_texture : source_color;
uniform float scroll_speed : hint_range(0.0, 1.0) = 0.1;
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.01;

// --- 【新增】辉光效果的 Uniforms ---
uniform vec4 glow_color : source_color = vec4(0.5, 0.9, 1.0, 1.0); // 辉光颜色 (默认淡青色)
uniform float glow_brightness_threshold : hint_range(0.0, 1.0) = 0.9; // 亮度阈值，超过这个值才发光
uniform float glow_speed : hint_range(0.0, 10.0) = 5.0; // 辉光闪烁速度
uniform float glow_intensity : hint_range(0.0, 2.0) = 0.5; // 辉光强度

void fragment() {
	// =============================================================
	// Part 1: 流动的内部寒气 (我们已经完成的部分)
	// =============================================================
	float scrolling_x = fract(UV.x + TIME * scroll_speed);
	vec2 scrolling_uv = vec2(scrolling_x, UV.y);
	
	float noise_value = texture(noise_texture, scrolling_uv).r;
	noise_value = (noise_value - 0.5) * 2.0;
	
	vec2 distorted_uv = UV;
	distorted_uv.y += noise_value * distortion_strength;
	
	// 从现在开始，我们用 base_color 来存储冰刺的基础颜色
	vec4 base_color = texture(TEXTURE, distorted_uv);
	
	// =============================================================
	// Part 2: 【新增】闪烁的晶体高光
	// =============================================================
	
	// 1. 计算基础颜色的亮度
	//    dot(vec, vec3(0.299, 0.587, 0.114)) 是一种更精确的亮度计算方法
	float brightness = dot(base_color.rgb, vec3(0.299, 0.587, 0.114));
	
	// 2. 创建一个在 0.0 到 1.0 之间平滑变化的脉冲值
	float pulse = (sin(TIME * glow_speed) + 1.0) / 2.0;
	
	// 3. 判断当前像素是否为高光
	//    step(edge, x) 函数：如果 x < edge, 返回 0.0; 否则返回 1.0
	//    这会创建一个非黑即白的“高光遮罩 (highlight_mask)”
	float highlight_mask = step(glow_brightness_threshold, brightness);
	
	// 4. 计算最终的辉光颜色
	//    辉光颜色 * 脉冲强度 * 高光遮罩
	//    只有在高光区域 (mask=1.0)，辉光才会被计算
	vec3 final_glow = glow_color.rgb * pulse * glow_intensity * highlight_mask;
	
	// =============================================================
	// Final Output: 最终颜色 = 基础颜色 + 辉光
	// =============================================================
	
	// 我们只把辉光加到颜色上 (rgb)，保持原始的 alpha 透明度
	COLOR.rgb = base_color.rgb + final_glow;
	COLOR.a = base_color.a;
}