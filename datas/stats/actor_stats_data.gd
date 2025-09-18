# res://resources/stats/actor_stats_data.gd
class_name ActorStatsData
extends Resource

# 这是核心。我们导出一个字典。
# Godot 4 的编辑器非常强大，它会自动识别出键的类型是 Attributes.Stat 枚举，
# 并在你添加新条目时提供一个下拉选框，这正是你想要的！
# 值的类型是 float。
@export var base_attributes: Dictionary[Attributes.Stat, float] = {}
