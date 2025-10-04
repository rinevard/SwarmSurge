extends Node2D
class_name BaseCreature

var group: Global.GROUP = Global.GROUP.NEUTRAL
var group_master: BaseCreature = null

@onready var creature_detector: CreatureDetector = $CreatureDetector
@onready var detected_area: Area2D = $DetectedArea

func _ready() -> void:
	update_group(group, group_master)

func _physics_process(delta: float) -> void:
	match group:
		Global.GROUP.FRIEND:
			$GroupLabel.text = "Friend"
		Global.GROUP.ENEMY:
			$GroupLabel.text = "Enemy"
		Global.GROUP.NEUTRAL:
			$GroupLabel.text = "Neutral"

func get_master() -> BaseCreature:
	return group_master

## 非中立阵营的creature会打开detector关闭detectedarea，
## 中立阵营的creature会打开detectedarea关闭detector。
func update_group(p_group: Global.GROUP, p_group_master: BaseCreature) -> void:
	group = p_group
	group_master = p_group_master
	if group != Global.GROUP.NEUTRAL:
		creature_detector.set_deferred("monitoring", true)
		detected_area.set_deferred("monitorable", false)
	else:
		creature_detector.set_deferred("monitoring", false)
		detected_area.set_deferred("monitorable", true)

## 把中立阵营的 creature 加入自己的聚落中
func _on_neutral_creature_detected(creature: BaseCreature) -> void:
	if group == Global.GROUP.NEUTRAL:
		return
	creature.update_group(group, group_master)
