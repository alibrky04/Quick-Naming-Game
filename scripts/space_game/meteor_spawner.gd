extends Node2D

@onready var colShape: CollisionShape2D = $SpawnArea/CollisionShape2D
@onready var meteor: PackedScene = preload("res://scenes/space_game/meteor.tscn")
@onready var timer: Timer = $Timer
@onready var meteors: Node2D = $"../Meteors"
@onready var spaceship: Node2D = get_parent().get_node("Spaceship")

var positionInArea: Vector2
var itemGenerationSpeed: float

func _ready() -> void:
	update_generation_speed()
	
	timer.start(itemGenerationSpeed)

func _process(_delta: float) -> void:
	update_generation_speed()

func _on_timer_timeout() -> void:
	spawn_meteor()
		
func spawn_meteor() -> void:
	var centerpos = global_position
		
	var shape = colShape.shape as RectangleShape2D
	
	var size = shape.extents * 2
	
	positionInArea.x = randf_range(centerpos.x - size.x / 2, centerpos.x + size.x / 2)
	positionInArea.y = randf_range(centerpos.y - size.y / 2, centerpos.y + size.y / 2)
	
	var spawn = meteor.instantiate()
	spawn.global_position = positionInArea
	spawn.item = SetManager.create_random_item()
	spawn.item_type = SetManager.selected_set["type"]
	GameManager.currentItems.append(spawn)
	
	meteors.add_child.call_deferred(spawn)

func update_generation_speed():
	GameManager.calculate_speed()
	itemGenerationSpeed = 480.0 / max(GameManager.itemSpeed, 0.01)
	timer.set_wait_time(itemGenerationSpeed)
