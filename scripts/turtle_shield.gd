extends Area2D
class_name TurtleShield

var group: Global.GROUP = Global.GROUP.FRIEND
var global_position_on_ready: Vector2 = Vector2.ZERO
const TURTLE_SHIELD = preload("res://scenes/turtle_shield.tscn")

static func new_shield(p_global_position: Vector2, p_group: Global.GROUP) -> TurtleShield:
	var shield: TurtleShield = TURTLE_SHIELD.instantiate()
	shield.global_position_on_ready = p_global_position
	shield.group = p_group
	return shield

func _ready() -> void:
	global_position = global_position_on_ready

func update_group(p_group: Global.GROUP) -> void:
	group = p_group
