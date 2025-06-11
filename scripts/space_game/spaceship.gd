extends Node2D

var health

@onready var hit_box: Area2D = $HitBox
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player: AudioStreamPlayer = $Player

signal ship_broke

func _ready() -> void:
	health = 21

func _process(_delta: float) -> void:
	reflect_damage()

func _on_hit_box_area_entered(area: Area2D) -> void:
	var meteor = area.get_parent()

	if not meteor.canActivate or not meteor.visible:
		return

	health -= 1
	play_hit_animation()

	if is_instance_valid(meteor):
		GameManager.currentItems.erase(meteor)
		player.play()
		meteor.visible = false
		await player.finished
		meteor.queue_free()

func reflect_damage():
	if health == 14:
		sprite_2d.texture = load("res://assets/Images/space_game/spaceship_damaged.png")
	elif health == 7:
		sprite_2d.texture = load("res://assets/Images/space_game/spaceship_broken.png")
	elif health <= 0:
		ship_broke.emit()
		queue_free()

func play_hit_animation() -> void:
	var original_scale = scale
	var original_modulate = sprite_2d.modulate
	var tween := create_tween()

	# Scale punch
	tween.tween_property(self, "scale", original_scale * 1.2, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", original_scale, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Flash red
	tween.parallel().tween_property(sprite_2d, "modulate", Color(1, 0.3, 0.3), 0.05)
	tween.tween_property(sprite_2d, "modulate", original_modulate, 0.1)
