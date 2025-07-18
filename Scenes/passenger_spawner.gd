# PassengerSpawner.gd - Add this as an autoload or attach to a node in your main scene
extends Node

@export var passenger_scene: PackedScene # Assign your passenger scene in the inspector
@export var spawn_points: Array[Vector2] = [] # Define safe spawn locations

func _ready():
	# Define safe spawn points based on your map
	# These should be on sidewalks, building entrances, etc.
	spawn_points = [
		Vector2(600, 180),   # Near buildings on the left
		Vector2(800, 250),   # Sidewalk area
		Vector2(950, 180),   # Near the roundabout
		Vector2(1100, 300),  # Right side buildings
		Vector2(550, 350),   # Lower left area
		Vector2(850, 450),   # Lower middle
		Vector2(1200, 250),  # Far right
		Vector2(700, 120),   # Upper area
		Vector2(1000, 400),  # Lower right
		Vector2(650, 300),   # Mid-left area
		Vector2(-940, -380)
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
	
	# Add to the scene tree (assuming this spawner is in the main scene)
	get_tree().current_scene.add_child(new_passenger)
	
	# Set position
	new_passenger.global_position = spawn_position
	
	print("New passenger spawned at: ", spawn_position)
	return new_passenger

func spawn_passenger_at_random_safe_location():
	return spawn_passenger()
