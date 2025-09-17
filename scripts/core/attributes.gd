# res://scripts/core/attributes.gd
# 这是一个全局的属性定义文件。所有属性都在这里注册。
class_name Attributes

# 使用 enum 来创建我们的全局属性列表
enum Stat {
	# --- 核心属性 ---
	HEALTH,
	MAX_HEALTH,
	
	# --- 进攻属性 ---
	DAMAGE,
	ATTACK_SPEED,
	CRIT_CHANCE,
	
	# --- 防御属性 ---
	ARMOR,
	DODGE_CHANCE,
	
	# --- 主要属性 ---
	STRENGTH,
	DEXTERITY,
	INTELLIGENCE,
	
	# --- 其他 ---
	MOVE_SPEED,
	LUCK
}
