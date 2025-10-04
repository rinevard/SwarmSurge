extends BaseCreature

var speed: float = 300.0

func _ready() -> void:
	update_group(Global.GROUP.ENEMY, self)
