extends Node

# Global score manager - make this an autoload singleton
signal score_changed(new_score)

var score: int = 0

func _ready():
	# Initialize score
	score = 0

func add_score(points: int = 1):
	score += points
	score_changed.emit(score)
	print("Score increased! Current score: ", score)

func get_score() -> int:
	return score

func reset_score():
	score = 0
	score_changed.emit(score)
