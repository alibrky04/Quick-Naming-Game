extends Node2D

const menu_cloud_speed = 20.0
const game_cloud_speed = 50.0

const menu_cloud_alpha = 0.75
const game_cloud_alpha = 1.25

@export var cloud_speed := menu_cloud_speed
@export var reset_margin := 60.0

var cloud_list := []

func _ready() -> void:
	for child in get_children():
		if child is Sprite2D:
			cloud_list.append(child)

func _process(delta: float) -> void:
	var screen_height = get_viewport_rect().size.y

	for cloud in cloud_list:
		cloud.position.y += cloud_speed * delta
		if cloud.position.y > screen_height + reset_margin:
			cloud.position.y = -reset_margin
			cloud.position.x = randf_range(cloud.position.x - 10, cloud.position.x + 10)
