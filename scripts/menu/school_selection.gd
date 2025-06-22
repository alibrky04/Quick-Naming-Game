extends Node2D

@onready var shadow: ColorRect = $Shadow

func _on_home_pressed() -> void:
	GameManager.currentProfile = ""
	get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/main_menu.tscn")

func _on_settings_pressed() -> void:
	shadow.visible = true
	var settings = load("res://scenes/menu/settings.tscn").instantiate()
	get_tree().current_scene.add_child(settings)
	settings.position = Vector2(660, 60)
	settings.return_back_signal.connect(_on_return_back_signal)

func _on_return_back_signal() -> void:
	shadow.visible = false

func _on_pre_school_pressed() -> void:
	GameManager.selected_school = "preschool"
	SetManager.unique_data_path = "res://assets/sets_unique_preschool.json"
	SetManager.set_count = 3
	SetManager.played_set_types = []
	if SetManager.debug_target_set > 3:
		SetManager.debug_enabled = false
	SetManager.json_unique_data = SetManager.read_json(SetManager.unique_data_path)
	get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/game_selection.tscn")

func _on_elementary_school_pressed() -> void:
	GameManager.selected_school = "elementary"
	SetManager.unique_data_path = "res://assets/sets_unique_elemantary.json"
	SetManager.set_count = 6
	SetManager.played_set_types = []
	SetManager.json_unique_data = SetManager.read_json(SetManager.unique_data_path)
	get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/game_selection.tscn")

func _on_button_button_down() -> void:
	GameManager.currentProfile = ""
	
	if !GameManager.recentProfileAction:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/profile/login_screen.tscn")
	else:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/profile/new_account.tscn")
