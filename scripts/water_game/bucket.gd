extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player: AudioStreamPlayer = $Player

var fill = 0

func _process(_delta: float) -> void:
	check_fill()

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.get_parent().has_method("catch") and area.get_parent().is_told:
		area.get_parent().catch()
		player.play()
		fill += 1

func check_fill():
	if fill == 5:
		sprite_2d.texture = load("res://assets/Images/water_game/half.png")
	elif fill == 10:
		sprite_2d.texture = load("res://assets/Images/water_game/full.png")
