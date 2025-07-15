@tool
extends Node2D

# Simple tool to create paths by clicking in the editor
@export var create_path_mode: bool = false : set = set_create_path_mode
@export var current_path_points: Array[Vector2] = []
@export var path_color: Color = Color.YELLOW
@export var point_size: float = 8.0
@export var clear_current_path: bool = false : set = clear_path

var path_2d_node: Path2D

func set_create_path_mode(value: bool):
	create_path_mode = value
	if create_path_mode:
		print("Path creation mode enabled. Click in the scene to add points.")
	else:
		print("Path creation mode disabled.")

func clear_path(value: bool):
	if value:
		current_path_points.clear()
		print("Path cleared")
		queue_redraw()

func _draw():
	if not Engine.is_editor_hint():
		return
	
	# Draw current path points
	for i in range(current_path_points.size()):
		var point = current_path_points[i]
		draw_circle(point, point_size, path_color)
		
		# Draw point numbers
		var font = ThemeDB.fallback_font
		var text = str(i)
		draw_string(font, point + Vector2(10, 0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	
	# Draw lines between points
	for i in range(current_path_points.size() - 1):
		draw_line(current_path_points[i], current_path_points[i + 1], path_color, 2.0)
	
	# Draw line back to start if we have more than 2 points
	if current_path_points.size() > 2:
		draw_line(current_path_points[-1], current_path_points[0], path_color, 2.0)

func _input(event):
	if not Engine.is_editor_hint() or not create_path_mode:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		current_path_points.append(to_local(mouse_pos))
		print("Added point: ", mouse_pos)
		queue_redraw()

func create_path2d_from_points() -> Path2D:
	"""Convert current points to a Path2D node"""
	if current_path_points.size() < 2:
		print("Need at least 2 points to create a path")
		return null
	
	var path_2d = Path2D.new()
	var curve = Curve2D.new()
	
	# Add all points to the curve
	for point in current_path_points:
		curve.add_point(point)
	
	# Close the loop
	if current_path_points.size() > 2:
		curve.add_point(current_path_points[0])
	
	path_2d.curve = curve
	return path_2d

func export_path_to_scene():
	"""Add the current path as a Path2D node to the scene"""
	var path_2d = create_path2d_from_points()
	if path_2d != null:
		get_parent().add_child(path_2d)
		path_2d.owner = get_tree().edited_scene_root
		path_2d.name = "AICarPath_" + str(get_parent().get_children().size())
		print("Created Path2D node: ", path_2d.name)
