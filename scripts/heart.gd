extends Control
class_name Heart

var tween_duration: float = 0.3
var is_melt = false

@onready var heart_full: TextureRect = $HeartFull

func _ready() -> void:
	heart_full.material = heart_full.material.duplicate()

func melt() -> void:
	if is_melt:
		return
	var tween = create_tween()
	tween.tween_method(
		func(value): 
			if heart_full.material is ShaderMaterial:
				heart_full.material.set_shader_parameter("progress", value),
		0.0,
		1.0,
		tween_duration
	).set_trans(Tween.TRANS_SINE)
	is_melt = true

func unmelt() -> void:
	if not is_melt:
		return
	var tween = create_tween()
	tween.tween_method(
		func(value): 
			if heart_full.material is ShaderMaterial:
				heart_full.material.set_shader_parameter("progress", value),
		1.0,
		0.0,
		tween_duration
	).set_trans(Tween.TRANS_SINE)
	is_melt = false
