extends BaseCreature
class_name SwarmPart

var velocity: Vector2 = Vector2.ZERO

const MAX_SPEED: float = 600.0
const MIN_SPEED: float = 80.0
const MAX_FORCE: float = 800.0

# TODO: 这些参数应该根据聚落大小动态调整, 当 master 获取了新生物就可以调整
# 另一个思路是这些移动变量全都由 master 管理, 一个聚落里一个 master 管理本聚落的移动变量 
const PERCEPTION_RADIUS: float = 300.0 # 把本距离内的生物视作邻居
const SEPARATION_RADIUS: float = 120.0 # 相邻生物应当尽量保持本距离

const WEIGHT_SEPARATION: float = 5.0
const WEIGHT_KEEP_DISTANCE: float = 3.0

func _physics_process(delta: float) -> void:
	tmp_update_label()
	if group == Global.GROUP.NEUTRAL:
		return

	var neighbors: Array[SwarmPart] = _get_neighbors()
	var separation_force: Vector2 = _calc_separation(neighbors) * WEIGHT_SEPARATION
	var keep_distance_force: Vector2 = Vector2.ZERO
	if swarm_master:
		var master_next_global_position: Vector2 = swarm_master.global_position + swarm_master.velocity * delta
		keep_distance_force = (master_next_global_position - global_position) * WEIGHT_KEEP_DISTANCE

	var acceleration: Vector2 = separation_force + keep_distance_force
	velocity += acceleration * delta
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
	# 避免抖动
	if velocity.length() < MIN_SPEED:
		velocity = velocity.normalized() * MIN_SPEED

	position += velocity * delta

func activate(_enemies: Array[BaseCreature]) -> void:
	print(name + " is activated!")

#region 聚落移动
func _get_neighbors() -> Array[SwarmPart]:
	var result: Array[SwarmPart] = []
	if swarm_master == null:
		return result
	if not (swarm_master is SwarmMaster):
		return result
	var master := swarm_master as SwarmMaster
	for member in master.swarm_parts.keys():
		if member == self:
			continue
		if member is SwarmPart:
			var part := member as SwarmPart
			if part.global_position.distance_to(global_position) <= PERCEPTION_RADIUS:
				result.append(part)
	return result

func _calc_separation(neighbors: Array[SwarmPart]) -> Vector2:
	var steer: Vector2 = Vector2.ZERO
	var count: int = 0
	for n in neighbors:
		var d := global_position.distance_to(n.global_position)
		if d > 0.0 and d < SEPARATION_RADIUS:
			var diff: Vector2 = (global_position - n.global_position)
			# 越近影响越大
			diff = diff.normalized() / max(d, 1.0)
			steer += diff
			count += 1
	# 同样不能离主兽太近
	if swarm_master != null:
		var d := global_position.distance_to(swarm_master.global_position)
		if d > 0.0 and d < SEPARATION_RADIUS:
			var diff: Vector2 = (global_position - swarm_master.global_position)
			diff = diff.normalized() / max(d, 1.0)
			steer += diff
			count += 1
	if count > 0:
		steer /= float(count)
	if steer == Vector2.ZERO:
		return Vector2.ZERO
	var desired := steer.normalized() * MAX_SPEED
	return _steer_towards(desired)

func _steer_towards(desired_velocity: Vector2) -> Vector2:
	var steer: Vector2 = desired_velocity - velocity
	var steer_len := steer.length()
	if steer_len > MAX_FORCE:
		steer = steer * (MAX_FORCE / steer_len)
	return steer
#endregion
