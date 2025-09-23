# res://resources/formulas/damage_formula.gd
class_name DamageFormula
extends Resource

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
		var attribute_value = source_stats.get_stat(contribution.attribute)
		
		# 应用该贡献的公式：(属性值 * 乘区) + 固定值
		calculated_value += (attribute_value * contribution.multiplier) + contribution.flat_bonus

	# 2. 应用最终的总乘区
	calculated_value *= final_multiplier

	return calculated_value
