extends Node

enum GROUP {
	FRIEND,
	ENEMY,
	NEUTRAL
}

var bullet_handler: BulletHandler = null

func reset_game_data(game: Game) -> void:
	bullet_handler = game.bullet_handler
