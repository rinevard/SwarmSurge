extends Node

const HEDGEHOG = preload("res://assets/sfxs/hedgehog.wav")
const HIT = preload("res://assets/sfxs/hit.wav")
const SHIELD = preload("res://assets/sfxs/shield.wav")
const ACTIVATE_SIGNAL = preload("res://assets/sfxs/signallllllllll.ogg")

enum SFXs {
	HEDGEHOG,
	HIT,
	SHIELD,
	ACTIVATE_SIGNAL
}

var audio_player_cnt: int = 10
var audio_players: Array[AudioStreamPlayer2D]

# 将枚举值映射到对应的音效资源
var sfx_map: Dictionary

func _ready() -> void:
	sfx_map = {
		SFXs.HEDGEHOG: HEDGEHOG,
		SFXs.HIT: HIT,
		SFXs.SHIELD: SHIELD,
		SFXs.ACTIVATE_SIGNAL: ACTIVATE_SIGNAL
	}
	
	for i in range(audio_player_cnt):
		var player = AudioStreamPlayer2D.new()
		add_child(player)
		audio_players.append(player)


## 播放指定的音效
## sfx: 要播放的音效，来自于SFXs枚举
## global_pos: 音效在世界中的播放位置
func play_sfx(sfx: SFXs, global_pos: Vector2) -> void:
	# 首先检查传入的sfx是否有效，这是一个好习惯
	if not sfx_map.has(sfx):
		printerr("SFXManager: 尝试播放一个未在sfx_map中定义的音效: ", SFXs.keys()[sfx])
		return

	var sfx_stream = sfx_map[sfx]

	# 遍历播放器池，寻找空闲的播放器
	for player in audio_players:
		if not player.is_playing():
			player.stream = sfx_stream
			player.global_position = global_pos
			player.volume_db = 0.0
			player.play()
			return

	# 如果循环结束后都没有找到空闲播放器
	# 新建播放器，添加到池中，并用它来播放。
	print_debug("SFXManager: 音效池已满，正在创建一个新的AudioStreamPlayer2D。当前池大小: ", audio_player_cnt)
	
	var new_player = AudioStreamPlayer2D.new()
	add_child(new_player)
	audio_players.append(new_player)
	audio_player_cnt += 1
	
	new_player.stream = sfx_stream
	new_player.global_position = global_pos
	new_player.volume_db = 0.0
	new_player.play()

var mute_db: float = -30.0
func stop_all_sfx() -> void:
	# 这里的 tween 扔了个 error: started with no Tweeners.
	var tween = get_tree().create_tween()
	var tween_duration: float = 0.3
	var is_any_sfx_playing: bool = false

	for player in audio_players:
		if player.is_playing():
			is_any_sfx_playing = true
			tween.tween_property(player, "volume_db", mute_db, tween_duration)

	# 如果有任何音效正在淡出，则等待动画完成
	if is_any_sfx_playing:
		await tween.finished

	# 动画结束后，真正停止所有播放器并重置音量，以便它们可以被复用
	for player in audio_players:
		player.stop()
		player.volume_db = 0.0
