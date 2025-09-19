# res://scripts/resources/weapon_resource.gd
class_name WeaponResource
extends Resource

# --- 枚举定义 ---
# 行为类型，用于WeaponInstance决定如何“使用”attack_scene
enum BehaviorType { 
	PROJECTILE,      # 作为发射物射出
	MELEE_THRUST,    # 执行向前刺击动画
	MELEE_SWIPE      # 执行挥舞/旋转动画
}

# 武器标签，用于未来的套装奖励系统
# enum Tag { BLADE, GUN, MAGIC, PRIMITIVE, ... }

# --- 核心数据 ---
@export_group("核心信息")
@export var id: StringName = &""         # 唯一ID，如 &"wpn_knife"
@export var weapon_name: String = ""       # 显示名称
@export var tags: Array[String] = []       # 标签列表 (暂时用字符串，未来可转枚举)

@export_group("行为定义")
# 武器的核心行为类型
@export var behavior_type: BehaviorType

# 该武器行为所关联的“攻击实例”场景 (子弹、刀光等)
# 对于MELEE类型，这可能是刀光特效；对于PROJECTILE，这是子弹本身。
@export var attack_scene: PackedScene

@export_group("核心数值")
# 武器的冷却时间，未来可以用公式资源代替
@export var base_cooldown: float = 1.0
@export var range: float = 300.0 # 武器的有效范围 (索敌和攻击都用)
# 武器的基础伤害公式
@export var damage_formula: DamageFormula
