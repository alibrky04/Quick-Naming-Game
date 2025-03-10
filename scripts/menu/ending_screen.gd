extends Node2D

@onready var score: Label = $Texts/Score
@onready var count: Label = $Texts/Count
@onready var game_over: AudioStreamPlayer = $GameOver

func _ready() -> void:
	game_over.play()

func _on_restart_pressed() -> void:
	SetManager.random_set_select()
	get_tree().change_scene_to_file("res://scenes/balloon_game/balloon_game.tscn")

func _on_home_pressed() -> void:
	AudioManager.on_scene_changed("menu")
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
