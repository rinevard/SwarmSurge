extends Node2D

@onready var pause_menu: PauseMenu = $CanvasLayer/PauseMenu
@onready var die_menu: DieMenu = $CanvasLayer/DieMenu
@onready var start_menu: StartMenu = $CanvasLayer/StartMenu
@onready var transition_mask: ColorRect = $CanvasLayer/TransitionMask

var game: Game = null

const GAME = preload("res://scenes/game.tscn")

func _ready() -> void:
	Global.player_die.connect(_on_player_die)
	pause_menu.hide()
	die_menu.hide()
	start_menu.show()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()

func _on_player_die() -> void:
	die_menu.show()

func _toggle_pause() -> void:
	Global.game_paused = not Global.game_paused
	pause_menu.visible = Global.game_paused
	if Global.game_paused:
		pause_menu.show()
		MusicPlayer.stop_all()
	else:
		pause_menu.hide()
		MusicPlayer.continue_all()

func _on_pause_menu_pause_clicked() -> void:
	_toggle_pause()

func _on_pause_menu_reset_game() -> void:
	Global.game_paused = true
	MusicPlayer.stop_all()
	pause_menu.hide()
	await _transition_fade_in()

	if game and is_instance_valid(game):
		game.call_deferred("queue_free")
	game = GAME.instantiate()
	Global.reset_game_data(game)
	call_deferred("add_child", game)
	Global.game_paused = false
	await _transition_fade_out()


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

func _on_start_menu_exit_clicked() -> void:
	await _transition_fade_in()
	get_tree().quit()

func _on_start_menu_start_clicked() -> void:
	await _transition_fade_in()
	start_menu.hide()

	if game and is_instance_valid(game):
		game.call_deferred("queue_free")
	game = GAME.instantiate()
	Global.reset_game_data(game)
	call_deferred("add_child", game)
	Global.game_paused = false
	await _transition_fade_out()

func _on_die_menu_reset_clicked() -> void:
	Global.game_paused = true
	MusicPlayer.stop_all()
	die_menu.hide()
	await _transition_fade_in()

	if game and is_instance_valid(game):
		game.call_deferred("queue_free")
	game = GAME.instantiate()
	Global.reset_game_data(game)
	call_deferred("add_child", game)
	Global.game_paused = false
	await _transition_fade_out()
