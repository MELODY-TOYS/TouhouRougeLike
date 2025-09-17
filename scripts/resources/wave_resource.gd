# scripts/resources/wave_resource.gd
extends Resource
class_name WaveResource

# --- 核心数据字段 ---

# 波次名称，方便在编辑器里识别
@export var wave_name: String = "New Wave"

# 整个波次的总时长。这对于我们未来制作时间轴编辑器至关重要。
@export var duration: float = 60.0 # 默认一波 60 秒

# 核心：一个包含了多个 SpawnEvent 资源的数组。
# 通过指定类型 Array[SpawnEvent]，Godot 的检查器会变得非常智能，
# 只允许我们将 SpawnEvent 类型的资源拖拽进这个数组里。
@export var events: Array[SpawnEvent]
