# res://scripts/player/weapons/base_weapon_instance.gd
class_name BaseWeaponInstance
extends Node2D

# --- 核心数据与组件 ---
var weapon_data: WeaponResource
var attack_timer: Timer

# --- 通用状态 ---
var current_target: Node2D = null
var can_attack: bool = true
var is_attacking: bool = false # 状态锁，防止在攻击动画期间进行新的索敌和旋转

# --- Godot 生命周期 ---
func _ready():
	_load_data()
	_initialize_timer()

func _physics_process(_delta: float):
	# 只有在不攻击时，才更新目标和朝向
	if not is_attacking:
		current_target = _find_nearest_enemy()
		if is_instance_valid(current_target):
			look_at(current_target.global_position)

	# 冷却结束，尝试攻击
	if can_attack:
		_try_execute_attack()

# --- 内部核心函数 ---
func _load_data():
	var tscn_path = scene_file_path
	if tscn_path.is_empty():
		push_error("武器实例 '%s' 不是一个独立的场景，无法自动加载数据。" % name)
		return

	var data_path = tscn_path.replace("scenes/player/weapons/", "datas/weapons/").replace(".tscn", ".tres")

	var loaded_data = load(data_path)
	if loaded_data is WeaponResource:
		weapon_data = loaded_data
	else:
		push_error("在路径 '%s' 未找到或类型不匹配的WeaponResource。" % data_path)

func _initialize_timer():
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	add_child(attack_timer)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	_reset_attack_cooldown() # 第一次启动计时器

func _on_attack_timer_timeout():
	can_attack = true

func _try_execute_attack():
	# --- 核心修改在这里 ---
	# 1. 检查是否有有效目标。
	#    current_target 是由 _physics_process 中的 _find_nearest_enemy 实时更新的。
	if not is_instance_valid(current_target):
		# 如果没有目标，则不执行任何操作，也不进入冷却。
		# 武器会保持“待命”状态，在下一帧继续寻找目标。
		return

	# 2. 如果有目标，才执行攻击流程。
	can_attack = false
	_reset_attack_cooldown() # 进入冷却
	_execute_attack()      # 执行具体攻击

func _reset_attack_cooldown():
	var player_stats = ASC.get_stats_component_from(Global.player)
	var final_cooldown = weapon_data.base_cooldown if weapon_data else 1.0
	if player_stats:
		var attack_speed_percent = player_stats.get_stat(Attributes.Stat.ATTACK_SPEED)
		if attack_speed_percent > -100:
			final_cooldown /= (1.0 + attack_speed_percent / 100.0)
	
	attack_timer.wait_time = final_cooldown
	attack_timer.start()

func _find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var nearest_enemy = null
	if not weapon_data: return null
	
	var search_range_sq = weapon_data.attack_range * weapon_data.attack_range
	var min_dist_sq = search_range_sq

	for enemy in enemies:
		var dist_sq = global_position.distance_squared_to(enemy.global_position)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			nearest_enemy = enemy
	
	return nearest_enemy
	
# --- 待子类覆写的“抽象”方法 ---
func _execute_attack():
	push_error("方法 _execute_attack() 必须被子类实现！")
