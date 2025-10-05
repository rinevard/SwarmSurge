extends SwarmPart
class_name Scorpion

var bullet_speed: float = 600.0

## override, 索敌发射子弹
func activate(enemies: Array[BaseCreature]) -> void:
	print(enemies)
	var nearest_enemy: BaseCreature = null
	var nearest_enemy_distance: float = INF
	for enemy in enemies:
		var distance: float = global_position.distance_to(enemy.global_position)
		if distance < nearest_enemy_distance:
			nearest_enemy = enemy
			nearest_enemy_distance = distance

	print("nearest_enemy: ", nearest_enemy)
	if nearest_enemy:
		if Global.bullet_handler:
			Global.bullet_handler.create_bullet(global_position, (nearest_enemy.global_position - global_position).normalized() * bullet_speed, Global.GROUP.FRIEND)
