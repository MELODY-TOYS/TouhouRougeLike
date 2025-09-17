# res://scripts/components/base_stats_component.gd
class_name BaseStatsComponent
extends Node

# 信号可以放在基类，因为所有StatsComponent可能都需要广播它们的状态
signal health_updated(current_health, max_health)
signal died(killer)

# 行为接口：任何继承我的子类，都应该能响应该函数
func process_damage(attacker: Node, physical_source: Node, base_damage: float) -> void:
	# 基类中的实现可以为空，或者抛出一个错误，强制子类去实现它
	push_error("process_damage() must be implemented by the subclass!")
