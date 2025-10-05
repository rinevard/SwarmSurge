extends Node2D

func _process(delta: float) -> void:
	print("fps: ", Engine.get_frames_per_second())
