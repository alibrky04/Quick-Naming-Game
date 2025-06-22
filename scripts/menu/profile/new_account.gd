extends Node2D

@onready var shadow: ColorRect = $Shadow
@onready var forms: VBoxContainer = $Forms
@onready var user_error: Label = $UserError
@onready var create_button: Button = $Create

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

func _on_create_pressed() -> void:
	var userName = forms.get_node("UserName/TextEdit").text.strip_edges()
	var profileName = forms.get_node("Name/TextEdit").text.strip_edges()
	var profileSurname = forms.get_node("Surname/TextEdit").text.strip_edges()
	
	if userName == "" or profileName == "" or profileSurname == "":
		user_error.text = "Lütfen tüm alanları doldurunuz."
		user_error.visible = true
		return
	
	user_error.visible = false

	if !SQLManager.user_exists(userName):
		var data = {
			"user_name": userName,
			"name": profileName,
			"surname": profileSurname
		}
		SQLManager.insert_data("profiles", data)
		GameManager.currentProfile = userName
		get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/school_selection.tscn")
	else:
		user_error.text = "User already exists."
		user_error.visible = true

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ENTER:
		for field_name in ["UserName/TextEdit", "Name/TextEdit", "Surname/TextEdit"]:
			var te = forms.get_node(field_name)
			if te.has_focus():
				create_button.emit_signal("pressed")
				get_viewport().set_input_as_handled()
				return

		if create_button.visible and not create_button.disabled:
			create_button.emit_signal("pressed")
			get_viewport().set_input_as_handled()

func _on_button_button_down() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/profile/profile_screen.tscn")
