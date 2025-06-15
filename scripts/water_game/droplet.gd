extends Node2D

@onready var item_image: Sprite2D = $ItemImage

# Animation Variables
var star_scene = preload("res://scenes/ui/star.tscn")
const corner_position = Vector2(80, 80)
const corner_scale = Vector2(0.2, 0.2)
const animation_duration = 0.8
var rotation_amount = 360

var isClickable = false
var canActivate = true
var item = ""
var item_type = ""

var fall_speed = GameManager.itemSpeed
var is_told = false

func _ready():
	if item_image:
		var game_name = GameManager.games[GameManager.selectedGame]
		var path = "res://assets/SetImages/{0}/{1}.png".format([game_name, item])
		set_item(path)

func _process(delta: float) -> void:
	if is_told:
		fall_speed = GameManager.itemSpeed * 8.0
	else:
		fall_speed = GameManager.itemSpeed

	position.y += fall_speed * delta

	if position.y > 800:
		canActivate = false
	elif position.y > 1180:
		GameManager.currentItems.erase(self)
		queue_free()

func set_item(image_path: String):
	item_image.texture = load(image_path)

func catch():
	GameManager.add_points(10)
	
	GameManager.currentItems.erase(self)
	queue_free()
	
	GameManager.speedBooster += GameManager.staticSpeedBoost
	GameManager.boost_reset.start()
	GameManager.itemCounter += 1
	
	play_star()

func play_star():
	var star = star_scene.instantiate()
	star.position = position
	star.scale = Vector2(1, 1)
	get_parent().add_child(star)
	
	var tween = get_tree().create_tween()
	
	rotation_amount = randi_range(180, 720) * (-1 if randi() % 2 == 0 else 1)
	
	tween.tween_property(star, "position", corner_position, animation_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(star, "scale", corner_scale, animation_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(star, "rotation_degrees", rotation_amount, animation_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
	#tween.parallel().tween_property(star, "modulate:a", 0, animation_duration)
	tween.finished.connect(func():
		star.queue_free()
		tween.kill()
	)
	
