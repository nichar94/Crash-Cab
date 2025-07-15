extends CharacterBody2D

# Car properties
@export var speed: float = 100.0  # Consistent speed in pixels/second
@export var rotation_speed: float = 5.0  # How fast the car rotates to face direction
@export var path_follow_distance: float = 20.0  # How close to get to each point

# Path following
var path_points: Array[Vector2] = []
var current_path_index: int = 0
var target_position: Vector2
var is_following_path: bool = false

# Visual components (assign these in the inspector or create them in code)
@onready var sprite: Sprite2D = $Sprite2D  # Your car sprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	# Add to a group so other systems can identify AI cars
	add_to_group("AICars")
	
	# Set up collision layer/mask if needed
	# collision_layer = 2  # AI cars layer
	# collision_mask = 1   # Can collide with player, walls, etc.

func _physics_process(delta):
	if is_following_path and path_points.size() > 0:
		follow_path(delta)
		move_and_slide()

func set_path(new_path: Array[Vector2]):
	"""Set a new path for the car to follow"""
	path_points = new_path
	current_path_index = 0
	is_following_path = true
	if path_points.size() > 0:
		target_position = path_points[0]

func follow_path(delta: float):
	"""Main path following logic"""
	if current_path_index >= path_points.size():
		# Path completed, loop back to start
		current_path_index = 0
		target_position = path_points[0]
	
	# Calculate direction to target
	var direction = (target_position - global_position).normalized()
	
	# Move towards target
	velocity = direction * speed
	
	# Rotate car to face movement direction
	var target_rotation = direction.angle()
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
	
	# Check if we've reached the current target
	if global_position.distance_to(target_position) <= path_follow_distance:
		# Move to next point in path
		current_path_index += 1
		if current_path_index < path_points.size():
			target_position = path_points[current_path_index]
		else:
			# Loop back to start
			current_path_index = 0
			target_position = path_points[0]

func stop_following_path():
	"""Stop the car from following its path"""
	is_following_path = false
	velocity = Vector2.ZERO

func resume_following_path():
	"""Resume path following"""
	is_following_path = true

func get_current_speed() -> float:
	"""Get the actual speed the car is moving"""
	return velocity.length()
