extends Label

func _ready() -> void:
	GameManager.score_updated.connect(update_score)

func update_score(new_score: int) -> void:
	text = str(new_score)
