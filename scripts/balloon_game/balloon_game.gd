extends Node2D

@onready var shadow: ColorRect = $Shadow
@onready var progress_bar = $ProgressBar
@onready var game_time: Timer = $GameTime

const total_time = 60
var remaining_time = total_time

func _ready() -> void:
	GameManager.itemSpeed = GameManager.initialSpeed
	
	progress_bar.min_value = 0
	progress_bar.max_value = total_time
	progress_bar.value = total_time
	
	game_time.start(total_time)
	
func _process(delta: float) -> void:
	remaining_time -= delta
	
	progress_bar.value = remaining_time

func _on_stt_text_signal(message) -> void:
	for item in GameManager.currentItems:
		if not item.isClickable and item.item in message and item.canActivate:
			item.isClickable = true
			item.indicator.visible = true
			break

func _on_game_time_timeout() -> void:
	shadow.visible = true
	
	for item in GameManager.currentItems.duplicate():
		if is_instance_valid(item):
			item.queue_free()
	GameManager.currentItems.clear()
	
	SQLManager.save_score()
