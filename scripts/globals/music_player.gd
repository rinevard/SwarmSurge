extends Node

@onready var master_player: AudioStreamPlayer = $MasterPlayer
@onready var hedgehog_player: AudioStreamPlayer = $HedgehogPlayer
@onready var scorpion_player: AudioStreamPlayer = $ScorpionPlayer
@onready var turtle_player: AudioStreamPlayer = $TurtlePlayer

func init_music() -> void:
	mute_master()
	mute_hedgehog()
	mute_scorpion()
	mute_turtle()
	master_player.play()
	hedgehog_player.play()
	scorpion_player.play()
	turtle_player.play()

var last_time: float = 0.0
func continue_all() -> void:
	master_player.play(last_time)
	hedgehog_player.play(last_time)
	scorpion_player.play(last_time)
	turtle_player.play(last_time)

func stop_all() -> void:
	last_time = master_player.get_playback_position()
	master_player.stop()
	hedgehog_player.stop()
	scorpion_player.stop()
	turtle_player.stop()

func play_master() -> void:
	master_player.volume_db = 0.0

func play_hedgehog() -> void:
	hedgehog_player.volume_db = 0.0

func play_scorpion() -> void:
	scorpion_player.volume_db = 0.0

func play_turtle() -> void:
	turtle_player.volume_db = 0.0

func mute_master() -> void:
	master_player.volume_db = -80.0

func mute_hedgehog() -> void:
	hedgehog_player.volume_db = -80.0

func mute_scorpion() -> void:
	scorpion_player.volume_db = -80.0

func mute_turtle() -> void:
	turtle_player.volume_db = -80.0
