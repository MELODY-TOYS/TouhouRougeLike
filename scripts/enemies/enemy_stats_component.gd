# res://scripts/enemies/enemy_stats_component.gd
class_name EnemyStatsComponent
extends BaseStatsComponent

# 覆写基类定义的“伤害处理”接口
func process_damage(_attacker: Node, _physical_source: Node, base_damage: float) -> void:
	var health = get_stat(Attributes.Stat.HEALTH)
	if health <= 0:
		return

	var max_health = get_stat(Attributes.Stat.MAX_HEALTH)
	
	# --- 敌人相对简单的伤害计算逻辑 ---
	# 敌人暂时没有复杂的减伤，直接受到基础伤害
	var final_damage = base_damage
	
	# 应用最终伤害
	health = max(0.0, health - final_damage)
	set_stat(Attributes.Stat.HEALTH, health)
	
	# 广播状态变化
	stats_changed.emit()

	# 检查死亡
	if health == 0.0:
		died.emit()
