extends Node2D

@onready var shadow: ColorRect = $Shadow
@onready var forms: VBoxContainer = $Forms
@onready var user_error: Label = $UserError

func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

func _on_settings_pressed() -> void:
	shadow.visible = true
	var settings = load("res://scenes/menu/settings.tscn").instantiate()
	get_tree().current_scene.add_child(settings)
	settings.return_back_signal.connect(_on_return_back_signal)

func _on_return_back_signal() -> void:
	shadow.visible = false

func _on_create_pressed() -> void:
	var userName = forms.get_node("UserName/TextEdit").text
	var profileName = forms.get_node("Name/TextEdit").text
	var profileSurname = forms.get_node("Surname/TextEdit").text
	
	var data = {
		"user_name": userName,
		"name": profileName,
		"surname": profileSurname
	}
	if !SQLManager.user_exists(userName):
		SQLManager.insert_data("profiles", data)
		GameManager.currentProfile = userName
		get_tree().change_scene_to_file("res://scenes/menu/school_selection.tscn")
	else:
		user_error.visible = true
