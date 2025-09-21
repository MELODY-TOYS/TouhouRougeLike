# res://scripts/player/weapons/melee_weapon_instance.gd
class_name MeleeWeaponInstance
extends BaseWeaponInstance

# --- 近战通用状态 ---
# 用于防止单次攻击对同一敌人造成多次伤害
# 这个变量现在由所有继承此类的近战武器共享
var hit_list: Array = []

# --- Godot 生命周期 ---
func _ready():
	super() # 确保首先执行 BaseWeaponInstance 的 _ready()
	_setup_hitbox()

# --- 内部设置函数 ---
# 负责查找并连接 Hitbox 的信号，这段代码从子类中提取而来
func _setup_hitbox():
	var hitbox = get_node_or_null("%Hitbox")
	if hitbox and hitbox is Area2D:
		# 连接到下面定义的通用命中处理函数
		hitbox.body_entered.connect(_on_hitbox_body_entered)
	else:
		# 如果找不到 Hitbox，发出警告，因为所有近战武器都依赖它
		push_error("错误: MeleeWeaponInstance '%s' 需要一个名为 'Hitbox' 的 Area2D 子节点。" % name)

# --- 通用命中处理 ---
# 这段代码从 SwipeWeapon 和 ThrustWeapon 中完全提取，因为它们是重复的
func _on_hitbox_body_entered(body: Node2D):
	# 检查碰撞的是否是敌人，以及本次攻击是否已命中过
	if not body.is_in_group("enemy") or hit_list.has(body):
		return # 如果是，则忽略

	# 将敌人添加到命中列表，防止本轮攻击重复造成伤害
	hit_list.append(body)

	# 获取敌人的属性组件并造成伤害
	var target_stats = ASC.get_stats_component_from(body)
	if target_stats and weapon_data:
		# 伤害计算暂时保持不变
		var final_damage = weapon_data.damage_formula.calculate(ASC.get_stats_component_from(Global.player))
		target_stats.process_damage(Global.player, self, final_damage)
