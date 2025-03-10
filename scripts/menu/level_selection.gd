extends Node2D

@onready var grid = $GridContainer

func _ready():
	for button in grid.get_children():
		if button is Button:
			button.pressed.connect(_on_level_selected.bind(button))

func _on_level_selected(button: Button):
	GameManager.difficultyLevel = int(str(button.name))
	
	if GameManager.selectedGame == 1:
		get_tree().change_scene_to_file("res://scenes/balloon_game/balloon_game.tscn")
		AudioManager.on_scene_changed("balloon_game")

func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
