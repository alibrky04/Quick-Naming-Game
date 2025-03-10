extends Node

@onready var music_player = $"/root/AudioManager"

var menu_music_path = "res://assets/Musics/main_menu_music.wav"
var current_music = "menu"

func _ready():
	if not music_player.playing:
		music_player.stream = load(menu_music_path)
		music_player.play()

func change_music(new_music_path: String):
	menu_music_path = new_music_path
	music_player.stream = load(menu_music_path)
	music_player.play()

func on_scene_changed(scene: String, new_music_path: String = menu_music_path):
	if scene == "menu":
		change_music(new_music_path)
	elif scene == "balloon_game":
		current_music = "balloon_game"
		music_player.stop()
