extends Node2D

signal return_back_signal()
signal menu_back_signal()

func _on_cancel_button_down() -> void:
	queue_free()
	return_back_signal.emit()

func _on_to_game_select_button_down() -> void:
	menu_back_signal.emit()
	AudioManager.on_scene_changed("menu")
	
	CloudBackground.cloud_speed = CloudBackground.menu_cloud_speed
	for cloud in CloudBackground.cloud_list:
		cloud.modulate.a = CloudBackground.menu_cloud_alpha
	
	get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/game_selection.tscn")

func _on_home_button_down() -> void:
	menu_back_signal.emit()
	AudioManager.on_scene_changed("menu")
	GameManager.currentProfile = ""
	
	CloudBackground.cloud_speed = CloudBackground.menu_cloud_speed
	for cloud in CloudBackground.cloud_list:
		cloud.modulate.a = CloudBackground.menu_cloud_alpha
		
	get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/main_menu.tscn")

func _on_restart_button_down() -> void:
	menu_back_signal.emit()
	
	SetManager.random_set_select()
	if GameManager.selectedGame == 1:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/balloon_game/balloon_game.tscn")
	elif GameManager.selectedGame == 2:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/mole_game/mole_game.tscn")
	elif GameManager.selectedGame == 3:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/space_game/space_game.tscn")
	elif GameManager.selectedGame == 4:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/water_game/water_game.tscn")
