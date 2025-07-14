# ScoreManager.gd - Add this as a node in your main scene
extends Node

signal score_changed(new_score)

var current_score: int = 0

func _ready():
	print("Score Manager initialized. Starting score: ", current_score)

func add_score(points: int = 1):
	print("add_score called with points: ", points)
	print("Current score before: ", current_score)
	current_score += points
	print("Current score after: ", current_score)
	emit_signal("score_changed", current_score)
	print("Score increased! Current score: ", current_score)

func get_score() -> int:
	return current_score

func reset_score():
	current_score = 0
	emit_signal("score_changed", current_score)
	print("Score reset to 0")

# Optional: Save/load high score
func get_high_score() -> int:
	# You can expand this later to save to file
	return current_score
