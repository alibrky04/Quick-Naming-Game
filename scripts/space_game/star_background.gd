extends Node2D

const game_star_speed = 60.0

var star_speed = game_star_speed
var reset_margin = 250.0

var star_list = []

func _ready() -> void:
	for child in get_children():
		if child is Sprite2D:
			star_list.append(child)

func _process(delta: float) -> void:
	var screen_height = get_viewport_rect().size.y

	for star in star_list:
		star.position.y += star_speed * delta
		if star.position.y > screen_height + reset_margin:
			star.position.y = -reset_margin
			star.position.x = randf_range(star.position.x - 10, star.position.x + 10)
