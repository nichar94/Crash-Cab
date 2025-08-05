extends RigidBody2D

@export var sprite_textures: Array[Texture2D] = []
@export var slice_spacing: float = 2.0  # Vertical spacing between slices
@export var slice_offset: Vector2 = Vector2(0.5, 0.0)  # X offset for 3D effect
@export var rotation_speed: float = 8.0  # How fast sprite follows rigidbody rotation
@export var engine_power: float = 800.0
@export var steering_power: float = 2.5
@export var friction: float = 0.98  # Friction to slow down the car
@export var max_speed: float = 400.0

@onready var sprite_stack: Node2D
var sprite_slices: Array[Sprite2D] = []

func _ready():
	# Create SpriteStack node if it doesn't exist
	sprite_stack = get_node_or_null("SpriteStack")
	if not sprite_stack:
		sprite_stack = Node2D.new()
		sprite_stack.name = "SpriteStack"
		add_child(sprite_stack)
	
	setup_sprite_stack()
	
	# Set RigidBody2D properties for better car physics
	gravity_scale = 0  # No gravity for top-down car
	linear_damp = 2.0  # Natural slowdown
	angular_damp = 3.0  # Prevent spinning out of control

func setup_sprite_stack():
	# Clear existing sprites
	for child in sprite_stack.get_children():
		child.queue_free()
	
	sprite_slices.clear()
	
	# Create sprite slices
	for i in range(sprite_textures.size()):
		var sprite = Sprite2D.new()
		sprite.texture = sprite_textures[i]
		sprite.name = "Slice_" + str(i)
		
		# Position each slice with 3D-like offset
		sprite.position.y = -i * slice_spacing  # Vertical stacking
		sprite.position.x = i * slice_offset.x   # Horizontal offset for 3D effect
		
		# Set z_index for proper layering (higher slices appear on top)
		sprite.z_index = i
		
		# Add to sprite stack
		sprite_stack.add_child(sprite)
		sprite_slices.append(sprite)
	
	print("Created ", sprite_slices.size(), " sprite slices")

func _physics_process(delta):
	handle_input(delta)
	update_sprite_rotation()
	apply_friction()

func handle_input(delta):
	var acceleration = 0.0
	var turn = 0.0
	
	# Get input
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		acceleration = engine_power
		print("Forward")
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		acceleration = -engine_power * 0.6  # Reverse is slower
		print("Backward")
	
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		turn = -steering_power
		print("Left turn")
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		turn = steering_power
		print("Right turn")
	
	# Apply car-like physics
	if acceleration != 0:
		var force = Vector2(0, -acceleration).rotated(rotation)
		apply_central_force(force)
		
		# Only allow steering when moving
		if abs(linear_velocity.length()) > 10:
			apply_torque(turn * 1000)  # Much stronger torque
	else:
		# Allow some steering even when stationary (like real cars)
		if turn != 0:
			apply_torque(turn * 200)
	
	# Limit max speed
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed

func apply_friction():
	# Apply friction to slow down the car naturally
	linear_velocity *= friction
	angular_velocity *= friction

func update_sprite_rotation():
	if not sprite_stack:
		return
		
	# Make sprite stack rotate to match the car's direction
	var target_rotation = rotation
	sprite_stack.rotation = lerp_angle(sprite_stack.rotation, target_rotation, rotation_speed * get_physics_process_delta_time())
	
	# Optional: Add slight banking effect based on turning
	var bank_amount = clamp(angular_velocity * 0.05, -0.1, 0.1)
	
	# Apply banking to each sprite individually for more dramatic effect
	for i in range(sprite_slices.size()):
		if sprite_slices[i]:
			sprite_slices[i].rotation = bank_amount * (i + 1) * 0.2

# Optional: Function to change sprite stack at runtime
func set_sprite_textures(new_textures: Array[Texture2D]):
	sprite_textures = new_textures
	setup_sprite_stack()

# Optional: Function to adjust slice spacing and offset
func set_slice_spacing(new_spacing: float, new_offset: Vector2 = slice_offset):
	slice_spacing = new_spacing
	slice_offset = new_offset
	for i in range(sprite_slices.size()):
		if sprite_slices[i]:
			sprite_slices[i].position.y = -i * slice_spacing
			sprite_slices[i].position.x = i * slice_offset.x
		
