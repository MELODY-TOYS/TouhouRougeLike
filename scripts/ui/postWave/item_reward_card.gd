# res://scripts/ui/components/item_choice_card.gd
class_name ItemRewardCard
extends VBoxContainer

# --- 信号 ---
# 定义两个不同的信号，清晰地表达用户的意图
signal taken(reward_data: RewardData)
signal recycled(reward_data: RewardData)

# --- 节点引用 ---
@onready var info_display: RewardCard = %RewardCard
@onready var take_button: Button = %TakeButton
@onready var recycle_button: Button = %RecycleButton

var _reward_data: RewardData

func _ready():
	take_button.pressed.connect(_on_take_button_pressed)
	recycle_button.pressed.connect(_on_recycle_button_pressed)

# --- 公共接口 (API) ---
func display(data: RewardData, recycle_value: int):
	_reward_data = data
	info_display.display(data)
	# 动态更新回收按钮的文本，显示能获得多少钱
	recycle_button.text = "回收 (+%d)" % recycle_value

# --- 信号处理 ---
func _on_take_button_pressed():
	print("Take Button Pressed!") # <--- 添加这行
	if is_instance_valid(_reward_data):
		print("Reward data is valid, emitting signal.") # <--- 添加这行
		taken.emit(_reward_data)
	else:
		print("Reward data is NULL!") # <--- 添加这行

func _on_recycle_button_pressed():
	if is_instance_valid(_reward_data):
		recycled.emit(_reward_data)
