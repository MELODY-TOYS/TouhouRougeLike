# arena.gd
extends Node2D

# 使用 enum 可以让你在 Godot 编辑器中看到一个下拉菜单，非常方便！
enum MapType { BAMBOO_FOREST, MISTY_LAKE }

# 导出这个变量，这样你就可以在 Game.tscn 的编辑器界面里直接选择地图了
@export var current_map_type: MapType = MapType.MISTY_LAKE

# 预加载你的纯视觉地图场景
const MAP_SCENES = {
	
}

@onready var map_container = $MapContainer

func _ready():
	# 场景启动时，根据在编辑器里选好的类型加载地图
	load_current_map()

func load_current_map():
	# 确保 map_container 是空的
	for child in map_container.get_children():
		child.queue_free()

	# 检查我们选择的地图是否存在
	if MAP_SCENES.has(current_map_type):
		var map_scene = MAP_SCENES[current_map_type]
		var map_instance = map_scene.instantiate()
		map_container.add_child(map_instance)
	else:
		print("Selected map type does not exist!")

# （可选）提供一个公共接口，让 Game.gd 可以在游戏过程中切换地图
func change_map(new_map_type: MapType):
	current_map_type = new_map_type
	load_current_map()
