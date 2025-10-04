extends BaseCreature
class_name SwarmMaster

var speed: float = 300.0
var swarm_parts: Array[BaseCreature] = []
var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	update_group(Global.GROUP.FRIEND, self)

func _physics_process(delta: float) -> void:
	tmp_update_label()

	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	
	velocity = direction.normalized() * speed
	position += velocity * delta

func add_swarm_part(swarm_part: BaseCreature) -> void:
	swarm_parts.append(swarm_part)
	swarm_part.update_group(Global.GROUP.FRIEND, self)

func remove_swarm_part(swarm_part: BaseCreature) -> void:
	swarm_parts.erase(swarm_part)
	swarm_part.update_group(Global.GROUP.NEUTRAL, null)
