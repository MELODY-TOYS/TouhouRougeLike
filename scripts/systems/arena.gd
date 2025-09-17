@tool
extends Node2D

signal arena_generated(limits_rect: Rect2)

@onready var tile_map: TileMap = $TileMap
@onready var decorations_container: Node2D = $Decorations

@export var width: int = 25:
	set(value):
		width = value
		if Engine.is_editor_hint() and tile_map:
			generate_arena()

@export var height: int = 15:
	set(value):
		height = value
		if Engine.is_editor_hint() and tile_map:
			generate_arena()

const TILE_SIZE = 16

@export var decoration_textures: Array[Texture2D]
@export var decoration_count: int = 50

# --- 瓦片坐标常量定义 ---
# 我们假设未来会有一张图集，瓦片按 3x3 布局
const TILE_CORNER_TL = Vector2i(0, 0) # 左上角
const TILE_EDGE_TOP = Vector2i(1, 0)    # 上边缘
const TILE_CORNER_TR = Vector2i(7, 0) # 右上角

const TILE_EDGE_LEFT = Vector2i(0, 1)   # 左边缘
const TILE_FLOOR = Vector2i(1, 1)       # 地板
const TILE_EDGE_RIGHT = Vector2i(7, 1)  # 右边缘

const TILE_CORNER_BL = Vector2i(0, 7) # 左下角
const TILE_EDGE_BOTTOM = Vector2i(1, 7) # 下边缘
const TILE_CORNER_BR = Vector2i(7, 7) # 右下角


func _ready() -> void:
	generate_arena()

func generate_arena() -> void:
	if not tile_map:
		return
		
	tile_map.clear()
	
	var offset = Vector2i(-width / 2, -height / 2)
	
	for x in range(width):
		for y in range(height):
			var final_pos = Vector2i(x, y) + offset
			var tile_coord: Vector2i
			
			if x == 0 and y == 0: tile_coord = TILE_CORNER_TL
			elif x == width - 1 and y == 0: tile_coord = TILE_CORNER_TR
			elif x == 0 and y == height - 1: tile_coord = TILE_CORNER_BL
			elif x == width - 1 and y == height - 1: tile_coord = TILE_CORNER_BR
			elif y == 0: tile_coord = TILE_EDGE_TOP
			elif y == height - 1: tile_coord = TILE_EDGE_BOTTOM
			elif x == 0: tile_coord = TILE_EDGE_LEFT
			elif x == width - 1: tile_coord = TILE_EDGE_RIGHT
			else: tile_coord = TILE_FLOOR
			
			tile_map.set_cell(0, final_pos, 0, tile_coord)
	
	# 2. 在生成结束后，计算边界并发出信号
	var half_width_pixels = (width / 2.0) * TILE_SIZE
	var half_height_pixels = (height / 2.0) * TILE_SIZE
	
	var limits = Rect2(
		-half_width_pixels, 
		-half_height_pixels, 
		width * TILE_SIZE, 
		height * TILE_SIZE
	)	
	arena_generated.emit(limits)
	generate_decorations(limits)

func generate_decorations(area_rect: Rect2):
	print(area_rect)
	if not decorations_container: return
	if decoration_textures.is_empty(): return
	
	# 清空旧的装饰物
	for child in decorations_container.get_children():
		child.queue_free()

	for i in range(decoration_count):
		# 1. 创建一个全新的、空的 Sprite2D 节点
		var decoration_sprite = Sprite2D.new()
		
		# 2. 从图片数组中随机挑选一个纹理并应用
		decoration_sprite.texture = decoration_textures.pick_random()
		
		# 3. 随机找个位置
		var random_pos = Vector2(
			randf_range(area_rect.position.x + 64, area_rect.end.x - 64),
			randf_range(area_rect.position.y + 64, area_rect.end.y - 64)
		)
		decoration_sprite.position = random_pos
		
		# 4. (可选但推荐) 随机翻转和轻微旋转，增加多样性
		decoration_sprite.flip_h = randi() % 2 == 0
		#decoration_sprite.rotation_degrees = randf_range(-15.0, 15.0)
		
		# 5. 将这个配置好的 Sprite2D 添加到场景中
		decorations_container.add_child(decoration_sprite)
