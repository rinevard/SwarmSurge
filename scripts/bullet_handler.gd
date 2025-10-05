extends Node2D
class_name BulletHandler

func create_bullet(p_global_position: Vector2, p_velocity: Vector2, p_group: Global.GROUP) -> void:
	print("create bullet!")
	var bullet: ScorpBullet = ScorpBullet.new_bullet(p_global_position, p_velocity, p_group)
	add_child(bullet)
