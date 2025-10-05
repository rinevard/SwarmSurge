extends Panel

# 地图边界
const MAP_MIN_X = -2350.0
const MAP_MAX_X = 4750.0
const MAP_MIN_Y = -1200.0
const MAP_MAX_Y = 2900.0

# 地图总尺寸
const MAP_WIDTH = MAP_MAX_X - MAP_MIN_X  # 7100
const MAP_HEIGHT = MAP_MAX_Y - MAP_MIN_Y  # 4100

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	queue_redraw()  # 每帧重绘小地图

func _draw() -> void:
	# 获取小地图Panel的尺寸
	var panel_size = size
	
	# 绘制玩家master（绿色点）
	if Global.player_master and is_instance_valid(Global.player_master):
		var player_pos = Global.player_master.global_position
		var minimap_pos = world_to_minimap(player_pos, panel_size)
		draw_circle(minimap_pos, 5, Color.GREEN)
	
	# 绘制敌人masters（红色点）
	for enemy_master in Global.enemy_masters:
		if enemy_master and is_instance_valid(enemy_master):
			var enemy_pos = enemy_master.global_position
			var minimap_pos = world_to_minimap(enemy_pos, panel_size)
			draw_circle(minimap_pos, 5, Color.RED)

# 将世界坐标转换为小地图坐标
func world_to_minimap(world_pos: Vector2, panel_size: Vector2) -> Vector2:
	# 归一化世界坐标到 [0, 1]
	var normalized_x = (world_pos.x - MAP_MIN_X) / MAP_WIDTH
	var normalized_y = (world_pos.y - MAP_MIN_Y) / MAP_HEIGHT
	
	# 映射到小地图尺寸
	var minimap_x = normalized_x * panel_size.x
	var minimap_y = normalized_y * panel_size.y
	
	return Vector2(minimap_x, minimap_y)
