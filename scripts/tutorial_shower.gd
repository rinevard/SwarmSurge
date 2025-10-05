extends Control

const SHOW_INTERVAL: float = 4.0
const FADE_DURATION: float = 0.5

var pick_tutorial: Array[String] = ["WASD to Move\nApproach neutral creatures to collect them", "The circle beneath creatures indicates their faction"]
var battle_tutorial: String = "Defeat an enemy leader to leave their swarm neutral\nYou can then move in to collect them"
var pick_tutorial_text_shown: bool = false
var battle_tutorial_shown: bool = false
var battle_tutorial_hiding: bool = false

@onready var my_label: RichTextLabel = $MyLabel

func start_tutorial() -> void:
	if Global.tutorial_ended:
		return
	_show_pick_tutorial()

func _process(_delta: float) -> void:
	if Global.tutorial_ended:
		return
	if pick_tutorial_text_shown and Global.first_creature_picked and not battle_tutorial_shown:
		battle_tutorial_shown = true
		my_label.text = battle_tutorial
		var tween_in = get_tree().create_tween()
		tween_in.tween_property(my_label, "modulate:a", 1.0, FADE_DURATION)
	if battle_tutorial_shown and Global.first_enemy_master_destroyed and not battle_tutorial_hiding:
		battle_tutorial_hiding = true
		var tween_out = get_tree().create_tween()
		tween_out.tween_property(my_label, "modulate:a", 0.0, FADE_DURATION)
		tween_out.tween_callback(func(): Global.tutorial_ended = true)
		tween_out.tween_callback(func(): my_label.text = "")


func _show_pick_tutorial() -> void:
	my_label.modulate.a = 0.0
	
	for text in pick_tutorial:
		my_label.text = text
		var tween = get_tree().create_tween()
		tween.tween_property(my_label, "modulate:a", 1.0, FADE_DURATION)
		tween.tween_interval(SHOW_INTERVAL - 2 * FADE_DURATION)
		tween.tween_property(my_label, "modulate:a", 0.0, FADE_DURATION)
		await tween.finished

	pick_tutorial_text_shown = true
