# res://scripts/components/hurtbox_component.gd
class_name HurtboxComponent
extends Area2D

# --- 配置 ---
# damage_interval: 触发伤害事件的频率（秒）。
@export var damage_interval: float = 1.0
# target_groups:  一个字符串数组，定义了该Hurtbox会对其造成伤害的目标分组。
#                 这提供了一个游戏逻辑层面的过滤器，即便物理层已经通过Mask进行了预过滤。
@export var target_groups: Array[String] = ["player"]
@export var damage_formula: DamageFormula


# --- 内部状态 ---
# owner_node:     对该组件拥有者（即攻击方）的引用，在_ready时自动获取。
var owner_node: Node
# targets_in_range: 一个字典，用于追踪当前在范围内的目标及其专属的伤害计时器。
#                   键是目标节点(Node2D)，值是对应的Timer节点。
var targets_in_range: Dictionary = {}


func _ready() -> void:
	owner_node = get_parent()
	# 健壮性检查：确保该组件被正确地附加到一个父节点下。
	if not is_instance_valid(owner_node):
		push_error("HurtboxComponent requires a parent node to function as its owner.")
		set_physics_process(false) # 禁用自身以防止运行时错误。
		return

	# 手动连接信号，将所有逻辑都保留在脚本内部，增强代码的自包含性。
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


# 当一个物理实体进入范围时调用。
func _on_body_entered(body: Node2D) -> void:
	# 通过is_target_valid辅助函数进行验证，避免代码重复。
	if not _is_target_valid(body) or targets_in_range.has(body):
		return
	# 为每一个进入的目标动态创建一个专属的Timer，以独立处理伤害间隔。
	var timer = Timer.new()
	
	timer.wait_time = damage_interval
	timer.autostart = true
	add_child(timer) # Timer必须被添加到场景树才能开始计时。
	print("DEBUG: Timer added to scene tree. Is inside tree? ", timer.is_inside_tree()) # <-- 增加打印2

	# 使用.bind()将当前目标(body)作为参数传递给回调函数。
	# 这使得_on_damage_tick能够准确地知道是哪个目标的计时器到期了。
	timer.timeout.connect(_on_damage_tick.bind(body))

	# 记录目标和它的专属计时器，用于后续的管理（如离开时销毁）。
	targets_in_range[body] = timer
	
	# 立即触发第一次伤害，以提供即时的玩家反馈。
	_on_damage_tick(body)


# 当一个物理实体离开范围时调用。
func _on_body_exited(body: Node2D) -> void:
	# 确认离开的实体是我们正在追踪的目标。
	if not targets_in_range.has(body):
		return
			
	# 从字典中获取并安全地销毁对应的计时器，防止内存泄漏和逻辑错误。
	var timer_to_remove = targets_in_range[body]
	timer_to_remove.queue_free()
	
	# 将目标从追踪字典中移除。
	targets_in_range.erase(body)


func _on_damage_tick(body: Node2D) -> void:
	
	# --- DEBUG 探针 #1: 函数入口 ---
	# 确认函数被成功调用，以及目标(body)是谁。
	print("--- DAMAGE TICK START ---")
	print("Tick Target: ", body)

	# 1. 健壮性检查：确保目标在场景中依然有效。
	if not is_instance_valid(body):
		print("DEBUG: Target is no longer valid. Cleaning up timer.")
		_on_body_exited(body)
		return
		
	# 2. 获取目标的“处理部门” (StatsComponent)
	print("DEBUG: Attempting to get stats from target: ", body.name)
	var target_stats = ASC.get_stats_component_from(body)
	
	# --- DEBUG 探针 #2: 目标StatsComponent获取结果 ---
	if not target_stats:
		# 如果获取失败，打印错误并退出，这是关键的调试信息。
		print(">> ERROR: Failed to get StatsComponent from target '%s'. Aborting damage tick." % body.name)
		return
	else:
		print(">> SUCCESS: Found target_s StatsComponent: ", target_stats)

	# 3. 获取攻击方的“后勤部门” (StatsComponent)
	print("DEBUG: Attempting to get stats from owner: ", owner_node.name)
	var attacker_stats = ASC.get_stats_component_from(owner_node)

	# --- DEBUG 探针 #3: 攻击方StatsComponent获取结果 ---
	if not attacker_stats:
		print(">> ERROR: Failed to get StatsComponent from owner '%s'. Aborting damage tick." % owner_node.name)
		return
	else:
		print(">> SUCCESS: Found attacker_s StatsComponent: ", attacker_stats)
	
	# 4. 准备所有需要传递的参数
	var attacker = owner_node
	var physical_source = self
	
	# a. 从攻击方的StatsComponent获取基础伤害值
	print("DEBUG: Getting 'damage' attribute from attacker_s stats...")
	var base_damage = attacker_stats.get_attribute_value(&"damage")

	# --- DEBUG 探针 #4: 伤害值获取结果 ---
	print(">> INFO: Calculated base_damage: ", base_damage)

	# 5. 直接调用目标的process_damage函数，传递所有参数
	print("DEBUG: Calling process_damage on target_stats...")
	target_stats.process_damage(attacker, physical_source, base_damage)
	print("--- DAMAGE TICK END ---")
	

# 辅助函数，用于检查一个节点是否属于我们定义的目标分组之一。
func _is_target_valid(body: Node2D) -> bool:
	# --- 结束Debug打印 ---

	for group in target_groups:
		if body.is_in_group(group):
			print("DEBUG: Match found! Body is in group: ", group) # <-- 成功的打印
			return true
	
	print("DEBUG: No match found. Target is not valid.") # <-- 失败的打印
	return false
