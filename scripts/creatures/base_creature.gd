extends Node2D
class_name BaseCreature

var group: Global.GROUP = Global.GROUP.NEUTRAL
var swarm_master: BaseCreature = null

@onready var neutral_creature_detector: CreatureDetector = $NeutralCreatureDetector
@onready var opponent_detector: OpponentDetector = $OpponentDetector
@onready var group_detected_area: Area2D = $GroupDetectedArea

func _ready() -> void:
	update_group(group, swarm_master)

## 非中立阵营的creature会打开detector，
## 中立阵营的creature会关闭detector。
func update_group(p_group: Global.GROUP, p_swarm_master: BaseCreature) -> void:
	group = p_group
	swarm_master = p_swarm_master
	match group:
		# 中立阵营不检测
		Global.GROUP.NEUTRAL:
			neutral_creature_detector.set_deferred("monitoring", false)
			_update_opponent_detector_by_group(group)
			_update_detected_area_by_group(group)
		Global.GROUP.FRIEND:
			neutral_creature_detector.set_deferred("monitoring", true)
			_update_opponent_detector_by_group(group)
			_update_detected_area_by_group(group)
		Global.GROUP.ENEMY:
			neutral_creature_detector.set_deferred("monitoring", true)
			_update_opponent_detector_by_group(group)
			_update_detected_area_by_group(group)

## 把中立阵营的 creature 加入自己的聚落中
func _on_neutral_creature_detected(creature: BaseCreature) -> void:
	if group == Global.GROUP.NEUTRAL:
		return
	if swarm_master:
		# 老大有人来了喵
		swarm_master.add_swarm_part(creature)
	else:
		creature.update_group(group, self)

func _update_opponent_detector_by_group(p_group: Global.GROUP) -> void:
	# 2: neutral, 5: friend, 6: enemy
	match p_group:
		Global.GROUP.NEUTRAL:
			# 中立没有敌人
			opponent_detector.set_deferred("monitoring", false)
			opponent_detector.call_deferred("set_collision_mask_value", 2, false)
			opponent_detector.call_deferred("set_collision_mask_value", 5, false)
			opponent_detector.call_deferred("set_collision_mask_value", 6, false)
		Global.GROUP.FRIEND:
			# 友方检测敌人
			opponent_detector.set_deferred("monitoring", true)
			opponent_detector.call_deferred("set_collision_mask_value", 2, false)
			opponent_detector.call_deferred("set_collision_mask_value", 5, false)
			opponent_detector.call_deferred("set_collision_mask_value", 6, true)
		Global.GROUP.ENEMY:
			# 敌方检测友方
			opponent_detector.set_deferred("monitoring", true)
			opponent_detector.call_deferred("set_collision_mask_value", 2, false)
			opponent_detector.call_deferred("set_collision_mask_value", 5, true)
			opponent_detector.call_deferred("set_collision_mask_value", 6, false)

func _update_detected_area_by_group(p_group: Global.GROUP) -> void:
	# 2: neutral, 5: friend, 6: enemy
	match group:
		Global.GROUP.NEUTRAL:
			group_detected_area.call_deferred("set_collision_layer_value", 2, true)
			group_detected_area.call_deferred("set_collision_layer_value", 5, false)
			group_detected_area.call_deferred("set_collision_layer_value", 6, false)
		Global.GROUP.FRIEND:
			group_detected_area.call_deferred("set_collision_layer_value", 2, false)
			group_detected_area.call_deferred("set_collision_layer_value", 5, true)
			group_detected_area.call_deferred("set_collision_layer_value", 6, false)
		Global.GROUP.ENEMY:
			group_detected_area.call_deferred("set_collision_layer_value", 2, false)
			group_detected_area.call_deferred("set_collision_layer_value", 5, false)
			group_detected_area.call_deferred("set_collision_layer_value", 6, true)

func tmp_update_label() -> void:
	match group:
		Global.GROUP.FRIEND:
			$GroupLabel.text = "Friend"
		Global.GROUP.ENEMY:
			$GroupLabel.text = "Enemy"
		Global.GROUP.NEUTRAL:
			$GroupLabel.text = "Neutral"

func _on_bullet_detected(bullet: ScorpBullet) -> void:
	# 敌方子弹和友方角色碰撞, 友方子弹和敌方角色碰撞
	# 中立角色不和子弹碰撞, 中立子弹不和角色碰撞
	if (bullet.group == Global.GROUP.ENEMY and group == Global.GROUP.FRIEND) \
		or (bullet.group == Global.GROUP.FRIEND and group == Global.GROUP.ENEMY):
		print("bullet hit me! I am " + name + "!")
