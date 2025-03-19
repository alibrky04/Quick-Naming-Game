extends Node2D

@onready var profile: Label = $Profile

signal return_back_signal()

func _ready() -> void:
	if GameManager.currentProfile != "":
		profile.text = "Hesap: " + GameManager.currentProfile

func _on_cancel_pressed() -> void:
	queue_free()
	return_back_signal.emit()

func _on_easy_pressed() -> void:
	GameManager.initialSpeed = 30

func _on_normal_pressed() -> void:
	GameManager.initialSpeed = 60

func _on_hard_pressed() -> void:
	GameManager.initialSpeed = 120

func _on_scores_pressed() -> void:
	if GameManager.currentProfile != "":
		if SQLManager.get_last_scores(GameManager.currentProfile, 1):
			var plot = load("res://scenes/ui/plot_interface.tscn").instantiate()
			
			self.add_child(plot)
			
			plot.chart.global_position = Vector2(90, 480)
