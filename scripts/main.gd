extends Node2D

@onready var pause_menu: PauseMenu = $CanvasLayer/PauseMenu
@onready var game: Game = $Game

const GAME = preload("res://scenes/game.tscn")

func _ready() -> void:
	pause_menu.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()

func _toggle_pause() -> void:
	Global.game_paused = not Global.game_paused
	pause_menu.visible = Global.game_paused
	Engine.time_scale = 0.0 if Global.game_paused else 1.0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if Global.game_paused else Input.MOUSE_MODE_CAPTURED)
	if Global.game_paused:
		pause_menu.show()
	else:
		pause_menu.hide()

func _on_pause_menu_pause_clicked() -> void:
	_toggle_pause()

func _on_pause_menu_reset_game() -> void:
	pass
