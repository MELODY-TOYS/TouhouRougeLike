# res://scripts/resources/rewards/weapon_reward_data.gd
@tool
class_name WeaponRewardData
extends RewardData

# ============================================================================
# -- 武器独有的核心数据 --
# ============================================================================
@export_group("武器配置")

# 武器的核心：它要实例化哪个场景？
# 这是这个类最重要的、独有的数据。
@export var weapon_scene: PackedScene

# 武器的标签。这些标签将用于未来的“套装奖励”系统。
# 同时，我们也可以按您之前的想法，用它来自动生成UI上的类型文本。
@export var tags: Array[String] = []


# ============================================================================
# -- 效果逻辑实现 --
# ============================================================================
#
## 实现(override)基类定义的“应用效果”函数
## 它的职责是告诉玩家的 WeaponManager，去添加这把武器。
#func apply_effect() -> void:
	## 1. 安全地获取玩家身上的 WeaponManager 节点
	#var weapon_manager = target_player.get_node_or_null("WeaponManager")
	#
	## 2. 健壮性检查
	#if not is_instance_valid(weapon_manager):
		#push_error("在玩家 %s 上未找到 WeaponManager 节点！无法添加武器。" % target_player.name)
		#return
	#
	#if not weapon_scene:
		#push_error("WeaponRewardData (%s) 没有配置 weapon_scene！" % self.resource_path)
		#return
		#
	## 3. 调用 WeaponManager 的公共接口来添加武器
	#weapon_manager.add_weapon(weapon_scene)
	#
	#print("应用武器奖励: 添加了 %s" % display_name)


# ============================================================================
# -- (可选但推荐) 编辑器辅助功能 --
# ============================================================================

# 当在编辑器里修改 weapon_scene 时，可以尝试自动填充一些基础信息
func _set(property, value):
	if property == "weapon_scene":
		weapon_scene = value
		# 检查 weapon_scene 是否有效，并且我们是否在编辑器里
		if is_instance_valid(weapon_scene) and Engine.is_editor_hint():
			_autofill_from_scene()
	return true # 表示我们处理了这个属性的设置

func _autofill_from_scene():
	# 这是一个辅助函数，可以尝试从 weapon_scene 中获取信息
	# 比如，如果武器场景的根节点脚本里有一个 `default_name` 变量，
	# 我们可以读取它来自动填充 display_name，提升策划的配置效率。
	# 这是一个高级技巧，可以先留空，但展示了@tool脚本的强大之处。
	
	# 例如，我们至少可以根据文件名来猜测一个名字
	if display_name == "" or display_name == "未命名奖励":
		# 从路径中提取文件名，例如 "res://.../shotgun.tscn" -> "shotgun"
		var file_name = weapon_scene.resource_path.get_file().get_basename()
		# 将其转换为更易读的标题格式，例如 "shotgun" -> "Shotgun"
		display_name = file_name.capitalize()
		print("已根据场景文件名自动填充名称: ", display_name)
