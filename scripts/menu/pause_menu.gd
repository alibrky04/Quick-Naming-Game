extends Node2D

signal return_back_signal()
signal menu_back_signal()

func _on_cancel_button_down() -> void:
	queue_free()
	return_back_signal.emit()

func _on_to_game_select_button_down() -> void:
	menu_back_signal.emit()
	AudioManager.on_scene_changed("menu")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/game_selection.tscn")

func _on_home_button_down() -> void:
	menu_back_signal.emit()
	AudioManager.on_scene_changed("menu")
	GameManager.currentProfile = ""
	get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/main_menu.tscn")
