extends RigidBody2D

@export_group("Car Settings")
@export var engine_power: float = 950.0
@export var steering_power: float = 28.4867
@export var brake_power: float = 1200.0
@export var drift_factor: float = 0.35

var acceleration: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var steer_direction: float = 0.0
var can_pickup_passenger = false
var nearby_passenger = null
var has_passenger = false

# Reference to the animated sprite node
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	gravity_scale = 0
	linear_damp = 1.0
	angular_damp = 3.0
	add_to_group("Car")
	print("Car initialized, has_passenger:", has_passenger)

func _physics_process(delta):
	var throttle = 0.0
	var steering = 0.0
	var brake = 0.0
	
	if Input.is_action_pressed("up"):
		throttle = 1.0
	elif Input.is_action_pressed("down"):
		throttle = -0.5
	
	var steering_direction = 1 if throttle >= 0 else -1 
	
	if Input.is_action_pressed("left"):
		steering = -1.0 * steering_direction
	elif Input.is_action_pressed("right"):
		steering = 1.0 * steering_direction
	
	apply_car_physics(throttle, steering, brake, delta)
	update_sprite_direction()

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
		return true
	else:
		print("No passenger to drop off!")
		return false

func apply_car_physics(throttle: float, steering: float, brake: float, delta: float):
	var local_velocity = global_transform.basis_xform_inv(linear_velocity)
	var engine_force = Vector2(0, -throttle * engine_power)
	var force = global_transform.basis_xform(engine_force)
	apply_central_force(force)
	
	var speed = linear_velocity.length()
	if speed > 5.0:
		var steer_force = steering * steering_power * speed
		apply_torque(steer_force)
	
	if brake > 0:
		var brake_force = -linear_velocity.normalized() * brake_power * brake
		apply_central_force(brake_force)
	
	var forward_velocity = global_transform.basis_xform(Vector2(0, local_velocity.y))
	var side_velocity = global_transform.basis_xform(Vector2(local_velocity.x, 0))
	linear_velocity = forward_velocity + side_velocity * drift_factor

func update_sprite_direction():
	# Only update if the car is moving with sufficient speed
	if linear_velocity.length() < 10.0:
		return
	
	# Use the car's velocity to determine sprite direction
	var vel = linear_velocity.normalized()
	
	# Determine which animation to use based on velocity components
	var animation_name: String
	var sprite_rotation: float = 0.0
	
	# Check which direction has the strongest component
	var abs_x = abs(vel.x)
	var abs_y = abs(vel.y)
	
	if abs_x > abs_y:
		# Horizontal movement is dominant
		if vel.x > 0:
			animation_name = "right"
			sprite_rotation = linear_velocity.angle()  # Additional rotation for exact direction
		else:
			animation_name = "left"
			sprite_rotation = linear_velocity.angle() - PI  # Subtract 180° since left sprite faces left
	else:
		# Vertical movement is dominant
		if vel.y > 0:
			animation_name = "down"
			sprite_rotation = linear_velocity.angle() - PI/2  # Subtract 90° since down sprite faces down
		else:
			animation_name = "up"
			sprite_rotation = linear_velocity.angle() + PI/2  # Add 90° since up sprite faces up
	
	# Apply the animation and rotation
	if animated_sprite:
		animated_sprite.play(animation_name)
		# Compensate for the RigidBody2D's rotation by subtracting it from the sprite rotation
		animated_sprite.rotation = sprite_rotation - rotation
