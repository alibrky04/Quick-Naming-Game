extends Node

const staticSpeedBoost = 5
const games = {1: "balloon_game", 2: "mole_game", 3: "space_game", 4: "water_game"}

var initialSpeed = 120
var selectedGame = 1
var score = 0
var itemCounter = 0
var setItemIndex = 0
var speedBooster = 0
var itemSpeed = initialSpeed + speedBooster
var is_paused = false
var can_increase_speed = true

var selected_school = ""
var set_mode = "easy"
var do_shuffle = false
var shuffle_mode = "M1"

var currentItems = []
var currentProfile = ""
var recentProfileAction = 0 # 0: Log in, 1: Sign up

@onready var boost_reset: Timer = $BoostReset

signal score_updated(new_score)

func _ready() -> void:
	calculate_speed()
	SQLManager.load_game_settings()

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
	calculate_speed()
	
func calculate_speed() -> void:
	itemSpeed = initialSpeed + (speedBooster * int(!is_paused) * int(can_increase_speed))

func remove_combining_marks(text: String) -> String:
	var output = ""
	for c in text:
		var code = c.unicode_at(0)
		if code < 0x0300 or code > 0x036F:
			output += c
	return output

func _exit_tree() -> void:
	SQLManager.save_game_settings()
