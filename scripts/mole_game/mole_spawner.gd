extends Node2D

@onready var nests: GridContainer = $Nests
@onready var timer: Timer = $Timer

var mole = preload("res://scenes/mole_game/mole.tscn")
var itemGenerationSpeed: float
var nest_nodes: Array[TextureRect] = []

func _ready() -> void:
	for child in nests.get_children():
		if child is TextureRect:
			nest_nodes.append(child)
	
	update_generation_speed()
	timer.start()

func _process(_delta: float) -> void:
	update_generation_speed()

func update_generation_speed():
	GameManager.calculate_speed()
	itemGenerationSpeed = 360.0 / max(GameManager.itemSpeed, 0.01)
	timer.set_wait_time(itemGenerationSpeed)

func _on_timer_timeout() -> void:
	spawn_mole()

func spawn_mole() -> void:
	var empty_nests = nest_nodes.filter(func(nest):
		for child in nest.get_children():
			if child is Mole:
				return false
		return true
	)
	
	if empty_nests.is_empty():
		return
	
	var chosen_nest = empty_nests.pick_random()
	
	var spawn = mole.instantiate()
	spawn.item = SetManager.create_random_item()
	spawn.item_type = SetManager.selected_set["type"]
	GameManager.currentItems.append(spawn)
	
	chosen_nest.add_child(spawn)
	spawn.despawn_timer.start(itemGenerationSpeed)
	
	spawn.position = Vector2(chosen_nest.size.x / 2, -300)

func _on_game_time_timeout() -> void:
	timer.stop()
