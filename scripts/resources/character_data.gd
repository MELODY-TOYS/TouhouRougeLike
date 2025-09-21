# res://scripts/resources/character_data.gd
class_name CharacterData
extends Resource

# --- 基础信息 ---
# 用于角色选择界面和游戏内UI的展示
@export_group("基础信息")
@export var character_name: String = "角色名称"
@export_multiline var description: String = "角色的背景故事或玩法描述"
@export var character_icon: Texture2D # 用于角色选择界面的小图标

# --- 视觉表现 ---
# 定义了角色在游戏世界中的外观
@export_group("视觉表现")
@export var character_scene: PackedScene # 指向角色的场景 (例如 player_cirno.tscn)
# 如果所有角色共享同一个场景，可以用下面的纹理替换方案
# @export var character_texture: Texture2D

# --- 核心玩法数据 ---
# 定义了角色的数值和特殊能力
@export_group("核心玩法")
# 链接到该角色的基础属性资源文件 (ActorStatsData 类型)
@export var base_stats_data: ActorStatsData 
## 一个数组，用于存放该角色的所有独特天赋 (TalentResource 类型)
#@export var talents: Array[TalentResource] = []
# [可选] 初始武器
# @export var starting_weapon: WeaponResource
