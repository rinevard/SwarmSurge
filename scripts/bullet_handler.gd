extends Node2D
class_name BulletHandler

func create_bullet(p_global_position: Vector2, p_velocity: Vector2, p_group: Global.GROUP, is_hedgehog_bullet: bool = false) -> void:
	if is_hedgehog_bullet:
		var stab: HedgehogStab = HedgehogStab.new_bullet(p_global_position, p_velocity, p_group)
		add_child(stab)
	else:
		var bullet: ScorpBullet = ScorpBullet.new_bullet(p_global_position, p_velocity, p_group)
		add_child(bullet)
