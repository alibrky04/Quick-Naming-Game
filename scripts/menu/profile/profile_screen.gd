extends Node2D

@onready var shadow: ColorRect = $Shadow

func _on_home_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/main_menu.tscn")

func _on_settings_pressed() -> void:
	shadow.visible = true
	var settings = load("res://scenes/menu/settings.tscn").instantiate()
	get_tree().current_scene.add_child(settings)
	settings.position = Vector2(660, 60)
	settings.return_back_signal.connect(_on_return_back_signal)

func _on_return_back_signal() -> void:
	shadow.visible = false

func _on_login_pressed() -> void:
	GameManager.recentProfileAction = 0
	get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/profile/login_screen.tscn")

func _on_new_profile_pressed() -> void:
	GameManager.recentProfileAction = 1
	get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/profile/new_account.tscn")

func _on_button_button_down() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/main_menu.tscn")
