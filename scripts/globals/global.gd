extends Node

# 仅由 player_master 触发
signal player_die()

enum GROUP {
	FRIEND,
	ENEMY,
	NEUTRAL
}

var bullet_handler: BulletHandler = null
var player_master: SwarmMaster = null
var enemy_masters: Array[EnemyMaster] = []

#region 教程
var tutorial_ended: bool = false
var first_creature_picked: bool = false
var first_enemy_master_destroyed: bool = false
#endregion

var game_paused: bool = false

func reset_game_data(game: Game) -> void:
	bullet_handler = game.bullet_handler
	player_master = null
	enemy_masters = []
