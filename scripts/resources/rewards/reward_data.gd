# res://scripts/resources/rewards/reward_data.gd
class_name RewardData
extends Resource

# ============================================================================
# -- 显示数据 (所有奖励共有的属性) --
# ============================================================================
@export_group("显示信息")

# 奖励的名称，会直接显示在UI上
@export var display_name: String = "未命名奖励"

@export var type_text: String = "通用奖励"

# 奖励的图标
@export var icon: Texture2D

@export var base_price: int = 0 # 价格在这里

# 奖励的详细描述，支持多行输入
@export_multiline var description: String = "这是一个奖励。"

# (未来扩展) 奖励的稀有度，可以用来决定UI卡片的边框颜色等
# enum Rarity { COMMON, RARE, EPIC }
# @export var rarity: Rarity = Rarity.COMMON


# ============================================================================
# -- 效果逻辑 (所有奖励都必须实现的行为) --
# ============================================================================

# “应用效果”函数。这是一个“虚拟”函数。
# 它定义了一个“合同”：任何自称是RewardData的东西，都必须能被“应用”。
# 但具体如何应用，由它的子类自己去决定。
func apply_effect() -> void:
	# 在基类中，我们只抛出一个错误，强制子类去重写(override)这个方法。
	push_error("函数 apply_effect() 必须被 RewardData 的子类 (%s) 实现！" % self.get_script().get_path())
