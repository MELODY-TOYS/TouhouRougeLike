# res://scripts/ui/shop/shop_ui.gd
class_name ShopUI
extends Control

# 当玩家点击"出发"按钮时发射，通知 PostWaveUIManager 流程结束
signal shop_closed

# --- 资源预加载 ---
# 预加载单个商品卡片的场景，这是动态生成商品列表的关键
const ShopItemCard_Scene = preload("res://scenes/ui/postWave/ShopItemCard.tscn")

# --- 节点引用 ---
@onready var shop_item_container: HBoxContainer = %ShopItemContainer
@onready var player_hoding_items: GridContainer = %PlayerHoding/Item/VScrollBar/GridContainer
@onready var player_hoding_weapons: GridContainer = %PlayerHoding/Weapon/GridContainer
@onready var money_info = %MoneyInfo # 假设 MoneyInfo 脚本有一个 update_display(amount) 方法
@onready var refresh_button: Button = %LeftPanel/ShopInfo/Button
@onready var depart_button: Button = %RightPanel/Button

# 商店的核心逻辑，在 _ready 中被调用
func _ready() -> void:
	# 1. 连接必要的UI信号
	depart_button.pressed.connect(_on_depart_button_pressed)
	refresh_button.pressed.connect(_on_refresh_button_pressed)
	
	# 2. 初始时填充商店和玩家信息
	_populate_shop()
	_update_player_info()


# --- 核心功能 ---

# 填充商店的商品列表
func _populate_shop() -> void:
	# a. 清空旧的商品
	for child in shop_item_container.get_children():
		child.queue_free()
		
	# b. 获取当前波次的商品列表 (这部分逻辑未来需要实现)
	#    现在我们用一个假数据代替
	var items_to_display = _get_items_for_sale() 
	
	# c. 遍历商品数据，实例化商品卡片UI
	for item_data in items_to_display:
		var card = ShopItemCard_Scene.instantiate()
		card.set_item_data(item_data) # 假设卡片有一个方法来接收商品数据并更新显示
		shop_item_container.add_child(card)
		
		# d. 连接每个卡片自己的"购买"信号到这里的处理函数
		card.buy_pressed.connect(_on_item_buy_pressed)

# 更新所有与玩家状态相关的UI元素
func _update_player_info() -> void:
	# a. 更新货币显示
	money_info.update_display(PlayerState.get_money())
	
	# b. 更新玩家持有的道具/武器列表 (未来实现)
	#    这通常需要清空 GridContainer 再重新根据 PlayerState 的数据填充
	pass


# --- 信号处理 ---

# 当任何一个商品卡片的"购买"按钮被按下时
func _on_item_buy_pressed(item_data) -> void:
	var cost = item_data.price
	
	# 检查玩家是否有足够的钱
	if PlayerState.can_afford(cost):
		# 1. 扣钱
		PlayerState.spend_money(cost)
		
		# 2. 给予道具/武器
		PlayerState.add_item(item_data)
		
		# 3. 购买成功后更新UI
		#    可以禁用或移除已购买的商品卡片
		#    同时更新货币和玩家持有物列表
		print("购买 %s 成功!" % item_data.name)
		_update_player_info()
		# 你可能还需要找到对应的卡片并禁用它
	else:
		print("钱不够，买不起 %s" % item_data.name)
		# 在这里可以播放一个"失败"的音效或给出一个视觉提示


# 当"刷新"按钮被按下时
func _on_refresh_button_pressed() -> void:
	var refresh_cost = 10 # 假设刷新花费10块钱
	if PlayerState.can_afford(refresh_cost):
		PlayerState.spend_money(refresh_cost)
		print("刷新商店！")
		_populate_shop() # 重新填充商品
		_update_player_info()
	else:
		print("钱不够，无法刷新")

# 当"出发"按钮被按下时
func _on_depart_button_pressed() -> void:
	print("离开商店，准备进入下一波。")
	shop_closed.emit() # 发射信号，让 PostWaveUIManager 的 await 结束


# --- 数据获取 (临时) ---
# 这是一个临时的假函数，未来它应该从一个更复杂的系统中获取商品
# 比如根据当前波数、玩家幸运值等从一个商品池里随机抽取
func _get_items_for_sale() -> Array:
	# 在这里，你应该定义一个 ItemResource (继承自 Resource)
	# 用来存储商品信息，比如：
	# var item1 = load("res://items/sword.tres")
	# var item2 = load("res://items/potion.tres")
	# return [item1, item2]
	return [] # 暂时返回空数组
