extends SwarmPart
class_name Turtle

const SHIELD_MIN_SCALE: float = 0.3
const SHIELD_MAX_SCALE: float = 1.0

const FAST_ALIGN_TIME: float = 0.15
const SLOW_ALIGN_TIME: float = 1.0

var shield: TurtleShield = null

var _fast_align_time_left: float = 0.0

@onready var shield_pos_marker: Marker2D = $ShieldPosMarker

## override, 转动龟壳使其在 master 到自己的连线的射线上
func _physics_process(delta: float) -> void:
	super(delta)
	_rotate_shield(delta)

## override
func activate(_enemies: Array[BaseCreature]) -> void:
	_fast_align_time_left = FAST_ALIGN_TIME

## override, 进入中立时移除龟壳, 非中立时创建龟壳
func update_group(p_group: Global.GROUP, p_swarm_master: BaseCreature) -> void:
	super(p_group, p_swarm_master)
	if p_group == Global.GROUP.NEUTRAL:
		if shield and is_instance_valid(shield):
			shield.queue_free()
			shield = null
	else:
		if not shield:
			shield = TurtleShield.new_shield(shield_pos_marker.global_position, p_group)
			call_deferred("add_child", shield)
		else:
			# 同步阵营
			shield.update_group(p_group)

func _rotate_shield(delta) -> void:
	if not shield or not is_instance_valid(shield):
		return
	if group == Global.GROUP.NEUTRAL:
		return
	if swarm_master == null:
		return

	# 选择当前对齐时间（快/慢）
	var time_to_target := SLOW_ALIGN_TIME
	if _fast_align_time_left > 0.0:
		time_to_target = FAST_ALIGN_TIME
		_fast_align_time_left = _fast_align_time_left - delta

	# 目标角度
	var master_to_self: Vector2 = global_position - swarm_master.global_position
	if master_to_self == Vector2.ZERO:
		return
	var target_angle: float = master_to_self.angle() + PI/2

	# 目标位置
	var radius: float = (shield_pos_marker.global_position - global_position).length()
	var desired_pos: Vector2 = global_position + master_to_self.normalized() * radius

	# 计算角速度并应用
	var current_angle: float = shield.global_rotation
	var angle_diff: float = wrapf(target_angle - current_angle, -PI, PI)
	var angle_step_per_sec: float = angle_diff / max(time_to_target, 0.0001)
	shield.rotation = current_angle + angle_step_per_sec * delta

	# 计算平移速度并应用
	var pos_offset: Vector2 = desired_pos - shield.global_position
	var move_step_per_sec: Vector2 = pos_offset / max(time_to_target, 0.0001)
	shield.global_position = shield.global_position + move_step_per_sec * delta

## override
func die() -> void:
	super()
