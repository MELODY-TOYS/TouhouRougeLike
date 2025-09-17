# scripts/systems/enemy_spawner.gd
extends Node

# 允许我们在编辑器里把一个 WaveResource 文件拖拽进来
@export var wave_resource: WaveResource

var wave_time: float = 0.0 # 记录当前波次已进行的时间
var is_wave_active: bool = false

var event_index: int = 0 # 指向下一个要执行的事件

# 我们需要一个节点作为所有生成出来的敌人的“容器”，方便管理
# 最佳实践是让使用这个 Spawner 的人从外部指定这个容器
@export var enemy_container: Node


# --- 公共控制函数 ---

func start_wave():
	if not wave_resource or not enemy_container:
		print("Error: Wave Resource or Enemy Container is not set.")
		return
	
	# 重置状态
	wave_time = 0.0
	is_wave_active = true
	event_index = 0
	
	# （可选）对事件按时间进行排序，确保它们是有序的
	wave_resource.events.sort_custom(
		func(a, b): return a.trigger_time < b.trigger_time
	)
	print("Wave started!")


# --- 核心逻辑 ---

func _process(delta: float):
	if not is_wave_active:
		return
		
	# 1. 计时
	wave_time += delta
	
	# 2. 检查是否有待处理的事件
	if event_index >= wave_resource.events.size():
		# 所有事件都已执行完毕
		if wave_time >= wave_resource.duration:
			is_wave_active = false
			print("Wave finished!")
		return
			
	# 3. 获取下一个事件
	var next_event = wave_resource.events[event_index]
	
	# 4. 判断是否到了触发时间
	if wave_time >= next_event.trigger_time:
		execute_spawn_event(next_event)
		# 将索引指向再下一个事件
		event_index += 1


func execute_spawn_event(event: SpawnEvent):
	print("Executing event: spawn %d of %s" % [event.count, event.enemy_scene.resource_path])
	
	for i in range(event.count):
		var enemy_instance = event.enemy_scene.instantiate()
		
		# （TODO: 在这里实现复杂的生成位置逻辑）
		# 现在，我们先用一个非常简单的随机位置作为占位符
		var spawn_position = Vector2(randf_range(-400, 400), randf_range(-300, 300))
		enemy_instance.global_position = spawn_position
		
		enemy_container.add_child(enemy_instance)
