extends Area2D
# Reference to the passenger spawner node in scene
@export var passenger_spawner: Node # Drag the PassengerSpawner node here in inspector
@onready var main_scene = get_tree().current_scene  # NEW: Reference to main scene

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
				
				# ADD TIME BONUS - New addition!
				if main_scene.has_method("add_time"):
					main_scene.add_time(10)
					print("Added 10 seconds bonus time!")
				else:
					print("ERROR: Could not find add_time method in main scene")
				
				# Spawn new passenger after successful drop-off
				spawn_new_passenger()
			else:
				print("Drop-off failed!")
		else:
			print("No passenger in car")

func spawn_new_passenger():
	# Method 1: Use assigned spawner from inspector
	if passenger_spawner != null and passenger_spawner.has_method("spawn_passenger"):
		var new_passenger = passenger_spawner.spawn_passenger()
		# NEW: Register the new passenger with ArrowManager
		register_passenger_with_arrow_manager(new_passenger)
		return
	
	# Method 2: Find spawner in scene by name
	var spawner = get_tree().current_scene.get_node_or_null("PassengerSpawner")
	if spawner != null and spawner.has_method("spawn_passenger"):
		var new_passenger = spawner.spawn_passenger()
		# NEW: Register the new passenger with ArrowManager
		register_passenger_with_arrow_manager(new_passenger)
	else:
		print("ERROR: Could not find PassengerSpawner node in scene!")

# NEW: Helper function to register new passengers with ArrowManager
func register_passenger_with_arrow_manager(passenger):
	if passenger == null:
		return
		
	var arrow_manager = get_node("../ArrowManager")
	if arrow_manager and arrow_manager.has_method("register_new_passenger"):
		arrow_manager.register_new_passenger(passenger)
		print("DropOffZone: Registered new passenger with ArrowManager")
	else:
		print("DropOffZone: Could not find ArrowManager to register passenger")

func _on_success_timer_timeout():
	$SuccessLabel.hide()
	print("Success message hidden after 2 seconds")
