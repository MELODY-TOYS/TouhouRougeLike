# res://scenes/loot/power_item.gd
class_name PowerItem
extends Area2D

func _ready() -> void:
	# 连接自身的 body_entered 信号到处理函数
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# 检查进入的是否是玩家 (最稳妥的方式是检查分组)
	if body.is_in_group("player"):
		# 调用玩家身上的“吸收”函数
		body.absorb_power_item()
		
		# 自我销毁
		get_parent().queue_free()
