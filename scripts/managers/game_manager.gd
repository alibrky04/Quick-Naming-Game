extends Node

const staticSpeedBoost = 5

var initialSpeed = 120
var selectedGame = 1
var difficultyLevel = 1
var score = 0
var itemCounter = 0
var setItemIndex = 0
var speedBooster = 0
var itemSpeed = initialSpeed + speedBooster
var is_paused = false

var currentItems = []
var currentProfile = ""

@onready var boost_reset: Timer = $BoostReset

signal score_updated(new_score)
signal item_generated()

func add_points(points: int) -> void:
	score += points
	score_updated.emit(score)

func get_ending_screen() -> void:
	var ending_scene = load("res://scenes/menu/ending_screen.tscn").instantiate()
	get_tree().current_scene.add_child(ending_scene)
	
	ending_scene.position = Vector2(690, 220)
	
	ending_scene.score.text = "Puan: " + str(score)
	ending_scene.count.text = "Balon Sayısı: " + str(itemCounter)
	ending_scene.best_score.text = "En Yüksek Puan: " + str(SQLManager.get_best_score())
	
	score = 0
	itemCounter = 0
	setItemIndex = 0
	speedBooster = 0

func _on_boost_reset_timeout() -> void:
	if itemSpeed > initialSpeed:
		speedBooster -= staticSpeedBoost
	
func calculate_speed() -> void:
	itemSpeed = GameManager.initialSpeed + (speedBooster * int(!is_paused))

func remove_combining_marks(text: String) -> String:
	var output = ""
	for c in text:
		var code = c.unicode_at(0)
		if code < 0x0300 or code > 0x036F:
			output += c
	return output
