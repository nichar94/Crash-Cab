extends RigidBody2D

@export_group("Car Settings")
@export var engine_power: float = 800.0
@export var steering_power: float = 40.0
@export var brake_power: float = 1200.0
@export var drift_factor: float = 0.9

var acceleration: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var steer_direction: float = 0.0

func _ready():
	gravity_scale = 0
	linear_damp = 1.0
	angular_damp = 3.0

func _physics_process(delta):
	var throttle = 0.0
	var steering = 0.0
	var brake = 0.0
	
	if Input.is_action_pressed("ui_up"):
		throttle = 1.0
	elif Input.is_action_pressed("ui_down"):
		throttle = -0.5
	
	var steering_direction = 1 if throttle >= 0 else -1 
	
	if Input.is_action_pressed("ui_left"):
		steering = -1.0 * steering_direction
	elif Input.is_action_pressed("ui_right"):
		steering = 1.0 * steering_direction
	
	apply_car_physics(throttle, steering, brake, delta)

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
