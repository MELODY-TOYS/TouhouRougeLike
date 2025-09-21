# res://scripts/projectiles/base_projectile.gd
class_name BaseProjectile
extends Area2D

@export var hit_effect_scene: PackedScene

# --- 核心属性 (由发射器在运行时配置) ---
var damage: float = 10.0
var speed: float = 600.0
var piercing_left: int = 0

# --- 内部状态 ---
var hit_list: Array = []
var is_dying: bool = false # 状态锁，防止重复触发死亡流程

# --- 子节点引用 (请确保你场景中的节点名称与此一致) ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
# 这个引用是可选的，如果找不到节点，它会是 null，代码会安全处理
@onready var trail_particles: GPUParticles2D = $TrailParticles if has_node("TrailParticles") else null


# --- Godot 生命周期 ---

func _ready():
	# 连接 area_entered 信号，这是我们的命中检测器
	area_entered.connect(_on_area_entered)
	
	# 添加一个屏幕外检测器，当弹道飞出屏幕时自动销毁，防止内存泄漏
	var visibility_notifier = VisibleOnScreenNotifier2D.new()
	visibility_notifier.screen_exited.connect(destroy) # 飞出屏幕时，调用优雅销毁
	add_child(visibility_notifier)


func _physics_process(delta: float):
	# 如果正在“死亡”中，就停止移动
	if is_dying:
		return
	
	# 沿自己的正前方 (本地x轴) 持续移动
	position += transform.x * speed * delta


# --- 核心公共函数 ---

# 这是该弹道的公共接口，由发射它的武器 (ProjectileWeaponInstance) 调用
func setup(start_transform: Transform2D, _damage: float, _speed: float, _piercing: int):
	self.global_transform = start_transform # 设置初始位置和方向
	self.damage = _damage
	self.speed = _speed
	self.piercing_left = _piercing


# 这是一个全新的“优雅销毁”函数，取代了直接调用 queue_free()
func destroy():
	# 如果已经处于死亡流程中，直接返回，避免重复执行
	if is_dying:
		return
	is_dying = true

	# 1. 停止一切活动
	speed = 0
	# 使用 set_deferred 来安全地禁用碰撞体，避免在物理帧内直接修改
	collision_shape.set_deferred("disabled", true)
	
	# 2. 隐藏子弹的视觉主体
	if is_instance_valid(sprite):
		sprite.hide()
	
	# 3. 处理拖尾特效（如果存在）
	if is_instance_valid(trail_particles):
		# 命令粒子系统停止发射新的粒子
		trail_particles.emitting = false
		
		# 创建一个定时器，等待粒子效果播放完毕
		var wait_time = trail_particles.lifetime
		var timer = get_tree().create_timer(wait_time)
		
		# 当定时器时间到，连接到 queue_free() 来执行真正的销毁
		timer.timeout.connect(queue_free)
	else:
		# 如果没有任何需要等待的特效，就立即请求销毁
		queue_free()


# --- 信号处理函数 ---

func _on_area_entered(area: Area2D):
	# 如果正在死亡或已经命中过目标，则忽略
	if is_dying or hit_list.has(area):
		return

	# 检查命中对象是否为有效的敌人
	var enemy = area.get_owner()
	if not is_instance_valid(enemy):
		return
	
	hit_list.append(area) # 将命中的hitbox添加到列表，防止重复命中

	# 对敌人造成伤害
	var enemy_stats = ASC.get_stats_component_from(enemy)
	if enemy_stats:
		# 伤害来源依然是玩家
		enemy_stats.process_damage(Global.player, self, damage)
		
	if hit_effect_scene: # 检查是否在编辑器里指定了特效
		var effect_instance = hit_effect_scene.instantiate()
		
		# 确保实例化出来的东西真的是一个 Node2D (或其子类)
		if effect_instance is Node2D:
			effect_instance.global_position = self.global_position
			get_tree().current_scene.add_child(effect_instance)

	# 处理穿透逻辑
	if piercing_left <= 0:
		destroy() # 没有穿透力了，调用优雅销毁
	else:
		piercing_left -= 1 # 消耗一次穿透力
