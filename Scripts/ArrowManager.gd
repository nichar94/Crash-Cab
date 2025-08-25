extends Node

# References
var player: Node2D
var arrow: Node2D
var current_target: Node2D
var building: Node2D
var passengers: Array = []
var game_state: String = "pickup"  # "pickup" or "dropoff"

# Preload the arrow scene
var arrow_scene = preload("res://Scenes/DirectionalArrow.tscn")

func _ready():
	# Find references (adjust these paths to match your scene structure)
	player = get_node()  # Adjust path to your taxi/player node
	building = get_node("../Building")  # Adjust path to your building node
	
	# Create arrow instance
	arrow = arrow_scene.instantiate()
	add_child(arrow)
	arrow.hide_arrow()
	
	# Connect to passenger signals if you have them
	update_passengers_list()

func _process(delta):
	if not arrow or not player:
		return
		
	if game_state == "pickup":
		handle_pickup_state()
	elif game_state == "dropoff":
		handle_dropoff_state()

func handle_pickup_state():
	# Find nearest passenger
	var nearest_passenger = find_nearest_passenger()
	
	if nearest_passenger and nearest_passenger != current_target:
		current_target = nearest_passenger
		arrow.update_target(current_target.global_position)
		arrow.show_arrow()
	elif not nearest_passenger:
		arrow.hide_arrow()
		current_target = null

func handle_dropoff_state():
	# Point to building
	if building and current_target != building:
		current_target = building
		arrow.update_target(building.global_position)
		arrow.show_arrow()

func find_nearest_passenger() -> Node2D:
	update_passengers_list()
	
	if passengers.is_empty():
		return null
		
	var nearest: Node2D = null
	var nearest_distance: float = INF
	
	for passenger in passengers:
		if not is_instance_valid(passenger):
			continue
			
		var distance = player.global_position.distance_to(passenger.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = passenger
			
	return nearest

func update_passengers_list():
	# Update this function based on how you manage passengers
	# This is a generic example - adjust for your passenger system
	passengers.clear()
	
	# Example: Find all nodes in a "Passengers" group
	var passenger_nodes = get_tree().get_nodes_in_group("passengers")
	for passenger in passenger_nodes:
		if is_instance_valid(passenger):
			passengers.append(passenger)

# Call these functions when passenger is picked up or dropped off
func passenger_picked_up():
	game_state = "dropoff"
	arrow.update_target(building.global_position)

func passenger_dropped_off():
	game_state = "pickup"
	current_target = null
