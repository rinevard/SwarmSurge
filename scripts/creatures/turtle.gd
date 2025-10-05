extends SwarmPart
class_name Turtle

const ALIGN_TIME: float = 0.6

var shield: TurtleShield = null

# 缩放动画相关
var _is_scaling: bool = false
var _scale_progress: float = 0.0
const SCALE_DURATION: float = 0.3  # 缩放动画总时间
const SCALE_MAX: float = 2.0  # 最大缩放倍数

@onready var shield_pos_marker: Marker2D = $ShieldPosMarker

## override, 转动龟壳使其在 master 到自己的连线的射线上
func _physics_process(delta: float) -> void:
	if Global.game_paused:
		return
	super(delta)
	_rotate_shield(delta)

## override
func activate(_enemies: Array[BaseCreature]) -> void:
	if not shield or not is_instance_valid(shield):
		return
	
	# 如果已经在缩放中，忽略新的激活
	if _is_scaling:
		return

	if group == Global.GROUP.FRIEND:
		SfxPlayer.play_sfx(SfxPlayer.SFXs.SHIELD, global_position)
	# 开始缩放动画
	_is_scaling = true
	_scale_progress = 0.0

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

	# 如果正在缩放动画中，处理缩放
	if _is_scaling:
		_handle_scaling_animation(delta)

	# 常态：统一速度指向目标
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
	var angle_step_per_sec: float = angle_diff / max(ALIGN_TIME, 0.0001)
	shield.rotation = current_angle + angle_step_per_sec * delta

	# 计算平移速度并应用
	var pos_offset: Vector2 = desired_pos - shield.global_position
	var move_step_per_sec: Vector2 = pos_offset / max(ALIGN_TIME, 0.0001)
	shield.global_position = shield.global_position + move_step_per_sec * delta

func _handle_scaling_animation(delta: float) -> void:
	_scale_progress += delta
	
	if _scale_progress >= SCALE_DURATION:
		# 缩放动画完成，重置状态和缩放
		_is_scaling = false
		_scale_progress = 0.0
		shield.scale = Vector2.ONE
		return
	
	# 动画分为三个阶段：
	# 0-35%: 快速弹出放大（ease-out有往外推的感觉）
	# 35-65%: 停顿在最大值
	# 65-100%: 快速缩回（ease-in）
	var t = _scale_progress / SCALE_DURATION  # 归一化时间 [0, 1]
	var scale_value: float
	
	if t < 0.35:
		# 前段：快速弹出，使用 ease-out 曲线（1 - (1-x)^3）让它有"推出去"的感觉
		var phase_t = t / 0.35  # [0, 1]
		var eased_t = 1.0 - pow(1.0 - phase_t, 3.0)  # ease-out cubic
		scale_value = lerp(1.0, SCALE_MAX, eased_t)
	elif t < 0.65:
		# 中段：停顿在最大值
		scale_value = SCALE_MAX
	else:
		# 后段：快速缩回，使用 ease-in 曲线（x^2）
		var phase_t = (t - 0.65) / 0.35  # [0, 1]
		var eased_t = pow(phase_t, 2.0)  # ease-in quadratic
		scale_value = lerp(SCALE_MAX, 1.0, eased_t)
	
	shield.scale = Vector2(scale_value, scale_value)

## override
func die() -> void:
	super()
