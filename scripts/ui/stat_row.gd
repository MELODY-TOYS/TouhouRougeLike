# res://scripts/ui/components/stat_row.gd
@tool
class_name StatRow
extends HBoxContainer

# --- 配置 ---
@export var display_name: String:
	set(value):
		display_name = value
		_update_static_display()

@export var icon: Texture2D:
	set(value):
		icon = value
		_update_static_display()

@export var stat_type: Attributes.Stat

@export var is_percentage: bool = false:
	set(value):
		is_percentage = value
		_update_static_display()


# --- 节点引用 (我们不再使用 @onready) ---
var icon_rect: TextureRect
var name_label: Label
var value_label: Label


func _ready() -> void:
	# --- 核心修改：在 _ready 中手动查找节点 ---
	# find_child 会递归地、安全地查找子节点，直到找到为止
	# 第二个参数 false 表示不检查所有者，这在处理实例化的 tool 脚本时很重要
	icon_rect = find_child("Icon", true, false) as TextureRect
	name_label = find_child("NameLabel", true, false) as Label
	value_label = find_child("ValueLabel", true, false) as Label
	
	#if not is_instance_valid(Global.player):
		#print("[TEST] Global.player 不存在，正在创建模拟玩家...")
		#
		## 2. 创建一个临时的 Node2D 作为“假”玩家
		#var mock_player = Node2D.new()
		#mock_player.name = "MockPlayer"
		#
		## 3. 创建一个真实的 StatsComponent 实例
		#var stats_comp = BaseStatsComponent.new()
		##    我们需要给它一个临时的 StatsData 资源才能工作
		#stats_comp.stats_data = ActorStatsData.new() # 假设ActorStatsData可以这样新建
		#stats_comp.name = "StatsComponent"
		#
		## 4. 将属性组件加到“假”玩家下面
		#mock_player.add_child(stats_comp)
		#
		## 5. 将“假”玩家加到场景树中，这样它才能正常工作
		#add_child(mock_player)
		#
		## 6. 最关键的一步：把它注册到 Global 单例里
		#Global.player = mock_player
#
	## 在节点都确保找到后，再执行更新
	#_update_static_display()
	#
	if not Engine.is_editor_hint():
		# (游戏运行时的逻辑保持不变)
		var stats_comp = Global.player.get_node_or_null("StatsComponent")
		if stats_comp:
			stats_comp.stats_changed.connect(_update_value)
			_update_value()
	else:
		_update_value()


# --- 静态显示更新 (核心修改在这里) ---
func _update_static_display():
	# --- 安全检查 (Guard Clause) ---
	# 如果 name_label 还没有被 @onready 赋值，那它就是 null。
	# 这意味着节点还没有准备好，我们必须立刻停止执行，避免报错。
	if not name_label:
		return
		
	name_label.text = display_name
	icon_rect.texture = icon

# --- 动态数值更新 ---
func _update_value():
	# --- 同样的安全检查 ---
	if not value_label:
		return

	# 编辑器模式下，显示占位符
	if Engine.is_editor_hint():
		value_label.text = "+12%" if is_percentage else "123"
		return

	# 游戏运行时，获取真实数据
	var stats_comp = Global.player.get_node_or_null("StatsComponent")
	if not stats_comp:
		value_label.text = "N/A"
		return
		
	var value = stats_comp.get_stat(stat_type)
	
	if is_percentage:
		value_label.text = "+%.0f%%" % value
	else:
		value_label.text = str(value) if value < 0 else "+%s" % str(value)
