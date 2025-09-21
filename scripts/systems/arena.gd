@tool
extends Node2D

signal arena_generated(limits_rect: Rect2)

# --- 节点引用 ---
@onready var ground_layer: TileMapLayer = $TileLayers/GroundLayer
@onready var obstacle_layer: TileMapLayer = $TileLayers/ObstacleLayer

# --- 竞技场尺寸 ---
@export var width: int = 8:
	set(value):
		width = value
		if _can_generate():
			generate_arena()

@export var height: int = 8:
	set(value):
		height = value
		if _can_generate():
			generate_arena()

# =================== 瓦片常量定义 ===================
# --- 地面瓦片 ---
const FLOOR_TILES: Array[Vector2i] = [ Vector2i(1, 1) ]

# --- 竹子墙壁瓦片 ---
# 假设你新画的、有层次感的竹墙瓦片坐标是 (0,0) in your Bamboo.tres
const BAMBOO_WALL_HORIZONTAL = Vector2i(0, 2) 
# =======================================================

func _ready() -> void:
	if Engine.is_editor_hint():
		call_deferred("generate_arena")
	else:
		generate_arena()

# 主生成函数
func generate_arena() -> void:
	if not _can_generate():
		return

	ground_layer.clear()
	obstacle_layer.clear()
	
	var offset = Vector2i(-width / 2, -height / 2)
	
	for x in range(width):
		for y in range(height):
			var final_pos = Vector2i(x, y) + offset
			
			# --- 1. 绘制地面 (逻辑不变) ---
			var floor_coord = FLOOR_TILES.pick_random()
			ground_layer.set_cell(final_pos, 0, floor_coord)

			# --- 2. 【核心改动】只在顶部和底部边界生成竹墙 ---
			var is_top_boundary = (y == 0)
			var is_bottom_boundary = (y == height - 1)
			
			if is_top_boundary:
				# 在顶部边界放置竹墙
				obstacle_layer.set_cell(final_pos, 0, BAMBOO_WALL_HORIZONTAL,2)
			
			elif is_bottom_boundary:
				# 在底部边界放置竹墙
				# 我们可以使用同一个瓦片，但通过翻转来增加变化
				# Alternative ID 1 应该在 TileSet 中设置为 Flip V = true
				# 如果你还没设置，它会和顶部看起来一样，也没关系
				obstacle_layer.set_cell(final_pos, 0, BAMBOO_WALL_HORIZONTAL)

	# --- 发射边界信号 (逻辑不变) ---
	var tile_size = ground_layer.tile_set.tile_size
	var limits = Rect2(
		- (width / 2.0) * tile_size.x, 
		- (height / 2.0) * tile_size.y, 
		width * tile_size.x, 
		height * tile_size.y
	)	
	arena_generated.emit(limits)

# (辅助函数 _can_generate 不变)
func _can_generate() -> bool:
	if not is_inside_tree() or not is_instance_valid(ground_layer) or not is_instance_valid(obstacle_layer):
		return false
	if ground_layer.tile_set == null or obstacle_layer.tile_set == null:
		return false
	return true
