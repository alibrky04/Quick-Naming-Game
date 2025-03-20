extends Node2D

@onready var score: Label = $Texts/Score
@onready var count: Label = $Texts/Count
@onready var best_score: Label = $Texts/BestScore
@onready var game_over: AudioStreamPlayer = $GameOver

var star_scene = preload("res://scenes/ui/star.tscn")
const animation_duration = 0.8
var rotation_amount = 360

func _ready() -> void:
	game_over.play()
	
	if SQLManager.best_score_achieved:
		_on_best_score_achieved()

func _on_restart_pressed() -> void:
	SetManager.random_set_select()
	get_tree().change_scene_to_file("res://scenes/balloon_game/balloon_game.tscn")

func _on_home_pressed() -> void:
	AudioManager.on_scene_changed("menu")
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

func _on_best_score_achieved():
	const num_stars = 2
	var best_score_position = Vector2(280, 500)

	for i in range(num_stars):
		_spawn_star(best_score_position - Vector2(100 + i * 30, 25 + i * 30))

	for i in range(num_stars):
		_spawn_star(best_score_position + Vector2(100 + i * 30, 25 + i * 30))
		
	SQLManager.best_score_achieved = false

func _spawn_star(target_position: Vector2):
	var star = star_scene.instantiate()
	star.position = target_position
	star.scale = Vector2(0.5, 0.5)
	get_tree().current_scene.add_child(star)
	
	var tween = get_tree().create_tween()
	var rotation_amount = randi_range(180, 720) * (-1 if randi() % 2 == 0 else 1)
	var target_y = target_position.y + randi_range(-10, 10)

	tween.tween_property(star, "position:y", target_y, animation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(star, "rotation_degrees", rotation_amount, animation_duration).set_trans(Tween.TRANS_LINEAR)
	tween.chain().tween_property(star, "position:y", target_position.y, animation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_property(star, "scale", Vector2(0, 0), animation_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	tween.finished.connect(func():
		star.queue_free()
		tween.kill()
	)
