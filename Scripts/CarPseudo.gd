@tool
extends CharacterBody2D

@export_group("Car Settings")
@export var acceleration: float = 300.0
@export var max_speed: float = 400.0
@export var friction: float = 200.0
@export var turn_speed: float = 3.0

@export_group("Sprite Stack Settings")
@export var stack_height: float = 1.5  # Height offset between layers
@export var horizontal_offset: float = 0.0  # Horizontal offset per layer
@export var vertical_offset: float = 0.0  # Additional vertical offset per layer
@export var rotational_offset: float = 0.0  # Rotation offset per layer
@export var enable_tilt_effect: bool = true  # Enable sprite tilting during turns

# Car movement variables
var current_speed: float = 0.0
var rotation_dir: float = 0.0

# Sprite stack references
var sprite_layers: Array[Sprite2D] = []
@onready var sprite_stack: Node2D = $SpriteStack

func _ready():
	# Collect all sprite layers from the stack
	collect_sprite_layers()
	# Initialize the sprite stack positions
	setup_sprite_stack()

func collect_sprite_layers():
	sprite_layers.clear()
	
	# Get all children of SpriteStack node and sort them by name
	var children = sprite_stack.get_children()
	#children.sort_custom(_sort_sprites_by_name)
	
	for child in children:
		if child is Sprite2D:
			sprite_layers.append(child)
	
	print("Found ", sprite_layers.size(), " sprite layers")

func _sort_sprites_by_name(a: Node, b: Node) -> bool:
	return a.name < b.name

func setup_sprite_stack():
	# Sprites are already positioned correctly in the scene
	# Just apply visual effects for depth
	for i in range(sprite_layers.size()):
		var sprite = sprite_layers[i]
		
		# Set z-index for proper layering
		sprite.z_index = i
		
		# Add slight shadow effect for lower layers to enhance 3D depth
		if i < sprite_layers.size() - 3:  # Bottom layers get darker
			sprite.modulate = Color(0.7, 0.7, 0.7, 1.0)
		elif i < sprite_layers.size() - 1:  # Middle layers slightly darker
			sprite.modulate = Color(0.85, 0.85, 0.85, 1.0)
		else:  # Top layers keep full brightness
			sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _physics_process(delta):
	# Get input
	var input_vector = Vector2.ZERO
	rotation_dir = 0.0
	
	# Forward/backward movement (W/S)
	if Input.is_action_pressed("up"):
		input_vector.y = 1  # Forward
	elif Input.is_action_pressed("down"):
		input_vector.y = -1   # Backward
	
	# Rotation (A/D)
	if Input.is_action_pressed("left"):
		rotation_dir = -1
	elif Input.is_action_pressed("right"):
		rotation_dir = 1
	
	# Apply car physics
	apply_car_movement(input_vector, delta)
	update_sprite_stack_rotation()
	
	# Move the character
	move_and_slide()

func apply_car_movement(input: Vector2, delta: float):
	# Handle acceleration and deceleration
	if input.y != 0:
		current_speed += input.y * acceleration * delta
		current_speed = clampf(current_speed, -max_speed * 0.5, max_speed)  # Reverse is slower
	else:
		# Apply friction when no input
		current_speed = move_toward(current_speed, 0, friction * delta)
	
	# Handle rotation (only when moving)
	if abs(current_speed) > 10:  # Only turn when moving with sufficient speed
		rotation += rotation_dir * turn_speed * delta * (abs(current_speed) / max_speed)
	
	# Calculate velocity based on rotation and speed
	# Car sprites face right, so use Vector2(1, 0) as forward direction
	velocity = Vector2(current_speed, 0).rotated(rotation)

func update_sprite_stack_rotation():
	# Each sprite rotates around its own center with configurable offsets
	for i in range(sprite_layers.size()):
		var sprite = sprite_layers[i]
		
		# Sprites should maintain their orientation relative to the car body
		# Since car sprites face right by default, no additional rotation needed
		sprite.rotation = 0
		
		# Add rotational offset per layer (for spiral/twist effects)
		sprite.rotation += i * rotational_offset
		
		# Apply position offsets (these can create interesting stacking effects)
		var layer_horizontal_offset = i * horizontal_offset
		var layer_vertical_offset = i * vertical_offset
		
		# Keep original stacked position but add offsets
		sprite.position = Vector2(layer_horizontal_offset, -i * stack_height + layer_vertical_offset)
		
		# Optional: Add subtle tilt effect during turns
		if enable_tilt_effect:
			var tilt_amount = rotation_dir * 0.02 * (abs(current_speed) / max_speed)
			sprite.rotation += tilt_amount
