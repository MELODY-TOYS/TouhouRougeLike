# res://scripts/enemies/enemy_stats_component.gd
# (或者 res://scripts/components/stats_component.gd，以你的文件路径为准)
class_name EnemyStatsComponent
extends BaseStatsComponent # <-- 修改 #1: 继承基类，融入ASC系统

signal health_changed(current_health, max_health)

# --- 数据链接 ---
# 我们继续使用你已经定义好的EnemyStats资源
@export var stats_data: EnemyStats 

# --- 运行时状态 ---
var current_health: float
var move_speed:float
var damage:float

# --- Godot 生命周期函数 ---
func _ready() -> void:
	# 检查是否忘记在编辑器里拖入属性表
	if not stats_data:
		push_error("EnemyStatsComponent has no stats_data resource assigned!")
		return
	
	# 用“属性表”上的数据来初始化当前状态
	current_health = stats_data.max_health
	move_speed=stats_data.move_speed
	damage=stats_data.damage
# --- 核心接口实现 ---
# 修改 #2: 我们实现process_damage，而不是take_damage
func process_damage(attacker: Node, physical_source: Node, base_damage: float) -> void:
	if current_health <= 0: return

	# 这里的减伤逻辑暂时简化，未来可以从stats_data里读取护甲
	var final_damage = base_damage
	
	current_health = max(0, current_health - final_damage)
	
	health_changed.emit(current_health, stats_data.max_health)
	print("%s 受到了来自 '%s' 的 %s 点最终伤害！" % [get_parent().name, attacker.name, final_damage])

	if current_health == 0:
		died.emit(attacker)

# 修改 #3: 我们实现get_attribute_value，以符合基类接口
func get_attribute_value(attribute_name: StringName) -> float:
	# 我们直接从stats_data资源中安全地获取值
	if stats_data and stats_data.has(attribute_name):
		return stats_data.get(attribute_name)

	push_warning("Attempted to get attribute '%s' from '%s', but it was not found." % [attribute_name, get_parent().name])
	return 0.0
