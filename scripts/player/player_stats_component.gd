# res://scripts/player/player_stats_component.gd
class_name PlayerStatsComponent
extends BaseStatsComponent

# 覆写基类定义的“伤害处理”接口
func process_damage(attacker: Node, physical_source: Node, base_damage: float) -> void:
	var health = get_stat(Attributes.Stat.HEALTH)
	if health <= 0:
		return # 如果已经死亡，不再处理伤害

	var max_health = get_stat(Attributes.Stat.MAX_HEALTH)
	
	# --- 玩家独有的、复杂的伤害减免逻辑 ---
	# 1. 计算护甲减伤
	var armor = get_stat(Attributes.Stat.ARMOR)
	var final_damage = max(1.0, base_damage - armor) # 保证至少造成1点伤害
	
	# [未来扩展] 2. 计算闪避
	# var dodge_chance = get_stat(Attributes.Stat.DODGE_CHANCE)
	# if randf() < dodge_chance / 100.0:
	#     # 播放闪避特效/音效
	#     return # 闪避成功，提前结束函数
	
	# 应用最终伤害
	health = max(0.0, health - final_damage)
	set_stat(Attributes.Stat.HEALTH, health)
	
	# 广播状态变化
	health_updated.emit(health, max_health)

	# 检查死亡
	if health == 0.0:
		died.emit(attacker)
