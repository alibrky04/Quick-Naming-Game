extends Node2D

@onready var profile: Label = $Profile

signal return_back_signal()

func _ready() -> void:
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
