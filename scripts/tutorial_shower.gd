extends Control

const SHOW_INTERVAL: float = 4.0

var pick_tutorial: Array[String] = ["WASD to Move\nApproach neutral creatures to collect them", "The circle beneath you is your swarm's territory"]
var battle_tutorial: String = "Defeat an enemy leader to leave their minions neutral\nYou can then move in to collect them"
var pick_tutorial_text_shown: bool = false

@onready var my_label: RichTextLabel = $MyLabel

func start_tutorial() -> void:
	if Global.tutorial_ended:
		return
	_show_pick_tutorial()

func _process(_delta: float) -> void:
	if Global.tutorial_ended:
		return
	if pick_tutorial_text_shown and Global.first_creature_picked:
		my_label.text = battle_tutorial
		if Global.first_enemy_master_destroyed:
			my_label.text = ""
			Global.tutorial_ended = true

func _show_pick_tutorial() -> void:
	my_label.text = pick_tutorial[0]
	await get_tree().create_timer(SHOW_INTERVAL).timeout
	my_label.text = pick_tutorial[1]
	await get_tree().create_timer(SHOW_INTERVAL).timeout

	pick_tutorial_text_shown = true
