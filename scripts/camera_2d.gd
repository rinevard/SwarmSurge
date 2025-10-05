extends Camera2D

@export var follow_target: Node2D
@export var smoothing_speed: float = 5.0

func _physics_process(delta: float) -> void:
	if follow_target:
		global_position = global_position.lerp(follow_target.global_position, smoothing_speed * delta)
