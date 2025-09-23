# res://scenes/ui/health_bar.gd
class_name HealthBar
extends ProgressBar

# -------------------- Godot 生命周期 --------------------

func _ready() -> void:
	# 默认隐藏，在找到有效目标前，不应该显示。
	visible = false

	## --- "即插即用"的核心逻辑 ---
	## 作为一个“组件”，它的首要任务是服务于它的直接父节点。
	#var owner = get_parent()
	#
	## 安全检查：确保父节点存在。
	#if not is_instance_valid(owner):
		#push_warning("HealthBar: 必须被附加到一个父节点下才能自动工作。")
		#return
#
	## 使用ASC服务，从父节点身上查找StatsComponent。
	#var stats_component = ASC.get_stats_component_from(owner)
#
	## 如果成功找到了，就自动激活自己。
	#if is_instance_valid(stats_component):
		#track_stats(stats_component)
	#else:
		## 这是一个有用的警告：你把血条放到了一个没有属性的物体上。
		#push_warning("HealthBar: 在父节点 '%s' 上未能找到StatsComponent。" % owner.name)


# -------------------- 公共接口 (依然保留) --------------------

# 这个函数现在有两个作用：
# 1. 被_ready()内部调用，以完成自动激活。
# 2. 依然可以被外部系统（如HUD）调用，来手动覆写追踪目标。
func track_stats(stats_component: BaseStatsComponent):
	if not is_instance_valid(stats_component):
		push_warning("HealthBar: 尝试追踪一个无效的StatsComponent。")
		visible = false
		return

	# 连接到目标的health_updated信号。
	if not stats_component.health_updated.is_connected(_on_health_updated):
		stats_component.health_updated.connect(_on_health_updated)

	# 立即用目标的当前状态，更新一次血条的初始外观。
	var initial_max = stats_component.get_stat(Attributes.Stat.MAX_HEALTH)
	var initial_health = stats_component.get_stat(Attributes.Stat.HEALTH)
	_on_health_updated(initial_health, initial_max)
	
	visible = true

# -------------------- 信号回调 --------------------

func _on_health_updated(current_health: float, max_health: float):
	max_value = max_health
	value = current_health
