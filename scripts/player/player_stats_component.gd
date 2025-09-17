# res://scripts/player/player_stats_component.gd
class_name PlayerStatsComponent
extends BaseStatsComponent

# 我们暂时不需要任何属性，只需要一个能响应伤害的函数。

# 实现基类定义的“伤害处理”接口
func process_damage(attacker: Node, physical_source: Node, base_damage: float):
	# 从信息包中解包出我们需要的信息

	# --- 核心验证步骤 ---
	# 在控制台打印出一条清晰的日志，证明伤害事件已成功送达。
	print("玩家受到了来自 '%s' 的 %s 点伤害！" % [attacker.name, base_damage])
	
	# 暂时不做任何扣血操作，只打印信息。
