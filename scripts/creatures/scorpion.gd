extends SwarmPart
class_name Scorpion

var bullet_speed: float = 600.0

## override, 索敌发射子弹
func activate(enemies: Array[BaseCreature]) -> void:
	var nearest_enemy: BaseCreature = null
	var nearest_enemy_distance: float = INF
	for enemy in enemies:
		var distance: float = global_position.distance_to(enemy.global_position)
		if distance < nearest_enemy_distance:
			nearest_enemy = enemy
			nearest_enemy_distance = distance

	if nearest_enemy:
		if Global.bullet_handler:
			# 避免子弹卡着不动
			if (nearest_enemy.global_position.is_equal_approx(global_position)):
				return
			Global.bullet_handler.create_bullet(global_position, (nearest_enemy.global_position - global_position).normalized() * bullet_speed, group)

## override
func die() -> void:
	super()
