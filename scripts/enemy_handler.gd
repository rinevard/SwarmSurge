extends Node2D

@onready var creatures: Node2D = $"../Creatures"
@onready var swarm_master: SwarmMaster = $"../Creatures/SwarmMaster"

const ENEMY_MASTER = preload("res://scenes/creatures/enemy_master.tscn")
const HEDGEHOG = preload("res://scenes/creatures/hedgehog.tscn")
const SCORPION = preload("res://scenes/creatures/scorpion.tscn")
const TURTLE = preload("res://scenes/creatures/turtle.tscn")

# 生成参数常量
var check_interval: float = 10.0 # 每 10 秒检查一次敌人聚落数量, 太少就生成新聚落, 友方聚落越大, 检查间隔越大
const MIN_CHECK_INTERVAL: float = 10.0
const MAX_CHECK_INTERVAL: float = 15.0
const MAX_ENEMY_COLONIES: int = 2  # 最大敌方聚落数量
const BASE_SPAWN_DISTANCE: float = 1500.0  # 基础生成距离
const DISTANCE_PER_SWARM_SIZE: float = 70.0  # 每个友方生物增加的距离
const ENEMY_SIZE_MIN_RATIO: float = 0.4  # 敌方聚落大小相对当前我方聚落大小的最小比例
const ENEMY_SIZE_MAX_RATIO: float = 0.7  # 同上, 不过是最大比例
const PART_MIN_DISTANCE: float = 20.0  # 敌方副兽与master最小距离
const PART_MAX_DISTANCE: float = 100.0  # 同上, 不过是最大距离

# 敌方生物权重
const HEDGEHOG_WEIGHT: float = 0.4
const SCORPION_WEIGHT: float = 0.4
const TURTLE_WEIGHT: float = 0.2

# 在 base 距离(1500) + 聚落大小 * 额外距离(70)的随机位置生成敌方聚落
# 一个 ENEMY_MASTER, swarm_master 聚落大小 * randfrange(0.7, 1.0) 个随机生物
# 敌方聚落中心是enemymaster, 周围绕着一圈生物, 生物与master的距离在 (20, 200) 间随机
# 权重——刺猬: 0.4, 蝎子: 0.4, 乌龟: 0.2
# 把生物加到 creatures 节点下
# 每次取随机方向生成聚落

var _check_timer: float = 0.0

func _physics_process(delta: float) -> void:
	# 教程结束前不刷怪
	if not Global.tutorial_ended:
		return

	_check_timer += delta
	if _check_timer >= check_interval:
		print("check")
		_check_timer = 0.0
		var count := _count_enemy_masters()
		if count < MAX_ENEMY_COLONIES:
			_spawn_enemy_colony()

func _count_enemy_masters() -> int:
	var n := 0
	for child in creatures.get_children():
		if child is EnemyMaster:
			n += 1
	return n

func _spawn_enemy_colony() -> void:
	# 基于友方聚落大小，决定敌方副兽数量与生成距离
	var friend_swarm_size: int = 0
	if swarm_master and is_instance_valid(swarm_master):
		friend_swarm_size = swarm_master.swarm_parts.keys().size()

	check_interval = clamp(MIN_CHECK_INTERVAL + friend_swarm_size, MIN_CHECK_INTERVAL, MAX_CHECK_INTERVAL)
	
	var num_parts: int = int(round(float(friend_swarm_size) * randf_range(ENEMY_SIZE_MIN_RATIO, ENEMY_SIZE_MAX_RATIO)))
	num_parts = 1 if num_parts <= 1 else num_parts
	var distance_from_base: float = BASE_SPAWN_DISTANCE + float(friend_swarm_size) * DISTANCE_PER_SWARM_SIZE

	# 随机方向与中心点
	var dir_angle: float = randf() * TAU
	var dir: Vector2 = Vector2(cos(dir_angle), sin(dir_angle)).normalized()
	var center: Vector2 = Vector2.ZERO
	if swarm_master and is_instance_valid(swarm_master):
		center = swarm_master.global_position + dir * distance_from_base
	else:
		center = dir * distance_from_base

	# 敌方老大
	var enemy_master: EnemyMaster = ENEMY_MASTER.instantiate()
	enemy_master.global_position = center
	creatures.add_child(enemy_master)
	# 限制位置范围
	enemy_master.global_position.x = clamp(enemy_master.global_position.x, -2350, 4750)
	enemy_master.global_position.y = clamp(enemy_master.global_position.y, -1200, 2900)

	# 敌方副兽环绕分布
	for i in range(num_parts):
		var packed_scene := _choose_enemy_scene_by_weight()
		var part := packed_scene.instantiate() as SwarmPart
		var r: float = randf_range(PART_MIN_DISTANCE, PART_MAX_DISTANCE)
		var a: float = randf() * PI * 2.0
		var pos: Vector2 = center + Vector2(cos(a), sin(a)) * r
		creatures.add_child(part)
		# 无需手动调用 add_swarm_part, 敌方主兽会在足够接近时自动添加副兽
		# 限制位置范围
		pos.x = clamp(pos.x, -2350, 4750)
		pos.y = clamp(pos.y, -1200, 2900)
		part.global_position = pos

func _choose_enemy_scene_by_weight() -> PackedScene:
	var r := randf()
	if r < HEDGEHOG_WEIGHT:
		return HEDGEHOG
	elif r < HEDGEHOG_WEIGHT + SCORPION_WEIGHT:
		return SCORPION
	else:
		return TURTLE
