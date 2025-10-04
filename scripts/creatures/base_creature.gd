extends Node2D
class_name BaseCreature

var group: Global.GROUP = Global.GROUP.NEUTRAL
var swarm_master: BaseCreature = null

@onready var creature_detector: CreatureDetector = $CreatureDetector
@onready var detected_area: Area2D = $DetectedArea

func _ready() -> void:
	update_group(group, swarm_master)

## 非中立阵营的creature会打开detector关闭detectedarea，
## 中立阵营的creature会打开detectedarea关闭detector。
func update_group(p_group: Global.GROUP, p_swarm_master: BaseCreature) -> void:
	group = p_group
	swarm_master = p_swarm_master
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
	if swarm_master:
		# 老大有人来了喵
		swarm_master.add_swarm_part(creature)
	else:
		creature.update_group(group, self)


func tmp_update_label() -> void:
	match group:
		Global.GROUP.FRIEND:
			$GroupLabel.text = "Friend"
		Global.GROUP.ENEMY:
			$GroupLabel.text = "Enemy"
		Global.GROUP.NEUTRAL:
			$GroupLabel.text = "Neutral"
