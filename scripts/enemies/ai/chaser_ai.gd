# res://scripts/enemies/chaser_ai.gd
# 这是一个具体的AI实现，它继承自BaseEnemyAI。
# 它的唯一职责就是：不知疲倦地追击它的目标。

extends BaseEnemyAI

# --- 状态定义 ---
# ChaserAI只关心它自己的状态。
# 它的世界观非常简单。
enum State {
	CHASING
}

# --- Godot 生命周期函数 ---

func _ready() -> void:
	# super() 会调用父类(BaseEnemyAI)的_ready函数。
	# 这是一个非常好的习惯，它能确保父类中的初始化代码（如信号连接）被执行。
	super()
	target = Global.player
	# ChaserAI一出生就进入追击状态。
	change_state(State.CHASING)

func _physics_process(delta: float) -> void:
	# ChaserAI的状态机只处理它关心的状态。
	match current_state:
		State.CHASING:
			_chasing_state_logic(delta)

# --- 状态逻辑 ---

# 将具体的状态逻辑封装在独立的函数中，保持_physics_process的整洁。
func _chasing_state_logic(delta: float) -> void:
	# 健壮性检查：在每一帧都确认目标是否依然有效。
	# is_instance_valid() 是检查一个节点是否已被从场景树中移除（比如玩家死亡）的最安全方式。
	if not is_instance_valid(target):
		# 如果目标无效，可以选择停下或进入闲逛状态。
		# 为简单起见，我们先让它停下。
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# 从StatsComponent获取最新的移动速度。
	# 这样做的好处是，如果未来有buff或debuff改变了stats.move_speed，
	# 敌人会立刻以新的速度移动。
	var move_speed = stats.move_speed
	
	# 计算从当前位置到目标位置的方向向量。
	var direction = global_position.direction_to(target.global_position)
	
	# 设置速度并执行移动。
	velocity = direction * move_speed
	move_and_slide()
