# res://scripts/global/reward_manager.gd
extends Node

# ============================================================================
# -- 奖励池 (Data Pools) --
# ============================================================================
# 我们将在这里集中管理所有的奖励资源池。
# 使用 @export 允许我们直接在编辑器的 RewardManager 节点上配置它们。

# --- 升级奖励池 ---
# 包含了所有可能在升级时出现的 StatRewardData 资源
@export var upgrade_reward_pool: Array[RewardData]

# --- 商店商品池 ---
# 包含了所有可能在商店中刷新的商品（武器、道具等）
@export var shop_item_pool: Array[RewardData]

# --- (未来扩展) 敌人掉落池、宝箱池等 ---
# @export var enemy_loot_pool: Array[RewardData]


# ============================================================================
# -- 公共接口 (API) --
# ============================================================================

# --- 核心抽奖函数 ---
# 这是一个通用的、可复用的函数，用于从指定的池子中随机抽取奖励。
# @param pool: 要从中抽取的源数据池 (比如 upgrade_reward_pool)。
# @param count: 希望抽取的数量。
# @param allow_duplicates: 是否允许抽到重复的奖励？
# @return: 一个包含抽取结果的数组。
func get_rewards_from_pool(pool: Array, count: int, allow_duplicates: bool = false) -> Array[RewardData]:
	var options: Array[RewardData] = []
	
	# 健壮性检查
	if pool.is_empty():
		push_warning("尝试从一个空的奖励池中抽取奖励！")
		return options

	if allow_duplicates:
		# --- 允许重复的逻辑 ---
		for i in range(count):
			options.append(pool.pick_random())
	else:
		# --- 不允许重复的逻辑 (更常用) ---
		# 为了不修改原始的池子，我们先复制一份
		var temp_pool = pool.duplicate()
		temp_pool.shuffle() # 打乱数组顺序
		
		# 从打乱后的数组中，依次取出所需数量的奖励
		# 使用 min() 确保我们不会在池子数量不足时报错
		for i in range(min(count, temp_pool.size())):
			options.append(temp_pool.pop_front())
			
	return options
