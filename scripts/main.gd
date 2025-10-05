extends Node2D

@onready var pause_menu: PauseMenu = $CanvasLayer/PauseMenu
@onready var game: Game = $Game
@onready var transition_mask: ColorRect = $CanvasLayer/TransitionMask

const GAME = preload("res://scenes/game.tscn")

func _ready() -> void:
	pause_menu.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()

func _toggle_pause() -> void:
	Global.game_paused = not Global.game_paused
	pause_menu.visible = Global.game_paused
	if Global.game_paused:
		pause_menu.show()
	else:
		pause_menu.hide()

func _on_pause_menu_pause_clicked() -> void:
	_toggle_pause()

func _on_pause_menu_reset_game() -> void:
	Global.game_paused = true
	pause_menu.hide()
	await _transition_fade_in()

	if game and is_instance_valid(game):
		game.call_deferred("queue_free")
	game = GAME.instantiate()
	Global.reset_game_data(game)
	call_deferred("add_child", game)
	await _transition_fade_out()

	Global.game_paused = false

#region 切换场景
var transition_duration: float = 1.0

func _transition_fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(transition_mask, "material:shader_parameter/progress", 1.0, transition_duration)
	await tween.finished

func _transition_fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(transition_mask, "material:shader_parameter/progress", 0.0, transition_duration)
	await tween.finished
#endregion
