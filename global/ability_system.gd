# res://scripts/global/asc.gd
# 这是一个全局单例，其唯一职责是提供一个可靠的服务，
# 用于从任何节点上查找到其对应的StatsComponent。
extends Node

# --- 核心公共API ---
# 这个函数将是我们项目中查找StatsComponent的唯一标准方法。
# 它不再是私有的(_find)，也不再基于分组。

func get_stats_component_from(node: Node) -> BaseStatsComponent:
	# 1. 健壮性检查
	if not is_instance_valid(node):
		return null

	# 2. 按类查找：检查节点自身
	if node is BaseStatsComponent:
		return node
		
	# 3. 按类查找：遍历子节点
	for child in node.get_children():
		if child is BaseStatsComponent:
			return child
	
	return null # 如果找不到，返回null
