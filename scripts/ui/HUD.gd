# res://scripts/ui/hud.gd
extends CanvasLayer

# --- 节点引用 ---
@onready var health_bar: TextureProgressBar = %HealthBar
@onready var xp_bar: TextureProgressBar = %XPBar
@onready var money_label: Label = %Money_HBox/Label
@onready var wave_label: Label = %WaveLabel
@onready var time_label: Label = %TimeLabel
@onready var pending_rewards_vbox: VBoxContainer = %PendingRewards_VBox

func _ready() -> void:
	# 延迟一帧启动，确保所有节点（特别是Global.player）都已就绪
	call_deferred("_initialize_hud")


# --- 初始化与主循环 ---
func _initialize_hud() -> void:
	# --- 建立与数据源的连接 ---
	# 1. 连接来自 PlayerState 的进度更新信号
	PlayerState.resources_updated.connect(_on_player_resources_updated)
	PlayerState.leveled_up.connect(_on_player_leveled_up)
	
	# 2. 启动对 StatsComponent 的监听循环
	_start_stats_listener_loop()
	
	# --- 首次UI刷新 ---
	# 用 PlayerState 的初始值，完整刷新一次所有相关的UI
	_refresh_progression_ui()


func _start_stats_listener_loop() -> void:
	var stats_component = Global.player.get_node_or_null("StatsComponent")
	if not is_instance_valid(stats_component):
		push_error("HUD 无法启动监听，因为玩家的 StatsComponent 无效！")
		return
	
	# 启动无限循环，等待战斗属性变化
	while true:
		# 首次刷新血条等战斗属性
		_refresh_combat_ui()
		# 等待信号
		await stats_component.stats_changed

# --- UI刷新函数 ---
# 刷新与“进度”相关的UI（经验、等级、货币）
func _refresh_progression_ui() -> void:
	# 更新经验条
	xp_bar.max_value = PlayerState.xp_to_next_level
	xp_bar.value = PlayerState.current_reiryoku
	
	# 核心修改：在经验条上直接显示文字
	xp_bar.get_node("Label").text = "LV. %d" % PlayerState.level
	
	# 更新货币
	money_label.text = str(PlayerState.current_money)

# 刷新与“战斗”相关的UI（血条等）
func _refresh_combat_ui() -> void:
	var stats_component = Global.player.get_node_or_null("StatsComponent")
	if not is_instance_valid(stats_component): return

	# 刷新血条
	health_bar.max_value = stats_component.max_health
	health_bar.value = stats_component.current_health


# --- 信号处理函数 ---
# 当 PlayerState 的资源（经验/货币）发生变化时调用
func _on_player_resources_updated(_reiryoku: int, _money: int) -> void:
	# 直接调用通用的进度刷新函数
	_refresh_progression_ui()

# 当 PlayerState 报告玩家升级时调用
func _on_player_leveled_up(_new_level: int) -> void:
	# 刷新进度UI，以更新等级和新的经验条最大值
	_refresh_progression_ui()
	
	# 在右上角添加一个待结算项
	var temp_label = Label.new()
	temp_label.text = "待处理升级 +1"
	pending_rewards_vbox.add_child(temp_label)
