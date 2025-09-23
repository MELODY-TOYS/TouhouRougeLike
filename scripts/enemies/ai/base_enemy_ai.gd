# res://scripts/enemies/base_enemy_ai.gd
# 这是所有敌人AI脚本的通用基类。
# 它只提供所有AI共享的属性和核心功能，而不强制规定任何具体行为。

class_name BaseEnemyAI
extends CharacterBody2D

const POWER_ITEM_SCENE = preload("res://scenes/loots/power_item.tscn")
# --- 节点引用 ---
@onready var stats: EnemyStatsComponent = $StatsComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var view: Node2D = $View

# --- 核心变量 ---
# 我们提供一个通用的状态变量，但它的具体含义由子类通过自己的enum来定义。
# 我们用一个整数来存储它，以便子类的任何enum都可以赋值给它。
var current_state
var target: Node2D = null

# --- Godot 生命周期函数 ---
func _ready() -> void:
	# 健壮性检查
	if not stats:
		push_error("BaseEnemyAI requires an EnemyStatsComponent.")
		set_physics_process(false) # 彻底禁用物理进程以防万一
		return
			
	# 连接通用信号
	stats.died.connect(_on_died)

# --- 公共接口 ---
func set_target(new_target: Node2D) -> void:
	target = new_target

# (可选但推荐) 提供一个统一的状态切换接口，方便未来添加状态切换时的通用逻辑（如播放音效）
func change_state(new_state: int) -> void:
	# 可以在这里添加所有状态切换时都需要的通用代码
	# print("Changing state from %s to %s" % [current_state, new_state])
	current_state = new_state

# --- 信号处理 ---
func _on_died() -> void:
	print("死了")
	# 死亡逻辑不再是一种状态，而是一个确定的事件
	# 这样更简洁，因为死亡后不会再有其他状态了
	if is_processing(): # 检查节点是否还在处理中
		set_physics_process(false) # 立即停止所有AI逻辑
	
	velocity = Vector2.ZERO
	move_and_slide()
	
	# 未来：animation_player.play("death")
	#       await animation_player.animation_finished
	_drop_loot(1)
	queue_free()
	
	
	# --- 新增的掉落物处理函数 ---
# 负责处理所有战利品的生成逻辑。
# 未来可以轻松扩展，例如接收一个掉落物列表作为参数。
func _drop_loot(quantity: int = 1) -> void:
	# 健壮性检查：确保我们的P点场景已正确加载
	if not POWER_ITEM_SCENE:
		push_warning("掉落物场景 POWER_ITEM_SCENE 未设置！")
		return

	# 为了让掉落物散开一点，而不是完全重叠，我们定义一个小的散布半径
	var drop_scatter_radius: float = 20.0

	# 根据传入的数量，循环生成掉落物
	for i in range(quantity):
		# 1. 实例化场景
		var loot_instance = POWER_ITEM_SCENE.instantiate()
		
		# 2. 添加到场景树
		get_parent().call_deferred("add_child", loot_instance)
		
		# 3. 计算一个随机的偏移位置，让掉落物看起来更自然
		var offset = Vector2(
			randf_range(-drop_scatter_radius, drop_scatter_radius),
			randf_range(-drop_scatter_radius, drop_scatter_radius)
		)
		
		# 4. 设置最终位置
		loot_instance.global_position = self.global_position + offset
