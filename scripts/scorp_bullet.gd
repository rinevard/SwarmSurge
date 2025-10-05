extends Area2D
class_name ScorpBullet

var velocity: Vector2 = Vector2.ZERO
var group: Global.GROUP = Global.GROUP.NEUTRAL

static func new_bullet(p_global_position: Vector2, p_velocity: Vector2, p_group: Global.GROUP) -> ScorpBullet:
	var bullet: ScorpBullet = preload("res://scenes/scorp_bullet.tscn").instantiate()
	bullet.global_position = p_global_position
	bullet.velocity = p_velocity
	bullet.group = p_group
	return bullet

func _physics_process(delta: float) -> void:
	position += velocity * delta
