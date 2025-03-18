extends Node2D

@onready var shadow: ColorRect = $Shadow

func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

func _on_settings_pressed() -> void:
	shadow.visible = true
	var settings = load("res://scenes/menu/settings.tscn").instantiate()
	get_tree().current_scene.add_child(settings)
	settings.return_back_signal.connect(_on_return_back_signal)

func _on_return_back_signal() -> void:
	shadow.visible = false

func _on_login_pressed() -> void:
	pass # Replace with function body.

func _on_new_profile_pressed() -> void:
	pass # Replace with function body.
