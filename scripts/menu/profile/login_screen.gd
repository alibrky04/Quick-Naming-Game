extends Node2D

@onready var shadow: ColorRect = $Shadow
@onready var user_name: HBoxContainer = $UserName
@onready var text_edit: TextEdit = $UserName/TextEdit
@onready var login: Button = $Login
@onready var user_error: Label = $UserError

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
	var userName = user_name.get_node("TextEdit").text
	
	if SQLManager.user_exists(userName):
		GameManager.currentProfile = userName
		get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/school_selection.tscn")
	else:
		user_error.visible = true

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			if text_edit.has_focus():
				login.emit_signal("pressed")
				get_viewport().set_input_as_handled()
			elif login.visible and not login.disabled:
				login.emit_signal("pressed")
				get_viewport().set_input_as_handled()

func _on_button_button_down() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/profile/profile_screen.tscn")
