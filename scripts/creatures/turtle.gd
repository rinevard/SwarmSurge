extends SwarmPart
class_name Turtle

const SHIELD_MIN_SCALE: float = 0.3
const SHIELD_MAX_SCALE: float = 1.0

const SHIELD_MAX_TURN_SPEED: float = 3.0 # rad/s，转向速度上限
const SHIELD_MOVE_STIFFNESS: float = 8.0 # 位置误差 -> 期望速度 的比例系数
const SHIELD_MAX_SPEED: float = 300.0 # 龟壳最大平移速度
const SHIELD_VEL_DAMPING: float = 4.0 # 速度阻尼（越大收敛越快）

var shield: TurtleShield = null
var shield_velocity: Vector2 = Vector2.ZERO

@onready var shield_pos_marker: Marker2D = $ShieldPosMarker

## override, 转动龟壳使其在 master 到自己的连线的射线上
func _physics_process(delta: float) -> void:
	super(delta)
	_rotate_shield(delta)

## override
func activate(_enemies: Array[BaseCreature]) -> void:
	print("turtle activated!")

## override, 进入中立时移除龟壳, 非中立时创建龟壳
func update_group(p_group: Global.GROUP, p_swarm_master: BaseCreature) -> void:
	super(p_group, p_swarm_master)
	if p_group == Global.GROUP.NEUTRAL:
		if shield and is_instance_valid(shield):
			shield.queue_free()
			shield = null
			shield_velocity = Vector2.ZERO
	else:
		if not shield:
			shield = TurtleShield.new_shield(shield_pos_marker.global_position, p_group)
			call_deferred("add_child", shield)
			shield_velocity = Vector2.ZERO

func _rotate_shield(delta) -> void:
	if shield == null or not is_instance_valid(shield):
		return
	if swarm_master == null:
		return

	var master_to_self: Vector2 = global_position - swarm_master.global_position
	if master_to_self == Vector2.ZERO:
		return

	# 目标角度为该射线角度 + PI/2, 渐进式逼近
	var desired_angle: float = master_to_self.angle() + PI/2
	var current_angle: float = shield.global_rotation
	var angle_diff: float = wrapf(desired_angle - current_angle, -PI, PI)
	var max_turn: float = SHIELD_MAX_TURN_SPEED * delta
	var turn_step: float = clamp(angle_diff, -max_turn, max_turn)
	shield.global_rotation = current_angle + turn_step

	# 目标位置：沿 master->self 的方向, 距离取自初始标记到本体的距离
	var desired_radius: float = (shield_pos_marker.global_position - global_position).length()
	var desired_pos: Vector2 = global_position + master_to_self.normalized() * desired_radius

	# 根据位置误差计算期望速度，并做阻尼朝期望速度靠拢
	var pos_error: Vector2 = desired_pos - shield.global_position
	var desired_vel: Vector2 = pos_error * SHIELD_MOVE_STIFFNESS
	if desired_vel.length() > SHIELD_MAX_SPEED:
		desired_vel = desired_vel.normalized() * SHIELD_MAX_SPEED
	var vel_diff: Vector2 = desired_vel - shield_velocity
	var max_step: float = SHIELD_VEL_DAMPING * delta * SHIELD_MAX_SPEED
	var vel_step: Vector2 = vel_diff
	var step_len: float = vel_step.length()
	if step_len > max_step and step_len > 0.0:
		vel_step = vel_step.normalized() * max_step
	shield_velocity += vel_step

	# 限速并更新位置
	if shield_velocity.length() > SHIELD_MAX_SPEED:
		shield_velocity = shield_velocity.normalized() * SHIELD_MAX_SPEED
	shield.global_position += shield_velocity * delta
