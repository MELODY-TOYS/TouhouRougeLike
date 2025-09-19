# res://scripts/player/weapons/weapon_manager.gd
class_name WeaponManager
extends Node

# --- 配置 ---
# 武器环绕玩家的半径。@export使其可以在编辑器中被方便地调整。
@export var orbit_radius: float = 60.0

# --- Godot 生命周期 ---

func _ready():
	# 连接Godot的内置信号 child_order_changed。
	# 每当有子节点被添加(add_child)或移除(remove_child)时，
	# 这个信号就会自动发出，并调用我们的 _update_weapon_positions 函数。
	# 这是一种非常高效和自动化的方式来管理布局。
	child_order_changed.connect(_update_weapon_positions)

# --- 公共接口 ---

# 添加一把新武器。
func add_weapon(weapon_scene_path: String):
	var weapon_scene = load(weapon_scene_path)
	if not weapon_scene:
		push_error("无法加载武器场景: " + weapon_scene_path)
		return

	var new_weapon_instance = weapon_scene.instantiate()
	add_child(new_weapon_instance)
	# 注意：我们不需要在这里手动调用更新函数。
	# add_child() 会自动触发 child_order_changed 信号，从而调用更新函数。

# --- 核心布局逻辑 ---

# 重新计算并应用所有武器实例的位置，使它们均匀地环绕成一个圆形。
func _update_weapon_positions():
	var weapon_count = get_child_count()
	if weapon_count == 0:
		return

	# TAU 是 Godot 内置的常量，代表 2 * PI，即一个完整的圆周 (360度)。
	# 计算每把武器之间应该相隔多少弧度。
	var angle_step = TAU / weapon_count

	# 遍历当前所有的武器实例（它们都是WeaponManager的子节点）。
	for i in range(weapon_count):
		var weapon = get_child(i)
		
		# 计算当前武器应该处于的精确角度。
		var angle = i * angle_step
		
		# 使用三角函数的核心：
		# 创建一个基础向量 (orbit_radius, 0)，它指向正右方。
		# 然后将这个向量旋转我们计算出的角度，得到在圆周上的最终位置。
		var new_position = Vector2.RIGHT.rotated(angle) * orbit_radius
		
		# 将计算出的新位置应用给武器实例。
		if weapon is Node2D: # 安全检查
			weapon.position = new_position
