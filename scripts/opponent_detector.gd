extends Area2D
class_name OpponentDetector

signal non_neutral_creature_detected(creature: BaseCreature)

## 检测到detectedarea后，找到其父亲检查是否中立，如果不是中立则发信号给自己归属的 creature。
func _on_area_entered(area: Area2D) -> void:
	var creature = area.get_parent()
	if creature is BaseCreature:
		if creature.group != Global.GROUP.NEUTRAL:
			non_neutral_creature_detected.emit(creature)
