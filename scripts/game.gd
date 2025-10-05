extends Node2D
class_name Game

@onready var bullet_handler: BulletHandler = $BulletHandler

func _ready() -> void:
	Global.reset_game_data(self)
