# res://scripts/player/weapons/swipe_weapon.gd
class_name SwipeWeapon
extends MeleeWeaponInstance # <--- 继承自新的 MeleeWeaponInstance

@export_group("Swipe Behavior")
@export var swipe_angle_degrees: float = 120.0
@export var swipe_radius: float = 75.0
const SWIPE_ANIMATION_RATIO = 0.5 

# --- 内部状态 ---
var active_tween: Tween

# _ready() 函数已被移除，因为它的逻辑已移至 MeleeWeaponInstance
# var hit_list 已被移除，因为它现在由父类 MeleeWeaponInstance 提供

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
	hit_list.clear() # <--- hit_list 依然在这里清空，因为只有这里知道攻击何时开始

	# ... 挥砍动画的核心算法保持不变 ...
	var original_position = self.position
	var target_local_position = get_parent().to_local(target.global_position)
	var target_distance = target_local_position.length()
	var direction_to_target = target_local_position.normalized()
	var pivot_distance_from_player = target_distance - swipe_radius
	var pivot_point = direction_to_target * pivot_distance_from_player
	var angle_rad = deg_to_rad(swipe_angle_degrees)
	var center_angle = direction_to_target.angle()
	var start_angle = center_angle - (PI / 2.0) - (angle_rad / 2.0)
	var end_angle = center_angle - (PI / 2.0) + (angle_rad / 2.0)
	var start_position_offset = Vector2.RIGHT.rotated(start_angle) * swipe_radius
	self.position = pivot_point + start_position_offset

	active_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	active_tween.tween_method(
		_update_swipe_arc.bind(pivot_point, start_angle, end_angle, swipe_radius), 
		0.0, 
		1.0, 
		animation_duration
	)
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

# _on_hitbox_body_entered(body) 函数已被移除，因为它的逻辑已移至 MeleeWeaponInstance
