extends Node

var set_count = 12

var data_path = "res://assets/sets.json"
var json_data = {}

var unique_data_path = "res://assets/sets_unique_elemantary.json"
var json_unique_data = {}

var selected_set = {}

var random_set = {}
var last_four = []

func _ready():
	json_data = read_json(data_path)
	json_unique_data = read_json(unique_data_path)

func read_json(json_file_path: String):
	if FileAccess.file_exists(json_file_path):
		var dataFile = FileAccess.open(json_file_path, FileAccess.READ)
		var parsed_result = JSON.parse_string(dataFile.get_as_text())
		
		if parsed_result is Dictionary:
			return parsed_result
		else:
			print("Error reading file")
	else:
		print("File doesn't exist")
	
func random_set_select():
	random_set = json_unique_data["set_" + str(randi() % set_count + 1)]

func create_random_item():
	selected_set["type"] = random_set["type"]
	selected_set["items"] = []
	
	var word = pick_word()
	last_four.append(word)
	
	if last_four.size() == random_set["items"].size():
		last_four = []
	
	return word
func pick_word():
	if last_four.size() > 0:
		while true:
			var word = random_set["items"][randi() % random_set["items"].size()]
			if not last_four.has(word):
				return word
	return random_set["items"][randi() % random_set["items"].size()]
