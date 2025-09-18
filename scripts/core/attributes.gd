# res://scripts/core/attributes.gd
class_name Attributes

enum Stat {
	# ==================================================================
	# 类别一：基础属性 (Base Stats)
	# ==================================================================
	
	# --- 生存 ---
	MAX_HEALTH,           # 最大生命值
	HEALTH,               # 当前生命值
	HEALTH_REGEN,         # 每秒生命回复
	ARMOR,                # 护甲
	DODGE_CHANCE,         # 闪避几率
	
	# --- 伤害 (按类型细分) ---
	MELEE_DAMAGE,         # 近战伤害
	RANGED_DAMAGE,        # 远程伤害
	ELEMENTAL_DAMAGE,     # 元素伤害
	
	# --- 通用 ---
	MOVE_SPEED,           # 移动速度
	ATTACK_SPEED,         # 攻击速度 (通常是百分比)
	CRIT_CHANCE,          # 暴击几率
	CRIT_DAMAGE,          # 暴击伤害倍率

	# ==================================================================
	# 类别二：特殊与功能性属性 (Special & Utility Stats)
	# ==================================================================
	
	LUCK,                 # 幸运
	XP_GAIN_PERCENT,      # 经验获取百分比加成
	MONEY_GAIN_PERCENT,   # 金钱获取百分比加成
	PICKUP_RADIUS,        # 拾取范围
	LIFE_STEAL,           # 生命偷取
	

}
