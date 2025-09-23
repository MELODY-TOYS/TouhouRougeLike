# res://scripts/game/game.gd
extends Node2D

# --- 模块引用 ---
# 使用 @onready 确保在调用前，子节点已经准备就绪。
# 我们在这里获取对舞台、演员和生成器的引用。
@onready var arena = $Arena
@onready var player = $Player
@onready var enemy_spawner = $EnemySpawner


func _ready() -> void:
	# --- 游戏初始化流程 ---
	# 这是这个“导演”脚本的核心职责：建立模块间的连接并启动游戏。

	# 1. 连接“场地”与“玩家相机”
	# 我们在这里监听 Arena 发出的 arena_generated 信号，
	# 当信号发出时，调用 Player 节点上的 update_camera_limits 函数。
	# 这是之前在 arena.gd 中的耦合代码，现在被转移到了更高层级的管理者手中。
	#arena.arena_generated.connect(player.update_camera_limits)

	# 2. 启动游戏核心循环
	# Game 场景决定游戏何时开始。
	# 在这里，我们直接命令 EnemySpawner 开始它的工作。
	# 这是另一处从 arena.gd 转移过来的逻辑。
	enemy_spawner.start_wave()
	#todo，更新这个逻辑
	#Global.player.update_camera_limits()
	await get_tree().process_frame

	# 获取玩家身上的武器管理器
	var weapon_manager = player.get_node_or_null("WeaponManager")
	if weapon_manager:
		# 命令管理器添加小刀
		weapon_manager.add_weapon("res://scenes/player/weapons/shotgun.tscn")
	else:
		push_error("在Player节点上未找到WeaponManager！")
