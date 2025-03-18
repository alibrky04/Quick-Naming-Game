extends Node

var database: SQLite

func _ready() -> void:
	database = SQLite.new()
	database.path = "user://data.db"
	database.open_db()

func _process(_delta: float) -> void:
	pass
