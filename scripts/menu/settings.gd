extends Node2D

@onready var profile: Label = $VBoxContainer/Profile
@onready var sound_slider: HSlider = $VBoxContainer/Sound/SoundSlider

const MIN_DB = -80.0
const MAX_DB = 0.0

signal return_back_signal()

func _ready() -> void:
	if GameManager.currentProfile != "":
		profile.text = "Hesap: " + GameManager.currentProfile
	
	var db = AudioManager.player.volume_db
	sound_slider.value = clamp((db - MIN_DB) / (MAX_DB - MIN_DB) * 100.0, 0, 100)

func _on_cancel_pressed() -> void:
	queue_free()
	return_back_signal.emit()

func _on_easy_pressed() -> void:
	GameManager.initialSpeed = 60

func _on_normal_pressed() -> void:
	GameManager.initialSpeed = 120

func _on_hard_pressed() -> void:
	GameManager.initialSpeed = 180

func _on_scores_pressed() -> void:
	if GameManager.currentProfile != "":
		if SQLManager.get_last_scores(GameManager.currentProfile, 1):
			var plot = load("res://scenes/ui/plot_interface.tscn").instantiate()
			
			self.add_child(plot)
			
			plot.chart.global_position = Vector2(735, 550)

func _on_sound_slider_value_changed(value: float) -> void:
	var db = lerp(MIN_DB, MAX_DB, value / 100.0)
	AudioManager.player.volume_db = db
