extends Node

const staticSpeedBoost = 5

var initialSpeed = 60
var selectedGame = 1 # 1: Balloon Game
var difficultyLevel = 1
var score = 0
var itemCounter = 0
var setItemIndex = 0
var speedBooster = 0
var itemSpeed = initialSpeed + speedBooster

var currentItems = []
var lastItemGenerated = false

const number_map := {
	"bir": "1",
	"iki": "2",
	"üç": "3",
	"dört": "4",
	"beş": "5",
	"altı": "6",
	"yedi": "7",
	"sekiz": "8",
	"dokuz": "9",
	"sıfır": "0"
}

@onready var boost_reset: Timer = $BoostReset

signal score_updated(new_score)
signal item_generated()

func add_points(points: int) -> void:
	score += points
	score_updated.emit(score)

func get_ending_screen() -> void:
	var ending_scene = load("res://scenes/menu/ending_screen.tscn").instantiate()
	get_tree().current_scene.add_child(ending_scene)
	
	ending_scene.score.text = "Puan: " + str(score)
	ending_scene.count.text = "Balon Sayısı: " + str(itemCounter)
	
	score = 0
	itemCounter = 0
	lastItemGenerated = false
	setItemIndex = 0

func _on_boost_reset_timeout() -> void:
	if itemSpeed > initialSpeed:
		speedBooster -= staticSpeedBoost
	
func calculate_speed() -> void:
	itemSpeed = GameManager.initialSpeed + speedBooster

func convert_to_number(word) -> String:
	var number = ""
	
	if word in number_map:
		number = number_map[word]
	else:
		print("Unknown number: ", word)
		
	return number
