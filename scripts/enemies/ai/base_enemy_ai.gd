# res://scripts/enemies/base_enemy_ai.gd
# 这是所有敌人AI脚本的通用基类。
# 它只提供所有AI共享的属性和核心功能，而不强制规定任何具体行为。

class_name BaseEnemyAI
extends CharacterBody2D

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
	# 死亡逻辑不再是一种状态，而是一个确定的事件
	# 这样更简洁，因为死亡后不会再有其他状态了
	if is_processing(): # 检查节点是否还在处理中
		set_physics_process(false) # 立即停止所有AI逻辑
	
	velocity = Vector2.ZERO
	move_and_slide()
	
	# 未来：animation_player.play("death")
	#       await animation_player.animation_finished
	
	queue_free()
	
	
	
