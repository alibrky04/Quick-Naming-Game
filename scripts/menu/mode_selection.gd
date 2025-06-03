extends Node2D

@onready var shadow: ColorRect = $Shadow
@onready var easy: CheckBox = $VBoxContainer/Easy/Easy
@onready var hard: CheckBox = $VBoxContainer/Hard/Hard
@onready var shuffle: OptionButton = $VBoxContainer/Shuffle/Shuffle

var shuffle_list = ["hayır", "M1", "M2", "M3"]

func _ready():
	if GameManager.selected_school == "preschool":
		shuffle.set_item_disabled(3, true)

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

func _on_easy_toggled(toggled_on: bool) -> void:
	if toggled_on:
		hard.button_pressed = false
		GameManager.set_mode = "easy"
	else:
		if !hard.button_pressed:
			easy.button_pressed = true

func _on_hard_toggled(toggled_on: bool) -> void:
	if toggled_on:
		easy.button_pressed = false
		GameManager.set_mode = "hard"
	else:
		if !easy.button_pressed:
			hard.button_pressed = true

func _on_shuffle_item_selected(index: int) -> void:
	if index == 0:
		GameManager.do_shuffle = false
	else:
		GameManager.do_shuffle = true
		GameManager.shuffle_mode = shuffle_list[index]

func _on_pre_school_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/game_selection.tscn")
