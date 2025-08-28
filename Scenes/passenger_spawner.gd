# PassengerSpawner.gd - Add this as an autoload or attach to a node in your main scene
extends Node

@export var passenger_scene: PackedScene # Assign your passenger scene in the inspector
@export var spawn_points: Array[Vector2] = [] # Define safe spawn locations

func _ready():
	# Define safe spawn points based on your map
	# These should be on sidewalks, building entrances, etc.
	spawn_points = [
		Vector2(700, -250),   # Near buildings on the left
		Vector2(700, 300),   # Sidewalk area
		Vector2(750, 2250),   # Near the roundabout
		Vector2(1100, 300),  # Right side buildings
		Vector2(550, 350),   # Lower left area
		Vector2(850, 450),   # Lower middle
		Vector2(1200, 250),  # Far right
		Vector2(700, 120),   # Upper area
		Vector2(1000, 400),  # Lower right
		Vector2(650, 300),   # Mid-left area
		Vector2(1400, -1350)
	]

func spawn_passenger():
	if passenger_scene == null:
		print("ERROR: Passenger scene not assigned to spawner!")
		return null
	
	if spawn_points.is_empty():
		print("ERROR: No spawn points defined!")
		return null
	
	# Choose a random spawn point
	var spawn_position = spawn_points[randi() % spawn_points.size()]
	
	# Create new passenger instance
	var new_passenger = passenger_scene.instantiate()
	
	# NEW: Add passenger to group before adding to scene
	new_passenger.add_to_group("passengers")
	
	# FIX: Use call_deferred to avoid "flushing queries" error
	get_tree().current_scene.call_deferred("add_child", new_passenger)
	
	# FIX: Set position using call_deferred as well
	new_passenger.call_deferred("set_global_position", spawn_position)
	
	print("New passenger spawned at: ", spawn_position)
	return new_passenger

func spawn_passenger_at_random_safe_location():
	return spawn_passenger()
