extends Node

const staticSpeedBoost = 5
const games = {1: "balloon_game", 2: "mole_game", 3: "space_game", 4: "water_game"}
const min_similarity_short = 0.6
const min_similarity_long = 0.4

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
	
	var count_label_map = {
		1: 'Balon',
		2: 'Köstebek',
		3: 'Meteor',
		4: 'Damla'
		}
	
	ending_scene.score.text = "Puan: " + str(score)
	ending_scene.count.text = count_label_map[selectedGame] + " Sayısı: " + str(itemCounter)
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

func get_similarity(string_a: String, string_b: String) -> float:
	if string_a == string_b:
		return 1.0
	if string_a.length() == 0 or string_b.length() == 0:
		return 0.0
		
	var len_a = string_a.length()
	var len_b = string_b.length()
	var matrix = []
	
	for i in range(len_a + 1):
		matrix.append([])
		for j in range(len_b + 1):
			matrix[i].append(0)

	for i in range(len_a + 1):
		matrix[i][0] = i
	for j in range(len_b + 1):
		matrix[0][j] = j
		
	for i in range(1, len_a + 1):
		for j in range(1, len_b + 1):
			var cost = 0 if string_a[i - 1] == string_b[j - 1] else 1
			matrix[i][j] = min(matrix[i - 1][j] + 1, min(matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost))
			
	var distance = matrix[len_a][len_b]
	var max_len = max(len_a, len_b)
	return 1.0 - (float(distance) / float(max_len))
