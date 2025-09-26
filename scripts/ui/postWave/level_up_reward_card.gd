# res://scripts/ui/components/level_up_reward_card.gd
@tool
class_name LevelUpRewardCard
extends VBoxContainer

# --- 信号 ---
# 当这张卡片被选中时，发射这个信号
signal selected(reward_data: RewardData)

# --- 节点引用 ---
@onready var info_display: RewardCard = $RewardCard
@onready var select_button: Button = $SelectButton

# --- 内部状态 ---
var _reward_data: RewardData

# --- 编辑器预览属性 ---
@export var preview_data: RewardData:
	set(value):
		preview_data = value
		if Engine.is_editor_hint():
			call_deferred("display", value)

func _ready():
	select_button.pressed.connect(_on_select_button_pressed)
	if Engine.is_editor_hint() and is_instance_valid(preview_data):
		display(preview_data)

# --- 公共接口 (API) ---
func display(data: RewardData):
	_reward_data = data
	info_display.display(data)

# --- 信号处理 ---
func _on_select_button_pressed():
	#if is_instance_valid(_reward_data):
		selected.emit(_reward_data)
#TODO:增加实际的效果应用
