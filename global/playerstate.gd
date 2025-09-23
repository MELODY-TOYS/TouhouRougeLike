# res://scripts/global/playerstate.gd
extends Node

# --- PlayerState 数据 ---
signal leveled_up(new_level) # 升级信号
signal resources_updated(reiryoku, money) # 资源变动信号

var level: int = 1
var current_reiryoku: int = 0
var current_money: int = 0
var xp_to_next_level: int = 10


# --- 公共接口 (API) ---
# 任何东西想要给玩家加资源，都调用这个函数
func add_resources(reiryoku_amount: int, money_amount: int) -> void:
	current_reiryoku += reiryoku_amount
	current_money += money_amount
	
	print("全局资源增加 | 霊力: %d, 货币: %d" % [current_reiryoku, current_money])
	resources_updated.emit(current_reiryoku, current_money) # 发射信号，通知UI更新
	
	_check_for_level_up()

# --- 内部逻辑 ---
func _check_for_level_up() -> void:
	while current_reiryoku >= xp_to_next_level:
		current_reiryoku -= xp_to_next_level
		level += 1
		xp_to_next_level += 5 
		
		print("全局等级提升！当前等级: %d" % level)
		leveled_up.emit(level)
