# res://scripts/ui/item_choice_ui.gd
class_name ItemChoiceUI
extends ColorRect

# --- 信号 ---
# 中继来自底层卡片的信号，向上层“导演”报告
signal item_taken(item_data: RewardData)
signal item_recycled(item_data: RewardData)

# --- 节点引用 ---
# 确保在 ItemChoiceUI.tscn 场景中，有一个Control节点名为 "ItemCardContainer"
@onready var item_card_container: Control = %ItemCardContainer

# --- 测试专用配置 ---
# 在Godot编辑器中，选中ItemChoiceUI节点，
# 然后将一个测试用的道具.tres文件拖拽到这个属性槽里。
@export_group("静态测试")
@export var static_preview_item: RewardData


func _ready() -> void:
	# --- 静态连接逻辑 ---
	# 这个函数会在场景启动时，自动配置好用于测试的静态卡片。
	
	# 检查容器里是否有我们手动摆放的卡片
	if item_card_container.get_child_count() > 0:
		# 获取第一个子节点，我们假设它就是我们的测试卡片
		var static_card = item_card_container.get_child(0)
		
		# 做一次类型检查，确保它确实是 ItemRewardCard
		if static_card is ItemRewardCard:
			# 1. 将我们自己的信号，连接到卡片发出的信号上，实现“中继”
			static_card.taken.connect(_on_card_taken)
			static_card.recycled.connect(_on_card_recycled)
			
			# 2. 检查我们是否在Inspector里配置了预览数据
			if is_instance_valid(static_preview_item):
				# 3. 如果有，就用这个数据来调用卡片的 display 函数，让它显示出来
				#    这里我们可以硬编码一个用于测试的回收价值，比如 15
				static_card.display(static_preview_item, 15)
			else:
				# 如果没有配置预览数据，给出一个清晰的警告
				push_warning("ItemChoiceUI: 未在Inspector中设置'Static Preview Item'，卡片将没有数据。")

			print("ItemChoiceUI: 已成功连接用于测试的静态卡片。")


# --- 信号中继函数 ---

# 当底层卡片发出 "taken" 信号时，这个函数会被调用
func _on_card_taken(data_from_card: RewardData):
	# 打印调试信息，确认信号已到达这一层
	print("ItemChoiceUI: 接收到 'taken' 信号，正在向上中继...")
	# 将收到的数据，通过自己的信号原封不动地发射出去
	item_taken.emit(data_from_card)

# 当底层卡片发出 "recycled" 信号时，这个函数会被调用
func _on_card_recycled(data_from_card: RewardData):
	print("ItemChoiceUI: 接收到 'recycled' 信号，正在向上中继...")
	item_recycled.emit(data_from_card)


# --- 公共接口 (API) ---
# 这个函数将在未来我们切换到“动态模式”时使用。
# 现在它可以暂时留空，但保留下来以维持接口的完整性。
func present_choice(item_option: RewardData, recycle_value: int):
	# TODO: 未来在这里实现动态创建卡片的逻辑
	pass
