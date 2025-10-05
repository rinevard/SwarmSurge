extends Area2D
class_name TurtleShield

var group: Global.GROUP = Global.GROUP.FRIEND
const TURTLE_SHIELD = preload("res://scenes/turtle_shield.tscn")

static func new_shield(p_global_position: Vector2, p_group: Global.GROUP) -> TurtleShield:
	var shield: TurtleShield = TURTLE_SHIELD.instantiate()
	shield.global_position = p_global_position
	shield.group = p_group
	return shield
