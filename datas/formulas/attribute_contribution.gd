# res://resources/formulas/attribute_contribution.gd
class_name AttributeContribution
extends Resource

# 我们将类型提示 Attributes.Stat 放在这里
@export var attribute: Attributes.Stat

@export var multiplier: float = 1.0
@export var flat_bonus: float = 0.0
