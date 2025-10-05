extends Node

enum GROUP {
	FRIEND,
	ENEMY,
	NEUTRAL
}

var bullet_handler: BulletHandler = null
var player_master: SwarmMaster = null
var enemy_masters: Array[EnemyMaster] = []

func reset_game_data(game: Game) -> void:
	bullet_handler = game.bullet_handler
	player_master = null
	enemy_masters = []
