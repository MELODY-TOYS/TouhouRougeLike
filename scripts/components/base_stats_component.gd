# res://scripts/components/base_stats_component.gd
class_name BaseStatsComponent
extends Node

# ... (信号和核心属性定义不变) ...
signal health_updated(current_health, max_health)
signal died(killer)
@export var stats_data: ActorStatsData

func _ready():
	if not stats_data:
		push_error("错误：'%s' 上的Stats组件未指定stats_data！" % get_parent().name)
		return
	
	stats_data = stats_data.duplicate()

	# --- 最直接的初始化逻辑 ---
	# 我们相信配表数据是完整的。直接广播初始状态。
	if stats_data.base_attributes.has(Attributes.Stat.MAX_HEALTH):
		var max_health = get_stat(Attributes.Stat.MAX_HEALTH)
		var current_health = get_stat(Attributes.Stat.HEALTH)
		
		health_updated.emit(current_health, max_health)

# ... (get_stat, set_stat, process_damage 方法完全不变) ...
func get_stat(stat_to_get: Attributes.Stat) -> float:
	return stats_data.base_attributes.get(stat_to_get, 0.0)

func set_stat(stat_to_set: Attributes.Stat, value: float):
	stats_data.base_attributes[stat_to_set] = value

func process_damage(attacker: Node, physical_source: Node, base_damage: float):
	push_error("错误：方法 process_damage() 必须被 '%s' 的子类实现！" % self.name)
