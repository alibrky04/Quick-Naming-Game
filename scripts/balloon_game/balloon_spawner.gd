extends Area2D

@onready var colShape: CollisionShape2D = $CollisionShape2D
@onready var balloonSpawner: Area2D = $"."
@onready var balloon: PackedScene = preload("res://scenes/balloon_game/balloon.tscn")
@onready var timer: Timer = $Timer

var positionInArea: Vector2
const itemGenerationRate = 1

func _ready() -> void:
	timer.start(itemGenerationRate)

func _on_timer_timeout() -> void:
	if !GameManager.lastItemGenerated:
		spawn_balloon()
		
func spawn_balloon() -> void:
	var centerpos = balloonSpawner.global_position
		
	var shape = colShape.shape as RectangleShape2D
	
	var size = shape.extents * 2
	
	positionInArea.x = randf_range(centerpos.x - size.x / 2, centerpos.x + size.x / 2)
	positionInArea.y = randf_range(centerpos.y - size.y / 2, centerpos.y + size.y / 2)
	
	var spawn = balloon.instantiate()
	spawn.global_position = positionInArea
	spawn.item = SetManager.create_random_item()
	spawn.item_type = SetManager.selected_set["type"]
	GameManager.currentItems.append(spawn)
	
	get_tree().current_scene.add_child.call_deferred(spawn)

func _on_game_time_timeout() -> void:
	timer.stop()
	GameManager.lastItemGenerated = true
	GameManager.get_ending_screen()
