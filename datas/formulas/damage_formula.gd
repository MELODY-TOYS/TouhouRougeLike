# res://resources/formulas/damage_formula.gd
class_name DamageFormula
extends Resource

# --- 核心修正：强制预加载依赖 ---
# 我们在脚本的顶部创建一个常量，并使用preload()来加载Attributes.gd。
# 这会强制Godot的解析器在处理后续代码之前，先去加载并理解Attributes.gd。
# 这样，当它遇到 @export_enum(Attributes.Stat) 时，它就已经知道 Attributes 是什么了。
const Attributes = preload("res://scripts/core/attributes.gd")


# -----------------------------------------------------------------------------
# -- DamageFormula 的主属性 --
# -----------------------------------------------------------------------------

# --- 基础值 ---
@export var base_value: float = 0.0

# --- 属性贡献列表 ---
@export var attribute_contributions: Array[AttributeContribution] = []

# --- 最终乘区 ---
@export var final_multiplier: float = 1.0


# -----------------------------------------------------------------------------
# -- 核心计算函数 --
# -----------------------------------------------------------------------------
func calculate(source_stats: BaseStatsComponent) -> float:
	var calculated_value = base_value

	# 1. 遍历并累加所有属性的贡献
	for contribution in attribute_contributions:
		if not contribution: 
			continue
		
		# 从攻击方的StatsComponent中，获取当前属性的数值。
		var attribute_value = source_stats.get_attribute_value(contribution.attribute)
		
		# 应用该贡献的公式：(属性值 * 乘区) + 固定值
		calculated_value += (attribute_value * contribution.multiplier) + contribution.flat_bonus

	# 2. 应用最终的总乘区
	calculated_value *= final_multiplier

	return calculated_value
