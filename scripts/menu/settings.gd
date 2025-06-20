extends Node2D

@onready var profile: Label = $Tabs/Diğer/Diğer/Profile
@onready var sound_slider: HSlider = $Tabs/Diğer/Diğer/Sound/SoundSlider

@onready var text_edit: TextEdit = $Tabs/Oyun/Oyun/HBoxContainer/TextEdit
@onready var button: Button = $Tabs/Oyun/Oyun/HBoxContainer/Button
@onready var speed_check: CheckBox = $Tabs/Oyun/Oyun/SpeedControl/SpeedCheck

@onready var option_button: OptionButton = $Tabs/Oyun/Oyun/SetType/OptionButton

@onready var easy: CheckBox = $Tabs/Oyun/Oyun/Modes/Easy/Easy
@onready var hard: CheckBox = $Tabs/Oyun/Oyun/Modes/Hard/Hard
@onready var shuffle: OptionButton = $Tabs/Oyun/Oyun/Modes/Shuffle/Shuffle

const MIN_DB = -80.0
const MAX_DB = 0.0

var shuffle_list = ["Hayır", "M1", "M2", "M3"]

signal return_back_signal()

func _ready() -> void:
	if GameManager.currentProfile != "":
		profile.text = "Hesap: " + GameManager.currentProfile
	
	var db = AudioManager.player.volume_db
	sound_slider.value = clamp((db - MIN_DB) / (MAX_DB - MIN_DB) * 100.0, 0, 100)
	
	speed_check.button_pressed = GameManager.can_increase_speed == true
	easy.button_pressed = GameManager.set_mode == "easy"
	hard.button_pressed = GameManager.set_mode == "hard"
	
	shuffle.set_block_signals(true)
	
	if GameManager.selected_school == "preschool":
		shuffle.set_item_disabled(3, true)
		
	if GameManager.do_shuffle:
		shuffle.select(shuffle_list.find(GameManager.shuffle_mode))
	else:
		shuffle.select(0)
		
	shuffle.set_block_signals(false)
	
	option_button.set_block_signals(true)
	
	if GameManager.selected_school == "preschool":
		option_button.set_item_disabled(4, true)
		option_button.set_item_disabled(5, true)
		option_button.set_item_disabled(6, true)
	
	if SetManager.debug_enabled:
		option_button.select(SetManager.debug_target_set)
	else:
		option_button.select(0)
		
	option_button.set_block_signals(false)

func _on_cancel_pressed() -> void:
	queue_free()
	return_back_signal.emit()

func _on_text_edit_text_changed() -> void:
	var old_text := text_edit.text

	var filtered := ""
	for c in old_text:
		if c.is_valid_int():
			filtered += c

	if old_text != filtered:
		text_edit.text = filtered
		text_edit.set_caret_column(filtered.length())

func _on_button_pressed() -> void:
	if not text_edit.text.is_empty():
		GameManager.initialSpeed = int(text_edit.text)
		text_edit.placeholder_text = str(GameManager.initialSpeed)

func _on_scores_pressed() -> void:
	if GameManager.currentProfile != "":
		if SQLManager.get_last_scores(GameManager.currentProfile, 1):
			var plot = load("res://scenes/ui/plot_interface.tscn").instantiate()
			
			self.add_child(plot)
			
			plot.chart.global_position = Vector2(735, 350)

func _on_sound_slider_value_changed(value: float) -> void:
	var db = lerp(MIN_DB, MAX_DB, value / 100.0)
	AudioManager.player.volume_db = db

func _on_speed_check_toggled(toggled_on: bool) -> void:
	GameManager.can_increase_speed = toggled_on

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

func _on_option_button_item_selected(index: int) -> void:
	if index > 0:
		SetManager.debug_enabled = true
		SetManager.debug_target_set = index

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ENTER:
		if text_edit.has_focus():
			button.emit_signal("pressed")
			get_viewport().set_input_as_handled()
		elif button.visible and not button.disabled:
			button.emit_signal("pressed")
			get_viewport().set_input_as_handled()
