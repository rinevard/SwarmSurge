extends Control
class_name PauseMenu

signal pause_clicked()
signal reset_game()

func _on_continue_button_pressed() -> void:
	pause_clicked.emit()

func _on_reset_button_pressed() -> void:
	reset_game.emit()
