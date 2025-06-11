extends Node

@onready var player = $"/root/AudioManager"

var menu_music_path = "res://assets/Musics/main_menu_music.wav"
var current_music = "menu"

const default_volume = -20.0

func _ready():
	if not player.playing:
		player.stream = load(menu_music_path)
		player.play()
	
	player.volume_db = default_volume

func change_music(new_music_path: String):
	menu_music_path = new_music_path
	player.stream = load(menu_music_path)
	player.play()

func on_scene_changed(scene: String, new_music_path: String = menu_music_path):
	if scene == "menu":
		change_music(new_music_path)
	elif scene == "balloon_game":
		current_music = "balloon_game"
		player.stop()
	elif scene == "mole_game":
		current_music = "mole_game"
		player.stop()
	elif scene == "space_game":
		current_music = "space_game"
		player.stop()
	elif scene == "water_game":
		current_music = "water_game"
		player.stop()
