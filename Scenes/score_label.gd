# ScoreUI.gd - Attach this to a Label node for displaying the score
extends Label

var score_manager: Node

func _ready():
	# Find the ScoreManager in the scene
	score_manager = get_tree().current_scene.get_node_or_null("ScoreManager")
	
	if score_manager != null:
		# Connect to score changes
		score_manager.score_changed.connect(_on_score_changed)
		# Initialize display
		_on_score_changed(score_manager.get_score())
	else:
		print("ERROR: Could not find ScoreManager!")
		text = "Score: ERROR"

func _on_score_changed(new_score: int):
	text = "Score: " + str(new_score)

# Optional: Add some visual flair when score changes
func _on_score_changed_with_animation(new_score: int):
	text = "Score: " + str(new_score)
	
	# Simple scale animation when score increases
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
