extends Node2D

class_name Mole

@onready var item_image: Sprite2D = $ItemImage
@onready var spawn_noise: AudioStreamPlayer = $SpawnNoise
@onready var despawn_noise: AudioStreamPlayer = $DespawnNoise
@onready var despawn_timer: Timer = $DespawnTimer

var canActivate = true
var item = ""
var item_type = ""

func _ready():
	if item_image:
		spawn_noise.play()
		var game_name = GameManager.games[GameManager.selectedGame]
		var path = "res://assets/SetImages/{0}/{1}.png".format([game_name, item])
		set_item(path)

func set_item(image_path: String):
	item_image.texture = load(image_path)

func hit_mole():
	if not is_inside_tree():
		return
	if is_instance_valid(self):
		despawn_timer.stop()
		despawn_noise.play()
		GameManager.add_points(10)
		GameManager.currentItems.erase(self)
		queue_free()
		GameManager.speedBooster += GameManager.staticSpeedBoost
		GameManager.boost_reset.start()
		GameManager.itemCounter += 1

func _on_despawn_timer_timeout():
	if is_instance_valid(self):
		despawn_noise.play()
		GameManager.currentItems.erase(self)
		queue_free()
