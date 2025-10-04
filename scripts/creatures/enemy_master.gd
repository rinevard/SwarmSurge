extends BaseCreature
class_name EnemyMaster

var speed: float = 300.0

func _ready() -> void:
	update_group(Global.GROUP.ENEMY, self)

func _physics_process(delta: float) -> void:
	tmp_update_label()
