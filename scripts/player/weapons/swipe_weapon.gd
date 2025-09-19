class_name SwipeWeapon
extends BaseWeaponInstance

@export_group("Swipe Behavior")
@export var swipe_angle_degrees: float = 120.0
@export var swipe_radius: float = 75.0 # 这是刀光弧线本身的半径
const SWIPE_ANIMATION_RATIO = 0.5 

# --- 内部状态 ---
var hit_list: Array = []
var active_tween: Tween

# --- Godot 生命周期 ---
func _ready():
	super()
	var hitbox = get_node_or_null("%Hitbox")
	if hitbox and hitbox is Area2D:
		hitbox.body_entered.connect(_on_hitbox_body_entered)
	else:
		push_error("错误：SwipeWeapon需要一个名为'Hitbox'的Area2D子节点。")

# --- 核心攻击实现 ---
func _execute_attack():
	if not is_instance_valid(current_target):
		is_attacking = false; return

	is_attacking = true
	_execute_swipe_animation(current_target)

func _execute_swipe_animation(target: Node2D):
	if active_tween and active_tween.is_running():
		active_tween.kill()

	var animation_duration = attack_timer.wait_time * SWIPE_ANIMATION_RATIO
	
	%Hitbox.monitoring = true
	hit_list.clear()

	# --- [核心] Brotato式挥砍的最终算法 ---
	
	# 1. 保存轨道位置，这是我们最终要“回家”的地方。
	var original_position = self.position

	# 2. 计算几何关系
	#    我们需要的是相对于玩家(WeaponManager)的本地坐标
	var target_local_position = get_parent().to_local(target.global_position)
	var target_distance = target_local_position.length()
	var direction_to_target = target_local_position.normalized()

	# 3. 计算“挥砍圆心”(Pivot Point)的本地位置
	#    这个圆心在玩家和敌人之间，距离敌人为swipe_radius
	var pivot_distance_from_player = target_distance - swipe_radius
	var pivot_point = direction_to_target * pivot_distance_from_player

	# 4. 计算挥砍的起始和结束角度（相对于新的圆心 pivot_point）
	#    挥砍的中心线，应该垂直于从玩家到敌人的方向线
	var angle_rad = deg_to_rad(swipe_angle_degrees)
	var center_angle = direction_to_target.angle()
	var start_angle = center_angle - (PI / 2.0) - (angle_rad / 2.0)
	var end_angle = center_angle - (PI / 2.0) + (angle_rad / 2.0)
	
	# 5. 武器“瞬移”到挥砍的起点
	var start_position_offset = Vector2.RIGHT.rotated(start_angle) * swipe_radius
	self.position = pivot_point + start_position_offset

	# 6. 创建Tween，并委托它调用我们的自定义更新函数
	active_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	active_tween.tween_method(
		_update_swipe_arc.bind(pivot_point, start_angle, end_angle, swipe_radius), 
		0.0, 
		1.0, 
		animation_duration
	)
	
	# 7. 动画结束后，回到轨道位置
	active_tween.tween_callback(func(): self.position = original_position)

	await active_tween.finished
	%Hitbox.monitoring = false
	is_attacking = false

# --- 自定义的弧线更新函数 ---
func _update_swipe_arc(progress: float, pivot: Vector2, start_ang: float, end_ang: float, rad: float):
	var current_angle = lerp(start_ang, end_ang, progress)
	
	var offset_position = Vector2.RIGHT.rotated(current_angle) * rad
	self.position = pivot + offset_position
	
	self.rotation = current_angle + PI / 2.0

func _on_hitbox_body_entered(body: Node2D):
	if not body.is_in_group("enemy") or hit_list.has(body):
		return
	hit_list.append(body)
	var target_stats = ASC.get_stats_component_from(body)
	if target_stats and weapon_data:
		var base_damage = weapon_data.damage_formula.base_value
		target_stats.process_damage(Global.player, self, base_damage)
