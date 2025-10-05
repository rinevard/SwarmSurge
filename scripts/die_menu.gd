extends Control
class_name DieMenu

signal reset_clicked()

func _on_reset_button_pressed() -> void:
	reset_clicked.emit()
