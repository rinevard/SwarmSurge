extends Area2D
class_name HedgehogStab

var velocity: Vector2 = Vector2.ZERO
var rotation_speed: float = 15.0
var group: Global.GROUP = Global.GROUP.NEUTRAL
const HEDGEHOG_STAB = preload("res://scenes/hedgehog_stab.tscn")

static func new_bullet(p_global_position: Vector2, p_velocity: Vector2, p_group: Global.GROUP) -> HedgehogStab:
	var stab: HedgehogStab = HEDGEHOG_STAB.instantiate()
	stab.global_position = p_global_position
	stab.velocity = p_velocity
	stab.group = p_group
	
	# 2: neutral, 5: friend, 6: enemy
	match p_group:
		Global.GROUP.NEUTRAL:
			stab.call_deferred("set_collision_mask_value", 2, false)
			stab.call_deferred("set_collision_mask_value", 5, false)
			stab.call_deferred("set_collision_mask_value", 6, false)
		Global.GROUP.FRIEND:
			stab.call_deferred("set_collision_mask_value", 2, false)
			stab.call_deferred("set_collision_mask_value", 5, false)
			stab.call_deferred("set_collision_mask_value", 6, true)
		Global.GROUP.ENEMY:
			stab.call_deferred("set_collision_mask_value", 2, false)
			stab.call_deferred("set_collision_mask_value", 5, true)
			stab.call_deferred("set_collision_mask_value", 6, false)
		
	return stab

func _physics_process(delta: float) -> void:
	position += velocity * delta
	rotation += rotation_speed * delta

func _on_area_entered(area: Area2D) -> void:
	var creature = area.get_parent()
	if creature is BaseCreature:
		if (creature.group == Global.GROUP.ENEMY and group == Global.GROUP.FRIEND) \
			or (creature.group == Global.GROUP.FRIEND and group == Global.GROUP.ENEMY):
			creature.on_bullet_hit(self)
