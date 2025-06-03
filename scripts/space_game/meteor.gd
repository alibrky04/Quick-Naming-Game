extends Node2D

# Animation Variables
var star_scene = preload("res://scenes/ui/star.tscn")
const corner_position = Vector2(120, 120)
const corner_scale = Vector2(0.2, 0.2)
const animation_duration = 0.8
var rotation_amount = 360

@onready var item_image: Sprite2D = $ItemImage
@onready var spaceship: Node2D = get_parent().get_parent().get_node("Spaceship")
@onready var player: AudioStreamPlayer = $Player

var canActivate = true
var item = ""
var item_type = ""
var already_broken = false

var direction: Vector2
var distance: float
var t: float
var speed: float

func _ready():
	var game_name = GameManager.games[GameManager.selectedGame]
	var path = "res://assets/SetImages/%s/%s.png" % [game_name, item]
	set_item(path)
	
	distance = global_position.distance_to(spaceship.global_position)
	direction = (spaceship.global_position - global_position).normalized()
	rotation = direction.angle() + deg_to_rad(270)

func _process(delta: float) -> void:
	t = 480.0 / max(GameManager.itemSpeed, 0.01)
	speed = distance / t
	
	if !GameManager.is_paused:
		position += direction * speed * delta

func set_item(image_path: String):
	item_image.texture = load(image_path)

func destroy_meteor():
	if not is_inside_tree():
		return
	if is_instance_valid(self):
		already_broken = true
		
		GameManager.add_points(10)

		await play_shake()

		player.play()
		visible = false
		play_star()
		await player.finished
		
		GameManager.currentItems.erase(self)
		queue_free()
		
		GameManager.speedBooster += GameManager.staticSpeedBoost
		GameManager.boost_reset.start()
		GameManager.itemCounter += 1

func play_star():
	var star = star_scene.instantiate()
	
	var global_pos = item_image.get_global_position()
	star.global_position = global_pos
	star.scale = Vector2(1, 1)

	var main_scene = get_tree().root.get_node("SpaceGame")
	main_scene.add_child(star)

	var tween = get_tree().create_tween()

	rotation_amount = randi_range(180, 720) * (-1 if randi() % 2 == 0 else 1)

	tween.tween_property(star, "global_position", corner_position, animation_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(star, "scale", corner_scale, animation_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(star, "rotation_degrees", rotation_amount, animation_duration)\
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

	tween.finished.connect(func():
		star.queue_free()
		tween.kill()
	)

func play_shake() -> void:
	var tween = create_tween()
	var shake_amount = 5.0
	var original_position = position
	
	tween.tween_property(self, "position", original_position + Vector2(shake_amount, 0), 0.03)
	tween.tween_property(self, "position", original_position - Vector2(shake_amount, 0), 0.03)
	tween.tween_property(self, "position", original_position, 0.03)

	await tween.finished
