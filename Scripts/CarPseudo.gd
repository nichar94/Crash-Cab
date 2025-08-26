
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
var sprite_rotation: float = 0.0  # For testing sprite rotation
var can_pickup_passenger = false
var nearby_passenger = null
var has_passenger = false
# Sprite stack references
var sprite_layers: Array[Sprite2D] = []
@onready var sprite_stack: Node2D = $SpriteStack

func _ready():
	# Collect all sprite layers from the stack
	collect_sprite_layers()
	# Initialize the sprite stack positions
	setup_sprite_stack()
	add_to_group("Car")
	print("Car initialized, has_passenger:", has_passenger)
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
	
	# Sprite rotation follows car rotation for proper sprite stacking
	sprite_rotation += rotation_dir * turn_speed * delta
	#print(rad_to_deg(sprite_rotation))
	
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
	
	# Calculate velocity based on sprite rotation and speed
	# Car sprites face right, so use Vector2(1, 0) as forward direction
	velocity = Vector2(current_speed, 0).rotated(sprite_rotation)

func update_sprite_stack_rotation():
	# Test: Each sprite rotates around its own center at the same speed
	for i in range(sprite_layers.size()):
		var sprite = sprite_layers[i]
		
		# All sprites rotate at the same speed around their own origins
		sprite.rotation = sprite_rotation + (i * rotational_offset)
		
func _process(delta):
	if can_pickup_passenger and Input.is_action_just_pressed("pickup"):
		if nearby_passenger and not has_passenger:
			nearby_passenger.pickup()
			has_passenger = true
			print("Passenger picked up! has_passenger:", has_passenger)
	
	if Input.is_action_just_pressed("pickup"):
		print("Pickup key pressed! has_passenger:", has_passenger)

func drop_off_passenger():
	if has_passenger:
		has_passenger = false
		print("Passenger dropped off! has_passenger:", has_passenger)
		
		# NEW: Notify ArrowManager that passenger was dropped off
		var arrow_manager = get_node("../ArrowManager")
		if arrow_manager:
			arrow_manager.passenger_dropped_off()
			print("CarController: Notified ArrowManager of dropoff")
		
		return true
	else:
		print("No passenger to drop off!")
		return false
