# res://scripts/effects/base_effect.gd
class_name BaseEffect
extends Node2D

# 以后所有特效场景的根节点都应该附加这个脚本
# 或者附加继承自这个脚本的子类脚本 (比如我们之前的 self_destruct_effect.gd)

# 我们可以在这里定义所有特效都共有的行为，比如：
# func setup(scale: float, rotation: float):
#     self.scale = Vector2.ONE * scale
#     self.rotation = rotation
@onready var vfx:GPUParticles2D= $GPUParticles2D

func _ready() -> void:
	vfx.emitting=true
