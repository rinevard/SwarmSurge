extends Control

signal game_win()

@onready var my_label: RichTextLabel = $MyLabel

const FADE_SPEED = 1.5
const VISIBLE_DURATION = 2.0
const NUM_CREATURES_TO_WIN = 20

var last_collected_count = -1
var target_alpha = 0.0
var visible_timer = 0.0
var has_won = false

func _ready() -> void:
	my_label.self_modulate.a = 0.0

func _process(delta: float) -> void:
	if not Global.tutorial_ended:
		my_label.text = ""
		my_label.self_modulate.a = 0.0
		target_alpha = 0.0
		visible_timer = 0.0
		last_collected_count = Global.collected_creature_count
		return

	if Global.collected_creature_count != last_collected_count:
		last_collected_count = Global.collected_creature_count
		my_label.text = "Collected Creatures [" + str(Global.collected_creature_count) + " / " + str(NUM_CREATURES_TO_WIN) + "]"
		target_alpha = 1.0
		visible_timer = VISIBLE_DURATION

		if not has_won and last_collected_count >= NUM_CREATURES_TO_WIN:
			has_won = true
			game_win.emit()

	if visible_timer > 0:
		visible_timer -= delta
		if visible_timer <= 0:
			target_alpha = 0.0
	
	my_label.self_modulate.a = move_toward(my_label.self_modulate.a, target_alpha, FADE_SPEED * delta)
