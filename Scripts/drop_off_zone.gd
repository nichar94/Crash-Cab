extends Area2D

# Reference to the passenger spawner node in scene
@export var passenger_spawner: Node # Drag the PassengerSpawner node here in inspector

func _ready():
	body_entered.connect(_on_body_entered)
	$SuccessLabel.hide()
	if not $SuccessTimer.timeout.is_connected(_on_success_timer_timeout):
		$SuccessTimer.timeout.connect(_on_success_timer_timeout)
	print("DropOffZone ready, signals connected")

func _on_body_entered(body):
	if body.is_in_group("Car"):
		print("Car entered DropOffZone, has passenger: ", body.has_passenger)
		if body.has_passenger:
			var success = body.drop_off_passenger()
			if success:
				$SuccessLabel.show()
				$SuccessTimer.start()
				print("Drop-off successful, showing Success!")
				
				# ADD SCORE HERE - This is the key addition!
				ScoreManager.add_score(1)
				
				# Spawn new passenger after successful drop-off
				spawn_new_passenger()
			else:
				print("Drop-off failed!")
		else:
			print("No passenger in car")

func spawn_new_passenger():
	# Method 1: Use assigned spawner from inspector
	if passenger_spawner != null and passenger_spawner.has_method("spawn_passenger"):
		passenger_spawner.spawn_passenger()
		return
	
	# Method 2: Find spawner in scene by name
	var spawner = get_tree().current_scene.get_node_or_null("PassengerSpawner")
	if spawner != null and spawner.has_method("spawn_passenger"):
		spawner.spawn_passenger()
	else:
		print("ERROR: Could not find PassengerSpawner node in scene!")

func _on_success_timer_timeout():
	$SuccessLabel.hide()
	print("Success message hidden after 2 seconds")
