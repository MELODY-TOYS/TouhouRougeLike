# res://scripts/ui/level_up_choice_ui.gd
class_name LevelUpChoiceUI
extends ColorRect

# --- 信号 ---
# 唯一的、向外报告的信号：玩家最终做出了一个选择
signal reward_chosen(chosen_data: RewardData)

# --- 资源与节点引用 ---
const LEVEL_UP_CARD_SCENE = preload("res://scenes/ui/postWave/LevelUpRewardCard.tscn")
@onready var card_container: HBoxContainer = %CardContainer
@onready var reroll_button: Button = %RerollButton
@onready var title_label: Label = %TitleLabel # 添加标题引用

func _ready():
	# 刷新按钮现在连接到内部的处理函数
	reroll_button.pressed.connect(_on_reroll_button_pressed)
	
	for card in card_container.get_children():
		# 做一个类型检查，确保我们只连接真正的卡片
		if card is LevelUpRewardCard:
			card.selected.connect(_on_card_selected)

# --- 公共接口 (API) ---
# 外部导演调用这个函数来启动一轮选择
func present_choice(title: String, options: Array[RewardData]):
	title_label.text = title
	self.show()
	_display_cards(options)
	_update_reroll_button_state()

# --- 内部逻辑 ---
# 负责显示卡片的核心函数
func _display_cards(options: Array[RewardData]):
	# 清空旧卡片
	for child in card_container.get_children():
		child.queue_free()
	
	if options.is_empty(): return
		
	# 创建新卡片
	for data in options:
		var card = LEVEL_UP_CARD_SCENE.instantiate()
		card_container.add_child(card)
		card.display(data)
		# 依然连接 effect_applied 信号，这是我们的出口
		card.effect_applied.connect(_on_card_effect_applied)

# --- 信号处理与内部交互 ---
# 当任何一张卡片报告“效果已应用”时
func _on_card_effect_applied(chosen_data: RewardData):
	# 中继这个事件，报告给导演
	reward_chosen.emit(chosen_data)

# 当刷新按钮被点击时，执行完整的内部刷新逻辑
func _on_reroll_button_pressed():
	print("UI内部：处理刷新请求...")
	
	# (未来) 从PlayerState获取刷新价格
	# var cost = PlayerState.get_reroll_cost() 
	var cost = 10 # 暂时硬编码
	
	# 检查玩家是否有足够的货币
	if PlayerState.current_money >= cost:
		# 1. 扣钱
		# PlayerState.spend_money(cost) # 未来实现
		print("花了 %d 块钱刷新" % cost)
		
		# 2. 从PlayerState获取一组新的选项
		var new_options = PlayerState.get_reward_options(4)
		
		# 3. 重新显示卡片
		_display_cards(new_options)
		
		# 4. 更新刷新按钮的状态（价格可能变了）
		_update_reroll_button_state()
	else:
		print("钱不够，无法刷新！")
		# （可选）可以在按钮上播放一个“无法点击”的动画

# 更新刷新按钮的外观和状态
func _update_reroll_button_state():
	# (未来) 动态显示价格和可用性
	# var cost = PlayerState.get_reroll_cost()
	# reroll_button.text = "刷新 (%d)" % cost
	# reroll_button.disabled = PlayerState.current_money < cost
	pass # 暂时留空

# --- 信号处理 ---
func _on_card_selected(chosen_data: RewardData):
	# 逻辑保持不变，依然是向上中继信号
	reward_chosen.emit(chosen_data)
