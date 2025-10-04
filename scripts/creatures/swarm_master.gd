extends BaseCreature

var speed: float = 300.0

func _ready() -> void:
	update_group(Global.GROUP.FRIEND, self)

func _process(delta: float) -> void:
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	
	position += direction.normalized() * speed * delta
