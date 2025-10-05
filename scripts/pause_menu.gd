extends Control
class_name PauseMenu

signal pause_clicked()
signal reset_game()

@onready var my_label: RichTextLabel = $Panel/MyLabel

func set_text(txt: String):
	my_label.text = txt

func _on_continue_button_pressed() -> void:
	pause_clicked.emit()

func _on_reset_button_pressed() -> void:
	reset_game.emit()
