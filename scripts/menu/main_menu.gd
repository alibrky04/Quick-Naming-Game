extends Node2D

@onready var shadow: ColorRect = $Shadow

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/profile/profile_screen.tscn")

func _on_settings_button_pressed() -> void:
	shadow.visible = true
	var settings = load("res://scenes/menu/settings.tscn").instantiate()
	get_tree().current_scene.add_child(settings)
	settings.return_back_signal.connect(_on_return_back_signal)

func _on_return_back_signal() -> void:
	shadow.visible = false
