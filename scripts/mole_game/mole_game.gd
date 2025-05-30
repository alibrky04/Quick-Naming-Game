extends Node2D

@onready var shadow: ColorRect = $Shadow
@onready var progress_bar = $ProgressBar
@onready var game_time: Timer = $GameTime

const total_time = 60
var remaining_time = total_time
var resume_speed = 0
var is_paused = false

func _ready() -> void:
	GameManager.itemSpeed = GameManager.initialSpeed
	
	progress_bar.min_value = 0
	progress_bar.max_value = total_time
	progress_bar.value = total_time
	
	game_time.start(total_time)
	
func _process(delta: float) -> void:
	if not is_paused:
		remaining_time -= delta
		progress_bar.value = remaining_time

func _on_stt_text_signal(word: Variant) -> void:
	for item in GameManager.currentItems:
		if not item.isClickable and item.canActivate:
			if item.item in word or (item.item == "1" && "bir" in word):
				item.isClickable = true
				# item.indicator.visible = true
				item.pop_balloon()
				break

func _on_game_time_timeout() -> void:
	for item in GameManager.currentItems.duplicate():
		if is_instance_valid(item):
			item.queue_free()
	GameManager.currentItems.clear()
	
	SQLManager.save_score()
	
	shadow.visible = true
	GameManager.get_ending_screen()

func _on_pause_button_down() -> void:
	pause_resume(true)
	shadow.visible = true
	var pause_menu = load("res://scenes/menu/pause_menu.tscn").instantiate()
	get_tree().current_scene.add_child(pause_menu)
	pause_menu.position = Vector2(690, 220)
	pause_menu.return_back_signal.connect(_on_return_back_signal)
	pause_menu.menu_back_signal.connect(_on_menu_back_signal)

func pause_resume(state: bool):
	GameManager.is_paused = state
	GameManager.boost_reset.paused = state
	is_paused = state
	game_time.paused = state
	for item in GameManager.currentItems:
		item.canActivate = !state
	
	if state:
		resume_speed = GameManager.initialSpeed
		GameManager.initialSpeed = 0
		GameManager.calculate_speed()
		CloudBackground.cloud_speed = 0
	else:
		GameManager.initialSpeed = resume_speed
		GameManager.calculate_speed()
		CloudBackground.cloud_speed = CloudBackground.game_cloud_speed

func _on_return_back_signal() -> void:
	shadow.visible = false
	pause_resume(false)

func _on_menu_back_signal() -> void:
	pause_resume(false)
	for item in GameManager.currentItems.duplicate():
		if is_instance_valid(item):
			item.queue_free()
	GameManager.currentItems.clear()
	
	GameManager.score = 0
	GameManager.itemCounter = 0
	GameManager.setItemIndex = 0
	GameManager.speedBooster = 0
