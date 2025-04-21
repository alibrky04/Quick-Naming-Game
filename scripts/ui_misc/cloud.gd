extends Sprite2D

var speed = 60

func _process(delta: float) -> void:
	position.y += speed * delta
	if position.y > get_viewport_rect().size.y + 80:
		position.y = -80
		position.x = randf_range(position.x - 10, position.x + 10)
