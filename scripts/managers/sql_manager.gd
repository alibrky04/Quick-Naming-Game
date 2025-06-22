extends Node

var database: SQLite

var tables = {
	"profiles": {
		"user_name": {
			"data_type": "text",
			"primary_key": true,
			"not_null": true
		},
		"name": {"data_type": "text"},
		"surname": {"data_type": "text"},
	},
	"best_scores": {
		"user_name": {
			"data_type": "text",
			"primary_key": true,
			"foreign_key": "profiles.user_name",
			"not_null": true
		},
		"best_score": {"data_type": "int"}
	},
	"games": {
		"game_id": {
			"data_type": "int",
			"primary_key": true, 
			"not_null": true,
			"auto_increment": true
		},
		"game_date": {
			"data_type": "text",
			"not_null": true
		},
	},
	"plays": {
		"score_id": {
			"data_type": "int",
			"primary_key": true,
			"not_null": true,
			"auto_increment": true
		},
		"user_name": {
			"data_type": "text",
			"not_null": true,
			"foreign_key": "profiles.user_name"
		},
		"game_id": {
			"data_type": "int",
			"not_null": true, 
			"foreign_key": "games.game_id"
		},
	},
	"player_scores": {
		"score_id": {
			"data_type": "int",
			"primary_key": true,
			"foreign_key": "plays.score_id",
			"not_null": true
		},
		"score": {"data_type": "int"}
	},
	"saves": {
		"save_id": {
			"data_type": "int",
			"primary_key": true,
			"not_null": true,
			"auto_increment": true
		},
		"initial_speed": {
			"data_type": "int",
			"not_null": true
		},
		"set_mode": {
			"data_type": "text",
			"not_null": true
		},
		"do_shuffle": {
			"data_type": "int",
			"not_null": true 
		},
		"shuffle_mode": {
			"data_type": "text",
			"not_null": true
		},
		"can_increase_speed": {
			"data_type": "int",
			"not_null": true
		},
		"debug_enabled": {
			"data_type": "int",
			"not_null": true
		},
		"debug_target_set": {
			"data_type": "int",
			"not_null": true
		}
	}
}

var best_score_achieved = false

func _ready() -> void:
	database = SQLite.new()
	database.path = "user://data.db"
	database.open_db()
	database.foreign_keys = true
	
	for table in tables:
		if !table_exists(table):
			create_table(table, tables[table])

func create_table(table_name: String, columns: Dictionary):
	database.create_table(table_name, columns)

func drop_table(table_name: String):
	database.drop_table(table_name)

func insert_data(table_name: String, data: Dictionary):
	database.insert_row(table_name, data)

func table_exists(table_name: String) -> bool:
	var query = "SELECT name FROM sqlite_master WHERE type='table' AND name=?;"
	var success = database.query_with_bindings(query, [table_name])
	
	if success:
		if database.query_result.is_empty():
			return false
	else:
		print("Query failed.")
	return true

func user_exists(user_name: String) -> bool:
	var query = "SELECT COUNT(*) AS user_count FROM profiles WHERE user_name=?;"
	var success = database.query_with_bindings(query, [user_name])
	
	if success:
		if database.query_result[0]["user_count"]:
			return true
		return false
	else:
		print("Query failed.")
	return false

func save_score():
	# Insert the game into the games table
	insert_data("games", {"game_date": Time.get_datetime_string_from_system()})
	
	# Insert the play record into the plays table
	insert_data("plays", {"game_id": get_latest_game_id(), "user_name": GameManager.currentProfile})
	
	# Insert the score into the player_scores table
	insert_data("player_scores", {"score_id": get_latest_score_id(), "score": GameManager.score})

	# Check if the latest score is the best score
	check_and_save_best_score()
	
func get_latest_game_id():
	var query = "SELECT game_id FROM games ORDER BY game_date DESC LIMIT 1;"
	database.query(query)
	
	return database.query_result[0]["game_id"]

func get_latest_score_id():
	var query = "SELECT score_id FROM plays WHERE game_id = (SELECT game_id FROM games ORDER BY game_date DESC LIMIT 1) LIMIT 1;"
	database.query(query)
	
	return database.query_result[0]["score_id"]

func get_best_score():
	var query = "SELECT best_score from best_scores WHERE user_name=?;"
	database.query_with_bindings(query, [GameManager.currentProfile])
	
	return database.query_result[0]["best_score"]
	
func check_and_save_best_score():
	var latest_score = GameManager.score
	
	var query = "SELECT best_score FROM best_scores WHERE user_name=?;"
	var success = database.query_with_bindings(query, [GameManager.currentProfile])
	
	if success:
		if !database.query_result.is_empty():
			var best_score = database.query_result[0]["best_score"]
			
			if latest_score > best_score:
				var update_query = "UPDATE best_scores SET best_score=? WHERE user_name=?;"
				database.query_with_bindings(update_query, [latest_score, GameManager.currentProfile])
				best_score_achieved = true
		else:
			insert_data("best_scores", {"user_name": GameManager.currentProfile, "best_score": latest_score})
			best_score_achieved = true
	else:
		print("Query failed.")

func get_last_scores(user_name: String, score_number: int) -> Array:
	var query = """
		SELECT ps.score 
		FROM player_scores ps
		JOIN plays p ON ps.score_id = p.score_id
		WHERE p.user_name = ?
		ORDER BY p.score_id DESC
		LIMIT ?;
	"""
	var success = database.query_with_bindings(query, [user_name, score_number])
	
	if success:
		var scores = []
		for row in database.query_result:
			scores.append(row["score"])
		scores.reverse()
		return scores
	else:
		print("Query failed.")
		return []

func save_game_settings():
	var data := {
		"initial_speed": GameManager.initialSpeed,
		"set_mode": GameManager.set_mode,
		"do_shuffle": int(GameManager.do_shuffle),
		"shuffle_mode": GameManager.shuffle_mode,
		"can_increase_speed": int(GameManager.can_increase_speed),
		"debug_enabled": int(SetManager.debug_enabled),
		"debug_target_set": SetManager.debug_target_set
	}
	
	insert_data("saves", data)

func load_game_settings() -> void:
	var query := "SELECT * FROM saves ORDER BY save_id DESC LIMIT 1;"
	var success := database.query(query)
	
	if success and not database.query_result.is_empty():
		var row := database.query_result[0]

		GameManager.initialSpeed = row["initial_speed"]
		GameManager.set_mode = row["set_mode"]
		GameManager.do_shuffle = row["do_shuffle"] == 1
		GameManager.shuffle_mode = row["shuffle_mode"]
		GameManager.can_increase_speed = row["can_increase_speed"] == 1

		SetManager.debug_enabled = row["debug_enabled"] == 1
		SetManager.debug_target_set = row["debug_target_set"]
	else:
		print("No saved settings found.")
