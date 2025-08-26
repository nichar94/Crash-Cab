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
	# Find references - they're siblings, so go up one level then down
	player = get_node("res://Scenes/CarPseudo.tscn")
	building = get_node("res://Scenes/drop_off_zone.tscn")
	
	# Create arrow instance
	arrow = arrow_scene.instantiate()
	add_child(arrow)
	arrow.hide_arrow()
	
	# Connect to existing passengers and future spawned passengers
	connect_to_existing_passengers()
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
	# Clear invalid passengers
	passengers = passengers.filter(func(p): return is_instance_valid(p))
	
	# Add any new passengers from the scene
	var all_passengers = get_tree().get_nodes_in_group("passengers")
	for passenger in all_passengers:
		if passenger not in passengers:
			passengers.append(passenger)
			# Connect to the passenger's pickup signal
			if not passenger.passenger_picked_up.is_connected(_on_passenger_picked_up):
				passenger.passenger_picked_up.connect(_on_passenger_picked_up)

func connect_to_existing_passengers():
	# Connect to any passengers that already exist in the scene
	var existing_passengers = get_tree().get_nodes_in_group("passengers")
	for passenger in existing_passengers:
		if not passenger.passenger_picked_up.is_connected(_on_passenger_picked_up):
			passenger.passenger_picked_up.connect(_on_passenger_picked_up)
		passengers.append(passenger)

# Call this function when a new passenger is spawned
func register_new_passenger(passenger):
	if passenger not in passengers:
		passengers.append(passenger)
		# Connect to the passenger's pickup signal
		if not passenger.passenger_picked_up.is_connected(_on_passenger_picked_up):
			passenger.passenger_picked_up.connect(_on_passenger_picked_up)

# This gets called when any passenger is picked up
func _on_passenger_picked_up(passenger):
	print("ArrowManager: Passenger picked up!")
	game_state = "dropoff"
	# Remove picked up passenger from our list
	passengers.erase(passenger)
	# Point arrow to dropoff zone
	current_target = building
	if building:
		arrow.update_target(building.global_position)
		arrow.show_arrow()

# Call this when passenger is dropped off
func passenger_dropped_off():
	print("ArrowManager: Passenger dropped off!")
	game_state = "pickup"
	current_target = null
	# Arrow will automatically point to nearest passenger in next frame
