extends Node2D

class_name Mole

# Animation Variables
var potato_scene = preload("res://scenes/ui/potato.tscn")
const corner_position = Vector2(120, 120)
const corner_scale = Vector2(0.2, 0.2)
const animation_duration = 0.8
var rotation_amount = 360

@onready var item_image: Sprite2D = $ItemImage
@onready var despawn_timer: Timer = $DespawnTimer

var canActivate = true
var item = ""
var item_type = ""

var spawn_sounds: Array[AudioStream] = []
var despawn_sounds: Array[AudioStream] = []
var hit_sounds: Array[AudioStream] = []

func _ready():
	for i in range(1, 5):
		spawn_sounds.append(load("res://assets/Sounds/mole/mole_spawn_%d.mp3" % i))

	for i in range(1, 3):
		despawn_sounds.append(load("res://assets/Sounds/mole/mole_despawn_%d.mp3" % i))

	for i in range(1, 3):
		hit_sounds.append(load("res://assets/Sounds/mole/mole_hit_%d.mp3" % i))

	AudioManager.play_random_sound(spawn_sounds)

	var game_name = GameManager.games[GameManager.selectedGame]
	var path = "res://assets/SetImages/%s/%s.png" % [game_name, item]
	set_item(path)
	
	animate_spawn()

func set_item(image_path: String):
	item_image.texture = load(image_path)

func hit_mole():
	if not is_inside_tree():
		return
	if is_instance_valid(self):
		despawn_timer.stop()
		AudioManager.play_random_sound(hit_sounds)
		GameManager.add_points(10)
		GameManager.currentItems.erase(self)
		GameManager.speedBooster += GameManager.staticSpeedBoost
		GameManager.boost_reset.start()
		GameManager.itemCounter += 1

		play_potato()
		animate_hit()

func _on_despawn_timer_timeout():
	if is_instance_valid(self):
		AudioManager.play_random_sound(despawn_sounds)
		GameManager.currentItems.erase(self)
		animate_despawn()

func play_potato():
	var potato = potato_scene.instantiate()
	
	var global_pos = item_image.get_global_position()
	potato.global_position = global_pos
	potato.scale = Vector2(0.2, 0.2)

	var main_scene = get_tree().root.get_node("MoleGame")
	main_scene.add_child(potato)

	var tween = get_tree().create_tween()

	rotation_amount = randi_range(180, 720) * (-1 if randi() % 2 == 0 else 1)

	tween.tween_property(potato, "global_position", corner_position, animation_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(potato, "scale", corner_scale, animation_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(potato, "rotation_degrees", rotation_amount, animation_duration)\
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

	tween.finished.connect(func():
		potato.queue_free()
		tween.kill()
	)

func animate_spawn():
	scale = Vector2(0, 0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.3)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)		

func animate_hit():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.1)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(0, 0), 0.2)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.finished.connect(func(): queue_free())	

func animate_despawn():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.3)\
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.finished.connect(func(): queue_free())
