extends CharacterBody2D

@export var speed:float=300
@export var animation_blend_time=0.2
var facing_direction: int = 1

@onready var view: Node2D = $View
@onready var sprite_2d: Sprite2D = $View/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
# 获取对 Camera2D 的引用
@onready var camera_2d: Camera2D = $Camera2D
var is_turning: bool = false

func _ready() -> void:
	# 在玩家准备就绪时，将自身注册到全局单例中。
	Global.player = self
	# ... 你已有的其他 _ready 代码 ...

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
	var target_animation = ""
	if velocity.length_squared() > 0:
		target_animation = "Move"
	else:
		target_animation = "Idle"

	if animation_player.current_animation != target_animation:
		if is_turning!=true:
			animation_player.play(target_animation, animation_blend_time)

		# 根据移动方向翻转角色视觉
	if direction.x != 0 and sign(direction.x) != facing_direction:
		turn_around()

# 新增一个专门处理转身动画的函数
func turn_around():
	animation_player.stop()
	is_turning=true
	facing_direction *= -1
	
	# 压缩阶段
	var tween_squash = create_tween().set_parallel(true)
	tween_squash.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween_squash.tween_property(view, "scale:x", 0.1, 0.1) 
	await tween_squash.finished

	sprite_2d.flip_h = not sprite_2d.flip_h
	
	# 恢复阶段
	var tween_recover = create_tween().set_parallel(true)
	tween_recover.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween_recover.tween_property(view, "scale:x", 1.0, 0.1)
	await tween_recover.finished
	
	is_turning=false




func update_camera_limits(limits_rect: Rect2):
	camera_2d.limit_left = int(limits_rect.position.x)
	camera_2d.limit_top = int(limits_rect.position.y)
	camera_2d.limit_right = int(limits_rect.end.x)
	camera_2d.limit_bottom = int(limits_rect.end.y)

# _notification 是一个特殊的Godot函数，用于接收引擎的各种通知。
# 我们在这里处理“即将被删除”的通知，以确保全局引用被清理。
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		# 当玩家节点即将从场景树中被删除时（例如游戏结束），
		# 确保全局引用也被清空，避免“悬挂指针”问题。
		if Global.player == self:
			Global.player = null

func initialize(char_data: CharacterData):
	# 检查传入的数据是否有效
	if not char_data:
		push_error("错误: 尝试用空的 CharacterData 初始化玩家！")
		return

	# 1. 初始化属性组件
	#    我们假设 Player 场景中有一个名为 "PlayerStatsComponent" 的子节点
	var stats_component = $PlayerStatsComponent as BaseStatsComponent
	if stats_component and char_data.base_stats_data:
		stats_component.initialize_with_data(char_data.base_stats_data)
	else:
		push_warning("警告: 找不到 PlayerStatsComponent 或 CharacterData 中缺少 base_stats_data。")

	# 2. 初始化初始武器
	#    我们假设 Player 场景中有一个名为 "WeaponManager" 的子节点
	var weapon_manager = $WeaponManager # weapon_manager 脚本需要有 add_weapon 方法
	if weapon_manager and char_data.starting_weapon:
		weapon_manager.add_weapon(char_data.starting_weapon)
	else:
		push_warning("警告: 找不到 WeaponManager 或 CharacterData 中缺少 starting_weapon。")

	# 3. [未来] 应用天赋
	# if char_data.talents:
	# 	for talent in char_data.talents:
	# 		talent.apply(self)
