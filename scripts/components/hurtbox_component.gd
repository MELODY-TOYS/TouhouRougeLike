# res://scripts/components/hurtbox_component.gd
class_name HurtboxComponent
extends Area2D

# -------------------- 配置 --------------------

# 持续性伤害的触发间隔（秒）。
@export var damage_interval: float = 1.0

# 定义此伤害区域会影响的目标分组。
@export var target_groups: Array[String] = ["player"]

# [可选扩展] 未来可以链接一个伤害公式资源，以实现更复杂的伤害计算。
# @export var damage_formula: DamageFormula

# -------------------- 内部状态 --------------------

# 对该组件拥有者（即攻击方）的引用。
var owner_node: Node

# 追踪当前范围内的目标及其专属的伤害计时器。
var targets_in_range: Dictionary = {}


# -------------------- Godot 生命周期 --------------------

func _ready() -> void:
	owner_node = get_parent()
	if not is_instance_valid(owner_node):
		push_error("HurtboxComponent 必须有一个父节点作为其拥有者。")
		set_physics_process(false)
		return

	# 连接信号，保持组件的自包含性。
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


# -------------------- 信号回调 --------------------

# 当一个物理实体进入范围时调用。
func _on_body_entered(body: Node2D) -> void:
	if not _is_target_valid(body) or targets_in_range.has(body):
		return

	# 为每个目标动态创建专属的Timer，以独立处理伤害间隔。
	var timer = Timer.new()
	timer.wait_time = damage_interval
	timer.autostart = true
	add_child(timer)

	# 使用.bind()将目标(body)传递给回调函数，以精确识别是哪个目标的计时器到期。
	timer.timeout.connect(_on_damage_tick.bind(body))

	targets_in_range[body] = timer
	
	# 为了提供即时反馈，立即触发第一次伤害。
	_on_damage_tick(body)


# 当一个物理实体离开范围时调用。
func _on_body_exited(body: Node2D) -> void:
	if not targets_in_range.has(body):
		return
			
	# 安全地销毁对应的计时器，防止内存泄漏。
	var timer_to_remove = targets_in_range[body]
	timer_to_remove.queue_free()
	
	targets_in_range.erase(body)


# 伤害计时器到期时调用，负责执行单次伤害逻辑。
func _on_damage_tick(body: Node2D) -> void:
	# 健壮性检查：在造成伤害前，再次确认所有参与方是否依然有效。
	if not is_instance_valid(body):
		_on_body_exited(body) # 如果目标失效，执行清理逻辑
		return
		
	var target_stats = ASC.get_stats_component_from(body)
	var attacker_stats = ASC.get_stats_component_from(owner_node)

	if not target_stats or not attacker_stats:
		# 如果任何一方没有属性组件，则无法继续伤害流程。
		return
	
	# 从攻击方的属性中获取基础伤害值。
	# 我们假设碰撞伤害属于 MELEE_DAMAGE 类别。
	var base_damage = attacker_stats.get_stat(Attributes.Stat.MELEE_DAMAGE)

	# 将伤害事件派发给目标，由目标自己处理最终的减伤和状态变化。
	target_stats.process_damage(owner_node, self, base_damage)
	
# -------------------- 辅助函数 --------------------

# 检查一个节点是否属于我们定义的目标分组之一。
func _is_target_valid(body: Node2D) -> bool:
	for group in target_groups:
		if body.is_in_group(group):
			return true
	return false
