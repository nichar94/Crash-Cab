extends Node2D

# Path creation and management
@export var show_paths: bool = true  # Show path lines in editor
@export var path_color: Color = Color.CYAN
@export var path_width: float = 2.0

# Predefined paths - you can create these in the editor
@export var paths: Array[Path2D] = []

# AI car scene to spawn
@export var ai_car_scene: PackedScene  # Drag your AI car scene here

# Cars and their assigned paths
var ai_cars: Array[Node] = []
var car_paths: Dictionary = {}  # Maps car to its path points

func _ready():
	# Convert Path2D nodes to point arrays and spawn cars
	# Use call_deferred to avoid "busy setting up children" error
	call_deferred("setup_paths_and_cars")

func _draw():
	if show_paths and Engine.is_editor_hint() == false:
		draw_all_paths()

func setup_paths_and_cars():
	"""Convert Path2D nodes to point arrays and spawn AI cars"""
	print("Setting up paths and cars...")
	print("Number of paths: ", paths.size())
	
	for i in range(paths.size()):
		var path_2d = paths[i]
		print("Processing path ", i, ": ", path_2d)
		if path_2d != null:
			var path_points = get_path_points(path_2d)
			print("Path ", i, " has ", path_points.size(), " points")
			if path_points.size() > 0:
				spawn_ai_car_on_path(path_points, i)
			else:
				print("WARNING: Path ", i, " has no points!")
		else:
			print("WARNING: Path ", i, " is null!")

func get_path_points(path_2d: Path2D) -> Array[Vector2]:
	"""Convert a Path2D to an array of world position points"""
	var points: Array[Vector2] = []
	var curve = path_2d.curve
	
	if curve == null:
		return points
	
	# Sample points along the curve
	var path_length = curve.get_baked_length()
	var sample_distance = 50.0  # Distance between sampled points
	var samples = int(path_length / sample_distance)
	
	for i in range(samples + 1):
		var offset = (i * sample_distance) / path_length
		if offset > 1.0:
			offset = 1.0
		var point = curve.sample_baked(offset * path_length)
		points.append(path_2d.global_position + point)
	
	return points

func spawn_ai_car_on_path(path_points: Array[Vector2], path_index: int):
	"""Spawn an AI car and assign it to follow the given path"""
	print("Attempting to spawn AI car on path ", path_index)
	
	if ai_car_scene == null:
		print("ERROR: No AI car scene assigned to PathManager!")
		print("Please drag your AICar.tscn file to the 'Ai Car Scene' field in the inspector!")
		return
	
	print("AI car scene found: ", ai_car_scene)
	var ai_car = ai_car_scene.instantiate()
	print("AI car instantiated: ", ai_car)
	
	# Position car at start of path
	if path_points.size() > 0:
		ai_car.global_position = path_points[0]
		print("Car positioned at: ", path_points[0])
	
	# Add car to scene using call_deferred to avoid busy parent error
	get_parent().call_deferred("add_child", ai_car)
	print("Car queued to be added to scene. Parent: ", get_parent())
	
	# Set the car's path after it's added to the scene
	ai_car.call_deferred("set_path", path_points)
	
	# Store references
	ai_cars.append(ai_car)
	car_paths[ai_car] = path_points
	
	print("Successfully queued AI car spawn on path ", path_index, " with ", path_points.size(), " points")

func draw_all_paths():
	"""Draw all paths for debugging"""
	for car in car_paths.keys():
		var path_points = car_paths[car]
		draw_path_lines(path_points)

func draw_path_lines(points: Array[Vector2]):
	"""Draw lines connecting path points"""
	for i in range(points.size() - 1):
		var start = to_local(points[i])
		var end = to_local(points[i + 1])
		draw_line(start, end, path_color, path_width)
	
	# Connect last point to first (loop)
	if points.size() > 2:
		var start = to_local(points[points.size() - 1])
		var end = to_local(points[0])
		draw_line(start, end, path_color, path_width)

func add_car_to_path(car: Node, path_index: int):
	"""Add an existing car to a specific path"""
	if path_index < paths.size():
		var path_points = get_path_points(paths[path_index])
		car.set_path(path_points)
		car_paths[car] = path_points

func remove_car(car: Node):
	"""Remove a car from the system"""
	if car in ai_cars:
		ai_cars.erase(car)
	if car in car_paths:
		car_paths.erase(car)
	car.queue_free()

func get_all_ai_cars() -> Array[Node]:
	"""Get all AI cars managed by this system"""
	return ai_cars
