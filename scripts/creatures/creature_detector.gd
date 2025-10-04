extends Area2D
class_name CreatureDetector

signal neutral_creature_detected(creature: BaseCreature)

## detector检测到detectedarea后，找到其父亲检查是否是中立creature，如果是则发信号给自己归属的 creature。
func _on_area_entered(area: Area2D) -> void:
	var creature = area.get_parent()
	if creature is BaseCreature:
		if creature.group == Global.GROUP.NEUTRAL:
			neutral_creature_detected.emit(creature)
