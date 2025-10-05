extends BaseCreature
class_name EnemyMaster

var speed: float = 300.0
var swarm_parts: Dictionary[BaseCreature, bool] = {} # 使用字典避免重复添加
var neighbor_enemies: Dictionary[BaseCreature, int] = {} # int 表示计数次数, 一个 creature 可能被聚落里多个生物检测到
var velocity: Vector2 = Vector2.ZERO
var time_to_last_activation: float = 0.0

const ACTIVATION_INTERVAL: float = 3.0
const ACTIVATION_STEP: float = 150.0
const ACTIVATION_BATCH_INTERVAL: float = 0.3

func _ready() -> void:
	update_group(Global.GROUP.ENEMY, self)

func _physics_process(delta: float) -> void:
	_update_swarm_parts_and_enemies()
	tmp_update_label()

	#region 激活
	time_to_last_activation += delta
	if time_to_last_activation >= ACTIVATION_INTERVAL:
		_activate_swarm()
		time_to_last_activation = 0.0
	#endregion

func _activate_swarm() -> void:
	_activate_self()
	# 记录当前激活时刻的副兽数组
	var parts_snapshot: Array[BaseCreature] = swarm_parts.keys()
	if parts_snapshot.is_empty():
		return

	var master_pos: Vector2 = global_position
	var step: float = ACTIVATION_STEP
	var max_distance: float = 0.0
	var eligible_parts: Array[SwarmPart] = []

	# 预扫描：筛选可激活的副兽并计算最大距离
	for member in parts_snapshot:
		if member and is_instance_valid(member) and member is SwarmPart:
			var part := member as SwarmPart
			eligible_parts.append(part)
			var d: float = master_pos.distance_to(part.global_position)
			if d > max_distance:
				max_distance = d

	if eligible_parts.is_empty():
		return

	# 基于最大距离计算需要的分组数量（[0, step), [step, 2*step) ... 最后一组覆盖到最大距离）
	var num_groups: int = int(floor(max_distance / step)) + 1
	var activation_groups: Array[Array] = [] # Array[Array[SwarmPart]]
	activation_groups.resize(num_groups)
	for i in range(num_groups):
		activation_groups[i] = []

	# 构建二维激活顺序数组
	for part in eligible_parts:
		if part and is_instance_valid(part):
			var d: float = master_pos.distance_to(part.global_position)
			var idx: int = int(floor(d / step))
			idx = clamp(idx, 0, num_groups - 1)
			activation_groups[idx].append(part)

	# 依次激活每一组，组间间隔一定时间
	for batch in activation_groups:
		if batch.size() == 0:
			continue
		for part in batch:
			if part and is_instance_valid(part):
				part.activate(neighbor_enemies.keys())
		await get_tree().create_timer(ACTIVATION_BATCH_INTERVAL).timeout

## 我没时间研究怎么在阵营更换时正确修改字典/数组了, 直接在 physic_process 里一直检查
func _update_swarm_parts_and_enemies() -> void:
	var swarm_part_keys := swarm_parts.keys()
	var enemy_keys := neighbor_enemies.keys()
	# 如果有非本阵营的, 移除
	for part in swarm_part_keys:
		if part and is_instance_valid(part) and part.group == group:
			continue
		remove_swarm_part(part)

	# 如果有非敌对的, 移除
	for enemy in enemy_keys:
		if enemy and is_instance_valid(enemy) and enemy.group == Global.GROUP.FRIEND:
			continue
		remove_enemy(enemy)

func _activate_self() -> void:
	pass

func add_swarm_part(swarm_part: BaseCreature) -> void:
	swarm_parts[swarm_part] = true
	swarm_part.update_group(Global.GROUP.ENEMY, self)

func remove_swarm_part(swarm_part: BaseCreature) -> void:
	if swarm_parts.has(swarm_part):
		swarm_parts.erase(swarm_part)
	if swarm_part and is_instance_valid(swarm_part):
		swarm_part.update_group(Global.GROUP.NEUTRAL, null)

func add_enemy(creature: BaseCreature) -> void:
	if neighbor_enemies.has(creature):
		neighbor_enemies[creature] += 1
	else:
		neighbor_enemies[creature] = 1

func remove_enemy(creature: BaseCreature) -> void:
	if not neighbor_enemies.has(creature):
		return
	neighbor_enemies[creature] -= 1
	if neighbor_enemies[creature] <= 0:
		neighbor_enemies.erase(creature)

# override
func die() -> void:
	call_deferred("queue_free")
	var swarm_parts_copy := swarm_parts.duplicate()
	for part in swarm_parts_copy:
		remove_swarm_part(part)
