extends Control
class_name StartMenu

signal start_clicked()
signal exit_clicked()

var rotation_ratio_speed: float = 0.1
@onready var turtle_path_follow_2d: PathFollow2D = $Sprites/Path2D/TurtlePathFollow2D
@onready var hedgehog_path_follow_2d: PathFollow2D = $Sprites/Path2D/HedgehogPathFollow2D
@onready var scorpion_path_follow_2d: PathFollow2D = $Sprites/Path2D/ScorpionPathFollow2D

func _on_start_button_pressed() -> void:
	start_clicked.emit()

func _on_exit_button_pressed() -> void:
	exit_clicked.emit()

func _physics_process(delta: float) -> void:
	turtle_path_follow_2d.progress_ratio += rotation_ratio_speed * delta
	hedgehog_path_follow_2d.progress_ratio += rotation_ratio_speed * delta
	scorpion_path_follow_2d.progress_ratio += rotation_ratio_speed * delta
