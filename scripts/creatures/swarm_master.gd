extends BaseCreature
class_name SwarmMaster

var speed: float = 300.0
var swarm_parts: Array[BaseCreature] = []
var velocity: Vector2 = Vector2.ZERO
var time_to_last_activation: float = 0.0

const ACTIVATION_INTERVAL: float = 3.0
const ACTIVATION_STEP: float = 150.0
const ACTIVATION_BATCH_INTERVAL: float = 0.3

func _ready() -> void:
	update_group(Global.GROUP.FRIEND, self)

func _physics_process(delta: float) -> void:
	tmp_update_label()

	time_to_last_activation += delta
	if time_to_last_activation >= ACTIVATION_INTERVAL:
		_activate_swarm()
		time_to_last_activation = 0.0

	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	
	velocity = direction.normalized() * speed
	position += velocity * delta

func _activate_swarm() -> void:
	_activate()
	# 记录当前激活时刻的副兽数组
	var parts_snapshot: Array[BaseCreature] = swarm_parts.duplicate()
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
	var activation_groups: Array[Array] = []
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
				part.activate()
		await get_tree().create_timer(ACTIVATION_BATCH_INTERVAL).timeout
	

func _activate() -> void:
	pass

func add_swarm_part(swarm_part: BaseCreature) -> void:
	swarm_parts.append(swarm_part)
	swarm_part.update_group(Global.GROUP.FRIEND, self)

func remove_swarm_part(swarm_part: BaseCreature) -> void:
	swarm_parts.erase(swarm_part)
	swarm_part.update_group(Global.GROUP.NEUTRAL, null)
