extends CharacterBody2D

# Simple AI car for testing
@export var speed: float = 120.0
@export var rotation_speed: float = 5.0
@export var path_follow_distance: float = 20.0

var path_points: Array[Vector2] = []
var current_path_index: int = 0
var target_position: Vector2
var is_following_path: bool = false

func _ready():
	print("Minimal AI Car ready at: ", global_position)
	add_to_group("AICars")
	
	# Make sure we have a sprite
	if has_node("Sprite2D"):
		var sprite = get_node("Sprite2D")
		print("Sprite found: ", sprite)
		if sprite.texture == null:
			print("WARNING: Sprite has no texture! Car will be invisible!")
		else:
			print("Sprite texture: ", sprite.texture)
	else:
		print("WARNING: No Sprite2D node found!")
	
	# Check collision shape
	if has_node("CollisionShape2D"):
		var collision = get_node("CollisionShape2D")
		print("Collision shape: ", collision.shape)
		if collision.shape == null:
			print("WARNING: CollisionShape2D has no shape!")
	else:
		print("WARNING: No CollisionShape2D node found!")

func _physics_process(delta):
	if is_following_path and path_points.size() > 0:
		follow_path(delta)
		move_and_slide()

func set_path(new_path: Array[Vector2]):
	print("Setting path with ", new_path.size(), " points")
	path_points = new_path
	current_path_index = 0
	is_following_path = true
	if path_points.size() > 0:
		target_position = path_points[0]
		print("Starting to follow path...")

func follow_path(delta: float):
	if current_path_index >= path_points.size():
		current_path_index = 0
		target_position = path_points[0]
	
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	
	var target_rotation = direction.angle()
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
	
	if global_position.distance_to(target_position) <= path_follow_distance:
		current_path_index += 1
		if current_path_index < path_points.size():
			target_position = path_points[current_path_index]
		else:
			current_path_index = 0
			target_position = path_points[0]
