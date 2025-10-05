extends Area2D
class_name ScorpBullet

var velocity: Vector2 = Vector2.ZERO
var group: Global.GROUP = Global.GROUP.NEUTRAL
const SCORP_BULLET = preload("res://scenes/scorp_bullet.tscn")
const LIFE_TIME: float = 5.0
var live_time: float = 0.0


static func new_bullet(p_global_position: Vector2, p_velocity: Vector2, p_group: Global.GROUP) -> ScorpBullet:
	var bullet: ScorpBullet = SCORP_BULLET.instantiate()
	bullet.global_position = p_global_position
	bullet.velocity = p_velocity
	bullet.rotation = p_velocity.angle()
	bullet.group = p_group
	
	# 2: neutral, 5: friend, 6: enemy
	match p_group:
		Global.GROUP.NEUTRAL:
			bullet.call_deferred("set_collision_mask_value", 2, false)
			bullet.call_deferred("set_collision_mask_value", 5, false)
			bullet.call_deferred("set_collision_mask_value", 6, false)
		Global.GROUP.FRIEND:
			bullet.call_deferred("set_collision_mask_value", 2, false)
			bullet.call_deferred("set_collision_mask_value", 5, false)
			bullet.call_deferred("set_collision_mask_value", 6, true)
		Global.GROUP.ENEMY:
			bullet.call_deferred("set_collision_mask_value", 2, false)
			bullet.call_deferred("set_collision_mask_value", 5, true)
			bullet.call_deferred("set_collision_mask_value", 6, false)
		
	return bullet

func _physics_process(delta: float) -> void:
	if Global.game_paused:
		return
	live_time += delta
	if live_time >= LIFE_TIME:
		call_deferred("queue_free")
		return

	position += velocity * delta

func _on_area_entered(area: Area2D) -> void:
	if area is TurtleShield:
		if (area.group == Global.GROUP.ENEMY and group == Global.GROUP.FRIEND) \
			or (area.group == Global.GROUP.FRIEND and group == Global.GROUP.ENEMY):
			call_deferred("queue_free")
			return

	var creature = area.get_parent()
	if creature is BaseCreature:
		if (creature.group == Global.GROUP.ENEMY and group == Global.GROUP.FRIEND) \
			or (creature.group == Global.GROUP.FRIEND and group == Global.GROUP.ENEMY):
			creature.on_bullet_hit(self)
			call_deferred("queue_free")
