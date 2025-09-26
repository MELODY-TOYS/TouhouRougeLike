# res://scripts/game/game.gd
extends Node2D

# --- 资源预加载 ---
# 预加载我们的“波次后UI管理器”场景蓝图
const PostWaveUIManager_Scene = preload("res://scenes/ui/postWave/PostWaveUIManager.tscn")

# --- 模块引用 ---
@onready var arena = $Arena
@onready var player = $Player
@onready var enemy_spawner = $EnemySpawner
# @onready var hud = $HUD # 假设HUD也在这里

# --- 核心数据 ---
@export var wave_sequence: Array[WaveResource]

var current_wave_index: int = -1
var time_in_wave: float = 0.0
# 使用状态机来管理游戏流程，比布尔值更清晰、更健壮
enum GameState { PRE_GAME, WAVE_IN_PROGRESS, POST_WAVE_SEQUENCE, GAME_OVER }
var current_state: GameState = GameState.PRE_GAME


func _ready() -> void:
	# --- 游戏初始化流程 ---
	# 在游戏开始时，就将玩家Pawn注册到全局单例中
	# 确保这一步在所有其他逻辑之前
	Global.player = player
	
	# 初始化玩家武器
	var weapon_manager = player.get_node_or_null("WeaponManager")
	if weapon_manager:
		weapon_manager.add_weapon("res://scenes/player/weapons/shotgun.tscn")
	else:
		push_error("在Player节点上未找到WeaponManager！")
		
	# 启动游戏
	start_game()


func _process(delta: float):
	# 只在波次进行中才执行计时和结束判断
	if current_state != GameState.WAVE_IN_PROGRESS:
		return
	
	time_in_wave += delta
	# hud.update_time(time_in_wave) # 未来通过HUD脚本更新计时器
	
	# 判断波次结束条件
	if not wave_sequence.is_empty() and current_wave_index < wave_sequence.size():
		var current_wave_resource = wave_sequence[current_wave_index]
		var enemies_remaining = enemy_spawner.enemy_container.get_child_count()
		
		if time_in_wave >= current_wave_resource.duration and enemies_remaining == 0:
			_on_wave_completed()


# --- 游戏流程控制 ---
func start_game():
	current_wave_index = -1
	# 立即开始第一波
	_start_next_wave()

func _start_next_wave():
	# 切换状态，防止在UI流程中意外触发下一波
	current_state = GameState.PRE_GAME 
	
	current_wave_index += 1
	
	if current_wave_index >= wave_sequence.size():
		# 游戏胜利
		current_state = GameState.GAME_OVER
		print("恭喜！所有波次已完成！")
		# get_tree().change_scene_to_file("res://scenes/victory_screen.tscn")
		return
		
	time_in_wave = 0.0
	
	var next_wave_resource = wave_sequence[current_wave_index]
	enemy_spawner.wave_resource = next_wave_resource
	enemy_spawner.start_wave()
	
	current_state = GameState.WAVE_IN_PROGRESS
	print("Game Director: 第 %d 波开始！" % (current_wave_index + 1))


# 当波次结束时被调用（通过_process或调试按键）
func _on_wave_completed():
	# 防止重复触发
	#if current_state != GameState.WAVE_IN_PROGRESS:
		#return
		
	print("Game Director: 第 %d 波完成！" % (current_wave_index + 1))
	current_state = GameState.POST_WAVE_SEQUENCE
	
	# 启动波次后UI流程
	_start_post_wave_phase()


# --- 核心修改：异步的UI流程管理 ---
func _start_post_wave_phase():
	print("Game Director: 正在召唤UI管理器...")
	
	# 1. 实例化UI管理器
	var ui_manager = PostWaveUIManager_Scene.instantiate()
	# 2. 添加到场景树
	add_child(ui_manager)
	
	# 3. 启动并等待其完成所有工作（升级、商店等）
	await ui_manager.execute_full_sequence()
	# execute_full_sequence 内部会处理玩家输入的禁用和恢复
	# 当 await 执行完毕时，ui_manager 已经自我销毁
	
	# 4. UI流程结束，安全地开始下一波
	print("Game Director: UI流程结束，准备下一波。")
	_start_next_wave()


# --- 调试功能 ---
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.is_pressed() or event.is_echo():
		return
		
	match event.keycode:
		KEY_1:
			print("[DEBUG] 按下 1: 增加资源")
			PlayerState.add_resources(10, 10)
		KEY_2:
			print("[DEBUG] 按下 2: 强制结束当前波次")
			_on_wave_completed()
