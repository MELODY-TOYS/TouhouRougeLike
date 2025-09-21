# res://scripts/player/weapons/projectile_weapon_instance.gd
class_name ProjectileWeaponInstance
extends BaseWeaponInstance # <--- 直接继承 BaseWeaponInstance

# --- 行为参数 (Behavior Parameters) ---
# 这些参数定义了“发射弹道”这种行为的具体方式，它们属于这个类，而不是 WeaponResource
@export_group("Projectile Behavior")
@export var projectile_speed: float = 700.0
@export var projectile_piercing: int = 0
@export var projectile_count: int = 1
@export var spread_angle_degrees: float = 0.0

# --- 核心攻击实现 ---
func _execute_attack():
	# 检查核心数据是否存在
	if not is_instance_valid(current_target) or not weapon_data or not weapon_data.attack_scene:
		return

	# "发射后不管" 的武器，攻击动画视为瞬时完成
	is_attacking = true

	# 1. 获取攻击方 (玩家) 的属性组件
	var player_stats = ASC.get_stats_component_from(Global.player)
	if not player_stats:
		push_error("错误: 无法在 Global.player 上找到属性组件！")
		is_attacking = false
		return

	# 2. [核心] 在开火瞬间，调用伤害公式计算出最终伤害
	var final_damage = 0.0
	if weapon_data.damage_formula:
		final_damage = weapon_data.damage_formula.calculate(player_stats)
	else:
		push_warning("警告: 武器 '%s' 没有配置伤害公式！" % weapon_data.id)

	var base_rotation = self.global_rotation
	var spread_rad = deg_to_rad(spread_angle_degrees)

	# 循环发射所有弹道
	for i in range(projectile_count):
		var projectile = weapon_data.attack_scene.instantiate() as BaseProjectile
		if not projectile:
			push_error("错误: '%s' 的 AttackScene 无法被实例化为 BaseProjectile。" % weapon_data.id)
			continue

		# 3. 计算每个弹道的发射角度
		var angle_offset = 0.0
		if projectile_count > 1:
			angle_offset = lerp(-spread_rad / 2.0, spread_rad / 2.0, float(i) / (projectile_count - 1))
		
		var final_rotation = base_rotation + angle_offset
		var start_transform = Transform2D(final_rotation, self.global_position)
		
		# 4. 配置弹道，将计算好的最终伤害 "烙印" 在子弹上
		projectile.setup(start_transform, final_damage, projectile_speed, projectile_piercing)

		# 5. 将弹道添加到场景树中
		get_tree().current_scene.add_child(projectile)
	
	is_attacking = false
