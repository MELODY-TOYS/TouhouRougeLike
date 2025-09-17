extends Resource
class_name SpawnEvent

# --- 核心数据字段 ---

# 1. 何时 (When)
# 在波次开始后多少秒触发此事件
@export var trigger_time: float = 0.0

# 2. 生成谁 (Who)
# 我们使用 PackedScene，这样设计师可以直接把敌人的 .tscn 文件拖拽进来
@export var enemy_scene: PackedScene

# 3. 生成多少 (How Many)
# 本次事件生成的敌人数量
@export var count: int = 1

# 4. 在哪里 (Where)
# 我们使用枚举 (Enum) 来提供一个清晰的下拉选项，避免设计师手打字符串出错
enum SpawnLocation {
	AROUND_PLAYER, # 在玩家角色周围的一个安全环上
	RANDOM_IN_ARENA # 在竞技场内的随机位置
}
@export var spawn_location: SpawnLocation = SpawnLocation.AROUND_PLAYER
