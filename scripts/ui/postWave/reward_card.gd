# res://scripts/ui/reward_card.gd
@tool
class_name RewardCard
extends PanelContainer

# --- 强制预加载依赖 ---
# 这是一个@tool脚本的良好实践，确保在解析本脚本前，它所依赖的类已经被加载
const StatRewardData_Preload = preload("res://scripts/resources/rewards/reward_data.gd")
const WeaponRewardData_Preload = preload("res://scripts/resources/rewards/weapon_reward_data.gd")


# --- 节点引用 (最关键的部分) ---
# 确保这一部分代码是完整无误的！
@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel
@onready var type_label: Label = %TypeLabel
@onready var description_label: RichTextLabel = %DescriptionLabel


# --- 编辑器预览专用属性 ---
@export_group("编辑器预览")
@export var preview_in_editor: bool = false:
	set(value):
		preview_in_editor = value
		if Engine.is_editor_hint():
			_update_preview()

@export var preview_data: RewardData:
	set(value):
		preview_data = value
		if Engine.is_editor_hint():
			_update_preview()

# --- 内部状态 ---
var _reward_data: RewardData


func _ready() -> void:
	if not Engine.is_editor_hint():
		preview_in_editor = false


# --- 公共接口 (游戏运行时调用) ---
func display(data: RewardData):
	if Engine.is_editor_hint(): return
	
	_reward_data = data
	_update_display_from_data(data)


# --- 内部更新逻辑 ---
func _update_display_from_data(data: RewardData):
	# 安全检查，确保节点已准备就绪
	if not name_label:
		return
		
	if not is_instance_valid(data):
		name_label.text = "数据无效"
		type_label.text = ""
		description_label.text = ""
		icon.texture = null
		return
		
	icon.texture = data.icon
	name_label.text = data.display_name
	description_label.text = data.description
	
	# is StatRewardData 这样的类型检查现在可以正常工作了
	if data is RewardData:
		type_label.text = "属性升级"
	elif data is WeaponRewardData:
		type_label.text = "武器"
	else:
		type_label.text = data.type_text # 使用在RewardData中定义的type_text


# --- 编辑器专用预览函数 ---
func _update_preview():
	if not Engine.is_editor_hint(): return
	
	# 在setter里，节点可能还没准备好，所以我们延迟一帧执行
	call_deferred("_execute_preview_update")

func _execute_preview_update():
	# 再次安全检查
	if not name_label:
		return

	if preview_in_editor and is_instance_valid(preview_data):
		_update_display_from_data(preview_data)
	else:
		name_label.text = "卡片名称"
		type_label.text = "类型"
		description_label.text = "这里是奖励的描述文字..."
		icon.texture = null
