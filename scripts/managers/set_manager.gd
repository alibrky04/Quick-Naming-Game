extends Node

var set_count = 12

var unique_data_path = "res://assets/sets_unique_elemantary.json"
var json_unique_data = {}

var selected_set = {}

var random_set = {}
var last_picked = ""

var shuffled_queue = []

func _ready():
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
	if GameManager.do_shuffle:
		shuffle_set_select()
		return

	random_set = json_unique_data[GameManager.set_mode]["set_" + str(randi() % set_count + 1)]
	var count = 5 if GameManager.set_mode == "easy" else 6
	selected_set["type"] = random_set["type"]
	selected_set["items"] = generate_subset(count)
	initialize_shuffled_queue()

func shuffle_set_select():
	var school_type = GameManager.selected_school
	var mode = GameManager.set_mode
	var shuffle_mod = GameManager.shuffle_mode
	
	# Define shuffle distributions
	var shuffle_rules = {
		"elementary": {
			"easy": {
				"M1": [3, 2],
				"M2": [2, 2, 1],
				"M3": [2, 1, 1, 1]
			},
			"hard": {
				"M1": [3, 3],
				"M2": [2, 2, 2],
				"M3": [2, 2, 1, 1]
			}
		},
		"preschool": {
			"easy": {
				"M1": [3, 2],
				"M2": [2, 2, 1]
			},
			"hard": {
				"M1": [3, 3],
				"M2": [2, 2, 2]
			}
		}
	}

	if not shuffle_rules.has(school_type):
		print("Invalid school type:", school_type)
		return

	if not shuffle_rules[school_type].has(mode):
		print("Invalid mode for school type", school_type, ":", mode)
		return

	if not shuffle_rules[school_type][mode].has(shuffle_mod):
		print("Invalid shuffle mod for school type", school_type, "and mode", mode, ":", shuffle_mod)
		return

	var counts = shuffle_rules[school_type][mode][shuffle_mod]
	var set_keys = json_unique_data[mode].keys()
	var used_sets := []
	var result: Array = []
	selected_set["type"] = []

	for count in counts:
		var key = set_keys[randi() % set_keys.size()]
		while key in used_sets:
			key = set_keys[randi() % set_keys.size()]
		used_sets.append(key)

		var chosen_set = json_unique_data[mode][key]
		var type_name = chosen_set["type"]
		selected_set["type"].append(type_name)

		var pool = chosen_set["items"].duplicate()
		var chosen_items: Array = []

		for i in count:
			if pool.is_empty(): break
			var index = randi() % pool.size()
			var item = pool[index]
			result.append(item)
			chosen_items.append(item)
			pool.remove_at(index)

	selected_set["items"] = result
	initialize_shuffled_queue()

func generate_subset(count: int) -> Array:
	var pool = random_set["items"].duplicate()
	var result: Array = []

	while result.size() < count and pool.size() > 0:
		var index = randi() % pool.size()
		result.append(pool[index])
		pool.remove_at(index)

	return result

func initialize_shuffled_queue():
	shuffled_queue = selected_set["items"].duplicate()
	shuffled_queue.shuffle()

func create_random_item():
	var word = pick_word()
	return word

func pick_word():
	if shuffled_queue.size() == 0:
		initialize_shuffled_queue()
	
	var word = shuffled_queue.pop_front()
	
	while word == last_picked and shuffled_queue.size() > 0:
		word = shuffled_queue.pop_front()

	last_picked = word
	return word
