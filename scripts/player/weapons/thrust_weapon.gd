# res://scripts/player/weapons/thrust_weapon.gd
class_name ThrustWeapon
extends BaseWeaponInstance

# --- 行为定义 ---
const THRUST_ANIMATION_RATIO = 0.4 

# --- 内部状态 ---
var hit_list: Array = []

# --- Godot 生命周期 ---
func _ready():
	super()
	# ... (连接Hitbox信号的逻辑不变) ...

# --- 核心攻击实现 ---
func _execute_attack():
	# 基类已经找到了目标，并上锁了is_attacking
	if not is_instance_valid(current_target):
		is_attacking = false # 没目标，直接解锁
		return

	_execute_thrust_animation(current_target)

func _execute_thrust_animation(target: Node2D):
	var animation_duration = attack_timer.wait_time * THRUST_ANIMATION_RATIO
	var thrust_duration = animation_duration / 2.0

	var original_position = self.position

	%Hitbox.monitoring = true
	hit_list.clear()

	# 攻击方向已经被基类在攻击前锁定
	var direction = Vector2.RIGHT.rotated(rotation)
	var thrust_distance = weapon_data.range
	var target_position = original_position + direction * thrust_distance

	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_position, thrust_duration)
	tween.tween_property(self, "position", original_position, thrust_duration)

	await tween.finished
	%Hitbox.monitoring = false
	is_attacking = false # 解锁

# --- 命中逻辑 ---
func _on_hitbox_body_entered(body: Node2D):
	# ... (命中逻辑与SwipeWeapon完全相同) ...
	if not body.is_in_group("enemy") or hit_list.has(body):
		return
	
	hit_list.append(body)

	var target_stats = ASC.get_stats_component_from(body)
	if target_stats and weapon_data:
		var base_damage = weapon_data.damage_formula.base_value
		target_stats.process_damage(Global.player, self, base_damage)
