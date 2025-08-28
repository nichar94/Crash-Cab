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
	print("ArrowManager: Starting setup...")
	
	# Since ArrowManager, CarController, and DropOffZone are all siblings under Game:
	player = get_node("../CarController")
	building = get_node("../DropOffZone")
	
	print("ArrowManager: Found player: ", player)
	print("ArrowManager: Found building: ", building)
	
	if not player:
		print("ERROR: Could not find CarController!")
		return
	if not building:
		print("ERROR: Could not find DropOffZone!")
		return
	
	# Create arrow instance
	arrow = arrow_scene.instantiate()
	add_child(arrow)
	arrow.hide_arrow()
	print("ArrowManager: Arrow created and hidden")
	
	# Connect to existing passengers and future spawned passengers
	connect_to_existing_passengers()
	update_passengers_list()
	print("ArrowManager: Setup complete")

func _process(delta):
	if not arrow or not player:
		if not arrow:
			print("ArrowManager: No arrow!")
		if not player:
			print("ArrowManager: No player!")
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
		arrow.update_player_position(player.global_position)  # Send player position
		arrow.show_arrow()
		print("ArrowManager: Pointing arrow to passenger at: ", current_target.global_position)
	elif not nearest_passenger:
		arrow.hide_arrow()
		current_target = null
		print("ArrowManager: No passengers found, hiding arrow")
	elif nearest_passenger == current_target:
		# Update player position even if target hasn't changed
		arrow.update_player_position(player.global_position)

func handle_dropoff_state():
	# Point to building
	if building and current_target != building:
		current_target = building
		arrow.update_target(building.global_position)
		arrow.update_player_position(player.global_position)  # Send player position
		arrow.show_arrow()
	elif current_target == building:
		# Update player position even if target hasn't changed
		arrow.update_player_position(player.global_position)

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
	print("ArrowManager: Found ", all_passengers.size(), " passengers in 'passengers' group")
	
	for passenger in all_passengers:
		if passenger not in passengers:
			passengers.append(passenger)
			# Connect to the passenger's pickup signal
			if not passenger.passenger_picked_up.is_connected(_on_passenger_picked_up):
				passenger.passenger_picked_up.connect(_on_passenger_picked_up)
	
	print("ArrowManager: Total passengers tracked: ", passengers.size())

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
