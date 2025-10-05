extends Camera2D

@export var follow_target: Node2D

func _physics_process(delta: float) -> void:
	global_position = follow_target.global_position
