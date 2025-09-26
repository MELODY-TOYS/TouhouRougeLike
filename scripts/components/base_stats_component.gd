# res://scripts/components/base_stats_component.gd
class_name BaseStatsComponent
extends Node

# --- 信号 ---
# 通用信号，通知任何一个属性发生了变化
signal stats_changed
# 高频特化信号，用于处理死亡
@warning_ignore("unused_signal")
signal died()

# --- 资源引用 ---
@export var stats_data: ActorStatsData

# --- 公开的只读属性 ---
var current_health:
	get: return get_stat(Attributes.Stat.HEALTH)
var max_health:
	get: return get_stat(Attributes.Stat.MAX_HEALTH)
# 未来可为其他需要频繁访问的属性（如移速）添加类似的封装

func _ready():
	if not stats_data:
		push_error("错误：'%s' 上的Stats组件未指定stats_data！" % get_parent().name)
		return
	
	stats_data = stats_data.duplicate()
	
	# 初始化时发射一次信号，确保UI能获取到初始状态
	stats_changed.emit()


# --- 内部数据操作 ---
func get_stat(stat_to_get: Attributes.Stat) -> float:
	return stats_data.base_attributes.get(stat_to_get, 0.0)

func set_stat(stat_to_set: Attributes.Stat, value: float):
	# 优化：如果值没有变化，则不执行任何操作
	if get_stat(stat_to_set) == value:
		return
		
	stats_data.base_attributes[stat_to_set] = value
	stats_changed.emit() # 发射通用的、不带参数的信号

# --- 核心逻辑接口 ---
func process_damage(_attacker: Node, _physical_source: Node, _base_damage: float):
	push_error("错误：方法 process_damage() 必须被 '%s' 的子类实现！" % self.name)
