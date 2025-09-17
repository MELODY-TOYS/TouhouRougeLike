# res://scripts/global/global.gd
# 这是一个全局单例，用于存储整个游戏都可以访问的信息。
extends Node

# 我们将在这里存储对玩家节点的引用。
# 使用 Node2D 类型比 CharacterBody2D 更通用，以防未来玩家类型改变。
var player: Node2D = null
