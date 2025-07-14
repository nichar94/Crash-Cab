extends Control

@onready var score_label: Label = $ScoreLabel

func _ready():
	# Connect to the score manager's signal
	if ScoreManager:
		ScoreManager.score_changed.connect(_on_score_changed)
		# Update initial score display
		_on_score_changed(ScoreManager.get_score())

func _on_score_changed(new_score: int):
	score_label.text = "Score: " + str(new_score)
