# res://scripts/ui/post_wave_ui_manager.gd
class_name PostWaveUIManager
extends CanvasLayer

# --- 信号 ---
# 当整个序列完成后，发射这个信号
signal sequence_finished

# --- 内部资源引用 ---
const LevelUpChoiceUI_Scene = preload("res://scenes/ui/postWave/LevelUpChoiceUI.tscn")
const ItemChoiceUI_Scene = preload("res://scenes/ui/postWave/ItemChoiceUI.tscn")
# --- 节点引用 ---
# 必须确保场景中有一个名为 LeftPanel 的节点
@onready var left_panel: Control = %LeftPanel

# --- 公共接口 (API) ---
# 这个函数不再需要 player 参数
func execute_full_sequence():
	# 从全局获取玩家引用，并进行安全检查
	var player = Global.player
	if not is_instance_valid(player):
		push_error("PostWaveUIManager: Global.player 无效！流程无法继续。")
		sequence_finished.emit()
		queue_free()
		return
	
	player.set_input_enabled(false)
	
	# --- 阶段一：结算升级奖励 ---
	if PlayerState.get_pending_level_ups() > 0:
		await _execute_level_up_phase()

	# --- 阶段二：结算道具收获 ---
	if PlayerState.get_pending_items() > 0: # <-- 我们需要一个新的 PlayerState 函数
		await _execute_item_choice_phase()

	# --- 阶段三：进入商店 (未来) ---
	# await _execute_shopping_phase()
	
	# --- 阶段四：收尾 ---
	player.set_input_enabled(true)
	sequence_finished.emit()
	self.queue_free()


# --- 内部异步函数 ---
# 负责处理整个升级选择的循环流程
func _execute_level_up_phase() -> void:
	# 1. 实例化UI
	var ui_instance = LevelUpChoiceUI_Scene.instantiate()
	# 2. 将UI添加到指定的 LeftPanel 容器中
	left_panel.add_child(ui_instance)
	
	# 3. 进入循环，处理所有待处理的升级
	while PlayerState.get_pending_level_ups() > 0:
		# a. 获取选项
		#var options = PlayerState.get_reward_options(4)
		#
		## b. 显示选项
		#ui_instance.display_options(options)
		
		# c. 等待玩家选择
		var chosen_reward = await ui_instance.reward_chosen
		
		# d. (可选) 隐藏UI，为下一轮做准备
		#    如果希望每次都刷新UI，可以先 queue_free() 再 instantiate()
		#    如果希望保留UI实例，用 hide()
		ui_instance.hide() 
		
		# e. 消耗升级机会
		PlayerState.consume_pending_level_up()
	
	# 4. 所有升级都处理完了，销毁UI实例
	ui_instance.queue_free()

# --- 内部异步函数 ---
# 负责处理整个升级选择的循环流程
func _execute_item_choice_phase() -> void:
	# 1. 实例化UI
	var ui_instance = ItemChoiceUI_Scene.instantiate()
	# 2. 将UI添加到指定的 LeftPanel 容器中
	left_panel.add_child(ui_instance)
	
	# 3. 进入循环，处理所有待处理的升级
	while PlayerState.get_pending_items() > 0:
		# a. 获取选项
		#var options = PlayerState.get_reward_options(4)
		#
		## b. 显示选项
		#ui_instance.display_options(options)
		
		# c. 等待玩家选择
		var chosen_reward = await ui_instance.item_taken
		
		# d. (可选) 隐藏UI，为下一轮做准备
		#    如果希望每次都刷新UI，可以先 queue_free() 再 instantiate()
		#    如果希望保留UI实例，用 hide()
		ui_instance.hide() 
		
		# e. 消耗升级机会
		PlayerState.consume_pending_item()
	
	# 4. 所有升级都处理完了，销毁UI实例
	ui_instance.queue_free()
