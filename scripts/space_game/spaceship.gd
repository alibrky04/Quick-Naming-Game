extends Node2D

var health

@onready var hit_box: Area2D = $HitBox
@onready var sprite_2d: Sprite2D = $Sprite2D

signal ship_broke

func _ready() -> void:
	health = 15

func _process(_delta: float) -> void:
	reflect_damage()

func _on_hit_box_area_entered(area: Area2D) -> void:
	health -= 1
	
	if is_instance_valid(area.get_parent()):
		GameManager.currentItems.erase(area.get_parent())
		area.get_parent().queue_free()

func reflect_damage():
	if health == 10:
		sprite_2d.texture = load("res://assets/Images/space_game/spaceship_damaged.png")
	elif health == 5:
		sprite_2d.texture = load("res://assets/Images/space_game/spaceship_broken.png")
	elif health <= 0:
		ship_broke.emit()
		queue_free()
