# res://scripts/resources/enemy_stats.gd
class_name EnemyStats # class_name 让我们可以在Godot里直接创建这种类型的资源
extends Resource

@export_group("Health")
@export var max_health: float = 10.0

@export_group("Movement")
@export var move_speed: float = 50.0

@export_group("Combat")
@export var damage: float = 5.0
