extends HBoxContainer
class_name HealthBar

const HEART = preload("res://scenes/heart.tscn")
const HEALTH_BAR = preload("res://scenes/health_bar.tscn")
const GAME_SCALE: float = 0.2 # 在角色头上显示时的缩放比例

@export var max_health: int = 4
var hearts: Array[Heart] = []

func _ready() -> void:
	for i in range(max_health):
		var heart: Heart = HEART.instantiate()
		add_child(heart)
		hearts.append(heart)

static func new_health_bar(p_health: int) -> HealthBar:
	var health_bar: HealthBar = HEALTH_BAR.instantiate()
	health_bar.max_health = p_health
	return health_bar

func update_health(p_health: int) -> void:
	for i in range(hearts.size()):
		if i < p_health:
			hearts[i].unmelt()
		else:
			hearts[i].melt()
