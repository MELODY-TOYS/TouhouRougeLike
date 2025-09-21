# res://scripts/player/weapons/thrust_weapon.gd
class_name ThrustWeapon
extends MeleeWeaponInstance # <--- 继承自新的 MeleeWeaponInstance

# --- 行为定义 ---
const THRUST_ANIMATION_RATIO = 0.4 

# _ready() 函数已被移除，因为它的逻辑已移至 MeleeWeaponInstance
# var hit_list 已被移除，因为它现在由父类 MeleeWeaponInstance 提供

# --- 核心攻击实现 ---
func _execute_attack():
	if not is_instance_valid(current_target):
		is_attacking = false
		return

	is_attacking = true
	_execute_thrust_animation(current_target)

func _execute_thrust_animation(target: Node2D):
	var animation_duration = attack_timer.wait_time * THRUST_ANIMATION_RATIO
	var thrust_duration = animation_duration / 2.0

	var original_position = self.position

	%Hitbox.monitoring = true
	hit_list.clear() # <--- hit_list 依然在这里清空

	var direction = Vector2.RIGHT.rotated(rotation)
	var thrust_distance = weapon_data.range
	var target_position = original_position + direction * thrust_distance

	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_position, thrust_duration)
	tween.tween_property(self, "position", original_position, thrust_duration)

	await tween.finished
	%Hitbox.monitoring = false
	is_attacking = false

# _on_hitbox_body_entered(body) 函数已被移除，因为它的逻辑已移至 MeleeWeaponInstance
