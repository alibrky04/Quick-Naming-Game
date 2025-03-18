extends Area2D

@onready var item_image = $ItemImage
@onready var color_image = $ColorImage
@onready var shape_image = $ShapeImage
@onready var item_text = $ItemText
@onready var pop_sound: AudioStreamPlayer = $PopSound
@onready var indicator: Sprite2D = $Indicator

var star_scene = preload("res://scenes/ui/star.tscn")
const corner_position = Vector2(80, 80)
const corner_scale = Vector2(0.2, 0.2)
const animation_duration = 0.8
var rotation_amount = 360

var isClickable = false
var canActivate = true
var item = ""
var item_type = ""

func _ready():
	if item_image and item_text:
		set_item("res://assets/SetImages/" + item + ".png")

func _process(delta: float) -> void:
	GameManager.calculate_speed()
	position.y -= GameManager.itemSpeed * delta
	if position.y < -40:
		canActivate = false
	elif position.y < -100:
		GameManager.currentItems.erase(self)
		queue_free()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and isClickable:
		pop_balloon()

func set_item(image_path: String):
	if item_type == "object_naming":
		item_image.texture = load(image_path)
	elif item_type == "shape_naming":
		shape_image.texture = load(image_path)
	elif item_type == "color_naming":
		color_image.texture = load(image_path)
	elif item_type == "number_naming":
		item_text.text = GameManager.convert_to_number(item)
	else:
		item_text.text = item
		
func pop_balloon():
	GameManager.add_points(10)
	pop_sound.play()
	await pop_sound.finished
	GameManager.currentItems.erase(self)
	queue_free()
	GameManager.speedBooster += GameManager.staticSpeedBoost
	GameManager.boost_reset.start()
	GameManager.itemCounter += 1
	GameManager.item_generated.emit()
	
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
